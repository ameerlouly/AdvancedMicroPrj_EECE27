module id_ex_reg(
    input clk, rst,
    input flush,
    input inject_bubble,
    input [7:0] pc_plus1,
    input [7:0] IP,
    input [7:0] imm,

    // ---------- Control inputs from ID stage ----------
    input       [2:0] BType,
    input       [1:0] MemToReg,
    input             RegWrite,
    input             MemWrite,
    input             MemRead,
    input             UpdateFlags,
    input       [1:0] RegDistidx,
    input       [1:0]     ALU_src,
    input       [3:0] ALU_op,
    input             IO_Write,
    input             isCall,    
    input             loop_sel,
    input             Ret_sel,

    // ---------- Data inputs from ID stage ----------
    input  [7:0] ra_val_in,    // value of R[ra]
    input  [7:0] rb_val_in,    // value of R[rb]
    input  [1:0] ra,           // address of ra
    input  [1:0] rb,            // address of rb

    // ---------- Control outputs to EX stage ----------
    output reg      [2:0] BType_out,
    output reg      [1:0] MemToReg_out,
    output reg             RegWrite_out,
    output reg             MemWrite_out,
    output reg             MemRead_out,
    output reg             UpdateFlags_out,
    output reg       [1:0] RegDistidx_out,
    output reg       [1:0] ALU_src_out,
    output reg       [3:0] ALU_op_out,
    output reg             IO_Write_out,
    output reg             isCall_out,  
    output reg             loop_sel_out,
    output reg             Ret_sel_out,

    // ---------- Data outputs to EX stage ----------
    output reg  [7:0] ra_val_out,
    output reg  [7:0] rb_val_out,
    output reg  [1:0] ra_out,
    output reg  [1:0] rb_out,

    //  -------- PC_plus1 out, IP_out, immediate -----------
    output reg [7:0] pc_plus1_out,
    output reg [7:0] IP_out,
    output reg [7:0] imm_out
);

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            BType_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemRead_out <= 0;
            UpdateFlags_out <= 0;
            RegDistidx_out <= 0;
            ALU_src_out <= 0;
            ALU_op_out <= 0;
            IO_Write_out <= 0;
            ra_val_out <= 0;
            rb_val_out <= 0;
            ra_out <= 0;
            rb_out <= 0;
            IP_out <= 0;
            imm_out <= 0;
            pc_plus1_out <= 0;
            isCall_out <= 0;
            loop_sel_out <= 0;
            Ret_sel_out <= 0;
        end
        else if (flush) begin
            BType_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemRead_out <= 0;
            UpdateFlags_out <= 0;
            RegDistidx_out <= 0;
            ALU_src_out <= 0;
            ALU_op_out <= 0;
            IO_Write_out <= 0;
            ra_val_out <= 0;
            rb_val_out <= 0;
            ra_out <= 0;
            rb_out <= 0;
            IP_out <= 0;
            imm_out <= 0;
            pc_plus1_out <= 0;
            isCall_out <= 0;
            loop_sel_out <= 0;
            Ret_sel_out <= 0;
        end
        else if(inject_bubble) begin
            ALU_op_out <= 0; // no op
        end
        else begin
            BType_out <= BType;
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            MemWrite_out <= MemWrite;
            MemRead_out <= MemRead;
            UpdateFlags_out <= UpdateFlags;
            RegDistidx_out <= RegDistidx;
            ALU_src_out <= ALU_src;
            ALU_op_out <= ALU_op;
            IO_Write_out <= IO_Write;
            ra_val_out <= ra_val_in;
            rb_val_out <= rb_val_in;
            ra_out <= ra;
            rb_out <= rb;
            pc_plus1_out <= pc_plus1;    
            IP_out <= IP;   
            imm_out <= imm;     
            isCall_out <= isCall;
            loop_sel_out <= loop_sel;
            Ret_sel_out <= Ret_sel;
        end
    end

endmodule
