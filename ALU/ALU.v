module ALU #(parameter Width = 8) (
    input  reg [Width-1:0] A, B,
    input  reg [3:0]       opcode,
    input  reg [1:0]       ra,
    output reg [Width-1:0] out,
    output reg             C, Z, N, V,
    reg                    temp
);

always @(*) begin

    case (opcode)

        'b0010: begin
            {C, out} = A + B;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

            if (A[7] == 'b0 && B == 'b0 && out == 'b1)
                V = 1;
            else if (A == 'b1 && B == 'b1 && out == 'b0)
                V = 1;
            else
                V = 0;
        end

        'b0011: begin
            {C, out} = A - B;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

            if (A[7] == 'b0 && B == 'b0 && out == 'b1)
                V = 1;
            else if (A == 'b1 && B == 'b1 && out == 'b0)
                V = 1;
            else
                V = 0;
        end

        'b0100: begin
            out = A & B;
            C = 0;
            V = 0;
             if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;
        end

        'b0101: begin
            out = A | B;
            C = 0;
            V = 0;
            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;
        end

        'b0110: begin
            case (ra)
            'b00: begin // RLC
                temp     = C;
                C        = B[7];
                out[7:1] = B[6:0];
                out[0]   = C;
                V = 0;
            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;
            end

            'b01: begin // RRC
                temp     = C;
                C        = B[0];
                out[6:0] = B[7:1];
                out[7]   = C;
                V = 0;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

            end

            'b10: begin //CLRC
                C = 1;
                out = 0;
                Z=1;
                 N = 0;
            end

            'b11: begin //SETC
                C = 0;
                out = 0;
                Z=1;
                 N = 0;
            end
            endcase
        end

        'b1000: begin
        case (ra)
            'b00: begin // NOT (1's Complemnet)
                out = ~B;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

            end

            'b01: begin  //(2's Complemnet)
                out = ~B + 'b00000001;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

            end

           'b10 :begin // INC

                {C, out} = B + 'b00000001;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

                if (B[7] == 'b0 && out[7] == 'b1)
                    V = 1;
                else
                    V = 0;

            end

         'b11 :begin  // DEC
                {C, out} = B - 'b00000001;

            if (out == 0)
                Z = 1;
            else
                Z = 0;

            if (out[7] == 'b1)
                N = 1;
            else
                N = 0;

                if (B[7] == 'b1 && out[7] == 'b0)
                    V = 1;
                else
                    V = 0;

            end

        endcase

        end

    endcase

end

endmodule

