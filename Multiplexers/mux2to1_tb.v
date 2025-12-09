`timescale 1ns/1ps

/*
 * mux2to1_tb.v - 2-to-1 Multiplexer Testbench
 * 
 * Tests a parameterizable 2-to-1 multiplexer that selects between
 * two inputs (A and B) based on a select signal.
 * 
 * Selection:
 *   sel = 0 : output = A
 *   sel = 1 : output = B
 */

module mux2to1_tb;

    parameter OPERAND_SIZE = 8;
    
    // DUT Signals
    reg  [OPERAND_SIZE-1:0] A;
    reg  [OPERAND_SIZE-1:0] B;
    reg                     sel;
    wire [OPERAND_SIZE-1:0] mux_out;
    
    integer tests = 0;
    integer errors = 0;
    
    // Instantiate DUT
    mux2to1 #(.OPERAND_SIZE(OPERAND_SIZE)) dut (
        .A       (A),
        .B       (B),
        .sel     (sel),
        .mux_out (mux_out)
    );
    
    // Task to verify mux output
    task check_mux(
        input [OPERAND_SIZE-1:0] exp_out,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1;
        
        if (mux_out !== exp_out) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  A=%h, B=%h, sel=%b", A, B, sel);
            $display("  Expected output: %h, Got: %h", exp_out, mux_out);
        end else begin
            $display("TEST %0d PASSED: %s | Output=%h", tests, msg, mux_out);
        end
    end
    endtask
    
    // Main stimulus
    initial begin
        $display("\n=== MUX2TO1 (2-to-1 Multiplexer) TESTBENCH ===\n");
        
        // ====================================================================
        // TEST GROUP 1: Basic Selection (sel=0 → output=A)
        // ====================================================================
        $display("--- Test Group 1: sel=0 (Select A) ---");
        
        // Test 1.1: Simple values
        A = 8'h12;
        B = 8'h34;
        sel = 1'b0;
        check_mux(8'h12, "sel=0: Should output A (0x12)");
        
        // Test 1.2: Different values
        A = 8'hAB;
        B = 8'hCD;
        sel = 1'b0;
        check_mux(8'hAB, "sel=0: Should output A (0xAB)");
        
        // Test 1.3: All zeros
        A = 8'h00;
        B = 8'hFF;
        sel = 1'b0;
        check_mux(8'h00, "sel=0: A=0x00, B=0xFF, output A");
        
        // Test 1.4: All ones
        A = 8'hFF;
        B = 8'h00;
        sel = 1'b0;
        check_mux(8'hFF, "sel=0: A=0xFF, B=0x00, output A");
        
        // ====================================================================
        // TEST GROUP 2: Basic Selection (sel=1 → output=B)
        // ====================================================================
        $display("\n--- Test Group 2: sel=1 (Select B) ---");
        
        // Test 2.1: Simple values
        A = 8'h12;
        B = 8'h34;
        sel = 1'b1;
        check_mux(8'h34, "sel=1: Should output B (0x34)");
        
        // Test 2.2: Different values
        A = 8'hAB;
        B = 8'hCD;
        sel = 1'b1;
        check_mux(8'hCD, "sel=1: Should output B (0xCD)");
        
        // Test 2.3: All zeros
        A = 8'h00;
        B = 8'hFF;
        sel = 1'b1;
        check_mux(8'hFF, "sel=1: A=0x00, B=0xFF, output B");
        
        // Test 2.4: All ones
        A = 8'hFF;
        B = 8'h00;
        sel = 1'b1;
        check_mux(8'h00, "sel=1: A=0xFF, B=0x00, output B");
        
        // ====================================================================
        // TEST GROUP 3: Edge Cases
        // ====================================================================
        $display("\n--- Test Group 3: Edge Cases ---");
        
        // Test 3.1: Same value on both inputs, sel=0
        A = 8'h55;
        B = 8'h55;
        sel = 1'b0;
        check_mux(8'h55, "Same inputs: A=B=0x55, sel=0");
        
        // Test 3.2: Same value on both inputs, sel=1
        A = 8'h55;
        B = 8'h55;
        sel = 1'b1;
        check_mux(8'h55, "Same inputs: A=B=0x55, sel=1");
        
        // Test 3.3: Alternating bit pattern sel=0
        A = 8'b10101010;
        B = 8'b01010101;
        sel = 1'b0;
        check_mux(8'b10101010, "Alternating bits: select A");
        
        // Test 3.4: Alternating bit pattern sel=1
        A = 8'b10101010;
        B = 8'b01010101;
        sel = 1'b1;
        check_mux(8'b01010101, "Alternating bits: select B");
        
        // Test 3.5: Single bit set A, sel=0
        A = 8'b00000001;
        B = 8'b10000000;
        sel = 1'b0;
        check_mux(8'b00000001, "Single bit A: LSB=1, select A");
        
        // Test 3.6: Single bit set B, sel=1
        A = 8'b00000001;
        B = 8'b10000000;
        sel = 1'b1;
        check_mux(8'b10000000, "Single bit B: MSB=1, select B");
        
        // ====================================================================
        // TEST GROUP 4: Boundary Values
        // ====================================================================
        $display("\n--- Test Group 4: Boundary Values ---");
        
        // Test 4.1: Min value (0x00) selected via sel=0
        A = 8'h00;
        B = 8'hFF;
        sel = 1'b0;
        check_mux(8'h00, "Min value: A=0x00, sel=0");
        
        // Test 4.2: Max value (0xFF) selected via sel=0
        A = 8'hFF;
        B = 8'h00;
        sel = 1'b0;
        check_mux(8'hFF, "Max value: A=0xFF, sel=0");
        
        // Test 4.3: Min value (0x00) selected via sel=1
        A = 8'hFF;
        B = 8'h00;
        sel = 1'b1;
        check_mux(8'h00, "Min value: B=0x00, sel=1");
        
        // Test 4.4: Max value (0xFF) selected via sel=1
        A = 8'h00;
        B = 8'hFF;
        sel = 1'b1;
        check_mux(8'hFF, "Max value: B=0xFF, sel=1");
        
        // ====================================================================
        // TEST GROUP 5: Sequential Changes
        // ====================================================================
        $display("\n--- Test Group 5: Sequential Changes ---");
        
        // Test 5.1: Toggle sel with fixed inputs
        A = 8'hAA;
        B = 8'h55;
        sel = 1'b0;
        check_mux(8'hAA, "Toggle sel: sel=0, output A");
        
        sel = 1'b1;
        check_mux(8'h55, "Toggle sel: sel=1, output B");
        
        sel = 1'b0;
        check_mux(8'hAA, "Toggle sel: sel=0 again, output A");
        
        // Test 5.2: Change A while sel selects A
        A = 8'h11;
        B = 8'h22;
        sel = 1'b0;
        check_mux(8'h11, "Change A: A=0x11, sel=0");
        
        A = 8'h33;
        check_mux(8'h33, "Change A: A=0x33, sel=0 (output changes)");
        
        // Test 5.3: Change B while sel selects B
        A = 8'h44;
        B = 8'h55;
        sel = 1'b1;
        check_mux(8'h55, "Change B: B=0x55, sel=1");
        
        B = 8'h66;
        check_mux(8'h66, "Change B: B=0x66, sel=1 (output changes)");
        
        // Print summary
        $display("\n");
        $display("======================================");
        if (errors == 0) begin
            $display("  ALL %0d MUX2TO1 TESTS PASSED", tests);
        end else begin
            $display("  MUX2TO1 TESTBENCH FAILED");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
        end
        $display("======================================\n");
        
        $stop;
    end

endmodule
