`timescale 1ns/1ps

module ALU_tb;
    // fixed 8-bit ALU
    reg  [7:0] A, B;
    reg  [3:0] opcode;
    reg  [1:0] ra;
    wire [7:0] out;
    wire       C, Z, N, V;

    // instantiate ALU_F (no parameter)
    ALU uut (
        .A(A), .B(B), .opcode(opcode), .ra(ra),
        .out(out), .Z(Z), .N(N), .C(C), .V(V)
    );

    integer pass_count = 0;
    integer fail_count = 0;

    // expected values
    reg [7:0] expout;
    reg       expC, expZ, expN, expV;
    reg [8:0] wide;

    task do_check(input [127:0] testname);
        begin
            #1; // allow outputs to settle
            if ( (out === expout) && (C === expC) && (Z === expZ) && (N === expN) && (V === expV) ) begin
                $display("%0t ns: %s => TEST PASSED | A=%0d B=%0d Op=%b ra=%b out=%h C=%b Z=%b N=%b V=%b",
                         $time, testname, $signed(A), $signed(B), opcode, ra, out, C, Z, N, V);
                pass_count = pass_count + 1;
            end else begin
                $display("%0t ns: %s => TEST FAILED", $time, testname);
                $display("   Got:  out=%h C=%b Z=%b N=%b V=%b", out, C, Z, N, V);
                $display("   Exp:  out=%h C=%b Z=%b N=%b V=%b", expout, expC, expZ, expN, expV);
                $display("   A=%h B=%h Op=%b ra=%b", A, B, opcode, ra);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);

        // ---------- TESTS ----------
        // ADD (opcode 2)
        opcode = 4'd2;
        A = 8'd10; B = 8'd20;
        wide = {1'b0, A} + {1'b0, B};
        expout = wide[7:0]; expC = wide[8];
        expZ = (expout == 8'd0); expN = expout[7];
        expV = ( A[7] &  B[7] & ~expout[7]) | (~A[7] & ~B[7] & expout[7]);
        do_check("ADD simple");

        A = 8'd200; B = 8'd100; // 200+100 -> carry
        wide = {1'b0, A} + {1'b0, B};
        expout = wide[7:0]; expC = wide[8];
        expZ = (expout == 8'd0); expN = expout[7];
        expV = ( A[7] &  B[7] & ~expout[7]) | (~A[7] & ~B[7] & expout[7]);
        do_check("ADD carry/overflow");

        // SUB (opcode 3)
        opcode = 4'd3;
        A = 8'd50; B = 8'd20;
        wide = {1'b0, A} - {1'b0, B};
        expout = wide[7:0]; expC = (A < B);
        expZ = (expout == 8'd0); expN = expout[7];
        expV = ( A[7] & ~B[7] & ~expout[7]) | (~A[7] & B[7] & expout[7]);
        do_check("SUB simple");

        A = 8'd0; B = 8'd1; // borrow
        wide = {1'b0, A} - {1'b0, B};
        expout = wide[7:0]; expC = (A < B);
        expZ = (expout == 8'd0); expN = expout[7];
        expV = ( A[7] & ~B[7] & ~expout[7]) | (~A[7] & B[7] & expout[7]);
        do_check("SUB borrow");

        // AND (opcode 4)
        opcode = 4'd4;
        A = 8'hF0; B = 8'h0F;
        expout = A & B; expC = 1'b0; expZ = (expout == 8'd0); expN = expout[7]; expV = 1'b0;
        do_check("AND zero");

        A = 8'hA5; B = 8'hFF;
        expout = A & B; expC = 1'b0; expZ = (expout == 8'd0); expN = expout[7]; expV = 1'b0;
        do_check("AND nonzero");

        // OR (opcode 5)
        opcode = 4'd5;
        A = 8'h00; B = 8'h00;
        expout = A | B; expC = 1'b0; expZ = (expout == 8'd0); expN = expout[7]; expV = 1'b0;
        do_check("OR zero");

        A = 8'h12; B = 8'h34;
        expout = A | B; expC = 1'b0; expZ = (expout == 8'd0); expN = expout[7]; expV = 1'b0;
        do_check("OR nonzero");

        // RLC/RRC/SETC/CLRC (opcode 6)
        opcode = 4'd6;
        // RLC
        ra = 2'b00; B = 8'b1001_0110; A = 8'h00;
        expC = B[7]; expout = {B[6:0], expC}; expZ = (expout==0); expN = expout[7]; expV = 1'b0;
        do_check("RLC");

        // RRC
        ra = 2'b01; B = 8'b0110_1001;
        expC = B[0]; expout = {expC, B[7:1]}; expZ = (expout==0); expN = expout[7]; expV = 1'b0;
        do_check("RRC");

        // SETC -> per ALU_F: sets C=1 and out=0
        ra = 2'b10; B = 8'h55; A = 8'hAA;
        expC = 1'b1; expout = 8'b0; expZ = 1'b1; expN = 1'b0; expV = 1'b0;
        do_check("SETC");

        // CLRC -> sets C=0 and out=0
        ra = 2'b11; B = 8'hAA; A = 8'h01;
        expC = 1'b0; expout = 8'b0; expZ = 1'b1; expN = 1'b0; expV = 1'b0;
        do_check("CLRC");

        // NOT/NEG/INC/DEC (opcode 8)
        opcode = 4'd8;
        // NOT
        ra = 2'b00; B = 8'h0F;
        expout = ~B; expC = 1'b0; expZ = (expout==0); expN = expout[7]; expV = 1'b0;
        do_check("NOT");

        // NEG (two's complement) -- ALU_F sets C = carry of (~B + 1)
        ra = 2'b01; B = 8'h01;
        wide = {1'b0, ~B} + 9'd1;
        expout = wide[7:0]; expC = wide[8];
        expZ = (expout==0); expN = expout[7]; expV = (B == 8'h80);
        do_check("NEG");

        // INC (B + 1)
        ra = 2'b10; B = 8'hFF;
        wide = {1'b0, B} + 9'd1;
        expout = wide[7:0]; expC = wide[8];
        expZ = (expout==0); expN = expout[7];
        expV = (~B[7] & expout[7]); // overflow when 0x7F -> 0x80
        do_check("INC with carry");

        // DEC (B - 1)
        ra = 2'b11; B = 8'h00;
        wide = {1'b0, B} - 9'd1;
        expout = wide[7:0]; expC = (B == 8'd0);
        expZ = (expout==0); expN = expout[7];
        expV = (B[7] & ~expout[7]); // overflow when 0x80 -> 0x7F
        do_check("DEC borrow");

        // ---------- SUMMARY ----------
        #5;
        $display("TEST SUMMARY: Passed=%0d  Failed=%0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED :)");
        else                $display("SOME TESTS FAILED :(");

        $finish;
    end

endmodule
