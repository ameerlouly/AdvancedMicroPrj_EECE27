module ALU #(parameter Width = 8) (
    input  reg [Width-1:0] A, B,
    input  reg [3:0]       OpCode,
    input  reg [1:0]       ra,
    output reg [Width-1:0] Out,
    output reg             C, Z, N, V,
    reg                    temp
);

always @(*) begin

    case (OpCode)

        'b0010: begin
            {C, Out} = A + B;

            if (Out == 0)
                Z = 1;
            else
                Z = 0;

            if (Out < 0)
                N = 1;
            else
                N = 0;

            if (A > 0 && B > 0 && Out < 0)
                V = 1;
            else if (A < 0 && B < 0 && Out > 0)
                V = 1;
            else
                V = 0;
        end

        'b0011: begin
            {C, Out} = A - B;

            if (Out == 0)
                Z = 1;
            else
                Z = 0;

            if (Out < 0)
                N = 1;
            else
                N = 0;

            if (A > 0 && B > 0 && Out < 0)
                V = 1;
            else if (A < 0 && B < 0 && Out > 0)
                V = 1;
            else
                V = 0;
        end

        'b0100: begin
            Out = A & B;

            if (Out == 0)
                Z = 1;
            else
                Z = 0;

            if (Out < 0)
                N = 1;
            else
                N = 0;
        end

        'b0101: begin
            Out = A | B;

            if (Out == 0)
                Z = 1;
            else
                Z = 0;

            if (Out < 0)
                N = 1;
            else
                N = 0;
        end

        'b0110: begin

            if (ra == 0) begin
                temp     = C;
                C        = B[7];
                Out[7:1] = B[6:0];
                Out[0]   = C;
            end

            else if (ra == 1) begin
                temp     = C;
                C        = B[0];
                Out[6:0] = B[7:1];
                Out[7]   = C;
            end

            else if (ra == 2) begin
                C = 1;
            end

            else
                C = 0;

        end

        'b1000: begin

            if (ra == 0) begin
                Out = ~B;

                if (Out == 0)
                    Z = 1;
                else 
                    Z = 0;

                if (Out < 0)
                    N = 1;
                else 
                    N = 0;

            end

            else if (ra == 1) begin
                Out = ~B + 'b00000001;

                if (Out == 0)
                    Z = 1;
                else 
                    Z = 0;

                if (Out < 0)
                    N = 1;
                else 
                    N = 0;

            end

            else if (ra == 2) begin

                {C, Out} = B + 'b00000001;

                if (Out == 0)
                    Z = 1;
                else 
                    Z = 0;

                if (Out < 0)
                    N = 1;
                else 
                    N = 0;

                if (B > 0 && Out < 0)
                    V = 1;
                else
                    V = 0;

            end

            else begin
                {C, Out} = B - 'b00000001;

                if (Out == 0)
                    Z = 1;
                else 
                    Z = 0;

                if (Out < 0)
                    N = 1;
                else 
                    N = 0;

                if (B < 0 && Out > 0)
                    V = 1;
                else
                    V = 0;
            end

        end

    endcase

end

endmodule

