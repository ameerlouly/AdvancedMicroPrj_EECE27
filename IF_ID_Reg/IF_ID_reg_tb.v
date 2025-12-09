`timescale 1ns/1ps

/*
 * IF_ID_reg_tb.v - Updated IF/ID Pipeline Register Testbench
 * 
 * Tests the updated IF/ID pipeline register with:
 * - pc_plus1: PC + 1 value
 * - instruction: 8-bit instruction
 * - IP: Instruction pointer / related data
 * - data_B: Secondary data path
 * 
 * Control signals:
 * - if_id_en: Enable pipeline update (write_en)
 * - flush: Insert NOP (instruction = 0x00)
 */

module IF_ID_reg_tb;

    // DUT signals
    reg         clk;
    reg         rst;              // active-low
    reg         if_id_en;         // pipeline enable
    reg         flush;
    reg  [7:0]  pc_plus1;
    reg  [7:0]  instruction;
    reg  [7:0]  IP;
    reg  [7:0]  data_B;
    
    wire [7:0]  pc_plus1_out;
    wire [7:0]  instr_out;
    wire [7:0]  IP_out;
    wire [7:0]  data_B_out;
    
    integer tests = 0;
    integer errors = 0;
    
    // Instantiate DUT
    IF_ID_reg dut (
        .clk         (clk),
        .rst         (rst),
        .if_id_en    (if_id_en),
        .flush       (flush),
        .pc_plus1    (pc_plus1),
        .instruction (instruction),
        .IP          (IP),
        .data_B      (data_B),
        .pc_plus1_out(pc_plus1_out),
        .instr_out   (instr_out),
        .IP_out      (IP_out),
        .data_B_out  (data_B_out)
    );
    
    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to check all outputs
    task check_ifid(
        input [7:0]  exp_pc_plus1,
        input [7:0]  exp_instr,
        input [7:0]  exp_ip,
        input [7:0]  exp_data_b,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1; // small delay after clock edge
        
        if (pc_plus1_out !== exp_pc_plus1 || 
            instr_out !== exp_instr || 
            IP_out !== exp_ip || 
            data_B_out !== exp_data_b) begin
            
            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  Expected: PC+1=%0h, INSTR=%0h, IP=%0h, DATA_B=%0h",
                     exp_pc_plus1, exp_instr, exp_ip, exp_data_b);
            $display("  Got     : PC+1=%0h, INSTR=%0h, IP=%0h, DATA_B=%0h",
                     pc_plus1_out, instr_out, IP_out, data_B_out);
        end else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask
    
    // Main stimulus
    initial begin
        $display("\n=== IF/ID PIPELINE REGISTER TESTBENCH (UPDATED) ===\n");
        
        // Initialize inputs
        if_id_en = 1'b0;
        flush = 1'b0;
        pc_plus1 = 8'd0;
        instruction = 8'd0;
        IP = 8'd0;
        data_B = 8'd0;
        
        // Apply reset
        rst = 1'b0;
        @(posedge clk);
        check_ifid(8'd0, 8'd0, 8'd0, 8'd0, 
                   "After reset: all outputs should be 0");
        
        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_ifid(8'd0, 8'd0, 8'd0, 8'd0, 
                   "After reset release (if_id_en=0): no change");
        
        // Test 1: Normal write (if_id_en=1, flush=0)
        pc_plus1 = 8'h01;
        instruction = 8'h10;
        IP = 8'h20;
        data_B = 8'h30;
        if_id_en = 1'b1;
        @(posedge clk);
        check_ifid(8'h01, 8'h10, 8'h20, 8'h30,
                   "Normal write: all signals propagate");
        
        // Test 2: Stall (if_id_en=0) - outputs hold
        if_id_en = 1'b0;
        pc_plus1 = 8'hAA;  // change inputs
        instruction = 8'hBB;
        IP = 8'hCC;
        data_B = 8'hDD;
        @(posedge clk);
        check_ifid(8'h01, 8'h10, 8'h20, 8'h30,
                   "Stall (if_id_en=0): outputs hold previous values");
        
        // Test 3: Another write after stall
        if_id_en = 1'b1;
        pc_plus1 = 8'h02;
        instruction = 8'h40;
        IP = 8'h50;
        data_B = 8'h60;
        @(posedge clk);
        check_ifid(8'h02, 8'h40, 8'h50, 8'h60,
                   "After stall: new values propagate");
        
        // Test 4: Flush (instruction becomes NOP, pc_plus1 updates)
        flush = 1'b1;
        if_id_en = 1'b1;
        pc_plus1 = 8'h03;
        instruction = 8'h70;  // will be replaced with NOP
        IP = 8'h80;           // should not change
        data_B = 8'h90;       // should not change
        @(posedge clk);
        check_ifid(8'h03, 8'h00, 8'h50, 8'h60,
                   "Flush: instruction=NOP(0x00), pc_plus1 updates, others hold");
        
        // Test 5: Normal operation after flush
        flush = 1'b0;
        if_id_en = 1'b1;
        pc_plus1 = 8'h04;
        instruction = 8'hA5;
        IP = 8'hB5;
        data_B = 8'hC5;
        @(posedge clk);
        check_ifid(8'h04, 8'hA5, 8'hB5, 8'hC5,
                   "After flush: normal operation resumes");
        
        // Test 6: Boundary - all zeros
        pc_plus1 = 8'h00;
        instruction = 8'h00;
        IP = 8'h00;
        data_B = 8'h00;
        if_id_en = 1'b1;
        @(posedge clk);
        check_ifid(8'h00, 8'h00, 8'h00, 8'h00,
                   "Boundary: all zeros");
        
        // Test 7: Boundary - all ones
        pc_plus1 = 8'hFF;
        instruction = 8'hFF;
        IP = 8'hFF;
        data_B = 8'hFF;
        @(posedge clk);
        check_ifid(8'hFF, 8'hFF, 8'hFF, 8'hFF,
                   "Boundary: all ones (0xFF)");
        
        // Test 8: Alternating bit patterns
        pc_plus1 = 8'hAA;  // 10101010
        instruction = 8'h55;  // 01010101
        IP = 8'hCC;  // 11001100
        data_B = 8'h33;  // 00110011
        @(posedge clk);
        check_ifid(8'hAA, 8'h55, 8'hCC, 8'h33,
                   "Alternating bit patterns");
        
        // Test 9: Flush during stall (flush has priority but stall holds others)
        if_id_en = 1'b0;
        flush = 1'b1;
        pc_plus1 = 8'h99;  // will update
        instruction = 8'h88;  // will become NOP
        IP = 8'h77;  // won't update (stall)
        data_B = 8'h66;  // won't update (stall)
        @(posedge clk);
        // Note: Based on module, flush sets instruction=0, pc_plus1 updates, others unchanged
        check_ifid(8'h99, 8'h00, 8'hCC, 8'h33,
                   "Flush during stall: instruction->NOP, pc_plus1 updates, IP/data_B hold");
        
        // Test 10: Sequential instruction stream
        flush = 1'b0;
        if_id_en = 1'b1;
        pc_plus1 = 8'h05;
        instruction = 8'h12;
        IP = 8'h10;
        data_B = 8'h00;
        @(posedge clk);
        check_ifid(8'h05, 8'h12, 8'h10, 8'h00,
                   "Instruction sequence 1");
        
        pc_plus1 = 8'h06;
        instruction = 8'h34;
        IP = 8'h12;
        data_B = 8'h01;
        @(posedge clk);
        check_ifid(8'h06, 8'h34, 8'h12, 8'h01,
                   "Instruction sequence 2");
        
        pc_plus1 = 8'h07;
        instruction = 8'h56;
        IP = 8'h14;
        data_B = 8'h02;
        @(posedge clk);
        check_ifid(8'h07, 8'h56, 8'h14, 8'h02,
                   "Instruction sequence 3");
        
        // Test 11: Multiple flushes
        flush = 1'b1;
        @(posedge clk);
        check_ifid(8'h07, 8'h00, 8'h14, 8'h02,
                   "First flush sequence");
        
        flush = 1'b0;
        instruction = 8'h78;
        @(posedge clk);
        check_ifid(8'h07, 8'h78, 8'h14, 8'h02,
                   "After flush: resume normal operation");
        
        // Test 12: Rapid stall-enable toggling
        if_id_en = 1'b0;
        instruction = 8'hFF;  // change (shouldn't propagate)
        @(posedge clk);
        check_ifid(8'h07, 8'h78, 8'h14, 8'h02,
                   "Toggle enable OFF: hold values");
        
        if_id_en = 1'b1;
        instruction = 8'hEE;
        @(posedge clk);
        check_ifid(8'h07, 8'hEE, 8'h14, 8'h02,
                   "Toggle enable ON: propagate new instruction");
        
        // Test 13: PC increment across range
        pc_plus1 = 8'h7F;  // mid-range
        @(posedge clk);
        check_ifid(8'h7F, 8'hEE, 8'h14, 8'h02,
                   "PC+1 mid-range: 0x7F");
        
        pc_plus1 = 8'h80;  // crosses half-way
        @(posedge clk);
        check_ifid(8'h80, 8'hEE, 8'h14, 8'h02,
                   "PC+1 crossing: 0x80");
        
        // Test 14: Data path integrity
        data_B = 8'h12;
        IP = 8'h34;
        instruction = 8'h56;
        @(posedge clk);
        check_ifid(8'h80, 8'h56, 8'h34, 8'h12,
                   "Data path integrity check");
        
        // Test 15: Flush doesn't clear PC+1 (it propagates)
        pc_plus1 = 8'h88;
        instruction = 8'h99;
        flush = 1'b1;
        @(posedge clk);
        check_ifid(8'h88, 8'h00, 8'h34, 8'h12,
                   "Flush: PC+1 still updates (0x88), instruction->NOP");
        
        // Print summary
        $display("\n");
        $display("======================================");
        if (errors == 0) begin
            $display("  ALL %0d IF/ID REG TESTS PASSED ", tests);
        end else begin
            $display("  IF/ID REG TESTBENCH FAILED");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
        end
        $display("======================================\n");
        
        $stop;
    end

endmodule
