`timescale 1ns/1ps

module tb_Branch_Unit();

    // DUT Inputs
    reg [3:0] flag_mask;   // [Z,N,C,V]
    reg [2:0] BTYPE;

    // DUT Outputs
    wire [1:0] B_TAKE;
    wire [1:0] PC_SRC;

    // Instantiate the DUT
    Branch_Unit dut (
        .flag_mask(flag_mask),
        .BTYPE(BTYPE),
        .B_TAKE(B_TAKE),
        .PC_SRC(PC_SRC)
    );

    // PC source encoding
    localparam FW    = 2'b01;
    localparam DataB = 2'b10;
    localparam NORM  = 2'b00;

    // Branch Types
    localparam BR_NONE = 3'b000;
    localparam BR_JZ   = 3'b001;
    localparam BR_JN   = 3'b010;
    localparam BR_JC   = 3'b011;
    localparam BR_JV   = 3'b100;
    localparam BR_LOOP = 3'b101;
    localparam BR_JMP  = 3'b110;
    localparam BR_RET  = 3'b111;

    // Counters
    integer passed = 0;
    integer failed = 0;
    integer total  = 0;

    // Test task
    task run_test;
        input [3:0] t_flags;
        input [2:0] t_btype;
        input [1:0] expected_take;
        input [1:0] expected_pc;
        begin
            flag_mask = t_flags;
            BTYPE     = t_btype;
            #1;

            total = total + 1;

            if (B_TAKE !== expected_take || PC_SRC !== expected_pc) begin
                failed = failed + 1;
                $display("FAIL: flags=%b BTYPE=%b -> B_TAKE=%b (exp %b), PC_SRC=%b (exp %b)",
                         flag_mask, BTYPE, B_TAKE, expected_take, PC_SRC, expected_pc);
            end else begin
                passed = passed + 1;
                $display("PASS: flags=%b BTYPE=%b -> B_TAKE=%b, PC_SRC=%b",
                         flag_mask, BTYPE, B_TAKE, PC_SRC);
            end
        end
    endtask


    initial begin
        $display("\n=== Branch Unit Testbench Start ===\n");

        // BR_NONE
        run_test(4'b0000, BR_NONE, 2'b00, FW);

        // BR_JZ
        run_test(4'b0001, BR_JZ, 2'b01, FW);   // Z=1 -> take
        run_test(4'b0000, BR_JZ, 2'b00, NORM); // Z=0 -> no

        // BR_JN
        run_test(4'b0010, BR_JN, 2'b01, FW);   // N=1
        run_test(4'b0000, BR_JN, 2'b00, NORM); // N=0

        // BR_JC
        run_test(4'b0100, BR_JC, 2'b01, FW);   // C=1
        run_test(4'b0000, BR_JC, 2'b00, NORM);

        // BR_JV
        run_test(4'b1000, BR_JV, 2'b01, FW);   // V=1
        run_test(4'b0000, BR_JV, 2'b00, NORM);

        // BR_LOOP (Z == 0)
        run_test(4'b0000, BR_LOOP, 2'b01, FW); // Z=0 → LOOP continue
        run_test(4'b0001, BR_LOOP, 2'b00, NORM); // Z=1 → stop

        // BR_JMP (always take)
        run_test(4'bxxxx, BR_JMP, 2'b01, FW);

        // BR_RET (always take, PC from DataB)
        run_test(4'bxxxx, BR_RET, 2'b01, DataB);

        // DEFAULT case
        run_test(4'b0000, 3'bxxx, 2'b00, DataB);

        $display("\n=== Testbench Finished ===");
        $display("TOTAL TESTS = %0d", total);
        $display("PASSED      = %0d", passed);
        $display("FAILED      = %0d\n", failed);

        $finish;
    end

endmodule
