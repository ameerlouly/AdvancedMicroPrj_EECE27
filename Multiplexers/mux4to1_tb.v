`timescale 1ns/1ps

/*
 * mux4to1_tb.v - 4-to-1 Multiplexer Testbench
 * 
 * Tests a parameterizable 4-to-1 multiplexer that selects between
 * four inputs (A, B, C, D) based on a 2-bit select signal.
 * 
 * Selection:
 *   sel = 2'b00 : output = A
 *   sel = 2'b01 : output = B
 *   sel = 2'b10 : output = C
 *   sel = 2'b11 : output = D
 */

module mux4to1_tb;

    parameter OPERAND_SIZE = 8;
    
    // DUT Signals
    reg  [OPERAND_SIZE-1:0] A;
    reg  [OPERAND_SIZE-1:0] B;
    reg  [OPERAND_SIZE-1:0] C;
    reg  [OPERAND_SIZE-1:0] D;
    reg  [1:0]              sel;
    wire [OPERAND_SIZE-1:0] mux_out;
    
    integer tests = 0;
    integer errors = 0;
    
    // Instantiate DUT
    mux4to1 #(.OPERAND_SIZE(OPERAND_SIZE)) dut (
        .A       (A),
        .B       (B),
        .C       (C),
        .D       (D),
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
            $display("  A=%h, B=%h, C=%h, D=%h, sel=%b", A, B, C, D, sel);
            $display("  Expected output: %h, Got: %h", exp_out, mux_out);
        end else begin
            $display("TEST %0d PASSED: %s | Output=%h", tests, msg, mux_out);
        end
    end
    endtask
    
    // Main stimulus
    initial begin
        $display("\n=== MUX4TO1 (4-to-1 Multiplexer) TESTBENCH ===\n");
        
        // ====================================================================
        // TEST GROUP 1: Select Each Input (Positive Selection)
        // ====================================================================
        $display("--- Test Group 1: Select Each Input ---");
        
        // Test 1.1: Select A (sel=2'b00)
        A = 8'h11;
        B = 8'h22;
        C = 8'h33;
        D = 8'h44;
        sel = 2'b00;
        check_mux(8'h11, "sel=00: Should output A (0x11)");
        
        // Test 1.2: Select B (sel=2'b01)
        sel = 2'b01;
        check_mux(8'h22, "sel=01: Should output B (0x22)");
        
        // Test 1.3: Select C (sel=2'b10)
        sel = 2'b10;
        check_mux(8'h33, "sel=10: Should output C (0x33)");
        
        // Test 1.4: Select D (sel=2'b11)
        sel = 2'b11;
        check_mux(8'h44, "sel=11: Should output D (0x44)");
        
        // ====================================================================
        // TEST GROUP 2: All Zeros Input
        // ====================================================================
        $display("\n--- Test Group 2: All Zeros Input ---");
        
        A = 8'h00;
        B = 8'h00;
        C = 8'h00;
        D = 8'h00;
        
        // Test 2.1: Select A
        sel = 2'b00;
        check_mux(8'h00, "All zeros: sel=00, output=0x00");
        
        // Test 2.2: Select B
        sel = 2'b01;
        check_mux(8'h00, "All zeros: sel=01, output=0x00");
        
        // Test 2.3: Select C
        sel = 2'b10;
        check_mux(8'h00, "All zeros: sel=10, output=0x00");
        
        // Test 2.4: Select D
        sel = 2'b11;
        check_mux(8'h00, "All zeros: sel=11, output=0x00");
        
        // ====================================================================
        // TEST GROUP 3: All Ones Input
        // ====================================================================
        $display("\n--- Test Group 3: All Ones Input ---");
        
        A = 8'hFF;
        B = 8'hFF;
        C = 8'hFF;
        D = 8'hFF;
        
        // Test 3.1: Select A
        sel = 2'b00;
        check_mux(8'hFF, "All ones: sel=00, output=0xFF");
        
        // Test 3.2: Select B
        sel = 2'b01;
        check_mux(8'hFF, "All ones: sel=01, output=0xFF");
        
        // Test 3.3: Select C
        sel = 2'b10;
        check_mux(8'hFF, "All ones: sel=10, output=0xFF");
        
        // Test 3.4: Select D
        sel = 2'b11;
        check_mux(8'hFF, "All ones: sel=11, output=0xFF");
        
        // ====================================================================
        // TEST GROUP 4: Distinct Values - Comprehensive
        // ====================================================================
        $display("\n--- Test Group 4: Distinct Values ---");
        
        A = 8'hAA;
        B = 8'hBB;
        C = 8'hCC;
        D = 8'hDD;
        
        // Test 4.1: Select each input sequentially
        sel = 2'b00;
        check_mux(8'hAA, "Distinct: sel=00, output A=0xAA");
        
        sel = 2'b01;
        check_mux(8'hBB, "Distinct: sel=01, output B=0xBB");
        
        sel = 2'b10;
        check_mux(8'hCC, "Distinct: sel=10, output C=0xCC");
        
        sel = 2'b11;
        check_mux(8'hDD, "Distinct: sel=11, output D=0xDD");
        
        // ====================================================================
        // TEST GROUP 5: Bit Patterns
        // ====================================================================
        $display("\n--- Test Group 5: Bit Patterns ---");
        
        A = 8'b10101010;
        B = 8'b01010101;
        C = 8'b11110000;
        D = 8'b00001111;
        
        // Test 5.1: Alternating pattern A
        sel = 2'b00;
        check_mux(8'b10101010, "Alternating A: sel=00");
        
        // Test 5.2: Alternating pattern B (inverted)
        sel = 2'b01;
        check_mux(8'b01010101, "Alternating B (inverted): sel=01");
        
        // Test 5.3: Upper nibble pattern C
        sel = 2'b10;
        check_mux(8'b11110000, "Upper nibble C: sel=10");
        
        // Test 5.4: Lower nibble pattern D
        sel = 2'b11;
        check_mux(8'b00001111, "Lower nibble D: sel=11");
        
        // ====================================================================
        // TEST GROUP 6: Edge Cases
        // ====================================================================
        $display("\n--- Test Group 6: Edge Cases ---");
        
        // Test 6.1: Single bit set in each position
        A = 8'b00000001;
        B = 8'b00000010;
        C = 8'b00000100;
        D = 8'b00001000;
        
        sel = 2'b00;
        check_mux(8'b00000001, "Single bit LSB (A): sel=00");
        
        sel = 2'b01;
        check_mux(8'b00000010, "Single bit bit1 (B): sel=01");
        
        sel = 2'b10;
        check_mux(8'b00000100, "Single bit bit2 (C): sel=10");
        
        sel = 2'b11;
        check_mux(8'b00001000, "Single bit bit3 (D): sel=11");
        
        // Test 6.2: Single bit set in MSB
        A = 8'b10000000;
        B = 8'b01000000;
        C = 8'b00100000;
        D = 8'b00010000;
        
        sel = 2'b00;
        check_mux(8'b10000000, "Single bit MSB (A): sel=00");
        
        sel = 2'b01;
        check_mux(8'b01000000, "Single bit bit6 (B): sel=01");
        
        sel = 2'b10;
        check_mux(8'b00100000, "Single bit bit5 (C): sel=10");
        
        sel = 2'b11;
        check_mux(8'b00010000, "Single bit bit4 (D): sel=11");
        
        // ====================================================================
        // TEST GROUP 7: Same Input Multiple Times
        // ====================================================================
        $display("\n--- Test Group 7: Same Value Multiple Times ---");
        
        // Test 7.1: All inputs same value
        A = 8'h77;
        B = 8'h77;
        C = 8'h77;
        D = 8'h77;
        
        sel = 2'b00;
        check_mux(8'h77, "All same (A): sel=00");
        
        sel = 2'b01;
        check_mux(8'h77, "All same (B): sel=01");
        
        sel = 2'b10;
        check_mux(8'h77, "All same (C): sel=10");
        
        sel = 2'b11;
        check_mux(8'h77, "All same (D): sel=11");
        
        // Test 7.2: First two same
        A = 8'h55;
        B = 8'h55;
        C = 8'hAA;
        D = 8'hBB;
        
        sel = 2'b00;
        check_mux(8'h55, "A=B: sel=00, output 0x55");
        
        sel = 2'b01;
        check_mux(8'h55, "A=B: sel=01, output 0x55");
        
        // ====================================================================
        // TEST GROUP 8: Min/Max Boundary Values
        // ====================================================================
        $display("\n--- Test Group 8: Boundary Values ---");
        
        A = 8'h00;
        B = 8'h01;
        C = 8'hFE;
        D = 8'hFF;
        
        sel = 2'b00;
        check_mux(8'h00, "Min (A=0x00): sel=00");
        
        sel = 2'b01;
        check_mux(8'h01, "Near-min (B=0x01): sel=01");
        
        sel = 2'b10;
        check_mux(8'hFE, "Near-max (C=0xFE): sel=10");
        
        sel = 2'b11;
        check_mux(8'hFF, "Max (D=0xFF): sel=11");
        
        // ====================================================================
        // TEST GROUP 9: Sequential Multiplexing
        // ====================================================================
        $display("\n--- Test Group 9: Sequential Selection ---");
        
        A = 8'h10;
        B = 8'h20;
        C = 8'h30;
        D = 8'h40;
        
        // Test 9.1: Cycle through all inputs
        sel = 2'b00;
        check_mux(8'h10, "Sequential: sel=00");
        
        sel = 2'b01;
        check_mux(8'h20, "Sequential: sel=01");
        
        sel = 2'b10;
        check_mux(8'h30, "Sequential: sel=10");
        
        sel = 2'b11;
        check_mux(8'h40, "Sequential: sel=11");
        
        // Test 9.2: Reverse order
        sel = 2'b11;
        check_mux(8'h40, "Reverse: sel=11");
        
        sel = 2'b10;
        check_mux(8'h30, "Reverse: sel=10");
        
        sel = 2'b01;
        check_mux(8'h20, "Reverse: sel=01");
        
        sel = 2'b00;
        check_mux(8'h10, "Reverse: sel=00");
        
        // ====================================================================
        // TEST GROUP 10: Input Changes with Fixed Select
        // ====================================================================
        $display("\n--- Test Group 10: Dynamic Input Changes ---");
        
        // Test 10.1: Change A while selecting A
        sel = 2'b00;
        A = 8'h11;
        check_mux(8'h11, "Change A: A=0x11, sel=00");
        
        A = 8'h22;
        check_mux(8'h22, "Change A: A=0x22, sel=00 (output changes)");
        
        // Test 10.2: Change B while selecting B
        sel = 2'b01;
        B = 8'h33;
        check_mux(8'h33, "Change B: B=0x33, sel=01");
        
        B = 8'h44;
        check_mux(8'h44, "Change B: B=0x44, sel=01 (output changes)");
        
        // Test 10.3: Change C while selecting C
        sel = 2'b10;
        C = 8'h55;
        check_mux(8'h55, "Change C: C=0x55, sel=10");
        
        C = 8'h66;
        check_mux(8'h66, "Change C: C=0x66, sel=10 (output changes)");
        
        // Test 10.4: Change D while selecting D
        sel = 2'b11;
        D = 8'h77;
        check_mux(8'h77, "Change D: D=0x77, sel=11");
        
        D = 8'h88;
        check_mux(8'h88, "Change D: D=0x88, sel=11 (output changes)");
        
        // Print summary
        $display("\n");
        $display("======================================");
        if (errors == 0) begin
            $display("  ALL %0d MUX4TO1 TESTS PASSED", tests);
        end else begin
            $display("  MUX4TO1 TESTBENCH FAILED");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
        end
        $display("======================================\n");
        
        $stop;
    end

endmodule
