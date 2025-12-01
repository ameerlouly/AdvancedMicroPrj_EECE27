`timescale 1ns/1ps

module Register_file_tb;

    // DUT signals
    reg        clk;
    reg        rst;        // active-low reset
    reg        wenabel;    // write enable
    reg  [1:0] ra;
    reg  [1:0] rb;
    reg  [1:0] rd;
    reg  [7:0] write_data;
    wire [7:0] ra_date;
    wire [7:0] rb_date;

    integer tests  = 0;
    integer errors = 0;

    // Instantiate DUT
    Register_file dut (
        .clk        (clk),
        .rst        (rst),
        .wenabel    (wenabel),
        .ra         (ra),
        .rb         (rb),
        .rd         (rd),
        .write_data (write_data),
        .ra_date    (ra_date),
        .rb_date    (rb_date)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ===== Task to check a single read result =====
    task check_reg(
        input [7:0] actual,
        input [7:0] expected,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // small delay to allow comb logic to settle

        if (actual !== expected) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s | expected=%0h got=%0h",
                     tests, msg, expected, actual);
        end else begin
            $display("TEST %0d PASSED: %s | value=%0h",
                     tests, msg, actual);
        end
    end
    endtask

    // ===== Main stimulus =====
    initial begin
        // Initialize inputs
        wenabel    = 1'b0;
        ra         = 2'd0;
        rb         = 2'd0;
        rd         = 2'd0;
        write_data = 8'd0;

        // Apply reset (active-low)
        rst = 1'b0;
        @(posedge clk);

        // After reset: R0=0, R1=0, R2=0, R3=255
        ra = 2'd0; rb = 2'd1;
        #1;
        check_reg(ra_date, 8'd0,   "After reset: R0 should be 0");
        check_reg(rb_date, 8'd0,   "After reset: R1 should be 0");

        ra = 2'd2; rb = 2'd3;
        #1;
        check_reg(ra_date, 8'd0,   "After reset: R2 should be 0");
        check_reg(rb_date, 8'd255, "After reset: R3 (SP) should be 255");

        // Release reset
        rst = 1'b1;
        @(posedge clk);

        // Test 1: Write 0xAA to R0
        rd         = 2'd0;
        write_data = 8'hAA;
        wenabel    = 1'b1;
        @(posedge clk);          // write occurs here
        wenabel    = 1'b0;

        ra = 2'd0; rb = 2'd1;
        #1;
        check_reg(ra_date, 8'hAA, "R0 should be 0xAA after write");
        check_reg(rb_date, 8'd0,  "R1 should still be 0");

        // Test 2: Write 0x55 to R2
        rd         = 2'd2;
        write_data = 8'h55;
        wenabel    = 1'b1;
        @(posedge clk);
        wenabel    = 1'b0;

        ra = 2'd2; rb = 2'd3;
        #1;
        check_reg(ra_date, 8'h55, "R2 should be 0x55 after write");
        check_reg(rb_date, 8'd255,"R3 (SP) should still be 255");

        // Test 3: Overwrite R0 with 0x0F
        rd         = 2'd0;
        write_data = 8'h0F;
        wenabel    = 1'b1;
        @(posedge clk);
        wenabel    = 1'b0;

        ra = 2'd0; rb = 2'd2;
        #1;
        check_reg(ra_date, 8'h0F, "R0 should be overwritten with 0x0F");
        check_reg(rb_date, 8'h55, "R2 should still be 0x55");

        // Test 4: Check that when wenabel=0, no write happens
        rd         = 2'd1;
        write_data = 8'h99;
        wenabel    = 1'b0;   // no write
        @(posedge clk);

        ra = 2'd1;
        #1;
        check_reg(ra_date, 8'd0,  "R1 should remain 0 when wenabel=0");

        // Test 5: Reset again and re-check initial values
        rst = 1'b0;
        @(posedge clk);

        ra = 2'd0; rb = 2'd3;
        #1;
        check_reg(ra_date, 8'd0,   "After second reset: R0 should be 0");
        check_reg(rb_date, 8'd255, "After second reset: R3 (SP) should be 255");

        rst = 1'b1;

        // -------- Final result --------
        if (errors == 0) begin
            $display("======================================");
            $display("  ALL %0d REGISTER FILE TESTS PASSED ", tests);
            $display("======================================");
        end else begin
            $display("======================================");
            $display("  REGISTER FILE TESTBENCH FAILED ");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
            $display("======================================");
        end

        $stop;
    end

endmodule
