`timescale 1ns / 1ps

module tb_OutputPort;

  // ========================================================================
    // 1. Resources & Signals
    // ========================================================================
    reg clk;
    reg rstn;
    reg int_sig;
    reg [7:0] I_Port;
    wire [7:0] O_Port;

    // --- SPY SIGNALS (Internal Visibility) ---
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0]; // JMP Target
    wire [7:0] R1 = uut.regfile_inst.regs[1]; // CALL Target
    wire [7:0] R2 = uut.regfile_inst.regs[2]; // Status Flag
    wire [7:0] R3 = uut.regfile_inst.regs[3]; // Stack Pointer / Subroutine work

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
        // --- 4.1 Initialization ---
        I_Port = 0; int_sig = 0; rstn = 0; 
        
        $display("-------------------------------------------------------------");
        $display(" LOADING PROGRAM: JMP -> TRAP SKIP -> CALL -> RET");
        $display("-------------------------------------------------------------");

        // --- 4.3 Start Processor ---
        #20 rstn = 1;
        uut.regfile_inst.regs[3] = 8'hFF; // Init Stack Pointer
        uut.regfile_inst.regs[2] = 8'h00; // Clear R2

        // --- 4.2 Load Memory ---

        // 0x00: LDM R0, 0x06  (Load JMP Target Address)
        uut.mem_inst.mem[0] = 8'hC0; uut.mem_inst.mem[1] = 8'h06; //done

        // 0x02: JMP R0        (Unconditional Jump to Address 6)
        // Op:11(B), brx:0, rb:0 -> B0
        uut.mem_inst.mem[2] = 8'hB0; //done

        // 0x03: LDM R2, 0xFF  (TRAP! If R2 becomes FF, JMP failed)
        uut.mem_inst.mem[3] = 8'hC2; uut.mem_inst.mem[4] = 8'hFF;
        
        // 0x05: NOP (Alignment padding, should be skipped)
        uut.mem_inst.mem[5] = 8'h00; 

        // --- JUMP LANDS HERE (Address 0x06) ---
        
        // 0x06: LDM R1, 0x0C  (Load CALL Target Address 12)
        uut.mem_inst.mem[6] = 8'hC1; uut.mem_inst.mem[7] = 8'h0C;

        // 0x08: CALL R1       (Call Subroutine at 12. Pushes PC=9 to Stack)
        // Op:11(B), brx:1, rb:1 -> B5
        uut.mem_inst.mem[8] = 8'hB5;

        // --- RETURN LANDS HERE (Address 0x09) ---

        // 0x09: LDM R2, 0xAA  (Success Flag! We returned correctly)
        uut.mem_inst.mem[9] = 8'hC2; uut.mem_inst.mem[10] = 8'hAA;

        // 0x0B: STOP
        uut.mem_inst.mem[11] = 8'h00;

        // --- SUBROUTINE (Address 0x0C / 12) ---
        
        // 0x0C: LDM R0, 0x55  (Indicate inside Subroutine)
        uut.mem_inst.mem[12] = 8'hC0; uut.mem_inst.mem[13] = 8'h55;

        // 0x0E: RET           (Return to Address 9)
        // Op:11(B), brx:2, rb:2 (User preference) -> BA
        uut.mem_inst.mem[14] = 8'hBA;


        

        // --- 4.4 Runtime Duration ---
        #300; 

        // ====================================================================
        // 5. Verification & Results
        // ====================================================================
        $display("-------------------------------------------------------------");
        $display(" FINAL RESULTS");
        $display("-------------------------------------------------------------");
        
        $display("R0 Value : %h (Expected 55 - Set inside Subroutine)", R0);
        $display("R2 Value : %h (Expected AA - Success Flag)", R2);
        
        // CHECK 1: Did we skip the trap?
        if (R2 == 8'hFF) 
            $display("[FAIL] JMP Failed. Trap code executed (R2=FF).");
        else 
            $display("[PASS] JMP Verified. Trap skipped.");

        // CHECK 2: Did CALL/RET work?
        if (R0 == 8'h55 && R2 == 8'hAA) 
            $display("[PASS] CALL & RET Verified. Subroutine executed and returned.");
        else 
            $display("[FAIL] Flow Control Error.");

        $display("-------------------------------------------------------------");
        $stop;
    end

    // ========================================================================
    // 6. Monitor
    // ========================================================================
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%4t | PC:%2h | IR:%2h | R0:%2h R1:%2h R2:%2h", 
                     $time, PC, uut.IR, R0, R1, R2);
        end
    end

endmodule