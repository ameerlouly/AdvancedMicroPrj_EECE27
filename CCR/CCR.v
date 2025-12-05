module CCR(
    input clk, rst,
    input Z, N, C, V,           // Flag inputs from ALU
    input flag_en,              // Enable flag updates
    input [3:0] flag_mask,
    output reg [3:0] CCR_reg
);
    
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            CCR_reg <= 4'b0000;
        end
        else if(flag_en) begin
            if(flag_mask[0]) begin
                CCR_reg[0] <= Z;
            end 
            if(flag_mask[1]) begin 
                CCR_reg[1] <= N;  
            end
            if(flag_mask[2]) begin
                CCR_reg[2] <= C;  
            end
            if(flag_mask[3]) begin
                CCR_reg[3] <= V;  
            end
        end
    end
endmodule
