module CPU_WrapperV2 (
    input clk,
    input rstn,
    input [7 : 0] I_Port,
    input [7 : 0] I_Port,
    input intr_sig,
    output [7 : 0] O_Port
);

/*** Program Counter *****************************************************************************/
    wire [7 : 0]    pc_next,    //* Completed
                    pc_current, //* Completed
                    pc_plus1; //* Completed
    wire            pc_write; //* Completed
    wire [1 : 0]    pc_src; //todo
    
    Pc PC(
        .clk(clk),
        .rst(rstn),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    assign pc_plus1 = pc_current + 1;
    assign pc_write = cu_pc_write_en & hu_pc_write_en;
    assign if_id_end = cu_if_id_write_en & hu_if_id_write_en;

    mux4to1 PC_MUX (
        .d0(pc_plus1),
        .d1(),  //todo FW
        .d2(),  //todo DataB
        .d3(8'b0),
        .sel(pc_src),
        .out(pc_next)
    );

/*** Memory *****************************************************************************/
    wire [7 : 0] IR;
    
    memory mem_inst (
        .clk            (clk),
        .rst            (rstn),
        .addr_a         (pc_current),
        .data_out_a     (IR),
        .addr_b         (), //todo: Mem Stage  
        .data_out_b     (), //todo: Mem Stage
        .we_b           (), //todo: Mem Stage
        .write_data_b   ()  //todo: Mem Stage
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

    // Execut Wires
    wire    cu_alu_src;
    wire [3 : 0]    cu_alu_op;
    wire cu_flag_en;

    // Memory Wires
    wire    cu_mem_read,
            cu_mem_write;

    Control_unit ctrl_inst (
        .clk            (clk),
        .rst            (rstn),
        .INTR           (intr_sig),
        .opcode         (IR[7:4]),
        .ra             (IR[3:2]),
        // Fetch Control
        .PC_Write_En    (cu_pc_write),
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
        .BTYPE          (), // 3 Bits
        .Alu_src        (cu_alu_src),
        .UpdateFlags    (cu_flag_en),
        // Memory Control
        .IS_CALL        (),
        .MemToReg       (), // 2 Bits
        .MemWrite       (),
        .MemRead        (cu_mem_read),
        // Write-Back Control
        .IO_Write       ()
    );

    wire reg_dist;
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
        .BT            (),  //todo: From Branch Unit
        .pc_en         (hu_pc_write_en),
        .if_id_en      (hu_if_id_write_en),
        .flush         (hu_flush)
    );

/*** Register File *****************************************************************************/

    wire [7 : 0]    ra_data_out,
                    rb_data_out;

    Register_file regfile_inst (
        .clk        (clk),
        .rst        (rstn),
        .wenabel    (cu_reg_write),
        .SP_EN      (cu_sp_en),
        .SP_OP      (cu_sp_op),
        .ra         (ra_mux_out),
        .rb         (IR[1:0]),
        .rd         (reg_dist), 
        .write_data (),
        .ra_date    (ra_data_out),
        .rb_date    (rb_data_out)
    );

    wire [3 : 2]    ra_mux_out;
    mux2to1 #(.WIDTH(2)) ra_mux (
        .d0     (IR[3:2]),
        .d1     (2'b11),
        .sel    (cu_sp_sel),
        .out    (ra_mux_out)
    );

/*** ALU ****************************************************************************************/

    wire [7 : 0]    alu_a,
                    alu_b,
                    alu_out;

    wire            alu_z,
                    alu_n,
                    alu_c,
                    alu_v;

    wire [3 : 0]    alu_flag_mask,
                    ccr_reg_out;

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


endmodule