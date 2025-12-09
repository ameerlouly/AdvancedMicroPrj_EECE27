module mux2to1 #(parameter OPERAND_SIZE = 8)(
    input [OPERAND_SIZE-1:0] A,
    input [OPERAND_SIZE-1:0] B,
    input sel,
    output [OPERAND_SIZE-1:0] mux_out
);

assign mux_out = (sel)? B: A;
    
endmodule