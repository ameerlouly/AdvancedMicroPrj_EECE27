module CPU_Wrapper1 (
    input wire clk,
    input wire rst,
    output reg [3 : 0] CCR_out,

    // Interfacing with memory
    output mem_read, mem_write,
    output  wire [7:0]  mem_addr_a,
    input   reg  [7:0]  Instr_in,
    output  wire        mem_write_enable,             // write enable for port B
    output  wire [7:0]  mem_addr_b,
    output wire [7:0]   mem_write_data_b,
    input reg  [7:0]    mem_data_out_b
);

// PC Specific Signals
    wire pc_write;  // Should be taken from CU later on
    wire [7 : 0]    pc_next,
                    pc_current,
                    pc_plus1,
                    branch_addr,
                    jump_addr,
                    ret_addr;
    wire [1 : 0]    pc_src;

// CU Specific Signals
    wire [7:0]  ir;
    wire        reg_write;    // write to register file at WB
    wire  [1:0] dst_reg;      // destination register index (for writeback)
    wire  [3:0] alu_sel;      // ALU operation code
    wire  [1:0] op2_sel;      // 00 = reg(rb) (A-format uses register)
    wire  [1:0] wb_sel;       // 00=ALU, 01=MEM/IO, 10=PC+2 (unused here), 11=reserved
    wire        cu_mem_read;     // hint: this instruction will read memory (POP / IN)
    wire        cu_mem_write;    // hint: this instruction will write memory (PUSH / OUT)
    wire        flag_en;      // whether flags are affected (global enable)
    wire  [3:0] flag_mask; 

// ALU Specific Signals
    wire [7 : 0]    ALU_out;
    wire [7 : 0]    ALU_A, ALU_B;
    wire    ALU_Z, ALU_N, ALU_C, ALU_V;

// Register File Specific Signals
    wire [1 : 0]    rb_addr;
    wire [7 : 0]    ra_data;
    wire [7 : 0]    ra_data;
    wire [7 : 0]    rb_data;
    wire [7 : 0]    WData_RF;

/* CU Begin ************************************************************/
    control_unit_A CU (
        .ir(ir),
        .reg_write(reg_write),      // write to register file at WB
        .dst_reg(dst_reg),          // destination register index (for writeback)
        .alu_sel(alu_sel),          // ALU operation code
        .op2_sel(op2_sel),          // 00 = reg(rb) (A-format uses register)
        .wb_sel(wb_sel),            // 00=ALU, 01=MEM/IO, 10=PC+2 (unused here), 11=reserved
        .mem_read(cu_mem_read),        // hint: this instruction will read memory (POP / IN)
        .mem_write(cu_mem_write),      // hint: this instruction will write memory (PUSH / OUT)
        .flag_en(flag_en),          // whether flags are affected (global enable)
        .flag_mask(flag_mask)       // bit mask: [V C N Z] or chosen order (here we use Z,N,C,V bits)
    );

/* CU End **************************************************************/


/* PC Begin  *************************************************************/
    Pc PC_REG (
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    assign pc_plus1 = pc_current + 1;
    assign pc_write = 1'b1;

    PC_MUX PC_mux(
        .pc_plus1(pc_plus1),
        .branch_addr(branch_addr),
        .jump_addr(jump_addr),
        .ret_addr(ret_addr),
        .pc_src(pc_src),
        .pc_next(pc_next)
    );

    assign pc_src = 2'b00; // Always pc plus1 for current test
/* PC End  *************************************************************/

/* MEM Begin  *************************************************************/
    assign ir = Instr_in;
    assign mem_addr_a = pc_current;
    assign OutDataA
    assign cu_mem_read  = mem_read;
    assign cu_mem_write = mem_write;

    // memory MEM_Dual (
    //     .clk(clk),   //? Finished
    //     .rst(rst),   //? Finished    
    //     .addr_a(pc_current),   //? Finished  
    //     .instr_out(OutDataA),
    //     .we_b(cu_mem_write),             // write enable for port B
    //     .addr_b(rb_data),
    //     .write_data_b(AlU_out),
    //     .data_out_b(OutDataB)
    // );

/* MEM End  *************************************************************/

/* Register File Start **************************************************/

    always @(*) begin
        case (wb_sel)
            00: WData_RF = OutDataB;
            01: WData_RF = OutDataB;    // Change later to IP
            10: WData_RF = ALU_out;
            11: WData_RF = ALU_out;     // Change Later to OutDataA
        endcase
    end

    Register_file Register_File (
        .clk(clk),              // Clock signal
        .rst(rst),              // Active-low reset
        .wenabel(reg_write),          // Write enable signal
        .ra(ir[3 : 2]),         // Read address A  (selects R0..R3)
        .rb(ir[1 : 0]),         // Read address B  (selects R0..R3)
        .rd(dst_reg),         // Destination register index (for write)
        .write_data(WData_RF), // Data to be written into R[rd]
        .ra_date(ra_data),   // Output data from register R[ra]
        .rb_date(rb_data)    // Output data from register R[rb]
    );


/* Register File End **************************************************/

/* ALU Start **********************************************************/

    ALU ALU_instant (
        .A(ALU_A),
        .B(ALU_B),
        .sel(alu_sel),
        .cin(CCR_out[2]),
        .out(ALU_out),
        .Z(ALU_Z),
        .N(ALU_N),
        .C(ALU_C),
        .V(ALU_V)
    );

    assign ALU_B = rb_data;

    always @(*) begin
        case(op2_sel)
            00: ALU_A = ra_data;
            01: ALU_A = ra_data; //TODO : Change later
            10: ALU_A = ra_data; //TODO : Change later
            11: ALU_A = ra_data; //TODO : Change later
        endcase
    end    

/* ALU End ***********************************************************/

/* CCR Start *********************************************************/
    CCR CCR_Instant(
        .clk(clk),
        .rst(rst),
        .Z(ALU_Z),
        .N(ALU_N),
        .C(ALU_C),
        .V(ALU_V),
        .flag_en(flag_en),              // Enable flag updates
        .flag_mask(flag_mask),
        .CCR_reg(CCR_out)
    );

/* CCR End ***********************************************************/


endmodule