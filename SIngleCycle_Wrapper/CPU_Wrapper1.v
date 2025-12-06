module CPU_Wrapper1 (
    input wire clk,
    input wire rst,
);

// PC Specific Signals
    wire pc_write;
    wire [7 : 0]    pc_next,
                    pc_current,
                    pc_plus1,
                    branch_addr,
                    jump_addr,
                    ret_addr;
    wire [1 : 0]    pc_src;

/* PC Begin  *************************************************************/
    Pc PC_REG (
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    assign pc_plus1 = pc_current + 1;

    PC_MUX PC_MUX(
        .pc_plus1(pc_plus1),
        .branch_addr(branch_addr),
        .jump_addr(jump_addr),
        .ret_addr(ret_addr),
        .pc_src(pc_src),
        .pc_next(pc_next)
    );
/* PC End  *************************************************************/

/* CU Begin ************************************************************/
    control_unit_A (
    input  wire [7:0] ir,

    // control outputs (combinational)
    output reg        reg_write,    // write to register file at WB
    output reg  [1:0] dst_reg,      // destination register index (for writeback)
    output reg  [3:0] alu_sel,      // ALU operation code
    output reg  [1:0] op2_sel,      // 00 = reg(rb) (A-format uses register)
    output reg  [1:0] wb_sel,       // 00=ALU, 01=MEM/IO, 10=PC+2 (unused here), 11=reserved
    output reg        mem_read,     // hint: this instruction will read memory (POP / IN)
    output reg        mem_write,    // hint: this instruction will write memory (PUSH / OUT)
    output reg        flag_en,      // whether flags are affected (global enable)
    output reg  [3:0] flag_mask     // bit mask: [V C N Z] or chosen order (here we use Z,N,C,V bits)
);
/* CU End **************************************************************/

endmodule