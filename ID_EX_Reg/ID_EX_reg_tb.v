`timescale 1ns/1ps

module id_ex_reg_tb;

    // DUT signals
    reg        clk;
    reg        rst;         // active-low
    reg        flush;
    reg        wr_en;

    // Control inputs
    reg        reg_write;
    reg  [1:0] dst_reg;
    reg  [3:0] alu_sel;
    reg  [1:0] op2_sel;
    reg  [1:0] wb_sel;
    reg        mem_read;
    reg        mem_write;
    reg        flag_en;

    // Data inputs
    reg  [7:0] ra_val_in;
    reg  [7:0] rb_val_in;
    reg  [7:0] imm_in;
    reg  [7:0] pc_in;

    // Control outputs
    wire        reg_write_out;
    wire [1:0]  dst_reg_out;
    wire [3:0]  alu_sel_out;
    wire [1:0]  op2_sel_out;
    wire [1:0]  wb_sel_out;
    wire        mem_read_out;
    wire        mem_write_out;
    wire        flag_en_out;

    // Data outputs
    wire [7:0]  ra_val_out;
    wire [7:0]  rb_val_out;
    wire [7:0]  imm_out;
    wire [7:0]  pc_out;

    integer tests  = 0;
    integer errors = 0;

    // Instantiate DUT
    id_ex_reg dut (
        .clk          (clk),
        .rst          (rst),
        .flush        (flush),
        .wr_en        (wr_en),

        .reg_write    (reg_write),
        .dst_reg      (dst_reg),
        .alu_sel      (alu_sel),
        .op2_sel      (op2_sel),
        .wb_sel       (wb_sel),
        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .flag_en      (flag_en),

        .ra_val_in    (ra_val_in),
        .rb_val_in    (rb_val_in),
        .imm_in       (imm_in),
        .pc_in        (pc_in),

        .reg_write_out(reg_write_out),
        .dst_reg_out  (dst_reg_out),
        .alu_sel_out  (alu_sel_out),
        .op2_sel_out  (op2_sel_out),
        .wb_sel_out   (wb_sel_out),
        .mem_read_out (mem_read_out),
        .mem_write_out(mem_write_out),
        .flag_en_out  (flag_en_out),

        .ra_val_out   (ra_val_out),
        .rb_val_out   (rb_val_out),
        .imm_out      (imm_out),
        .pc_out       (pc_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check everything
    task check_idex(
        input        exp_reg_write,
        input  [1:0] exp_dst_reg,
        input  [3:0] exp_alu_sel,
        input  [1:0] exp_op2_sel,
        input  [1:0] exp_wb_sel,
        input        exp_mem_read,
        input        exp_mem_write,
        input        exp_flag_en,

        input  [7:0] exp_ra_val,
        input  [7:0] exp_rb_val,
        input  [7:0] exp_imm,
        input  [7:0] exp_pc,

        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // allow signals to settle

        if (reg_write_out !== exp_reg_write ||
            dst_reg_out   !== exp_dst_reg   ||
            alu_sel_out   !== exp_alu_sel   ||
            op2_sel_out   !== exp_op2_sel   ||
            wb_sel_out    !== exp_wb_sel    ||
            mem_read_out  !== exp_mem_read  ||
            mem_write_out !== exp_mem_write ||
            flag_en_out   !== exp_flag_en   ||

            ra_val_out    !== exp_ra_val    ||
            rb_val_out    !== exp_rb_val    ||
            imm_out       !== exp_imm       ||
            pc_out        !== exp_pc) begin

            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  Expected: rw=%b dst=%0d alu=%0h op2=%0d wb=%0d mr=%b mw=%b fe=%b",
                     exp_reg_write, exp_dst_reg, exp_alu_sel, exp_op2_sel, exp_wb_sel,
                     exp_mem_read, exp_mem_write, exp_flag_en);
            $display("            ra=%0h rb=%0h imm=%0h pc=%0h",
                     exp_ra_val, exp_rb_val, exp_imm, exp_pc);
            $display("  Got     : rw=%b dst=%0d alu=%0h op2=%0d wb=%0d mr=%b mw=%b fe=%b",
                     reg_write_out, dst_reg_out, alu_sel_out, op2_sel_out, wb_sel_out,
                     mem_read_out, mem_write_out, flag_en_out);
            $display("            ra=%0h rb=%0h imm=%0h pc=%0h",
                     ra_val_out, rb_val_out, imm_out, pc_out);
        end
        else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask

    // Main stimulus
    initial begin
        // init
        flush      = 1'b0;
        wr_en      = 1'b0;

        reg_write  = 1'b0;
        dst_reg    = 2'd0;
        alu_sel    = 4'd0;
        op2_sel    = 2'd0;
        wb_sel     = 2'd0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        flag_en    = 1'b0;

        ra_val_in  = 8'd0;
        rb_val_in  = 8'd0;
        imm_in     = 8'd0;
        pc_in      = 8'd0;

        // Reset
        rst = 1'b0;
        @(posedge clk);
        check_idex(1'b0, 2'd0, 4'd0, 2'd0, 2'd0, 1'b0, 1'b0, 1'b0,
                   8'd0, 8'd0, 8'd0, 8'd0,
                   "After reset: everything should be 0");

        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_idex(1'b0, 2'd0, 4'd0, 2'd0, 2'd0, 1'b0, 1'b0, 1'b0,
                   8'd0, 8'd0, 8'd0, 8'd0,
                   "After reset release (no write yet)");

        // Test 1: normal write
        wr_en      = 1'b1;
        flush      = 1'b0;

        reg_write  = 1'b1;
        dst_reg    = 2'd2;
        alu_sel    = 4'hA;
        op2_sel    = 2'd1;
        wb_sel     = 2'd2;
        mem_read   = 1'b1;
        mem_write  = 1'b0;
        flag_en    = 1'b1;

        ra_val_in  = 8'h11;
        rb_val_in  = 8'h22;
        imm_in     = 8'h33;
        pc_in      = 8'h44;

        @(posedge clk);
        check_idex(1'b1, 2'd2, 4'hA, 2'd1, 2'd2, 1'b1, 1'b0, 1'b1,
                   8'h11, 8'h22, 8'h33, 8'h44,
                   "Normal update from ID to EX");

        // Test 2: stall (wr_en=0) → values must hold
        wr_en      = 1'b0;

        reg_write  = 1'b0;
        dst_reg    = 2'd1;
        alu_sel    = 4'h3;
        op2_sel    = 2'd0;
        wb_sel     = 2'd1;
        mem_read   = 1'b0;
        mem_write  = 1'b1;
        flag_en    = 1'b0;

        ra_val_in  = 8'hAA;
        rb_val_in  = 8'hBB;
        imm_in     = 8'hCC;
        pc_in      = 8'hDD;

        @(posedge clk);
        check_idex(1'b1, 2'd2, 4'hA, 2'd1, 2'd2, 1'b1, 1'b0, 1'b1,
                   8'h11, 8'h22, 8'h33, 8'h44,
                   "Stall: outputs should hold previous values");

        // Test 3: flush → outputs should go to NOP/0
        wr_en      = 1'b1;
        flush      = 1'b1;

        @(posedge clk);
        check_idex(1'b0, 2'd0, 4'd0, 2'd0, 2'd0, 1'b0, 1'b0, 1'b0,
                   8'd0, 8'd0, 8'd0, 8'd0,
                   "Flush: outputs should be cleared");

        // Stop flushing
        flush      = 1'b0;

        // Test 4: write again after flush
        wr_en      = 1'b1;

        reg_write  = 1'b1;
        dst_reg    = 2'd3;
        alu_sel    = 4'h5;
        op2_sel    = 2'd2;
        wb_sel     = 2'd3;
        mem_read   = 1'b0;
        mem_write  = 1'b1;
        flag_en    = 1'b0;

        ra_val_in  = 8'hF0;
        rb_val_in  = 8'h0F;
        imm_in     = 8'h5A;
        pc_in      = 8'hC3;

        @(posedge clk);
        check_idex(1'b1, 2'd3, 4'h5, 2'd2, 2'd3, 1'b0, 1'b1, 1'b0,
                   8'hF0, 8'h0F, 8'h5A, 8'hC3,
                   "Update after flush");

        // Final result
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
