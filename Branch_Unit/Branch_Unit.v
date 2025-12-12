module Branch_Unit(
    input   reg [3:0]        flag_mask,     // [Z,N,C,V]
    input   reg [3:0]        opcode,
	input   reg [1:0]        ra,            // ra or brx
	input   reg [7:0]        R_ra,          // data in regester ra
    input   reg [7:0]        R_rb,          // data in regester rb
	input   reg [7:0]        pc_plus1,      // PC+1
	input   reg [7:0]        X_SP_plus1,    // X[++SP]
	output  reg [7:0]        X_SP__minus1,  // X[SP--]
    output  reg [7:0]        pc,
	output  reg [7:0]        new_R_ra,      // new data to put in regester ra
	output  reg [3:0]		 flags_storage  // used in RTI instruction (somewhere in the stack)
    );


	localparam COND_JMP    = 4'b1001;
	localparam LOOP        = 4'b1010;
	localparam UNCOND_JMP  = 4'b0011;

	localparam JZ  = 2'b00;
	localparam JN  = 2'b01;
	localparam JC  = 2'b10;
	localparam JV  = 2'b11;

	localparam JMP  = 2'b00;
	localparam CALL = 2'b01;
	localparam RET  = 2'b10;
	localparam RTI  = 2'b11;

	always @* begin
        
        case(opcode)

			COND_JMP: begin
           		case(ra)
            		JZ: pc = (flag_mask[0] == 1) ? R_rb: pc_plus1;
					JN: pc = (flag_mask[1] == 1) ? R_rb: pc_plus1;
					JC:	pc = (flag_mask[2] == 1) ? R_rb: pc_plus1;
					JV: pc = (flag_mask[3] == 1) ? R_rb: pc_plus1;
				endcase
			end


			LOOP: begin
				new_R_ra=R_ra-1;
				pc = (new_R_ra != 0) ? R_rb: pc_plus1;
			end


			UNCOND_JMP: begin
           		case(ra)
            		JMP:  pc = R_rb;

					CALL: begin 
						pc = R_rb; 
						X_SP__minus1= pc_plus1;  
					end

					RET:  pc = X_SP_plus1;

					RTI:begin 
						pc = X_SP_plus1;
					    flags_storage = flag_mask;
					end
				endcase
			end
        endcase



    end

endmodule

