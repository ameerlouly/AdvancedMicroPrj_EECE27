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
    wire            bu_bt;

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

// IDEX Output Wires
    wire [2:0] idex_BType;       // output [2:0]
    wire [1:0] idex_MemToReg;    // output [1:0]
    wire       idex_RegWrite;    // output [0:0]
    wire       idex_MemWrite;    // output [0:0]
    wire       idex_MemRead;     // output [0:0]
    wire       idex_UpdateFlags; // output [0:0]
    wire [1:0] idex_RegDistidx;  // output [1:0]
    wire [1:0] idex_ALU_src;     // output [0:0]
    wire [3:0] idex_ALU_op;      // output [3:0]
    wire       idex_IO_Write;    // output [0:0]
    wire       idex_isCall;

    wire [7:0] idex_ra_val;     // output [7:0]
    wire [7:0] idex_rb_val;     // output [7:0]
    wire [1:0] idex_ra;         // output [1:0]
    wire [1:0] idex_rb;         // output [1:0]

    wire [7:0] idex_pc_plus1;   // output [7:0]
    wire [7:0] idex_IP;         // output [7:0]
    wire [7:0] idex_imm;        // output [7:0]



// Ex-mem output wires
    wire [7:0]      exmem_pc_plus1;    // output [7:0]
    wire [7:0]      exmem_Rd2;         // output [7:0]
    wire            exmem_IO_Write;    // output [0:0]
    wire [1:0]      exmem_RegDistidx;  // output [1:0]
    wire [7:0]      exmem_ALU_res;     // output [7:0]
    wire [7:0]      exmem_FW_value;    // output [7:0]
    wire            exmem_MemWrite;    // output [0:0]
    wire [1:0]      exmem_MemToReg;    // output [1:0]
    wire            exmem_RegWrite;    // output [0:0]
    wire [7:0]      exmem_IP;          // output [7:0]
    wire            exmem_isCall;      // output [0:0]

    wire [7 : 0]    exmem_IP_mux_out;

// Mem-WB Output Wires
    wire [7:0] memwb_pc_plus1;    // output [7:0]
    wire [1:0] memwb_RegDistidx;  // output [1:0]
    wire [7:0] memwb_Rd2;         // output [7:0]
    wire [7:0] memwb_ALU_res;     // output [7:0]
    wire [7:0] memwb_data_B;      // output [7:0]
    wire [1:0] memwb_MemToReg;    // output [1:0]
    wire       memwb_RegWrite;    // output [0:0]
    wire [7:0] memwb_IP;          // output [7:0]
    wire       memwb_IO_Write;


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
        .d1(idex_rb_val), 
        .d2(mem_data_b_out),
        .d3(8'b00000000),
        .sel(pc_src),
        .out(pc_next)
    );

/*** Memory *****************************************************************************/
    wire [7 : 0] IR;

    wire [7 : 0]    WriteD_mux_out;

    mux2to1 #(.WIDTH(8)) mem_writeD_b_mux2to1 (
        .d0     (exmem_FW_value),
        .d1     (exmem_pc_plus1),
        .sel    (exmem_isCall),
        .out    (WriteD_mux_out)
    );

    memory mem_inst (
        .clk            (clk),
        .rst            (rstn),
        .addr_a         (pc_current),
        .data_out_a     (IR),
        .addr_b         (exmem_IP_mux_out), 
        .data_out_b     (mem_data_b_out), 
        .we_b           (exmem_MemWrite), 
        .write_data_b   (WriteD_mux_out)  
    );

/*** IF_ID_Reg *****************************************************************************/
    wire [7 : 0]    ifid_pc_plus1,
                    ifid_IR,
                    ifid_immby,
                    ifid_IP;
    // HU Wires
    wire            hu_flush;

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
        .PC_Plus_1_Out  (ifid_pc_plus1), // 8 bits, output
        .Instruction_Out(ifid_IR), // 8 bits, output
        .immbyout       (ifid_immby), // 8 bits, output
        .IP_out         (ifid_IP)  // 8 bits, output
    );

