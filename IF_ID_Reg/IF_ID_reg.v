module IF_ID_reg (
    input wire              clk,
    input wire              rst,
    input wire              if_id_en,
    input wire              flush,
    input wire      [7:0]   pc_plus1,
    input wire      [7:0]   instruction,
    input wire      [7:0]   IP,
    input wire      [7:0]   data_B,
    output reg      [7:0]   pc_plus1_out,
    output reg      [7:0]   instr_out,
    output reg      [7:0]   IP_out,
    output reg      [7:0]   data_B_out
);

always @(posedge clk or negedge rst) 
begin
    if(!rst)
    begin
        pc_plus1_out  <= 0; // pc = 0, pc+1 = 1
        instr_out <= 8'd0;
        IP_out <= 8'd0;
        data_B_out <= 8'd0;
    end
    else if(flush) //NOP
    begin
        instr_out <= 8'd0; // opcode = 0
        pc_plus1_out <= pc_plus1; // pc+1 -> pc
        // rest of outputs should stay the same as NO_OP will not use any of them.
    end
    else if(if_id_en)
    begin
        pc_plus1_out <= pc_plus1;
        instr_out <= instruction;
        IP_out <= IP;
        data_B_out <= data_B;
    end
end
    
endmodule