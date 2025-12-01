module PC_MUX(
    input  [7:0] pc_plus1,
    input  [7:0] branch_addr,
    input  [7:0] jump_addr,
    input  [7:0] ret_addr,
    input  [1:0] pc_src,
    output reg [7:0] pc_next
);

always @(*) begin
    case(pc_src)
        2'b00: pc_next = pc_plus1;     // normal sequence
        2'b01: pc_next = branch_addr;  // branch
        2'b10: pc_next = jump_addr;    // jump
        2'b11: pc_next = ret_addr;     // return
    endcase
end

endmodule