/*** Control Unit *****************************************************************************/
    
    // Fetch Wires
    wire    cu_pc_write_en,
            cu_if_id_write_en,
            cu_inject_bubble,
            cu_inject_int;

    // Decode Wires
    wire    cu_sp_en,
            cu_sp_op,
            cu_reg_write,
            cu_sp_sel,
            cu_reg_dist;

    // Execute Wires
    wire [1 : 0]   cu_alu_src;
    wire [3 : 0]    cu_alu_op;
    wire cu_flag_en;
    wire [2 : 0]    cu_btype;

    // Memory Wires
    wire [1 : 0]    cu_memtoreg;

    // Write-Back Control
    wire cu_io_write;
    wire loop_sel;

    Control_unit ctrl_inst (
        .clk            (clk),
        .rst            (rstn),
        .INTR           (int_sig),
        .opcode         (ifid_IR[7:4]),
        .ra             (ifid_IR[3:2]),
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
        .loop_sel       (loop_sel),
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
        .d0     (ifid_IR[3:2]),
        .d1     (ifid_IR[1:0]),
        .sel    (cu_reg_dist),
        .out    (reg_dist)
    );

/*** Hazard Unit *****************************************************************************/

    //todo: All of these will be taken and given to register later
    wire    hu_pc_write_en,
            hu_if_id_write_en;
    wire    hu_bubble;

    HU hu_inst (
        // ID Stage inputs
        .opcode        (ifid_IR[7:4]),
        .if_id_ra      (ifid_IR[3:2]),  // 2 Bits
        .if_id_rb      (ifid_IR[1:0]),  // 2 Bits

        // EX Stage inputs
        .id_ex_rd      (idex_RegDistidx),  // 2 Bits
        .id_ex_mem_read(idex_MemRead),
        .id_ex_reg_write(idex_RegWrite),

        //Inputs from MEM
        .ex_mem_rd(exmem_RegDistidx),
        .ex_mem_reg_write(exmem_RegWrite),

        // Inputs from Logic
        .branch_take   (bu_bt),

        .pc_en         (hu_pc_write_en),
        .if_id_en      (hu_if_id_write_en),
        .flush         (hu_flush),
        .bubble        (hu_bubble)
    );

/*** LOGIC Gates *****************************************************************************/
    wire    bubble_wire;

    assign pc_write = cu_pc_write_en & hu_pc_write_en;
    assign if_id_en = cu_if_id_write_en & hu_if_id_write_en;

    assign bubble_wire = hu_bubble | cu_inject_bubble;

