`timescale 1ns/1ps

module ALU_tb;
    parameter Width = 8;
    reg  [Width-1:0] A, B;
    reg  [3:0]       OpCode;
    reg  [1:0]       ra;
    wire [Width-1:0] Out;
    wire             C, Z, N, V;

    // Instantiate the user's ALU (assumes the ALU module is in scope)
    ALU #( .Width(Width) ) uut (
        .A(A), .B(B), .OpCode(OpCode), .ra(ra),
        .Out(Out), .C(C), .Z(Z), .N(N), .V(V)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    // helper registers for expected values
    reg [Width-1:0] expOut;
    reg             expC, expZ, expN, expV;
    reg [Width:0]   wide_result;
    wire signed [Width-1:0] sA = $signed(A);
    wire signed [Width-1:0] sB = $signed(B);
    wire signed [Width-1:0] sOut;

    // compute signed view of expOut when needed
    assign sOut = $signed(expOut);

    task do_check(input [127:0] testname);
        begin
            // small delay to allow combinational to settle
            #1;
            if ( (Out === expOut) && (C === expC) && (Z === expZ) && (N === expN) && (V === expV) ) begin
                $display("%0t ns: %s => TEST PASSED | A=%0d B=%0d Op=%b ra=%b Out=%h C=%b Z=%b N=%b V=%b",
                         $time, testname, $signed(A), $signed(B), OpCode, ra, Out, C, Z, N, V);
                pass_count = pass_count + 1;
            end else begin
                $display("%0t ns: %s => TEST FAILED", $time, testname);
                $display("   Got:  Out=%h C=%b Z=%b N=%b V=%b", Out, C, Z, N, V);
                $display("   Exp:  Out=%h C=%b Z=%b N=%b V=%b", expOut, expC, expZ, expN, expV);
                $display("   A=%h B=%h Op=%b ra=%b", A, B, OpCode, ra);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        // waveform
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);

        // ---------- TESTS ----------
        // 1) ADD (opcode 0010)
        OpCode = 4'b0010;
        // test vectors for add
        A = 8'd10; B = 8'd20;  // simple add
        // expected
        wide_result = {1'b0, A} + {1'b0, B};
        expOut = wide_result[Width-1:0];
        expC   = wide_result[Width];
        expZ   = (expOut == 0);
        expN   = expOut[Width-1];
        // signed overflow: (A_pos & B_pos & Out_neg) | (A_neg & B_neg & Out_pos)
        expV   = ( ($signed(A) >= 0) && ($signed(B) >= 0) && ($signed(expOut) < 0) ) ||
                 ( ($signed(A) < 0) && ($signed(B) < 0) && ($signed(expOut) >= 0) );
        do_check("ADD simple");

        // add causing carry and maybe overflow
        A = 8'd200; B = 8'd100; // 200+100 = 300 -> 44, carry=1
        wide_result = {1'b0, A} + {1'b0, B};
        expOut = wide_result[Width-1:0];
        expC   = wide_result[Width];
        expZ   = (expOut == 0);
        expN   = expOut[Width-1];
        expV   = ( ($signed(A) >= 0) && ($signed(B) >= 0) && ($signed(expOut) < 0) ) ||
                 ( ($signed(A) < 0) && ($signed(B) < 0) && ($signed(expOut) >= 0) );
        do_check("ADD carry/overflow");

        // 2) SUB (opcode 0011)
        OpCode = 4'b0011;
        A = 8'd50; B = 8'd20; // 30
        wide_result = {1'b0, A} - {1'b0, B};
        expOut = wide_result[Width-1:0];
        // C used in original as result of {C,Out} = A - B; but original code used that concatenation.
        // Many implementations interpret C as borrow flag (A < B). We'll compute borrow = (A < B).
        expC = (A < B) ? 1'b1 : 1'b0;
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        // overflow for subtraction: (A_sign & ~B_sign & ~Out_sign) | (~A_sign & B_sign & Out_sign)
        expV = ( ($signed(A) < 0) && ($signed(B) >= 0) && ($signed(expOut) >= 0) ) ||
               ( ($signed(A) >= 0) && ($signed(B) < 0) && ($signed(expOut) < 0) );
        do_check("SUB simple");

        A = 8'd0; B = 8'd1; // borrow case
        wide_result = {1'b0, A} - {1'b0, B};
        expOut = wide_result[Width-1:0];
        expC = (A < B) ? 1'b1 : 1'b0;
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        expV = ( ($signed(A) < 0) && ($signed(B) >= 0) && ($signed(expOut) >= 0) ) ||
               ( ($signed(A) >= 0) && ($signed(B) < 0) && ($signed(expOut) < 0) );
        do_check("SUB borrow");

        // 3) AND (0100)
        OpCode = 4'b0100;
        A = 8'hF0; B = 8'h0F; // 0xF0 & 0x0F = 0x00
        expOut = A & B;
        expC = 1'b0;
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        expV = 1'b0;
        do_check("AND zero");

        A = 8'hA5; B = 8'hFF; // not zero
        expOut = A & B;
        expC = 1'b0;
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        expV = 1'b0;
        do_check("AND nonzero");

        // 4) OR (0101)
        OpCode = 4'b0101;
        A = 8'h00; B = 8'h00;
        expOut = A | B;
        expC = 1'b0; expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("OR zero");

        A = 8'h12; B = 8'h34;
        expOut = A | B; expC = 1'b0; expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("OR nonzero");

        // 5) RLC/RRC/SETC/CLRC (0110)
        OpCode = 4'b0110;
        // RLC: ra = 0 (rotate left through carry as coded originally using B[7] etc.)
        ra = 2'b00;
        B  = 8'b1001_0110; // example
        // original code uses B and C; initial C assumed 0 (we set A too but code uses B and C)
        // The original ALU code uses temp=C then C=B[7], Out[7:1]=B[6:0], Out[0]=C;
        // So expected:
        expC = B[7];
        expOut = {B[6:0], expC};
        expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("RLC");

        // RRC: ra = 1
        ra = 2'b01;
        B  = 8'b0110_1001;
        expC = B[0];
        expOut = {expC, B[7:1]};
        expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("RRC");

        // SETC: ra = 2
        ra = 2'b10;
        B  = 8'h55;
        expC = 1'b1; expOut = A; // original only sets C=1
        expOut = A; // ALU leaves Out maybe unchanged (original code doesn't set Out)
        expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("SETC");

        // CLRC: ra = 3
        ra = 2'b11;
        B  = 8'hAA; A = 8'h01;
        expC = 1'b0; expOut = A;
        expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("CLRC");

        // 6) NOT/NEG/INC/DEC (1000)
        OpCode = 4'b1000;
        // NOT (ra=0)
        ra = 2'b00;
        B = 8'h0F;
        expOut = ~B;
        expC = 1'b0; expZ = (expOut == 0); expN = expOut[Width-1]; expV = 1'b0;
        do_check("NOT");

        // NEG (ra=1) original code: Out = ~B + 1  (two's complement)
        ra = 2'b01;
        B = 8'h01;
        wide_result = {1'b0, ~B} + 1;
        expOut = wide_result[Width-1:0];
        // original code didn't set C explicitly here (they did Out = ~B + 1), so C likely 0
        expC = 1'b0;
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        // Overflow for NEG: when B == 0x80 (min negative), negation overflows
        expV = (B == (1 << (Width-1)));
        do_check("NEG");

        // INC (ra=2): {C,Out} = B + 1  (carry possible)
        ra = 2'b10;
        B = 8'hFF;
        wide_result = {1'b0, B} + {{Width{1'b0}}, 1'b1};
        expOut = wide_result[Width-1:0];
        expC = wide_result[Width];
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        // Overflow when B was max positive (0x7F) and becomes negative
        expV = ( (B[Width-1] == 1'b0) && (expOut[Width-1] == 1'b1) );
        do_check("INC with carry");

        // DEC (ra=3): {C,Out} = B - 1
        ra = 2'b11;
        B = 8'h00;
        wide_result = {1'b0, B} - {{Width{1'b0}}, 1'b1};
        expOut = wide_result[Width-1:0];
        // original sets C from {C,Out} = B - 1 ? they used concatenation; we'll check borrow when B==0
        expC = (B == 0) ? 1'b1 : 1'b0;
        expZ = (expOut == 0);
        expN = expOut[Width-1];
        // Overflow on DEC as coded: when B sign flips (min negative -> dec)
        expV = ( (B[Width-1] == 1'b1) && (expOut[Width-1] == 1'b0) );
        do_check("DEC borrow");

        // ---------- END ----------
        #5;
        $display("TEST SUMMARY: Passed=%0d  Failed=%0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED :)");
        else                $display("SOME TESTS FAILED :(");

        $finish;
    end

endmodule
