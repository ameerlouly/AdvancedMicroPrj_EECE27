`timescale 1ns / 1ps

module HU_tb;

    // ==========================
    // 1. Inputs (Regs)
    // ==========================
    reg [1:0] if_id_ra;
    reg [1:0] if_id_rb;
    reg [1:0] id_ex_rd;
    reg       id_ex_mem_read; // High for Load instructions (LDD, POP, etc.)
    reg       BT;             // Branch Taken signal

    // ==========================
    // 2. Outputs (Wires)
    // ==========================
    wire pc_en;
    wire if_id_en;
    wire flush;

    // ==========================
    // 3. Instantiate the Device Under Test (DUT)
    // ==========================
    HU dut (
        .if_id_ra(if_id_ra),
        .if_id_rb(if_id_rb),
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read), 
        .BT(BT),
        .pc_en(pc_en),
        .if_id_en(if_id_en),
        .flush(flush)
    );

    // ==========================
    // 4. Test Logic
    // ==========================
    initial begin
        // Monitor changes in console
        $monitor("Time=%0t | RA=%d RB=%d RD(EX)=%d MemRead=%b BT=%b | PC_EN=%b IF_ID_EN=%b FLUSH=%b", 
                 $time, if_id_ra, if_id_rb, id_ex_rd, id_ex_mem_read, BT, pc_en, if_id_en, flush);

        // -------------------------------------------------------
        // Test Case 1: Normal Operation (No Hazards)
        // -------------------------------------------------------
        // Instruction F/D uses R0, R1. Instruction EX writes to R2.
        // Expectation: Run (1, 1, 0)
        #10;
        if_id_ra = 2'd0; if_id_rb = 2'd1; 
        id_ex_rd = 2'd2; id_ex_mem_read = 0; BT = 0;
        #1 check(1, 1, 0, "No Hazard");

        // -------------------------------------------------------
        // Test Case 2: Data Dependency but ALU Operation (Forwarding Case)
        // -------------------------------------------------------
        // Instruction F/D reads R1. Instruction EX writes R1 (e.g., ADD R1, R2).
        // Since it's ALU-to-ALU, Forwarding handles this. HU should NOT stall.
        // NOTE: If you are not using Forwarding, this test will fail (you want it to stall).
        #10;
        if_id_ra = 2'd1; if_id_rb = 2'd2; 
        id_ex_rd = 2'd1; id_ex_mem_read = 0; BT = 0;
        #1 check(1, 1, 0, "ALU Dependency (Forwarding Should Handle)");

        // -------------------------------------------------------
        // Test Case 3: Load-Use Hazard (STALL REQUIRED)
        // -------------------------------------------------------
        // Instruction F/D reads R1. Instruction EX is loading into R1 (LDD R1).
        // Forwarding cannot help here (data is in memory). Must Stall.
        // Expectation: Stall (0, 0, 1 or 0) -> Flush depends on your design choice
        #10;
        if_id_ra = 2'd1; if_id_rb = 2'd2; 
        id_ex_rd = 2'd1; id_ex_mem_read = 1; BT = 0;
        #1 check(0, 0, 1, "Load-Use Hazard on RA");

        // -------------------------------------------------------
        // Test Case 4: Load-Use Hazard on Second Operand (RB)
        // -------------------------------------------------------
        #10;
        if_id_ra = 2'd3; if_id_rb = 2'd1; // RB depends on EX
        id_ex_rd = 2'd1; id_ex_mem_read = 1; BT = 0;
        #1 check(0, 0, 1, "Load-Use Hazard on RB");

        // -------------------------------------------------------
        // Test Case 5: Branch Taken (Control Hazard)
        // -------------------------------------------------------
        // Branch logic says "Take Branch". We must flush the fetched instruction.
        // Expectation: Flush (x, x, 1) -> Usually we keep PC_EN=1 to fetch target.
        #10;
        if_id_ra = 2'd0; if_id_rb = 2'd0; 
        id_ex_rd = 2'd3; id_ex_mem_read = 0; BT = 1;
        #1 check(1, 1, 1, "Branch Taken Flush");

        // -------------------------------------------------------
        // Test Case 6: Branch AND Load-Use (Corner Case)
        // -------------------------------------------------------
        // Rare case: Stall condition meets Branch. Usually Flush wins.
        #10;
        if_id_ra = 2'd1; if_id_rb = 2'd0;
        id_ex_rd = 2'd1; id_ex_mem_read = 1; BT = 1;
        #1; // Just observe output, design dependent.

        #10 $finish;
    end

    // ==========================
    // Helper Task for Verification
    // ==========================
    task check;
        input exp_pc_en;
        input exp_if_id_en;
        input exp_flush;
        input [100*8:1] test_name;
        begin
            if (pc_en !== exp_pc_en || if_id_en !== exp_if_id_en || flush !== exp_flush) begin
                $display("FAIL: %s. Expected (PC=%b, IF=%b, FL=%b), Got (%b, %b, %b)", 
                         test_name, exp_pc_en, exp_if_id_en, exp_flush, pc_en, if_id_en, flush);
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

endmodule