/*** Register File *****************************************************************************/
  
    mux4to1 rf_wd_mux (
        .d0(memwb_ALU_res),
        .d1(memwb_data_B), 
        .d2(memwb_IP),
        .d3(8'b0),
        .sel(memwb_MemToReg),
        .out(rf_wd_mux_out)
    );

    wire [3 : 2]    ra_mux_out;
    mux2to1 #(.WIDTH(2)) ra_mux (
        .d0     (ifid_IR[3:2]),
        .d1     (2'b11),
        .sel    (cu_sp_sel),
        .out    (ra_mux_out)
    );                 

    Register_file regfile_inst (
        .clk        (clk),
        .rst        (rstn),
        .wenabel    (memwb_RegWrite),
        .SP_EN      (cu_sp_en),
        .SP_OP      (cu_sp_op),
        .ra         (ra_mux_out),
        .rb         (ifid_IR[1:0]),
        .rd         (memwb_RegDistidx), 
        .write_data (rf_wd_mux_out),
        .ra_date    (ra_data_out),
        .rb_date    (rb_data_out)
    );

/*** ID_EX Reg *****************************************************************************/

    id_ex_reg id_ex_reg_inst (
        .clk            (clk), // 1 bit, input
        .rst            (rstn), // 1 bit, input
        .flush          (hu_flush || cu_inject_bubble), // 1 bit, input //todo Might Need to remove
        .inject_bubble  (bubble_wire), // 1 bit, input

        // ---------- Data inputs ----------
        .pc_plus1       (ifid_pc_plus1), // 8 bits, input
        .IP             (ifid_IP), // 8 bits, input
        .imm            (ifid_immby), // 8 bits, input

        // ---------- Control inputs from ID stage ----------
        .BType          (cu_btype), // 3 bits, input
        .MemToReg       (cu_memtoreg), // 2 bits, input
        .RegWrite       (cu_reg_write), // 1 bit, input
        .MemWrite       (cu_mem_write), // 1 bit, input
        .MemRead        (cu_mem_read), // 1 bit, input
        .UpdateFlags    (cu_flag_en), // 1 bit, input
        .RegDistidx     (reg_dist), // 2 bits, input
        .ALU_src        (cu_alu_src), // 1 bit, input
        .ALU_op         (cu_alu_op), // 4 bits, input
        .IO_Write       (cu_io_write), // 1 bit, input
        .isCall         (cu_isCall),

        // ---------- Data inputs from ID stage ----------
        .ra_val_in      (ra_data_out), // 8 bits, input
        .rb_val_in      (rb_data_out), // 8 bits, input
        .ra             (ifid_IR[3:2]), // 2 bits, input
        .rb             (ifid_IR[1:0]), // 2 bits, input

        // ---------- Control outputs to EX stage ----------
        .BType_out       (idex_BType),       // 3 bits, output
        .MemToReg_out    (idex_MemToReg),    // 2 bits, output
        .RegWrite_out    (idex_RegWrite),    // 1 bit, output
        .MemWrite_out    (idex_MemWrite),    // 1 bit, output
        .MemRead_out     (idex_MemRead),     // 1 bit, output
        .UpdateFlags_out (idex_UpdateFlags), // 1 bit, output
        .RegDistidx_out  (idex_RegDistidx),  // 2 bits, output
        .ALU_src_out     (idex_ALU_src),     // 1 bit, output
        .ALU_op_out      (idex_ALU_op),      // 4 bits, output
        .IO_Write_out    (idex_IO_Write),     // 1 bit, output
        .isCall_out      (idex_isCall),

        // ---------- Data outputs to EX stage ----------
        .ra_val_out   (idex_ra_val),   // 8 bits, output
        .rb_val_out   (idex_rb_val),   // 8 bits, output
        .ra_out       (idex_ra),       // 2 bits, output
        .rb_out       (idex_rb),       // 2 bits, output

        // ---------- PC_plus1 out, IP_out, immediate ----------
        .pc_plus1_out (idex_pc_plus1), // 8 bits, output
        .IP_out       (idex_IP),       // 8 bits, output
        .imm_out      (idex_imm)       // 8 bits, output
    );

/*** Forwarding Unit ****************************************************************************************/

    wire [1 : 0]    fu_FWA,
                    fu_FWB;

    FU fu_inst (
        // ---------------- Control Signals ----------------
        .RegWrite_Ex_MEM (exmem_RegWrite),   // 1 bit, input
        .RegWrite_Mem_WB (memwb_RegWrite),   // 1 bit, Input

        // ---------------- Register Addresses ----------------
        .Rs_EX           (idex_ra), // 2 bits, input   idex
        .Rt_EX           (idex_rb), // 2 bits, input   idex
        .Rd_MEM          (exmem_RegDistidx), // 2 bits, input 
        .Rd_WB           (memwb_RegDistidx), // 2 bits, input

        // ---------------- Outputs to EX Stage ----------------
        .ForwardA        (fu_FWA), // 2 bits, output
        .ForwardB        (fu_FWB)  // 2 bits, output
    );

/*** ALU ****************************************************************************************/

    mux4to1 alu_a_mux (
        .d0(idex_ra_val),
        .d1(rf_wd_mux_out),  //? Make sure its Correct
        .d2(exmem_IP_mux_out),  //? Make sure its Correct
        .d3(8'b0),  
        .sel(fu_FWA),
        .out(alu_a)
    );

    wire [7 : 0]    alu_b_mux_out;
    mux4to1 alu_b_mux4to1 (
        .d0(idex_rb_val),
        .d1(rf_wd_mux_out),  //? Make sure its Correct
        .d2(exmem_IP_mux_out),  //? Make sure its Correct
        .d3(8'b0),  
        .sel(fu_FWB),
        .out(alu_b_mux_out)
    );

    // assign alu_a = ra_data_out; // Temporarily untill Fwd is done
    //! Old Arch MUX
    // mux2to1 #(.WIDTH(8)) alu_b_mux2to1 (
    //     .d0     (alu_b_mux_out),
    //     .d1     (idex_imm),
    //     .sel    (idex_ALU_src),
    //     .out    (alu_b)
    // );

    mux4to1 alu_b_src_mux (
        .d0(alu_b_mux_out),
        .d1(idex_imm), 
        .d2(alu_a),
        .d3(8'b00000000),
        .sel(idex_ALU_src),
        .out(alu_b)
    );

    ALU alu_inst (
        .A         (alu_a),
        .B         (alu_b),
        .sel       (idex_ALU_op),
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
        .flag_en   (idex_UpdateFlags),
        .flag_mask (alu_flag_mask), // 4 bits
        .CCR_reg   (ccr_reg_out)  // 4 bits
    );

/*** Branch Unit ****************************************************************************************/

    Branch_Unit branch_inst (
        .flag_mask (ccr_reg_out), // 4 bits
        .BTYPE     (idex_BType), // 3 bits
        .B_TAKE    (bu_bt), // 2 bits
        .PC_SRC    (pc_src)  // 2 bits
    );

/*** EX-MEM Register ****************************************************************************************/

    EX_MEM_reg ex_mem_reg_inst (
        // ---------------- Inputs ----------------
        .clk        (clk), // 1 bit, input
        .rst        (rstn), // 1 bit, input
        .pc_plus1   (idex_pc_plus1), // 8 bits, input
        .Rd2        (idex_rb_val), // 8 bits, input //? Make sure its correct
        .IO_Write   (idex_IO_Write), // 1 bit, input
        .RegDistidx (idex_RegDistidx), // 2 bits, input
        .ALU_res    (alu_out), // 8 bits, input
        .FW_value   (alu_b_mux_out), // 8 bits, input
        .MemWrite   (idex_MemWrite), // 1 bit, input
        .MemToReg   (idex_MemToReg), // 2 bits, input
        .RegWrite   (idex_RegWrite), // 1 bit, input
        .IP         (idex_IP), // 8 bits, input
        .isCall     (idex_isCall), // 1 bit, input

        // ---------------- Outputs ----------------
        .pc_plus1_out   (exmem_pc_plus1),    // 8 bits, output
        .Rd2_out        (exmem_Rd2),         // 8 bits, output
        .IO_Write_out   (exmem_IO_Write),    // 1 bit, output
        .RegDistidx_out (exmem_RegDistidx),  // 2 bits, output
        .ALU_res_out    (exmem_ALU_res),     // 8 bits, output
        .FW_value_out   (exmem_FW_value),    // 8 bits, output
        .MemWrite_out   (exmem_MemWrite),    // 1 bit, output
        .MemToReg_out   (exmem_MemToReg),    // 2 bits, output
        .RegWrite_out   (exmem_RegWrite),    // 1 bit, output
        .IP_out         (exmem_IP),          // 8 bits, output
        .isCall_out     (exmem_isCall)       // 1 bit, output
    );

    //! New to Architecture
    //** New Addition **//
    mux4to1 exmem_IP_mux (
        .d0(exmem_ALU_res),
        .d1(exmem_ALU_res),  //? Make sure its Correct
        .d2(exmem_IP),  //? Make sure its Correct
        .d3(exmem_ALU_res),  
        .sel(exmem_MemToReg),
        .out(exmem_IP_mux_out)
    );

/*** Mem-WB Register ****************************************************************************************/

    MEM_WB_Reg mem_wb_reg_inst (
        // ---------------- Inputs ----------------
        .clk        (clk), // 1 bit, input
        .rst        (rstn), // 1 bit, input
        .pc_plus1   (exmem_pc_plus1), // 8 bits, input
        .RegDistidx (exmem_RegDistidx), // 2 bits, input
        .Rd2        (exmem_Rd2), // 8 bits, input
        .ALU_res    (exmem_ALU_res), // 8 bits, input
        .data_B     (mem_data_b_out), // 8 bits, input
        .MemToReg   (exmem_MemToReg), // 2 bits, input
        .RegWrite   (exmem_RegWrite), // 1 bit, input
        .IP         (exmem_IP), // 8 bits, input
        .IO_Write   (exmem_IO_Write), // 1 Bit, Input

        // ---------------- Outputs ----------------
        .pc_plus1_out   (memwb_pc_plus1),   // 8 bits, output
        .RegDistidx_out (memwb_RegDistidx), // 2 bits, output
        .Rd2_out        (memwb_Rd2),        // 8 bits, output
        .ALU_res_out    (memwb_ALU_res),    // 8 bits, output
        .data_B_out     (memwb_data_B),     // 8 bits, output
        .MemToReg_out   (memwb_MemToReg),   // 2 bits, output
        .RegWrite_out   (memwb_RegWrite),   // 1 bit, output
        .IP_out         (memwb_IP),         // 8 bits, output
        .IO_Write_out   (memwb_IO_Write)    // 1 Bit, output
    );



/*** Output Port ****************************************************************************************/

    mux2to1 #(.WIDTH(8)) output_port_mux (
        .d0     (8'b00000000),
        .d1     (memwb_Rd2),
        .sel    (memwb_IO_Write),
        .out    (O_Port)
    );

endmodule