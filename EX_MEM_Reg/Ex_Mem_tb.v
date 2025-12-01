`timescale 1ns/1ps

module EX_MEM_reg_tb;

    // DUT signals
    reg        clk;
    reg        rst;            // active-low
    reg        write_en;
    reg        flush;

    reg  [7:0] alu_result_in;
    reg  [7:0] rb_in;
    reg  [7:0] addr_in;
    reg  [1:0] rd_in;

    reg        mem_read_in;
    reg        mem_write_in;
    reg        reg_write_in;
    reg        flag_write_in;

    wire [7:0] alu_result_out;
    wire [7:0] rb_out;
    wire [7:0] addr_out;
    wire [1:0] rd_out;

    wire       mem_read_out;
    wire       mem_write_out;
    wire       reg_write_out;
    wire       flag_write_out;

    integer tests  = 0;
    integer errors = 0;

    // Instantiate DUT
    EX_MEM_reg dut (
        .clk           (clk),
        .rst           (rst),
        .write_en      (write_en),
        .flush         (flush),
        .alu_result_in (alu_result_in),
        .rb_in         (rb_in),
        .addr_in       (addr_in),
        .rd_in         (rd_in),
        .mem_read_in   (mem_read_in),
        .mem_write_in  (mem_write_in),
        .reg_write_in  (reg_write_in),
        .flag_write_in (flag_write_in),
        .alu_result_out(alu_result_out),
        .rb_out        (rb_out),
        .addr_out      (addr_out),
        .rd_out        (rd_out),
        .mem_read_out  (mem_read_out),
        .mem_write_out (mem_write_out),
        .reg_write_out (reg_write_out),
        .flag_write_out(flag_write_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check outputs
    task check_exmem(
        input [7:0] exp_alu,
        input [7:0] exp_rb,
        input [7:0] exp_addr,
        input [1:0] exp_rd,
        input       exp_mem_read,
        input       exp_mem_write,
        input       exp_reg_write,
        input       exp_flag_write,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // small delay after clock edge

        if (alu_result_out !== exp_alu ||
            rb_out         !== exp_rb  ||
            addr_out       !== exp_addr||
            rd_out         !== exp_rd  ||
            mem_read_out   !== exp_mem_read ||
            mem_write_out  !== exp_mem_write ||
            reg_write_out  !== exp_reg_write ||
            flag_write_out !== exp_flag_write) begin

            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  expected: ALU=%0h RB=%0h ADDR=%0h RD=%0d MR=%b MW=%b RW=%b FW=%b",
                     exp_alu, exp_rb, exp_addr, exp_rd,
                     exp_mem_read, exp_mem_write, exp_reg_write, exp_flag_write);
            $display("  got     : ALU=%0h RB=%0h ADDR=%0h RD=%0d MR=%b MW=%b RW=%b FW=%b",
                     alu_result_out, rb_out, addr_out, rd_out,
                     mem_read_out, mem_write_out, reg_write_out, flag_write_out);
        end
        else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask

    // Main stimulus
    initial begin
        // init
        write_en      = 1'b0;
        flush         = 1'b0;
        alu_result_in = 8'd0;
        rb_in         = 8'd0;
        addr_in       = 8'd0;
        rd_in         = 2'd0;
        mem_read_in   = 1'b0;
        mem_write_in  = 1'b0;
        reg_write_in  = 1'b0;
        flag_write_in = 1'b0;

        // Apply reset
        rst = 1'b0;
        @(posedge clk);
        check_exmem(8'd0, 8'd0, 8'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0,
                    "After reset: all outputs should be 0");

        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_exmem(8'd0, 8'd0, 8'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0,
                    "After reset release (no write yet)");

        // Test 1: normal update
        alu_result_in = 8'hA5;
        rb_in         = 8'h3C;
        addr_in       = 8'h10;
        rd_in         = 2'd2;
        mem_read_in   = 1'b1;
        mem_write_in  = 1'b0;
        reg_write_in  = 1'b1;
        flag_write_in = 1'b1;
        write_en      = 1'b1;
        flush         = 1'b0;

        @(posedge clk);
        check_exmem(8'hA5, 8'h3C, 8'h10, 2'd2, 1'b1, 1'b0, 1'b1, 1'b1,
                    "Normal update from EX to MEM");

        // Test 2: stall (write_en=0) → outputs must hold
        write_en      = 1'b0;
        alu_result_in = 8'hFF;  // change inputs (should NOT pass)
        rb_in         = 8'hEE;
        addr_in       = 8'h22;
        rd_in         = 2'd1;
        mem_read_in   = 1'b0;
        mem_write_in  = 1'b1;
        reg_write_in  = 1'b0;
        flag_write_in = 1'b0;

        @(posedge clk);
        check_exmem(8'hA5, 8'h3C, 8'h10, 2'd2, 1'b1, 1'b0, 1'b1, 1'b1,
                    "Stall: outputs should hold previous values");

        // Test 3: flush → outputs should go to NOP (all zero, no writes)
        flush    = 1'b1;
        write_en = 1'b1;
        @(posedge clk);
        check_exmem(8'd0, 8'd0, 8'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0,
                    "Flush: outputs should be cleared (NOP)");

        // Stop flushing
        flush    = 1'b0;

        // Test 4: update after flush
        alu_result_in = 8'h55;
        rb_in         = 8'hAA;
        addr_in       = 8'h33;
        rd_in         = 2'd3;
        mem_read_in   = 1'b0;
        mem_write_in  = 1'b1;
        reg_write_in  = 1'b0;
        flag_write_in = 1'b0;
        write_en      = 1'b1;

        @(posedge clk);
        check_exmem(8'h55, 8'hAA, 8'h33, 2'd3, 1'b0, 1'b1, 1'b0, 1'b0,
                    "Update after flush");

        // Final result
        if (errors == 0) begin
            $display("======================================");
            $display("  ALL %0d EX/MEM REG TESTS PASSED ", tests);
            $display("======================================");
        end else begin
            $display("======================================");
            $display("  EX/MEM REG TESTBENCH FAILED ");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
            $display("======================================");
        end

        $stop;
    end

endmodule
