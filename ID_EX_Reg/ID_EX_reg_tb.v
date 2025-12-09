`timescale 1ns/1ps

/*
 * ID_EX_reg_tb.v - Updated ID/EX Pipeline Register Testbench
 * 
 * Tests the updated ID/EX pipeline stage with:
 * - PC+1, Instruction Pointer (IP), Immediate value
 * - Branch Type, Memory-to-Register, Register Write controls
 * - Memory Read/Write, ALU operation, Update Flags, IO Write
 * - Register addresses, register values, RegDistidx
 * - Flush behavior (controls cleared, pc_plus1 updates)
 */

module id_ex_reg_tb;

    // DUT signals
    reg         clk;
    reg         rst;
    reg         flush;
    
    // Control inputs
    reg  [1:0]  BType;
    reg  [1:0]  MemToReg;
    reg         RegWrite;
    reg         MemWrite;
    reg         MemRead;
    reg         UpdateFlags;
    reg  [1:0]  RegDistidx;
    reg         ALU_src;
    reg  [3:0]  ALU_op;
    reg         IO_Write;
    
    // Data inputs
    reg  [7:0]  ra_val_in;
    reg  [7:0]  rb_val_in;
    reg  [1:0]  ra;
    reg  [1:0]  rb;
    reg  [7:0]  pc_plus1;
    reg  [7:0]  IP;
    reg  [7:0]  imm;
    
    // Control outputs
    wire [1:0]  BType_out;
    wire [1:0]  MemToReg_out;
    wire        RegWrite_out;
    wire        MemWrite_out;
    wire        MemRead_out;
    wire        UpdateFlags_out;
    wire [1:0]  RegDistidx_out;
    wire        ALU_src_out;
    wire [3:0]  ALU_op_out;
    wire        IO_Write_out;
    
    // Data outputs
    wire [7:0]  ra_val_out;
    wire [7:0]  rb_val_out;
    wire [1:0]  ra_out;
    wire [1:0]  rb_out;
    wire [7:0]  pc_plus1_out;
    wire [7:0]  IP_out;
    wire [7:0]  imm_out;
    
    integer tests = 0;
    integer errors = 0;

    // Instantiate DUT
    id_ex_reg dut (
        .clk            (clk),
        .rst            (rst),
        .flush          (flush),
        .pc_plus1       (pc_plus1),
        .IP             (IP),
        .imm            (imm),
        .BType          (BType),
        .MemToReg       (MemToReg),
        .RegWrite       (RegWrite),
        .MemWrite       (MemWrite),
        .MemRead        (MemRead),
        .UpdateFlags    (UpdateFlags),
        .RegDistidx     (RegDistidx),
        .ALU_src        (ALU_src),
        .ALU_op         (ALU_op),
        .IO_Write       (IO_Write),
        .ra_val_in      (ra_val_in),
        .rb_val_in      (rb_val_in),
        .ra             (ra),
        .rb             (rb),
        .BType_out      (BType_out),
        .MemToReg_out   (MemToReg_out),
        .RegWrite_out   (RegWrite_out),
        .MemWrite_out   (MemWrite_out),
        .MemRead_out    (MemRead_out),
        .UpdateFlags_out(UpdateFlags_out),
        .RegDistidx_out (RegDistidx_out),
        .ALU_src_out    (ALU_src_out),
        .ALU_op_out     (ALU_op_out),
        .IO_Write_out   (IO_Write_out),
        .ra_val_out     (ra_val_out),
        .rb_val_out     (rb_val_out),
        .ra_out         (ra_out),
        .rb_out         (rb_out),
        .pc_plus1_out   (pc_plus1_out),
        .IP_out         (IP_out),
        .imm_out        (imm_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to check outputs
    task check_all_outputs(
        input [1:0]  exp_btype,
        input [1:0]  exp_memtoreg,
        input        exp_regwrite,
        input        exp_memwrite,
        input        exp_memread,
        input        exp_updateflags,
        input [1:0]  exp_regdistidx,
        input        exp_alu_src,
        input [3:0]  exp_alu_op,
        input        exp_io_write,
        input [7:0]  exp_ra_val,
        input [7:0]  exp_rb_val,
        input [1:0]  exp_ra,
        input [1:0]  exp_rb,
        input [7:0]  exp_pc_plus1,
        input [7:0]  exp_ip,
        input [7:0]  exp_imm,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1;
        
        if (BType_out !== exp_btype ||
            MemToReg_out !== exp_memtoreg ||
            RegWrite_out !== exp_regwrite ||
            MemWrite_out !== exp_memwrite ||
            MemRead_out !== exp_memread ||
            UpdateFlags_out !== exp_updateflags ||
            RegDistidx_out !== exp_regdistidx ||
            ALU_src_out !== exp_alu_src ||
            ALU_op_out !== exp_alu_op ||
            IO_Write_out !== exp_io_write ||
            ra_val_out !== exp_ra_val ||
            rb_val_out !== exp_rb_val ||
            ra_out !== exp_ra ||
            rb_out !== exp_rb ||
            pc_plus1_out !== exp_pc_plus1 ||
            IP_out !== exp_ip ||
            imm_out !== exp_imm) begin
            
            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
        end else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask

    // Main stimulus
    initial begin
        $display("\n=== ID/EX PIPELINE REGISTER TESTBENCH ===\n");
        
        // Initialize
        flush = 1'b0;
        BType = 2'd0;
        MemToReg = 2'd0;
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        MemRead = 1'b0;
        UpdateFlags = 1'b0;
        RegDistidx = 2'd0;
        ALU_src = 1'b0;
        ALU_op = 4'd0;
        IO_Write = 1'b0;
        ra_val_in = 8'd0;
        rb_val_in = 8'd0;
        ra = 2'd0;
        rb = 2'd0;
        pc_plus1 = 8'd0;
        IP = 8'd0;
        imm = 8'd0;

        // Apply reset
        rst = 1'b0;
        @(posedge clk);
        check_all_outputs(2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 4'd0, 1'b0,
                         8'd0, 8'd0, 2'd0, 2'd0, 8'd0, 8'd0, 8'd0,
                         "After reset: all outputs cleared");

        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_all_outputs(2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 4'd0, 1'b0,
                         8'd0, 8'd0, 2'd0, 2'd0, 8'd0, 8'd0, 8'd0,
                         "After reset release (no propagation yet)");

        // Test 1: Normal write - all signals valid
        BType = 2'b01;
        MemToReg = 2'b10;
        RegWrite = 1'b1;
        MemWrite = 1'b0;
        MemRead = 1'b1;
        UpdateFlags = 1'b1;
        RegDistidx = 2'b10;
        ALU_src = 1'b0;
        ALU_op = 4'h3;
        IO_Write = 1'b0;
        ra_val_in = 8'h12;
        rb_val_in = 8'h34;
        ra = 2'b00;
        rb = 2'b01;
        pc_plus1 = 8'h05;
        IP = 8'h10;
        imm = 8'h42;
        @(posedge clk);
        check_all_outputs(2'b01, 2'b10, 1'b1, 1'b0, 1'b1, 1'b1, 2'b10, 1'b0, 4'h3, 1'b0,
                         8'h12, 8'h34, 2'b00, 2'b01, 8'h05, 8'h10, 8'h42,
                         "Normal write: all signals propagate");

        // Test 2: Boundary - all zeros
        BType = 2'd0;
        MemToReg = 2'd0;
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        MemRead = 1'b0;
        UpdateFlags = 1'b0;
        RegDistidx = 2'd0;
        ALU_src = 1'b0;
        ALU_op = 4'd0;
        IO_Write = 1'b0;
        ra_val_in = 8'd0;
        rb_val_in = 8'd0;
        ra = 2'd0;
        rb = 2'd0;
        pc_plus1 = 8'd0;
        IP = 8'd0;
        imm = 8'd0;
        @(posedge clk);
        check_all_outputs(2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 4'd0, 1'b0,
                         8'd0, 8'd0, 2'd0, 2'd0, 8'd0, 8'd0, 8'd0,
                         "Boundary: all zeros");

        // Test 3: Boundary - all ones
        BType = 2'b11;
        MemToReg = 2'b11;
        RegWrite = 1'b1;
        MemWrite = 1'b1;
        MemRead = 1'b1;
        UpdateFlags = 1'b1;
        RegDistidx = 2'b11;
        ALU_src = 1'b1;
        ALU_op = 4'hF;
        IO_Write = 1'b1;
        ra_val_in = 8'hFF;
        rb_val_in = 8'hFF;
        ra = 2'b11;
        rb = 2'b11;
        pc_plus1 = 8'hFF;
        IP = 8'hFF;
        imm = 8'hFF;
        @(posedge clk);
        check_all_outputs(2'b11, 2'b11, 1'b1, 1'b1, 1'b1, 1'b1, 2'b11, 1'b1, 4'hF, 1'b1,
                         8'hFF, 8'hFF, 2'b11, 2'b11, 8'hFF, 8'hFF, 8'hFF,
                         "Boundary: all ones");

        // Test 4: Flush - outputs should be NOP but pc_plus1 updates
        flush = 1'b1;
        BType = 2'b10;
        MemToReg = 2'b01;
        RegWrite = 1'b1;
        MemWrite = 1'b1;
        MemRead = 1'b1;
        UpdateFlags = 1'b1;
        RegDistidx = 2'b01;
        ALU_src = 1'b1;
        ALU_op = 4'h5;
        IO_Write = 1'b1;
        pc_plus1 = 8'h20;
        @(posedge clk);
        check_all_outputs(2'd0, 2'd0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 4'd0, 1'b0,
                         8'd0, 8'd0, 2'd0, 2'd0, 8'h20, 8'hFF, 8'hFF,
                         "Flush: control signals cleared, pc_plus1 updates");

        // Test 5: After flush - resume normal operation
        flush = 1'b0;
        BType = 2'b00;
        MemToReg = 2'b01;
        RegWrite = 1'b1;
        MemWrite = 1'b1;
        MemRead = 1'b1;
        UpdateFlags = 1'b1;
        RegDistidx = 2'b01;
        ALU_src = 1'b1;
        ALU_op = 4'h5;
        IO_Write = 1'b1;
        pc_plus1 = 8'h22;
        IP = 8'h25;
        imm = 8'h50;
        ra_val_in = 8'hAA;
        rb_val_in = 8'hBB;
        ra = 2'b11;
        rb = 2'b11;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b1, 1'b1, 1'b1, 2'b01, 1'b1, 4'h5, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Resume after flush");

        // Test 6: Memory Read operation
        MemRead = 1'b1;
        MemWrite = 1'b0;
        ALU_op = 4'h2;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b0, 1'b1, 1'b1, 2'b01, 1'b1, 4'h2, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Memory read operation");

        // Test 7: Memory Write operation
        MemRead = 1'b0;
        MemWrite = 1'b1;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b1, 1'b0, 1'b1, 2'b01, 1'b1, 4'h2, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Memory write operation");

        // Test 8: I/O Write operation
        MemRead = 1'b0;
        MemWrite = 1'b0;
        IO_Write = 1'b1;
        RegWrite = 1'b0;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b0, 1'b0, 1'b0, 1'b1, 2'b01, 1'b1, 4'h2, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "I/O write operation");

        // Test 9: ALU operations - different types
        ALU_op = 4'h0;  // NOP
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b0, 1'b0, 1'b0, 1'b1, 2'b01, 1'b1, 4'h0, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "ALU op: NOP (0x0)");

        // Test 10: ALU operation extended
        ALU_op = 4'hC;  // Other operation
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b0, 1'b0, 1'b0, 1'b1, 2'b01, 1'b1, 4'hC, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "ALU op: 0xC");

        // Test 11: Register destination variations - R0
        RegDistidx = 2'b00;
        RegWrite = 1'b1;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, 1'b1, 4'hC, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Register destination: R0");

        // Test 12: Register destination - R1
        RegDistidx = 2'b01;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 2'b01, 1'b1, 4'hC, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Register destination: R1");

        // Test 13: Register destination - R2
        RegDistidx = 2'b10;
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10, 1'b1, 4'hC, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Register destination: R2");

        // Test 14: Branch Type variations
        BType = 2'b00;  // No branch
        @(posedge clk);
        check_all_outputs(2'b00, 2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10, 1'b1, 4'hC, 1'b1,
                         8'hAA, 8'hBB, 2'b11, 2'b11, 8'h22, 8'h25, 8'h50,
                         "Branch Type: 00 (no branch)");

        // Test 15: Data pattern - alternating bits
        BType = 2'b10;
        ra_val_in = 8'hAA;
        rb_val_in = 8'h55;
        imm = 8'h33;
        @(posedge clk);
        check_all_outputs(2'b10, 2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10, 1'b1, 4'hC, 1'b1,
                         8'hAA, 8'h55, 2'b11, 2'b11, 8'h22, 8'h25, 8'h33,
                         "Data pattern: alternating bits");

        // Print summary
        $display("\n");
        $display("======================================");
        if (errors == 0) begin
            $display("  ALL %0d ID/EX REG TESTS PASSED", tests);
        end else begin
            $display("  ID/EX REG TESTBENCH FAILED");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
        end
        $display("======================================\n");
        
        $stop;
    end

endmodule
