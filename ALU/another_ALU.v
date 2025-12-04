module ALU(
	input wire [7:0] A,
	input wire [7:0] B,
	input wire [3:0] sel,
	input wire cin,

	output reg [7:0] out,
	output reg Z, N, C, V	//flags are kept the same unless explicitly updated by an operation
);
	// ALU encodings (localparam)
	localparam ALU_NOP  = 4'b0000;

	localparam ALU_PASS = 4'b0001; // MOV - pass source
	localparam ALU_ADD  = 4'b0010;
	localparam ALU_SUB  = 4'b0011;
	localparam ALU_AND  = 4'b0100;
	localparam ALU_OR   = 4'b0101;

	localparam ALU_RLC  = 4'b0110;
	localparam ALU_RRC  = 4'b0111;
	localparam ALU_SETC = 4'b1000; // pseudo-op (set C flag)
	localparam ALU_CLRC = 4'b1001; // pseudo-op (clear C)

	localparam ALU_NOT  = 4'b1010;
	localparam ALU_NEG  = 4'b1011;

	localparam ALU_INC  = 4'b1100;
	localparam ALU_DEC  = 4'b1101;

	// giving initial values to outputs
	initial begin
		out = 8'h00;
		Z = 1'b0;
		N = 1'b0;
		C = 1'b0;
		V = 1'b0;
	end

	reg [8:0] temp_wide;

	always @* begin
		case (sel)
			ALU_PASS: out = B;		//none
			ALU_ADD: begin
				temp_wide = {1'b0, A} + {1'b0, B};	//all
				out = temp_wide[7:0];
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
				C = temp_wide[8];
				V = (A[7] == B[7]) && (out[7] != A[7]) ? 1'b1 : 1'b0;
			end
			ALU_SUB: begin
				temp_wide = {1'b0, A} - {1'b0, B};	//all
				out = temp_wide[7:0];
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
				C = temp_wide[8];
				V = (A[7] != B[7]) && (out[7] != A[7]) ? 1'b1 : 1'b0;
			end
			ALU_AND: begin
				out = A & B;	//Z,N
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
			end
			ALU_OR: begin 
				out = A | B;	//Z,N
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
			end

			ALU_RLC: begin 
				out = {B[6:0], cin};
				C = B[7];
			end
			ALU_RRC: begin 
				out = {cin, B[7:1]};
				C = B[0];
			end

			ALU_SETC: C = 1'b1;
			ALU_CLRC: C = 1'b0;

			ALU_NOT: begin
				out = ~B;		//Z,N
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
			end
			ALU_NEG: begin
				out = -B;		//Z,N
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
			end

			ALU_INC: begin
				out = B + 8'h01;	//all
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
				V = (B == 8'h7F) ? 1'b1 : 1'b0;
				C = (B == 8'hFF) ? 1'b1 : 1'b0;
			end
			ALU_DEC: begin 
				out = B - 8'h01;	//all
				Z = out == 8'h00 ? 1'b1 : 1'b0;
				N = out[7];
				V = (B == 8'h80) ? 1'b1 : 1'b0;
				C = (B == 8'h00) ? 1'b1 : 1'b0;
			end

			default: ; // NOP and unimplemented ops
		endcase
	end
endmodule
