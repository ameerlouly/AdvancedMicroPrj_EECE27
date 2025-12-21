`timescale 1ns / 1ps

module tb_CALL_RET;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // Internal Debug Signals (Assumes 'uut' is your top level instance)
    // Adjust path names (e.g., uut.regfile.regs) if your hierarchy differs
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0]; 
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] SP = uut.regfile_inst.regs[3]; // R3 is SP
    
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
    // 4. Test Logic
    // ========================================================================
    initial begin
        // --- Initialization ---
        rstn = 0;
        I_Port = 0;
        int_sig = 0;
        
        // --- Program Memory Loading ---
        $display("Loading CALL/RET Test Program...");

        // --- Simulation Start ---
        $display("Starting Simulation...");
        #20 rstn = 1; // Release Reset

        // -------------------------------------------------------------
        // MAIN PROGRAM (Starts at 0x00)
        // -------------------------------------------------------------
        
        // 0x00: LDM R0, 0x20  (Load Subroutine Address 32 into R0)
        // Op: 12 (1100), ra:00, rb:00 -> C0
        uut.mem_inst.mem[3] = 8'hC0; 
        uut.mem_inst.mem[4] = 8'h20;

        // 0x02: NOP (Safety bubble for Register Write)
        uut.mem_inst.mem[5] = 8'h00;

        // 0x03: NOP
        uut.mem_inst.mem[6] = 8'h00;
        uut.mem_inst.mem[7] = 8'h00;
        uut.mem_inst.mem[8] = 8'h00;

        // 0x04: CALL R0 (Call Subroutine at address in R0 [0x20])
        // Op: 11 (1011), brx:01 (CALL), rb:00 (R0) -> B4
        // Expected Behavior: Push (PC+1 = 0x05) to Stack, Jump to 0x20.
        uut.mem_inst.mem[9] = 8'hB4;

        // 0x05: LDM R2, 0xAA (Success Marker - We returned!)
        // This is the instruction we expect to run AFTER returning.
        uut.mem_inst.mem[10] = 8'hC2;
        uut.mem_inst.mem[11] = 8'hAA;

        // 0x07: STOP (Infinite Loop or NOPs)
        uut.mem_inst.mem[12] = 8'h00; 

        // -------------------------------------------------------------
        // SUBROUTINE (Starts at 0x20)
        // -------------------------------------------------------------
        
        // 0x20: LDM R1, 0xFF (Marker: We are in subroutine)
        uut.mem_inst.mem[32] = 8'hC1;
        uut.mem_inst.mem[33] = 8'hFF;

        // 0x22: RET (Return from Subroutine)
        // Op: 11 (1011), brx:10 (RET), rb:00 -> B8
        // Expected Behavior: Pop Stack into PC.
        uut.mem_inst.mem[34] = 8'hB8;


        // --- Monitor Execution ---
        
        // 1. Wait for CALL to execute
        wait(PC == 8'h20);
        $display("[TIME %0t] Entered Subroutine at PC=0x20.", $time);
        
        // CHECK STACK: 
        // SP should have decremented from 0xFF (255) to 0xFE (254).
        // Mem[0xFF] should contain the return address (0x05).
        #1; // Wait a delta for memory update
        if (SP === 8'hFE) $display("PASS: SP decremented correctly to 0xFE.");
        else $display("FAIL: SP is %h (Expected 0xFE).", SP);

        if (uut.mem_inst.mem[255] === 8'h05) $display("PASS: Stack pushed Return Address 0x05.");
        else $display("FAIL: Stack Top is %h (Expected 0x05).", uut.mem_inst.mem[255]);


        // 2. Wait for RET to execute
        wait(PC == 8'h05);
        $display("[TIME %0t] Returned from Subroutine to PC=0x05.", $time);

        // CHECK STACK:
        // SP should have incremented back to 0xFF.
        if (SP === 8'hFF) $display("PASS: SP incremented correctly to 0xFF.");
        else $display("FAIL: SP is %h (Expected 0xFF).", SP);

        
        // 3. Check Final Success Marker
        #20; // Allow LDM R2 to finish
        if (R2 === 8'hAA) $display("PASS: R2 Loaded 0xAA (Execution continued).");
        else $display("FAIL: R2 is %h (Expected 0xAA).", R2);

        $stop;
    end

    // Monitor for debugging
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%4t | PC:%h | IR:%h | SP:%h | TopStack:%h", 
                     $time, PC, uut.IR, SP, uut.mem_inst.mem[255]);
        end
    end

endmodule