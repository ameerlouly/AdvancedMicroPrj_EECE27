module CPU_WrapperV3 (
    input clk,
    input rstn,
    input [7 : 0] I_Port,
    input int_sig,  // Interrupt Signal
    output [7 : 0] O_Port
);

// RF outputs
    wire [7 : 0]    ra_data_out,
                    rb_data_out,
                    rf_wd_mux_out;

// Memory wires
    wire [7 : 0]    mem_data_b_out;
    wire    cu_mem_read,
            cu_mem_write,
            cu_isCall;

// Branch Unit Wires
    wire [1 : 0]    bu_bt;

// ALU and CCR Wires
    wire [7 : 0]    alu_a,
                    alu_b,
                    alu_out;

    wire            alu_z,
                    alu_n,
                    alu_c,
                    alu_v;

    wire [3 : 0]    alu_flag_mask,
                    ccr_reg_out;

/*** Program Counter *****************************************************************************/
    wire [7 : 0]    pc_next,
                    pc_current,
                    pc_plus1;
    wire            pc_write; 
    wire [1 : 0]    pc_src;
    
    Pc PC(
        .clk(clk),
        .rst(rstn),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    assign pc_plus1 = pc_current + 1;

    mux4to1 PC_MUX (
        .d0(pc_plus1),
        .d1(rb_data_out), 
        .d2(mem_data_b_out),
        .d3(8'b00000000),
        .sel(pc_src),
        .out(pc_next)
    );

/*** Memory *****************************************************************************/
    wire [7 : 0] IR;

    wire [7 : 0]    WriteD_mux_out;

    mux2to1 #(.WIDTH(8)) mem_writeD_b_mux2to1 (
        .d0     (rb_data_out),
        .d1     (pc_plus1),
        .sel    (cu_isCall),
        .out    (WriteD_mux_out)
    );

    memory mem_inst (
        .clk            (clk),
        .rst            (rstn),
        .addr_a         (pc_current),
        .data_out_a     (IR),
        .addr_b         (alu_out), 
        .data_out_b     (mem_data_b_out), 
        .we_b           (cu_mem_write), 
        .write_data_b   (WriteD_mux_out)  
    );

/*** Control Unit *****************************************************************************/
    
    // Fetch Wires
    wire    cu_pc_write_en,
            cu_if_id_write_en,
            cu_inject_bubble, //todo: Currently Empty
            cu_inject_int;  //todo: Currently Empty

    // Decode Wires
    wire    cu_sp_en,
            cu_sp_op,
            cu_reg_write,
            cu_sp_sel,
            cu_reg_dist;

    // Execute Wires
    wire    cu_alu_src;
    wire [3 : 0]    cu_alu_op;
    wire cu_flag_en;
    wire [2 : 0]    cu_btype;

    // Memory Wires
    wire [1 : 0]    cu_memtoreg;

    // Write-Back Control
    wire cu_io_write;

    Control_unit ctrl_inst (
        .clk            (clk),
        .rst            (rstn),
        .INTR           (int_sig),
        .opcode         (IR[7:4]),
        .ra             (IR[3:2]),
        // Fetch Control
        .PC_Write_En    (cu_pc_write_en),
        .IF_ID_Write_En (cu_if_id_write_en),
        .Inject_Bubble  (cu_inject_bubble),
        .Inject_Int     (cu_inject_int),
        // Decode Control
        .RegWrite       (cu_reg_write),
        .RegDist        (cu_reg_dist),
        .SP_SEL         (cu_sp_sel), // SP = Stack Pointer
        .SP_EN          (cu_sp_en),
        .SP_OP          (cu_sp_op),
        // Execute Control
        .Alu_Op         (cu_alu_op), // 4 Bits
        .BTYPE          (cu_btype), // 3 Bits
        .Alu_src        (cu_alu_src),
        .UpdateFlags    (cu_flag_en),
        // Memory Control
        .IS_CALL        (cu_isCall),
        .MemToReg       (cu_memtoreg), // 2 Bits
        .MemWrite       (cu_mem_write),
        .MemRead        (cu_mem_read),
        // Write-Back Control
        .IO_Write       (cu_io_write)
    );

    wire [1:0]  reg_dist;
    mux2to1 #(.WIDTH(2)) reg_dist_mux (
        .d0     (IR[3:2]),
        .d1     (IR[1:0]),
        .sel    (cu_reg_dist),
        .out    (reg_dist)
    );

