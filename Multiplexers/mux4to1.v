module mux4to1 #(parameter OPERAND_SIZE = 8)(
    input [OPERAND_SIZE-1:0] A,
    input [OPERAND_SIZE-1:0] B,
    input [OPERAND_SIZE-1:0] C,
    input [OPERAND_SIZE-1:0] D,
    input [1:0] sel,
    output [OPERAND_SIZE-1:0] mux_out
);

assign mux_out = (sel == 2'b11)? D: (sel == 2'b10)? C: (sel == 2'b01)? B: A;
    
endmodule