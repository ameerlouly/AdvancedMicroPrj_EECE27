module MEM_WB_Reg(
    input clk, rst,
    input wr_en,
    input flush,
    input [7:0] mem_data_in,
    output reg [7:0] mem_data_out
);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        mem_data_out <= 0;
    end
    else if(flush) begin
        mem_data_out <= 0;
    end
    else if(wr_en) begin
        mem_data_out <= mem_data_in;
    end
end
    
endmodule