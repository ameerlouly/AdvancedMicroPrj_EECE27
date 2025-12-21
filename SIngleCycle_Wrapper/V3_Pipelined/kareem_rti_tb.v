`timescale 1ns / 1ps

module tb_rti_test;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] PC = uut.PC.pc_current;
    
    // CCR Register Bits: {V, C, N, Z} 
    wire [3:0] CCR = uut.ccr_inst.CCR; // Ensure this matches your CCR instance name (.CCR or .CCR_reg)
    wire Flag_V = CCR[3];
    wire Flag_N = CCR[1];

    // ========================================================================
    // 2. DUT Instantiation
    // ========================================================================
    CPU_WrapperV3 uut (
        .clk(clk), 
        .rstn(rstn), 
        .I_Port(I_Port), 
        .int_sig(int_sig),
        .O_Port(O_Port)
    );

    // ========================================================================
    // 3. Clock Generation
    // ========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ========================================================================
    // 4. Test Sequence
    // ========================================================================
    initial begin
        // --- Initialize ---
        I_Port = 0;
        int_sig = 0;
        rstn = 0; 

                // 1. Release Reset
        #20 rstn = 1; 

        // ====================================================================
        // MEMORY SETUP
        // ====================================================================
        
        // 1. Setup Vectors
        uut.mem_inst.mem[0] = 8'h10; // Reset Vector: Jump to Main at 0x10
        uut.mem_inst.mem[1] = 8'h40; // Interrupt Vector: ISR is at 0x40

        // --------------------------------------------------------------------
        // MAIN PROGRAM (Starts at 0x10)
        // --------------------------------------------------------------------
        
        // 0x10: ADD R1, R2 
        // We moved this to the start. R1 and R2 are loaded directly via testbench below.
        // Result: 0x7F + 0x01 = 0x80 (-128). Flags: V=1, N=1.
        // Op: 2 (0010), ra:01, rb:10 -> 26
        uut.mem_inst.mem[16] = 8'h26; 

        // 0x11: NOP (Interrupt trigger window)
        uut.mem_inst.mem[17] = 8'h00;

        // 0x12: NOP 
        uut.mem_inst.mem[18] = 8'h00;
        
        // 0x13: STOP
        uut.mem_inst.mem[19] = 8'h00;

        // --------------------------------------------------------------------
        // ISR (Interrupt Service Routine - Starts at 0x40)
        // --------------------------------------------------------------------
        
        // 0x40: LDM R1, 0x00
        uut.mem_inst.mem[64] = 8'hC1;
        uut.mem_inst.mem[65] = 8'h00;
        
        // 0x42: NOP (Safety Bubble)
        // Added to prevent Forwarding errors inside ISR. 
        // Ensures LDM finishes WB before ADD reads R1.
        uut.mem_inst.mem[66] = 8'h00; 

        // 0x43: ADD R1, R1 (0+0=0. Flags: Z=1, V=0, N=0, C=0)
        // Op: 2 (0010), ra:01, rb:01 -> 25
        uut.mem_inst.mem[67] = 8'h25;

        // 0x44: RTI (Return from Interrupt - Should restore V=1, N=1)
        // Op: 11 (1011), brx:11 (3), rb:00 -> BC
        uut.mem_inst.mem[68] = 8'hBC;


        // ====================================================================
        // SIMULATION EXECUTION
        // ====================================================================
        
        
        // --------------------------------------------------------------------
        // DIRECT REGISTER LOADING (Bypassing LDM Instructions)
        // --------------------------------------------------------------------
        // This forces values into the registers immediately, avoiding forwarding hazards.
        // Force R1 = 127 (0x7F)
        uut.regfile_inst.regs[1] = 8'h7F; 
        // Force R2 = 1 (0x01)
        uut.regfile_inst.regs[2] = 8'h01;
        
        $display("[SETUP] Direct Register Load: R1=%h, R2=%h", uut.regfile_inst.regs[1], uut.regfile_inst.regs[2]);

        // 2. Wait for Main Program ADD to complete (Setting V=1, N=1)
        // ADD is at 0x10. It enters Fetch at T=25, Decode T=35, Ex T=45. 
        wait (PC == 8'h11); // Wait until PC advances past ADD
        #20; // Wait for Writeback and Flag updates
        
        $display("[MAIN] ADD executed. CCR: %b (Expect 1010 for V=1, N=1)", CCR);
        
        if (CCR[3] !== 1 || CCR[1] !== 1) 
            $display("ERROR: Main program failed to set V/N flags.");

        // 3. Trigger Interrupt
        $display("[TEST] Triggering Interrupt...");
        @(posedge clk);
        int_sig = 1;
        @(posedge clk);
        int_sig = 0;

        // 4. Wait for ISR Entry
        wait (PC == 8'h40);
        $display("[ISR] Entered ISR at 0x40.");
        
        // 5. Wait for ISR ADD to complete (Clearing V/N, Setting Z)
        wait (PC == 8'h44); // At RTI instruction
        #5;
        $display("[ISR] ISR Arithmetic done. CCR: %b (Expect 0001 for Z=1)", CCR);
        
        if (CCR[3] === 1 || CCR[1] === 1) 
            $display("ERROR: ISR failed to change flags.");

        // 6. Wait for Return (RTI)
        // PC should go back to 0x11 (Instruction after ADD)
        wait (PC == 8'h11);
        #10; // Wait for pipeline to settle logic
        
        $display("[MAIN] Returned from ISR. PC=%h, CCR: %b", PC, CCR);

        // ====================================================================
        // FINAL CHECK
        // ====================================================================
        $display("-------------------------------------------------------------");
        // We expect V=1 (Bit 3) and N=1 (Bit 1)
        if (CCR[3] == 1 && CCR[1] == 1) begin
            $display("PASS: Flags Restored Successfully! (V=1, N=1)");
        end else begin
            $display("FAIL: Flags NOT Restored. Got V=%b, N=%b (Expected 1, 1)", CCR[3], CCR[1]);
        end
        $display("-------------------------------------------------------------");

        $stop;
    end

endmodule