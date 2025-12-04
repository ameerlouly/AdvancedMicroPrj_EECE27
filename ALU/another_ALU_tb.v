`timescale 1ns / 1ps

module ALU_tb;
    // Inputs
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] sel;
    reg cin;
    
    // Outputs
    wire [7:0] out;
    wire Z, N, C, V;
    
    // Instantiate the ALU
    ALU uut (
        .A(A),
        .B(B),
        .sel(sel),
        .cin(cin),
        .out(out),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );
    
    // Test counter
    integer test_num = 0;
    integer errors = 0;
    
    // Task to display results
    task display_result;
        input [7:0] expected_out;
        input expected_Z, expected_N, expected_C, expected_V;
        input [200:0] test_name;
        begin
            test_num = test_num + 1;
            #10; // Wait for combinational logic to settle
            
            if (out != expected_out || Z != expected_Z || N != expected_N || 
                C != expected_C || V != expected_V) begin
                $display("TEST %0d FAILED: %s", test_num, test_name);
                $display("  A=%h, B=%h, sel=%b, cin=%b", A, B, sel, cin);
                $display("  Expected: out=%h Z=%b N=%b C=%b V=%b", 
                         expected_out, expected_Z, expected_N, expected_C, expected_V);
                $display("  Got:      out=%h Z=%b N=%b C=%b V=%b", out, Z, N, C, V);
                errors = errors + 1;
            end else begin
                $display("TEST %0d PASSED: %s", test_num, test_name);
            end
        end
    endtask
    
    initial begin
        $display("Starting ALU Testbench");
        $display("======================\n");
        
        // Initialize inputs
        A = 0; B = 0; sel = 0; cin = 0;
        #20;
        
        // Test ALU_PASS (0001)
        $display("\n--- Testing ALU_PASS ---");
        sel = 4'b0001; A = 8'h55; B = 8'h42;
        display_result(8'h42, 1'bx, 1'bx, 1'bx, 1'bx, "PASS operation");
        
        // Test ALU_ADD (0010)
        $display("\n--- Testing ALU_ADD ---");
        sel = 4'b0010; A = 8'h10; B = 8'h20; cin = 0;
        display_result(8'h30, 1'b0, 1'b0, 1'b0, 1'b0, "ADD: 0x10 + 0x20 = 0x30");
        
        A = 8'hFF; B = 8'h01;
        display_result(8'h00, 1'b1, 1'b0, 1'b1, 1'b0, "ADD: 0xFF + 0x01 = 0x00 (carry)");
        
        A = 8'h7F; B = 8'h01;
        display_result(8'h80, 1'b0, 1'b1, 1'b0, 1'b1, "ADD: 0x7F + 0x01 = 0x80 (overflow)");
        
        A = 8'h80; B = 8'h80;
        display_result(8'h00, 1'b1, 1'b0, 1'b1, 1'b1, "ADD: 0x80 + 0x80 (carry & overflow)");
        
        // Test ALU_SUB (0011)
        $display("\n--- Testing ALU_SUB ---");
        sel = 4'b0011; A = 8'h50; B = 8'h30;
        display_result(8'h20, 1'b0, 1'b0, 1'b0, 1'b0, "SUB: 0x50 - 0x30 = 0x20");
        
        A = 8'h30; B = 8'h50;
        display_result(8'hE0, 1'b0, 1'b1, 1'b1, 1'b0, "SUB: 0x30 - 0x50 = 0xE0 (borrow)");
        
        A = 8'h80; B = 8'h01;
        display_result(8'h7F, 1'b0, 1'b0, 1'b0, 1'b1, "SUB: 0x80 - 0x01 = 0x7F (overflow)");
        
        A = 8'h00; B = 8'h00;
        display_result(8'h00, 1'b1, 1'b0, 1'b0, 1'b0, "SUB: 0x00 - 0x00 = 0x00 (zero)");
        
        // Test ALU_AND (0100)
        $display("\n--- Testing ALU_AND ---");
        sel = 4'b0100; A = 8'hF0; B = 8'h0F;
        display_result(8'h00, 1'b1, 1'b0, 1'bx, 1'bx, "AND: 0xF0 & 0x0F = 0x00");
        
        A = 8'hFF; B = 8'h55;
        display_result(8'h55, 1'b0, 1'b0, 1'bx, 1'bx, "AND: 0xFF & 0x55 = 0x55");
        
        A = 8'hAA; B = 8'hFF;
        display_result(8'hAA, 1'b0, 1'b1, 1'bx, 1'bx, "AND: 0xAA & 0xFF = 0xAA (negative)");
        
        // Test ALU_OR (0101)
        $display("\n--- Testing ALU_OR ---");
        sel = 4'b0101; A = 8'hF0; B = 8'h0F;
        display_result(8'hFF, 1'b0, 1'b1, 1'bx, 1'bx, "OR: 0xF0 | 0x0F = 0xFF");
        
        A = 8'h00; B = 8'h00;
        display_result(8'h00, 1'b1, 1'b0, 1'bx, 1'bx, "OR: 0x00 | 0x00 = 0x00");
        
        // Test ALU_RLC (0110) - Rotate Left through Carry
        $display("\n--- Testing ALU_RLC ---");
        sel = 4'b0110; B = 8'b10101010; cin = 1'b0;
        display_result(8'b01010100, 1'bx, 1'bx, 1'b1, 1'bx, "RLC: rotate 0xAA left with cin=0");
        
        B = 8'b01010101; cin = 1'b1;
        display_result(8'b10101011, 1'bx, 1'bx, 1'b0, 1'bx, "RLC: rotate 0x55 left with cin=1");
        
        // Test ALU_RRC (0111) - Rotate Right through Carry
        $display("\n--- Testing ALU_RRC ---");
        sel = 4'b0111; B = 8'b10101010; cin = 1'b0;
        display_result(8'b01010101, 1'bx, 1'bx, 1'b0, 1'bx, "RRC: rotate 0xAA right with cin=0");
        
        B = 8'b10101011; cin = 1'b1;
        display_result(8'b11010101, 1'bx, 1'bx, 1'b1, 1'bx, "RRC: rotate 0xAB right with cin=1");
        
        // Test ALU_SETC (1000)
        $display("\n--- Testing ALU_SETC ---");
        sel = 4'b1000; A = 8'h00; B = 8'h00;
        display_result(8'hxx, 1'bx, 1'bx, 1'b1, 1'bx, "SETC: set carry flag");
        
        // Test ALU_CLRC (1001)
        $display("\n--- Testing ALU_CLRC ---");
        sel = 4'b1001; A = 8'h00; B = 8'h00;
        display_result(8'hxx, 1'bx, 1'bx, 1'b0, 1'bx, "CLRC: clear carry flag");
        
        // Test ALU_NOT (1010)
        $display("\n--- Testing ALU_NOT ---");
        sel = 4'b1010; B = 8'h0F;
        display_result(8'hF0, 1'b0, 1'b1, 1'bx, 1'bx, "NOT: ~0x0F = 0xF0");
        
        B = 8'hFF;
        display_result(8'h00, 1'b1, 1'b0, 1'bx, 1'bx, "NOT: ~0xFF = 0x00");
        
        // Test ALU_NEG (1011)
        $display("\n--- Testing ALU_NEG ---");
        sel = 4'b1011; B = 8'h05;
        display_result(8'hFB, 1'b0, 1'b1, 1'bx, 1'bx, "NEG: -0x05 = 0xFB");
        
        B = 8'h00;
        display_result(8'h00, 1'b1, 1'b0, 1'bx, 1'bx, "NEG: -0x00 = 0x00");
        
        B = 8'h80;
        display_result(8'h80, 1'b0, 1'b1, 1'bx, 1'bx, "NEG: -0x80 = 0x80 (overflow case)");
        
        // Test ALU_INC (1100)
        $display("\n--- Testing ALU_INC ---");
        sel = 4'b1100; B = 8'h42;
        display_result(8'h43, 1'b0, 1'b0, 1'b0, 1'b0, "INC: 0x42 + 1 = 0x43");
        
        B = 8'hFF;
        display_result(8'h00, 1'b1, 1'b0, 1'b1, 1'b0, "INC: 0xFF + 1 = 0x00 (carry)");
        
        B = 8'h7F;
        display_result(8'h80, 1'b0, 1'b1, 1'b0, 1'b1, "INC: 0x7F + 1 = 0x80 (overflow)");
        
        // Test ALU_DEC (1101)
        $display("\n--- Testing ALU_DEC ---");
        sel = 4'b1101; B = 8'h42;
        display_result(8'h41, 1'b0, 1'b0, 1'b0, 1'b0, "DEC: 0x42 - 1 = 0x41");
        
        B = 8'h00;
        display_result(8'hFF, 1'b0, 1'b1, 1'b1, 1'b0, "DEC: 0x00 - 1 = 0xFF (borrow)");
        
        B = 8'h80;
        display_result(8'h7F, 1'b0, 1'b0, 1'b0, 1'b1, "DEC: 0x80 - 1 = 0x7F (overflow)");
        
        B = 8'h01;
        display_result(8'h00, 1'b1, 1'b0, 1'b0, 1'b0, "DEC: 0x01 - 1 = 0x00 (zero)");
        
        // Test ALU_NOP (0000)
        $display("\n--- Testing ALU_NOP ---");
        sel = 4'b0000; A = 8'hAA; B = 8'hBB;
        display_result(8'hxx, 1'bx, 1'bx, 1'bx, 1'bx, "NOP: no operation");
        
        // Summary
        #20;
        $display("\n======================");
        $display("Test Summary:");
        $display("  Total tests: %0d", test_num);
        $display("  Errors: %0d", errors);
        if (errors == 0)
            $display("  ALL TESTS PASSED!");
        else
            $display("  SOME TESTS FAILED!");
        $display("======================\n");
        
        $finish;
    end
    
endmodule
