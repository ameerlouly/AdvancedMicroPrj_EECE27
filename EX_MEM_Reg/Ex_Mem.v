module EX_MEM_reg (
    input clk, rst,
    input [7:0] pc_plus1,
    input [7:0] Rd2,
    input [1:0] RegDistidx,
    input [7:0] ALU_res,
    input       MemRead,
    input [7:0] FW_value,
    input       MemWrite,
    input [1:0] MemToReg,
    input       RegWrite,
    input [7:0] IP,

    output reg [7:0] pc_plus1_out,
    output reg [7:0] Rd2_out,
    output reg [1:0] RegDistidx_out,
    output reg [7:0] ALU_res_out,
    output reg       MemRead_out,
    output reg [7:0] FW_value_out,
    output reg       MemWrite_out,
    output reg [1:0] MemToReg_out,
    output reg       RegWrite_out,
    output reg [7:0] IP_out
);

    // Sequential logic: update on clock
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            pc_plus1_out <= 0;
            Rd2_out <= 0;
            RegDistidx_out <= 0;
            ALU_res_out <= 0;
            MemRead_out <= 0;
            FW_value_out <= 0;
            MemWrite_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            IP_out <= 0;
        end
        else begin
            pc_plus1_out <= pc_plus1;
            Rd2_out <= Rd2;
            RegDistidx_out <= RegDistidx;
            ALU_res_out <= ALU_res;
            MemRead_out <= MemRead;
            FW_value_out <= FW_value;
            MemWrite_out <= MemWrite;
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            IP_out <= IP;
        end
    end

endmodule
