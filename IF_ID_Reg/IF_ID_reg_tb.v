`timescale 1ns/1ps

module IF_ID_reg_tb;

    // DUT signals
    reg        clk;
    reg        rst;        // active-low
    reg        write_en;
    reg        flush;
    reg  [7:0] pc;
    reg  [7:0] instr_in;
    wire [7:0] pc_out;
    wire [7:0] instr_out;

    integer tests  = 0;
    integer errors = 0;

    // Instantiate DUT
    IF_ID_reg dut (
        .clk      (clk),
        .rst      (rst),
        .write_en (write_en),
        .flush    (flush),
        .pc       (pc),
        .instr_in (instr_in),
        .pc_out   (pc_out),
        .instr_out(instr_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check pc_out & instr_out
    task check_ifid(
        input [7:0] exp_pc,
        input [7:0] exp_instr,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // small delay after clock edge

        if (pc_out !== exp_pc || instr_out !== exp_instr) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s | expected PC=%0h, INSTR=%0h  got PC=%0h, INSTR=%0h",
                     tests, msg, exp_pc, exp_instr, pc_out, instr_out);
        end else begin
            $display("TEST %0d PASSED: %s | PC=%0h, INSTR=%0h",
                     tests, msg, pc_out, instr_out);
        end
    end
    endtask

    // Main stimulus
    initial begin
        // init
        write_en = 1'b0;
        flush    = 1'b0;
        pc       = 8'd0;
        instr_in = 8'd0;

        // Apply reset
        rst = 1'b0;
        @(posedge clk);
        check_ifid(8'd0, 8'd0, "After reset: should be cleared (NOP)");

        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_ifid(8'd0, 8'd0, "After reset release (no write yet)");

        // Test 1: normal write
        pc       = 8'h10;
        instr_in = 8'hA5;
        write_en = 1'b1;
        flush    = 1'b0;
        @(posedge clk);  // update happens here
        check_ifid(8'h10, 8'hA5, "Normal write: PC=0x10, INSTR=0xA5");

        // Test 2: stall (write_en=0) → values must hold
        write_en = 1'b0;
        pc       = 8'h20;   // change inputs, shouldn't propagate
        instr_in = 8'h3C;
        @(posedge clk);
        check_ifid(8'h10, 8'hA5, "Stall: outputs should hold previous values");

        // Test 3: another normal update
        write_en = 1'b1;
        pc       = 8'h33;
        instr_in = 8'h55;
        @(posedge clk);
        check_ifid(8'h33, 8'h55, "Normal write: PC=0x33, INSTR=0x55");

        // Test 4: flush → should insert NOP (0x00)
        flush    = 1'b1;
        write_en = 1'b1;    // Flush has priority
        pc       = 8'h44;
        instr_in = 8'h77;
        @(posedge clk);
        check_ifid(8'd0, 8'd0, "Flush: outputs should become NOP (0,0)");

        // Stop flushing
        flush    = 1'b0;

        // Test 5: write again after flush
        write_en = 1'b1;
        pc       = 8'h22;
        instr_in = 8'h99;
        @(posedge clk);
        check_ifid(8'h22, 8'h99, "Write after flush: PC=0x22, INSTR=0x99");

        // Final result
        if (errors == 0) begin
            $display("======================================");
            $display("  ALL %0d IF/ID REG TESTS PASSED ", tests);
            $display("======================================");
        end else begin
            $display("======================================");
            $display("  IF/ID REG TESTBENCH FAILED ");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
            $display("======================================");
        end

        $stop;
    end

endmodule
