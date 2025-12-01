`timescale 1ns/1ps

module id_ex_reg_tb;

    // DUT signals
    reg         clk;
    reg         rst;           // active-low
    reg         wr_en;
    reg         flush;
    reg         reg_write;
    reg  [1:0]  dst_reg;
    reg  [3:0]  alu_sel;
    reg  [1:0]  op2_sel;
    reg  [1:0]  wb_sel;
    reg         mem_read;
    reg         mem_write;
    reg         flag_en;
    
    wire        reg_write_out;
    wire [1:0]  dst_reg_out;
    wire [3:0]  alu_sel_out;
    wire [1:0]  op2_sel_out;
    wire [1:0]  wb_sel_out;
    wire        mem_read_out;
    wire        mem_write_out;
    wire        flag_en_out;

    integer tests  = 0;
    integer errors = 0;

    // Instantiate DUT
    id_ex_reg dut (
        .clk            (clk),
        .rst            (rst),
        .wr_en          (wr_en),
        .flush          (flush),
        .reg_write      (reg_write),
        .dst_reg        (dst_reg),
        .alu_sel        (alu_sel),
        .op2_sel        (op2_sel),
        .wb_sel         (wb_sel),
        .mem_read       (mem_read),
        .mem_write      (mem_write),
        .flag_en        (flag_en),
        .reg_write_out  (reg_write_out),
        .dst_reg_out    (dst_reg_out),
        .alu_sel_out    (alu_sel_out),
        .op2_sel_out    (op2_sel_out),
        .wb_sel_out     (wb_sel_out),
        .mem_read_out   (mem_read_out),
        .mem_write_out  (mem_write_out),
        .flag_en_out    (flag_en_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check outputs
    task check_idex(
        input        exp_reg_write,
        input [1:0]  exp_dst_reg,
        input [3:0]  exp_alu_sel,
        input [1:0]  exp_op2_sel,
        input [1:0]  exp_wb_sel,
        input        exp_mem_read,
        input        exp_mem_write,
        input        exp_flag_en,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // small delay after clock edge

        if (reg_write_out !== exp_reg_write || 
            dst_reg_out !== exp_dst_reg || 
            alu_sel_out !== exp_alu_sel ||
            op2_sel_out !== exp_op2_sel ||
            wb_sel_out !== exp_wb_sel ||
            mem_read_out !== exp_mem_read ||
            mem_write_out !== exp_mem_write ||
            flag_en_out !== exp_flag_en) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  Expected: RW=%b DST=%b ALU=%b OP2=%b WB=%b MR=%b MW=%b FE=%b",
                     exp_reg_write, exp_dst_reg, exp_alu_sel, exp_op2_sel,
                     exp_wb_sel, exp_mem_read, exp_mem_write, exp_flag_en);
            $display("  Got:      RW=%b DST=%b ALU=%b OP2=%b WB=%b MR=%b MW=%b FE=%b",
                     reg_write_out, dst_reg_out, alu_sel_out, op2_sel_out,
                     wb_sel_out, mem_read_out, mem_write_out, flag_en_out);
        end else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask

    // Main stimulus
    initial begin
        // Initialize
        wr_en       = 1'b0;
        flush       = 1'b0;
        reg_write   = 1'b0;
        dst_reg     = 2'd0;
        alu_sel     = 4'd0;
        op2_sel     = 2'd0;
        wb_sel      = 2'd0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        flag_en     = 1'b0;

        // Apply reset
        rst = 1'b0;
        @(posedge clk);
        check_idex(1'b0, 2'd0, 4'd0, 2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 
                   "After reset: all outputs should be cleared");

        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_idex(1'b0, 2'd0, 4'd0, 2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 
                   "After reset release (no write yet)");

        // Test 1: Normal write with various values
        reg_write   = 1'b1;
        dst_reg     = 2'b10;
        alu_sel     = 4'b0101;
        op2_sel     = 2'b11;
        wb_sel      = 2'b10;
        mem_read    = 1'b1;
        mem_write   = 1'b0;
        flag_en     = 1'b1;
        wr_en       = 1'b1;
        flush       = 1'b0;
        @(posedge clk);
        check_idex(1'b1, 2'b10, 4'b0101, 2'b11, 2'b10, 1'b1, 1'b0, 1'b1,
                   "Normal write: all signals propagate correctly");

        // Test 2: Stall (wr_en=0) → values must hold
        wr_en       = 1'b0;
        reg_write   = 1'b0;
        dst_reg     = 2'b01;
        alu_sel     = 4'b1010;
        op2_sel     = 2'b00;
        wb_sel      = 2'b01;
        mem_read    = 1'b0;
        mem_write   = 1'b1;
        flag_en     = 1'b0;
        @(posedge clk);
        check_idex(1'b1, 2'b10, 4'b0101, 2'b11, 2'b10, 1'b1, 1'b0, 1'b1,
                   "Stall: outputs should hold previous values");

        // Test 3: Another normal update
        wr_en       = 1'b1;
        reg_write   = 1'b0;
        dst_reg     = 2'b11;
        alu_sel     = 4'b1111;
        op2_sel     = 2'b01;
        wb_sel      = 2'b00;
        mem_read    = 1'b1;
        mem_write   = 1'b1;
        flag_en     = 1'b0;
        @(posedge clk);
        check_idex(1'b0, 2'b11, 4'b1111, 2'b01, 2'b00, 1'b1, 1'b1, 1'b0,
                   "Normal write: new values propagate");

        // Test 4: Flush → should insert NOP (all zeros)
        flush       = 1'b1;
        wr_en       = 1'b1;    // Flush has priority
        reg_write   = 1'b1;
        dst_reg     = 2'b10;
        alu_sel     = 4'b0101;
        op2_sel     = 2'b10;
        wb_sel      = 2'b11;
        mem_read    = 1'b1;
        mem_write   = 1'b1;
        flag_en     = 1'b1;
        @(posedge clk);
        check_idex(1'b0, 2'b00, 4'b0000, 2'b00, 2'b00, 1'b0, 1'b0, 1'b0,
                   "Flush: all outputs should be reset (NOP)");

        // Test 5: Write after flush
        flush       = 1'b0;
        wr_en       = 1'b1;
        reg_write   = 1'b1;
        dst_reg     = 2'b01;
        alu_sel     = 4'b0011;
        op2_sel     = 2'b10;
        wb_sel      = 2'b01;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        flag_en     = 1'b1;
        @(posedge clk);
        check_idex(1'b1, 2'b01, 4'b0011, 2'b10, 2'b01, 1'b0, 1'b0, 1'b1,
                   "Write after flush: normal operation resumes");

        // Test 6: ALU operation change (ADD vs SUB)
        alu_sel     = 4'b0001;  // Different ALU op
        dst_reg     = 2'b00;
        mem_read    = 1'b0;
        mem_write   = 1'b1;
        @(posedge clk);
        check_idex(1'b1, 2'b00, 4'b0001, 2'b10, 2'b01, 1'b0, 1'b1, 1'b1,
                   "ALU operation change: new ALU selector propagates");

        // Test 7: Stall during memory operation
        wr_en       = 1'b0;
        @(posedge clk);
        check_idex(1'b1, 2'b00, 4'b0001, 2'b10, 2'b01, 1'b0, 1'b1, 1'b1,
                   "Stall during memory op: previous values held");

        // Print results
        if (errors == 0) begin
            $display("======================================");
            $display("  ALL %0d ID/EX REG TESTS PASSED ", tests);
            $display("======================================");
        end else begin
            $display("======================================");
            $display("  ID/EX REG TESTBENCH FAILED ");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
            $display("======================================");
        end

        $stop;
    end

endmodule
