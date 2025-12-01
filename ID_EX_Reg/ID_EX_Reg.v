module id_ex_reg(
    input clk, rst,
    input flush,
    input wr_en,
    input reg_write,    
    input  [1:0] dst_reg,      
    input  [3:0] alu_sel,  
    input  [1:0] op2_sel,      
    input  [1:0] wb_sel,        
    input   mem_read,     
    input   mem_write,    
    input   flag_en,
    output reg reg_write_out,    
    output reg  [1:0] dst_reg_out,      
    output reg  [3:0] alu_sel_out,  
    output reg  [1:0] op2_sel_out,      
    output reg  [1:0] wb_sel_out,        
    output reg   mem_read_out,     
    output reg  mem_write_out,    
    output reg   flag_en_out
);
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            reg_write_out <= 0;
            dst_reg_out <= 0;
            alu_sel_out <= 0;
            op2_sel_out <= 0;
            wb_sel_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            flag_en_out <= 0;
        end
        else if(flush) begin
            reg_write_out <= 0;
            dst_reg_out <= 0;
            alu_sel_out <= 0;
            op2_sel_out <= 0;
            wb_sel_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            flag_en_out <= 0;
        end
        else if(wr_en) begin
            reg_write_out <= reg_write;
            dst_reg_out <= dst_reg;
            alu_sel_out <= alu_sel;
            op2_sel_out <= op2_sel;
            wb_sel_out <= wb_sel;
            mem_read_out <= mem_read;
            mem_write_out <= mem_write;
            flag_en_out <= flag_en;
        end
    end
endmodule