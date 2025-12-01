`timescale 1ns/1ps

module pc_tb;

    // DUT signals
    reg        clk;
    reg        rst;         // active-low reset
    reg        pc_write;
    reg  [7:0] pc_next;
    wire [7:0] pc_current;

    integer tests  = 0;
    integer errors = 0;

    // Instantiate DUT
    Pc dut (
        .clk       (clk),
        .rst       (rst),
        .pc_write  (pc_write),
        .pc_next   (pc_next),
        .pc_current(pc_current)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------- TASKS ----------

    // Check PC value against expected
    task check_pc(
        input [7:0] expected,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // small delay after edge

        if (pc_current !== expected) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s | expected=%0h got=%0h",
                     tests, msg, expected, pc_current);
        end else begin
            $display("TEST %0d PASSED: %s | pc=%0h",
                     tests, msg, pc_current);
        end
    end
    endtask

    // ---------- MAIN STIMULUS ----------
    initial begin
        // init
        pc_write = 1'b0;
        pc_next  = 8'd0;

        // Apply reset (active-low)
        rst = 1'b0;
        @(posedge clk);
        check_pc(8'd0, "After reset PC should be 0");

        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_pc(8'd0, "PC holds 0 after reset release (no write)");

        // Test 1: write 0x10
        pc_next  = 8'h10;
        pc_write = 1'b1;
        @(posedge clk);  // update happens here
        pc_write = 1'b0; // stop writing
        check_pc(8'h10, "PC should load 0x10");

        // Test 2: stall (no write, PC must hold 0x10)
        @(posedge clk);
        check_pc(8'h10, "PC should hold 0x10 when pc_write=0 (stall)");

        // Test 3: write 0x25
        pc_next  = 8'h25;
        pc_write = 1'b1;
        @(posedge clk);
        pc_write = 1'b0;
        check_pc(8'h25, "PC should load 0x25");

        // Test 4: multiple stalls
        @(posedge clk);
        check_pc(8'h25, "PC hold 0x25 (stall #1)");
        @(posedge clk);
        check_pc(8'h25, "PC hold 0x25 (stall #2)");

        // Test 5: reset again
        rst = 1'b0;
        @(posedge clk);
        check_pc(8'd0, "PC should go back to 0 after reset");
        rst = 1'b1;

        // ---------- FINAL RESULT ----------
        if (errors == 0) begin
            $display("======================================");
            $display("  ALL %0d PC TESTS PASSED", tests);
            $display("======================================");
        end else begin
            $display("======================================");
            $display("  PC TESTBENCH FAILED ");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
            $display("======================================");
        end

        $stop;
    end

endmodule
