module Branch_Unit(
    input   reg [3:0]        flag_mask,     // [Z,N,C,V]
    input   reg [2:0]        BTYPE,
	output  reg     		 B_TAKE
    );


    localparam BR_NONE = 3'b000;
    localparam BR_JZ   = 3'b001;
    localparam BR_JN   = 3'b010;
    localparam BR_JC   = 3'b011;
    localparam BR_JV   = 3'b100;
    localparam BR_LOOP = 3'b101;
    localparam BR_JMP  = 3'b110; // Used for JMP, CALL
    localparam BR_RET  = 3'b111; // THIS (New Type for RET/RTI)


	always @* begin
        
        case(BTYPE)
					BR_NONE: B_TAKE = 1'b0;
            		BR_JZ:   B_TAKE = (flag_mask[0] == 1'b1) ? 1'b1: 1'b0;
					BR_JN:   B_TAKE = (flag_mask[1] == 1'b1) ? 1'b1: 1'b0;
					BR_JC:   B_TAKE = (flag_mask[2] == 1'b1) ? 1'b1: 1'b0;
					BR_JV:   B_TAKE = (flag_mask[3] == 1'b1) ? 1'b1: 1'b0;
					BR_LOOP: B_TAKE = (flag_mask[0] == 1'b1) ? 1'b1: 1'b0;
					BR_JMP:  B_TAKE = 1'b1;
					BR_RET:  B_TAKE = 1'b1;
                    default : B_TAKE = 1'b0;
                        
        endcase
    end

endmodule