/*** Hazard Unit *****************************************************************************/

    //todo: All of these will be taken and given to register later
    wire    hu_pc_write_en,
            hu_if_id_write_en,
            hu_flush;   // Currently Not used

    HU hu_inst (
        .if_id_ra      (IR[3:2]),  // 2 Bits
        .if_id_rb      (IR[1:0]),  // 2 Bits
        .id_ex_rd      (reg_dist),  // 2 Bits
        .id_ex_mem_read(cu_mem_read),
        .BT            (bu_bt),  //todo: From Branch Unit
        .pc_en         (hu_pc_write_en),
        .if_id_en      (hu_if_id_write_en),
        .flush         (hu_flush)
    );

/*** AND Gates *****************************************************************************/
    assign pc_write = cu_pc_write_en & hu_pc_write_en;
    assign if_id_en = cu_if_id_write_en & hu_if_id_write_en;

/*** IF_ID_Reg *****************************************************************************/

    IF_ID_Reg if_id_reg_inst (
        .clk            (clk), // 1 bit, input
        .rst            (rstn), // 1 bit, input

        // CONTROL INPUTS
        .IF_ID_EN       (if_id_en), // 1 bit, input (Active Low Enable)
        .Flush          (hu_flush), // 1 bit, input (Active High Reset)

        // DATA INPUTS
        .PC_Plus_1_In   (pc_plus1), // 8 bits, input
        .Instruction_In (IR), // 8 bits, input
        .immby          (IR), // 8 bits, input
        .IP             (I_Port), // 8 bits, input

        // DATA OUTPUTS
        .PC_Plus_1_Out  (), // 8 bits, output
        .Instruction_Out(), // 8 bits, output
        .immbyout       (), // 8 bits, output
        .IP_out         ()  // 8 bits, output
    );

/*** Register File *****************************************************************************/
  
    mux4to1 rf_wd_mux (
        .d0(alu_out),
        .d1(mem_data_b_out), 
        .d2(I_Port),
        .d3(8'b0),
        .sel(cu_memtoreg),
        .out(rf_wd_mux_out)
    );

    wire [3 : 2]    ra_mux_out;
    mux2to1 #(.WIDTH(2)) ra_mux (
        .d0     (IR[3:2]),
        .d1     (2'b11),
        .sel    (cu_sp_sel),
        .out    (ra_mux_out)
    );                 

    Register_file regfile_inst (
        .clk        (clk),
        .rst        (rstn),
        .wenabel    (cu_reg_write),
        .SP_EN      (cu_sp_en),
        .SP_OP      (cu_sp_op),
        .ra         (ra_mux_out),
        .rb         (IR[1:0]),
        .rd         (reg_dist), 
        .write_data (rf_wd_mux_out),
        .ra_date    (ra_data_out),
        .rb_date    (rb_data_out)
    );

/*** ALU ****************************************************************************************/

    //todo: When doing Pipelined
    // mux4to1 alu_a_mux (
    //     .d0(ra_data_out),
    //     .d1(),  //todo ResWB    (FWD)
    //     .d2(),  //todo ResMem   (FWD)
    //     .d3(8'b0),  
    //     .sel(),
    //     .out()
    // );

    // mux4to1 alu_b_mux4to1 (
    //     .d0(ra_data_out),
    //     .d1(),  //todo ResWB    (FWD)
    //     .d2(),  //todo ResMem   (FWD)
    //     .d3(8'b0),  
    //     .sel(),
    //     .out()
    // );

    assign alu_a = ra_data_out; // Temporarily untill Fwd is done

    mux2to1 #(.WIDTH(8)) alu_b_mux2to1 (
        .d0     (rb_data_out),
        .d1     (IR),
        .sel    (cu_alu_src),
        .out    (alu_b)
    );

    ALU alu_inst (
        .A         (alu_a),
        .B         (alu_b),
        .sel       (cu_alu_op),
        .cin       (ccr_reg_out[2]),
        .out       (alu_out),
        .Z         (alu_z),
        .N         (alu_n),
        .C         (alu_c),
        .V         (alu_v),
        .flag_mask (alu_flag_mask)  // 4 Bits
    );

    CCR ccr_inst (
        .clk       (clk),
        .rst       (rstn),
        .Z         (alu_z),
        .N         (alu_n),
        .C         (alu_c),
        .V         (alu_v),
        .flag_en   (cu_flag_en),
        .flag_mask (alu_flag_mask), // 4 bits
        .CCR_reg   (ccr_reg_out)  // 4 bits
    );

/*** Branch Unit ****************************************************************************************/

    Branch_Unit branch_inst (
        .flag_mask (alu_flag_mask), // 4 bits
        .BTYPE     (cu_btype), // 3 bits
        .B_TAKE    (bu_bt), // 2 bits
        .PC_SRC    (pc_src)  // 2 bits
    );

/*** Output Port ****************************************************************************************/

    mux2to1 #(.WIDTH(8)) output_port_mux (
        .d0     (8'b00000000),
        .d1     (rb_data_out),
        .sel    (cu_io_write),
        .out    (O_Port)
    );

endmodule