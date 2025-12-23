`timescale 1ns / 1ps

module tb_MemOps;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3];

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
        uut.mem_inst.mem[0] = 8'h1;
        forever #5 clk = ~clk; 
    end

    // ========================================================================
    // 4. Program Loading & Execution
    // ========================================================================
    initial begin
        rstn = 0;
        I_Port = 0;
        int_sig = 0;

        $display("Loading Memory Operation Test Program...");

                #20 rstn = 1;
        
        // --------------------------------------------------------------------
        // 1. LDM R0, 198 (0xC6) -> Load pointer address
        // --------------------------------------------------------------------
        // Op: 12 (1100), ra:00, rb:00 -> C0
         
        uut.mem_inst.mem[1] = 8'hC0; 
        uut.mem_inst.mem[2] = 8'hC6; // Immediate 198

        // --------------------------------------------------------------------
        // 2. LDM R1, 20 (0x14) -> Data to store later
        // --------------------------------------------------------------------
        // Op: 12 (1100), ra:00, rb:01 -> C1
        uut.mem_inst.mem[3] = 8'hC1;
        uut.mem_inst.mem[4] = 8'h14; // Immediate 20

        // --------------------------------------------------------------------
        // 3. LDM R3, 39 (0x27) -> Data to store indirect
        // --------------------------------------------------------------------
        // Op: 12 (1100), ra:00, rb:11 -> C3
        uut.mem_inst.mem[5] = 8'hC3;
        uut.mem_inst.mem[6] = 8'h27; // Immediate 39

        // --------------------------------------------------------------------

        // --------------------------------------------------------------------
        // 5. STD R1, 200 (0xC8) -> Store R1 (20) into Mem[200]
        // --------------------------------------------------------------------
        // Op: 12 (1100), ra:10 (STD), rb:01 (R1) -> C9
        uut.mem_inst.mem[7] = 8'hC9;
        uut.mem_inst.mem[8] = 8'hC8; // Address 200

        // --------------------------------------------------------------------
        // 6. LDD R2, 200 (0xC8) -> Load R2 from Mem[200]. Expect R2 = 20.
        // --------------------------------------------------------------------
        // Op: 12 (1100), ra:01 (LDD), rb:10 (R2) -> C6
        uut.mem_inst.mem[9] = 8'hC6;
        uut.mem_inst.mem[10] = 8'hC8; // Address 200

        // --------------------------------------------------------------------
        // 7. STI R0, R3 -> Store Indirect. Mem[R0] = R3. Mem[198] = 39.
        // --------------------------------------------------------------------
        // Op: 14 (1110), ra:00 (Ptr R0), rb:11 (Src R3) -> E3
        uut.mem_inst.mem[11] = 8'hE3;

        // --------------------------------------------------------------------


        // --------------------------------------------------------------------
        // 10. LDI R2, [R0] -> Load Indirect. R2 = Mem[R0]. Expect R2 = 39.
        // NOTE: Adjusted based on logic. "LDI R2, R3" implies using R0 as ptr.
        // --------------------------------------------------------------------
        // Op: 13 (1101), ra:00 (Ptr R0), rb:10 (Dest R2) -> D2
        uut.mem_inst.mem[12] = 8'hD2;

        // --------------------------------------------------------------------
        // END: Stop
        // --------------------------------------------------------------------
        uut.mem_inst.mem[13] = 8'h00;



        // Run enough time for all instructions
        #300; 

        // ========================================================================
        // 5. Check Results
        // ========================================================================
        $display("-------------------------------------------------------------");
        $display("MEMORY & INDIRECT ADDRESSING TEST REPORT");
        $display("-------------------------------------------------------------");
        
        // Check 1: Direct Store/Load (STD/LDD)
        // Memory[200] should be 20. R2 should be 20 (temporarily).
        // Since R2 is overwritten by LDI at the end, we check memory.
        if (uut.mem_inst.mem[200] === 8'd20) 
            $display("[PASS] STD R1, 200: Memory[200] contains %d (Expected 20).", uut.mem_inst.mem[200]);
        else
            $display("[FAIL] STD R1, 200: Memory[200] contains %d (Expected 20).", uut.mem_inst.mem[200]);

        // Check 2: Indirect Store (STI)
        // Memory[198] should be 39.
        if (uut.mem_inst.mem[198] === 8'd39) 
            $display("[PASS] STI R0, R3: Memory[198] contains %d (Expected 39).", uut.mem_inst.mem[198]);
        else
            $display("[FAIL] STI R0, R3: Memory[198] contains %d (Expected 39).", uut.mem_inst.mem[198]);

        // Check 3: Indirect Load (LDI)
        // R2 should be 39.
        if (R2 === 8'd39) 
            $display("[PASS] LDI R2, [R0]: R2 contains %d (Expected 39).", R2);
        else
            $display("[FAIL] LDI R2, [R0]: R2 contains %d (Expected 39).", R2);

        $display("-------------------------------------------------------------");
        $stop;
    end
    
    // Monitor
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%4t | PC:%2d | R0:%d R1:%d R2:%d R3:%d", 
                     $time, PC, R0, R1, R2, R3);
        end
    end

endmodule