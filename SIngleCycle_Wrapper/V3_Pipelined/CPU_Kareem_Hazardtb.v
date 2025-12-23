`timescale 1ns / 1ps

module tb_RAW_Hazard;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] PC = uut.PC.pc_current;
    
    // Check the memory location we are testing
    wire [7:0] Mem200 = uut.mem_inst.mem[200];

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
        
        $display("Loading RAW Hazard (Store-Load-Use) Program...");

                // --- Execute ---
        #20 rstn = 1;

        // Memory Setup: Reset Vector at 0x00
        uut.mem_inst.mem[0] = 8'h00; 

        // --------------------------------------------------------------------
        // Step 1: Initialize Registers
        // --------------------------------------------------------------------
        // 0x00: LDM R1, 10  (Set R1 = 10, to be used as accumulator)
        // Op: 12 (1100), ra:00, rb:01 -> C1
        uut.mem_inst.mem[0] = 8'hC1; 
        uut.mem_inst.mem[1] = 8'd10;

        // 0x02: LDM R0, 50  (Set R0 = 50, the value we will store)
        // Op: 12 (1100), ra:00, rb:00 -> C0
        uut.mem_inst.mem[2] = 8'hC0; 
        uut.mem_inst.mem[3] = 8'd50;

        // --------------------------------------------------------------------
        // Step 2: Store Value (Create Data in Memory)
        // --------------------------------------------------------------------
        // 0x04: STD R0, 200 (Store R0 into Address 200)
        // Op: 12 (1100), ra:10 (STD), rb:00 (R0) -> C8
        uut.mem_inst.mem[4] = 8'hC8;
        uut.mem_inst.mem[5] = 8'd200; // Address 200

        // --------------------------------------------------------------------
        // Step 3: Load Value (Producer of Hazard)
        // --------------------------------------------------------------------
        // 0x06: LDD R2, 200 (Load Mem[200] into R2)
        // Op: 12 (1100), ra:01 (LDD), rb:10 (R2) -> C6
        uut.mem_inst.mem[6] = 8'hC6;
        uut.mem_inst.mem[7] = 8'd200; // Address 200

        // --------------------------------------------------------------------
        // Step 4: Use Value (Consumer of Hazard - RAW)
        // --------------------------------------------------------------------
        // 0x08: ADD R1, R2 (R1 = R1 + R2 = 10 + 50 = 60)
        // This instruction enters EX while LDD is in MEM. 
        // A Load-Use Stall or Forwarding logic is required here.
        // Op: 2 (0010), ra:01 (R1), rb:10 (R2) -> 26
        uut.mem_inst.mem[8] = 8'h26;

        // 0x09: STOP (NOP)
        uut.mem_inst.mem[9] = 8'h00;



        // Run for 40 cycles to ensure stall cycles (if any) are covered
        repeat (40) @(posedge clk);

        // Final settle
        #5;

        $display("-------------------------------------------------------------");
        $display("RAW HAZARD TEST REPORT");
        $display("-------------------------------------------------------------");
        $display("Mem[200] (Expected 50): %d", Mem200);
        $display("R2 Loaded (Expected 50): %d", R2);
        $display("R1 Result (Expected 60): %d", R1);
        
        // Success Logic
        if (Mem200 == 50 && R2 == 50 && R1 == 60)
            $display("[SUCCESS] RAW Hazard resolved correctly.");
        else begin
            $display("[FAILURE] Incorrect execution.");
            if (R1 == 10) $display(" -> R1 is 10: ADD likely happened before R2 loaded (Data Hazard).");
            if (R2 == 0)  $display(" -> R2 is 0: Load failed.");
        end
            
        $display("-------------------------------------------------------------");
        $stop;
    end

    // --- Monitoring ---
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%t | PC:%h | R1:%d | R2:%d | Mem[200]:%d", 
                     $time, PC, R1, R2, Mem200);
        end
    end

endmodule