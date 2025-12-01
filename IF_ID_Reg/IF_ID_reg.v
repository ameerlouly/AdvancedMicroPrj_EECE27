module IF_ID_reg (
    input wire              clk,
    input wire              rst,
    input wire              write_en,
    input wire              flush,
    input wire      [7:0]   pc,
    input wire      [7:0]   instr_in,
    output reg      [7:0]   pc_out,
    output reg      [7:0]   instr_out
);

always @(posedge clk or negedge rst) 
begin
    if(!rst)
    begin
        pc_out    <= 8'd0;
        instr_out <= 8'd0;
    end
    else if(flush) //NOP
    begin
        pc_out <=   8'd0;
        instr_out<= 8'd0;
    end
    else if(write_en)
    begin
        pc_out <= pc;
        instr_out<= instr_in;
    end
end
    
endmodule