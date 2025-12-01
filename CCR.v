module CCR(
    input clk, rst,
    input Z, N, C, V,           // Flag inputs from ALU
    input flag_en,              // Enable flag updates
    output reg [3:0] CCR_reg
);
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            CCR_reg <= 4'b0000;
        end
        else if(flag_en) begin
            CCR_reg[0] <= Z;  // Zero flag
            CCR_reg[1] <= N;  // Negative flag
            CCR_reg[2] <= C;  // Carry flag
            CCR_reg[3] <= V;  // Overflow flag
        end
    end
endmodule