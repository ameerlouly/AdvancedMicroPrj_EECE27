module id_ex_reg(
    input clk, rst,
    input flush,
    input wr_en,

    // ---------- Control inputs from ID stage ----------
    input        reg_write,        //  write result to register file in WB stage
    input  [1:0] dst_reg,          //  destination register index
    input  [3:0] alu_sel,          //  ALU operation selector
    input  [1:0] op2_sel,          //  operand2 select (Rb or Immediate)
    input  [1:0] wb_sel,           //  write-back source select (ALU / MEM / PC)
    input        mem_read,         //  read from memory in MEM stage
    input        mem_write,        //  write to memory in MEM stage
    input        flag_en,          //  update CCR flags in WB stage


    // ---------- Data inputs from ID stage ----------
    input  [7:0] ra_val_in,    // value of R[ra]
    input  [7:0] rb_val_in,    // value of R[rb]
    input  [7:0] imm_in,       // immediate / EA / second byte
    input  [7:0] pc_in,        // PC of this instruction

    // ---------- Control outputs to EX stage ----------
    output reg        reg_write_out,    
    output reg  [1:0] dst_reg_out,      
    output reg  [3:0] alu_sel_out,  
    output reg  [1:0] op2_sel_out,      
    output reg  [1:0] wb_sel_out,        
    output reg        mem_read_out,     
    output reg        mem_write_out,    
    output reg        flag_en_out,

    // ---------- Data outputs to EX stage ----------
    output reg  [7:0] ra_val_out,
    output reg  [7:0] rb_val_out,
    output reg  [7:0] imm_out,
    output reg  [7:0] pc_out
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // ----- Control reset  -----
            reg_write_out <= 0;
            dst_reg_out   <= 0;
            alu_sel_out   <= 0;
            op2_sel_out   <= 0;
            wb_sel_out    <= 0;
            mem_read_out  <= 0;
            mem_write_out <= 0;
            flag_en_out   <= 0;

            // ----- Data reset  -----
            ra_val_out    <= 8'd0;
            rb_val_out    <= 8'd0;
            imm_out       <= 8'd0;
            pc_out        <= 8'd0;
        end
        else if (flush) begin
            // ----- Control flush  -----
            reg_write_out <= 0;
            dst_reg_out   <= 0;
            alu_sel_out   <= 0;
            op2_sel_out   <= 0;
            wb_sel_out    <= 0;
            mem_read_out  <= 0;
            mem_write_out <= 0;
            flag_en_out   <= 0;

            // ----- Data flush  -----
            ra_val_out    <= 8'd0;
            rb_val_out    <= 8'd0;
            imm_out       <= 8'd0;
            pc_out        <= 8'd0;
        end
        else if (wr_en) begin
            // ----- Control normal   -----
            reg_write_out <= reg_write;
            dst_reg_out   <= dst_reg;
            alu_sel_out   <= alu_sel;
            op2_sel_out   <= op2_sel;
            wb_sel_out    <= wb_sel;
            mem_read_out  <= mem_read;
            mem_write_out <= mem_write;
            flag_en_out   <= flag_en;

            // ----- Data normal   -----
            ra_val_out    <= ra_val_in;
            rb_val_out    <= rb_val_in;
            imm_out       <= imm_in;
            pc_out        <= pc_in;
        end
        // else: stall → hold old values (control + data)
    end

endmodule
