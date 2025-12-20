onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_OutputPort/uut/int_sig
add wave -noupdate -expand -group PC /tb_OutputPort/uut/PC/clk
add wave -noupdate -expand -group PC /tb_OutputPort/uut/PC/rst
add wave -noupdate -expand -group PC /tb_OutputPort/uut/PC/pc_write
add wave -noupdate -expand -group PC /tb_OutputPort/uut/PC/pc_next
add wave -noupdate -expand -group PC -radix hexadecimal /tb_OutputPort/uut/PC/pc_current
add wave -noupdate -expand -group {Interrupt mux} /tb_OutputPort/uut/u_interruptmux/d0
add wave -noupdate -expand -group {Interrupt mux} /tb_OutputPort/uut/u_interruptmux/d1
add wave -noupdate -expand -group {Interrupt mux} /tb_OutputPort/uut/u_interruptmux/d2
add wave -noupdate -expand -group {Interrupt mux} /tb_OutputPort/uut/u_interruptmux/d3
add wave -noupdate -expand -group {Interrupt mux} /tb_OutputPort/uut/u_interruptmux/sel
add wave -noupdate -expand -group {Interrupt mux} /tb_OutputPort/uut/u_interruptmux/out
add wave -noupdate -expand -group PCMux /tb_OutputPort/uut/PC_MUX/d0
add wave -noupdate -expand -group PCMux /tb_OutputPort/uut/PC_MUX/d1
add wave -noupdate -expand -group PCMux /tb_OutputPort/uut/PC_MUX/d2
add wave -noupdate -expand -group PCMux /tb_OutputPort/uut/PC_MUX/d3
add wave -noupdate -expand -group PCMux /tb_OutputPort/uut/PC_MUX/sel
add wave -noupdate -expand -group PCMux /tb_OutputPort/uut/PC_MUX/out
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/clk
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/rst
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/IF_ID_EN
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/Flush
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/PC_Plus_1_In
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/Instruction_In
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/immby
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/IP
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/PC_Plus_1_Out
add wave -noupdate -expand -group IF/ID -radix hexadecimal /tb_OutputPort/uut/if_id_reg_inst/Instruction_Out
add wave -noupdate -expand -group IF/ID -radix hexadecimal /tb_OutputPort/uut/if_id_reg_inst/immbyout
add wave -noupdate -expand -group IF/ID /tb_OutputPort/uut/if_id_reg_inst/IP_out
add wave -noupdate -expand -group MEM /tb_OutputPort/uut/mem_inst/clk
add wave -noupdate -expand -group MEM /tb_OutputPort/uut/mem_inst/rst
add wave -noupdate -expand -group MEM -radix unsigned /tb_OutputPort/uut/mem_inst/addr_a
add wave -noupdate -expand -group MEM -radix hexadecimal /tb_OutputPort/uut/mem_inst/data_out_a
add wave -noupdate -expand -group MEM /tb_OutputPort/uut/mem_inst/addr_b
add wave -noupdate -expand -group MEM /tb_OutputPort/uut/mem_inst/data_out_b
add wave -noupdate -expand -group MEM /tb_OutputPort/uut/mem_inst/we_b
add wave -noupdate -expand -group MEM /tb_OutputPort/uut/mem_inst/write_data_b
add wave -noupdate -expand -group MEM -childformat {{{/tb_OutputPort/uut/mem_inst/mem[70]} -radix hexadecimal}} -subitemconfig {{/tb_OutputPort/uut/mem_inst/mem[70]} {-height 15 -radix hexadecimal}} /tb_OutputPort/uut/mem_inst/mem
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/clk
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/rst
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/wenabel
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/SP_EN
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/SP_OP
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/ra
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/rb
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/rd
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/write_data
add wave -noupdate -expand -group {REGISTER File} -radix hexadecimal /tb_OutputPort/uut/regfile_inst/ra_date
add wave -noupdate -expand -group {REGISTER File} /tb_OutputPort/uut/regfile_inst/rb_date
add wave -noupdate -expand -group {REGISTER File} -childformat {{{/tb_OutputPort/uut/regfile_inst/regs[0]} -radix unsigned} {{/tb_OutputPort/uut/regfile_inst/regs[1]} -radix unsigned} {{/tb_OutputPort/uut/regfile_inst/regs[2]} -radix unsigned} {{/tb_OutputPort/uut/regfile_inst/regs[3]} -radix unsigned}} -expand -subitemconfig {{/tb_OutputPort/uut/regfile_inst/regs[0]} {-height 15 -radix unsigned} {/tb_OutputPort/uut/regfile_inst/regs[1]} {-height 15 -radix unsigned} {/tb_OutputPort/uut/regfile_inst/regs[2]} {-height 15 -radix unsigned} {/tb_OutputPort/uut/regfile_inst/regs[3]} {-height 15 -radix unsigned}} /tb_OutputPort/uut/regfile_inst/regs
add wave -noupdate -group {SP Mux} /tb_OutputPort/uut/ra_mux/WIDTH
add wave -noupdate -group {SP Mux} /tb_OutputPort/uut/ra_mux/d0
add wave -noupdate -group {SP Mux} /tb_OutputPort/uut/ra_mux/d1
add wave -noupdate -group {SP Mux} /tb_OutputPort/uut/ra_mux/sel
add wave -noupdate -group {SP Mux} /tb_OutputPort/uut/ra_mux/out
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/clk
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/rst
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/INTR
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/opcode
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/ra
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/PC_Write_En
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/IF_ID_Write_En
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/Inject_Bubble
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/Inject_Int
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/RegWrite
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/RegDist
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/SP_SEL
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/SP_EN
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/SP_OP
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/Alu_Op
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/BTYPE
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/Alu_src
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/IS_CALL
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/UpdateFlags
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/MemToReg
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/MemWrite
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/MemRead
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/loop_sel
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/IO_Write
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/current_state
add wave -noupdate -expand -group CU /tb_OutputPort/uut/ctrl_inst/next_state
add wave -noupdate -expand -group {REG DIST MUX} /tb_OutputPort/uut/reg_dist_mux/d0
add wave -noupdate -expand -group {REG DIST MUX} /tb_OutputPort/uut/reg_dist_mux/d1
add wave -noupdate -expand -group {REG DIST MUX} /tb_OutputPort/uut/reg_dist_mux/sel
add wave -noupdate -expand -group {REG DIST MUX} /tb_OutputPort/uut/reg_dist_mux/out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/clk
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/rst
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/flush
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/inject_bubble
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/pc_plus1
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/IP
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/imm
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/BType
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/MemToReg
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/RegWrite
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/MemWrite
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/MemRead
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/UpdateFlags
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/RegDistidx
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ALU_src
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ALU_op
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/IO_Write
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/isCall
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/loop_sel
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ra_val_in
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/rb_val_in
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ra
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/rb
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/BType_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/MemToReg_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/RegWrite_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/MemWrite_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/MemRead_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/UpdateFlags_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/RegDistidx_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ALU_src_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ALU_op_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/IO_Write_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/isCall_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/loop_sel_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ra_val_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/rb_val_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/ra_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/rb_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/pc_plus1_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/IP_out
add wave -noupdate -expand -group ID/EX /tb_OutputPort/uut/id_ex_reg_inst/imm_out
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/if_id_ra
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/if_id_rb
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/id_ex_rd
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/id_ex_mem_read
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/opcode
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/BT
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/pc_en
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/if_id_en
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/flush
add wave -noupdate -group HU /tb_OutputPort/uut/hu_inst/control_zero
add wave -noupdate -expand -group ALU -radix hexadecimal /tb_OutputPort/uut/alu_inst/A
add wave -noupdate -expand -group ALU -radix hexadecimal /tb_OutputPort/uut/alu_inst/B
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/sel
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/cin
add wave -noupdate -expand -group ALU -radix hexadecimal /tb_OutputPort/uut/alu_inst/out
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/Z
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/N
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/C
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/V
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/flag_mask
add wave -noupdate -expand -group ALU /tb_OutputPort/uut/alu_inst/temp_wide
add wave -noupdate -expand -group FU /tb_OutputPort/uut/fu_inst/RegWrite_Ex_MEM
add wave -noupdate -expand -group FU /tb_OutputPort/uut/fu_inst/RegWrite_Mem_WB
add wave -noupdate -expand -group FU /tb_OutputPort/uut/fu_inst/Rs_EX
add wave -noupdate -expand -group FU /tb_OutputPort/uut/fu_inst/Rt_EX
add wave -noupdate -expand -group FU -color Cyan /tb_OutputPort/uut/fu_inst/Rd_MEM
add wave -noupdate -expand -group FU -color Cyan /tb_OutputPort/uut/fu_inst/Rd_WB
add wave -noupdate -expand -group FU /tb_OutputPort/uut/fu_inst/ForwardA
add wave -noupdate -expand -group FU /tb_OutputPort/uut/fu_inst/ForwardB
add wave -noupdate -expand -group {FWa mux} /tb_OutputPort/uut/alu_a_mux/d0
add wave -noupdate -expand -group {FWa mux} /tb_OutputPort/uut/alu_a_mux/d1
add wave -noupdate -expand -group {FWa mux} /tb_OutputPort/uut/alu_a_mux/d2
add wave -noupdate -expand -group {FWa mux} /tb_OutputPort/uut/alu_a_mux/d3
add wave -noupdate -expand -group {FWa mux} /tb_OutputPort/uut/alu_a_mux/sel
add wave -noupdate -expand -group {FWa mux} /tb_OutputPort/uut/alu_a_mux/out
add wave -noupdate -expand -group {FWb mux} /tb_OutputPort/uut/alu_b_mux4to1/d0
add wave -noupdate -expand -group {FWb mux} /tb_OutputPort/uut/alu_b_mux4to1/d1
add wave -noupdate -expand -group {FWb mux} /tb_OutputPort/uut/alu_b_mux4to1/d2
add wave -noupdate -expand -group {FWb mux} /tb_OutputPort/uut/alu_b_mux4to1/d3
add wave -noupdate -expand -group {FWb mux} /tb_OutputPort/uut/alu_b_mux4to1/sel
add wave -noupdate -expand -group {FWb mux} -radix hexadecimal /tb_OutputPort/uut/alu_b_mux4to1/out
add wave -noupdate -expand -group {Imm mux} /tb_OutputPort/uut/alu_b_src_mux/d0
add wave -noupdate -expand -group {Imm mux} /tb_OutputPort/uut/alu_b_src_mux/d1
add wave -noupdate -expand -group {Imm mux} /tb_OutputPort/uut/alu_b_src_mux/d2
add wave -noupdate -expand -group {Imm mux} /tb_OutputPort/uut/alu_b_src_mux/d3
add wave -noupdate -expand -group {Imm mux} /tb_OutputPort/uut/alu_b_src_mux/sel
add wave -noupdate -expand -group {Imm mux} /tb_OutputPort/uut/alu_b_src_mux/out
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/clk
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/rst
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/Z
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/N
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/C
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/V
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/flag_en
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/flag_mask
add wave -noupdate -group {CCR } /tb_OutputPort/uut/ccr_inst/CCR_reg
add wave -noupdate -group BU /tb_OutputPort/uut/branch_inst/flag_mask
add wave -noupdate -group BU /tb_OutputPort/uut/branch_inst/BTYPE
add wave -noupdate -group BU /tb_OutputPort/uut/branch_inst/PC_SRC
add wave -noupdate -group BU /tb_OutputPort/uut/branch_inst/B_TAKE
add wave -noupdate -group LOOP /tb_OutputPort/uut/loop_sel_mux/d0
add wave -noupdate -group LOOP /tb_OutputPort/uut/loop_sel_mux/d1
add wave -noupdate -group LOOP /tb_OutputPort/uut/loop_sel_mux/sel
add wave -noupdate -group LOOP /tb_OutputPort/uut/loop_sel_mux/out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/clk
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/rst
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/pc_plus1
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/Rd2
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/IO_Write
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/RegDistidx
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/ALU_res
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/FW_value
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/MemWrite
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/MemToReg
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/RegWrite
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/IP
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/isCall
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/pc_plus1_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/Rd2_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/IO_Write_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/RegDistidx_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/ALU_res_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/FW_value_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/MemWrite_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/MemToReg_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/RegWrite_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/IP_out
add wave -noupdate -expand -group EX/MEM /tb_OutputPort/uut/ex_mem_reg_inst/isCall_out
add wave -noupdate -group IP /tb_OutputPort/uut/exmem_IP_mux/d0
add wave -noupdate -group IP /tb_OutputPort/uut/exmem_IP_mux/d1
add wave -noupdate -group IP /tb_OutputPort/uut/exmem_IP_mux/d2
add wave -noupdate -group IP /tb_OutputPort/uut/exmem_IP_mux/d3
add wave -noupdate -group IP /tb_OutputPort/uut/exmem_IP_mux/sel
add wave -noupdate -group IP /tb_OutputPort/uut/exmem_IP_mux/out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/clk
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/rst
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/pc_plus1
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/RegDistidx
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/Rd2
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/ALU_res
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/data_B
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/MemToReg
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/RegWrite
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/IP
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/IO_Write
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/FW_val
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/pc_plus1_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/RegDistidx_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/Rd2_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/ALU_res_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/data_B_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/MemToReg_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/RegWrite_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/IP_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/IO_Write_out
add wave -noupdate -expand -group MEM/WB /tb_OutputPort/uut/mem_wb_reg_inst/FW_val_out
add wave -noupdate -expand -group OP /tb_OutputPort/uut/output_port_mux/d0
add wave -noupdate -expand -group OP /tb_OutputPort/uut/output_port_mux/d1
add wave -noupdate -expand -group OP /tb_OutputPort/uut/output_port_mux/sel
add wave -noupdate -expand -group OP /tb_OutputPort/uut/output_port_mux/out
add wave -noupdate -expand -group {WB Mux} /tb_OutputPort/uut/rf_wd_mux/d0
add wave -noupdate -expand -group {WB Mux} /tb_OutputPort/uut/rf_wd_mux/d1
add wave -noupdate -expand -group {WB Mux} /tb_OutputPort/uut/rf_wd_mux/d2
add wave -noupdate -expand -group {WB Mux} /tb_OutputPort/uut/rf_wd_mux/d3
add wave -noupdate -expand -group {WB Mux} /tb_OutputPort/uut/rf_wd_mux/sel
add wave -noupdate -expand -group {WB Mux} /tb_OutputPort/uut/rf_wd_mux/out
add wave -noupdate -expand -group {interrupt for cu} /tb_OutputPort/uut/u_interrupt_reg/clk
add wave -noupdate -expand -group {interrupt for cu} /tb_OutputPort/uut/u_interrupt_reg/rst
add wave -noupdate -expand -group {interrupt for cu} /tb_OutputPort/uut/u_interrupt_reg/int_sig
add wave -noupdate -expand -group {interrupt for cu} /tb_OutputPort/uut/u_interrupt_reg/int_sig_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25470 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {300300 ps}
