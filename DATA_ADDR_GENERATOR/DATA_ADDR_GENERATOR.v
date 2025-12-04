module DATA_ADDR_GENERATOR(
    input clk, rst, 
    input [7:0] data_addr_in,
    output reg [7:0] data_addr_out
);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        data_addr_out <= 128;
    end
    else begin
        data_addr_out <= data_addr_in + 128;
        if(data_addr_out >= 223) begin// let stack size be 32B so range is from 128 to 222
            data_addr_out <= data_addr_out - 223; // overflow the memory
        end 
    end
end
    
endmodule