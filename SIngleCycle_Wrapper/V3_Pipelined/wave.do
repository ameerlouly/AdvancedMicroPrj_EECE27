onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_CPU_FormatA_B/clk
add wave -noupdate /tb_CPU_FormatA_B/rstn
add wave -noupdate /tb_CPU_FormatA_B/I_Port
add wave -noupdate /tb_CPU_FormatA_B/int_sig
add wave -noupdate /tb_CPU_FormatA_B/O_Port
add wave -noupdate /tb_CPU_FormatA_B/R0
add wave -noupdate /tb_CPU_FormatA_B/R1
add wave -noupdate /tb_CPU_FormatA_B/R2
add wave -noupdate /tb_CPU_FormatA_B/SP
add wave -noupdate /tb_CPU_FormatA_B/PC
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/wenabel
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/SP_EN
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/SP_OP
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/ra
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/rb
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/rd
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/write_data
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/ra_date
add wave -noupdate -expand -group RF /tb_CPU_FormatA_B/uut/regfile_inst/rb_date
add wave -noupdate -group {rf_wd Mux} /tb_CPU_FormatA_B/uut/rf_wd_mux/d0
add wave -noupdate -group {rf_wd Mux} /tb_CPU_FormatA_B/uut/rf_wd_mux/d1
add wave -noupdate -group {rf_wd Mux} /tb_CPU_FormatA_B/uut/rf_wd_mux/d2
add wave -noupdate -group {rf_wd Mux} /tb_CPU_FormatA_B/uut/rf_wd_mux/d3
add wave -noupdate -group {rf_wd Mux} /tb_CPU_FormatA_B/uut/rf_wd_mux/sel
add wave -noupdate -group {rf_wd Mux} /tb_CPU_FormatA_B/uut/rf_wd_mux/out
add wave -noupdate -expand -group CU /tb_CPU_FormatA_B/uut/ctrl_inst/opcode
add wave -noupdate -expand -group CU /tb_CPU_FormatA_B/uut/ctrl_inst/ra
add wave -noupdate -expand -group CU /tb_CPU_FormatA_B/uut/ctrl_inst/MemToReg
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/IF_ID_EN
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/Flush
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/PC_Plus_1_In
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/Instruction_In
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/immby
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/IP
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/PC_Plus_1_Out
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/Instruction_Out
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/immbyout
add wave -noupdate -expand -group IF_ID /tb_CPU_FormatA_B/uut/if_id_reg_inst/IP_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/flush
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/inject_bubble
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/pc_plus1
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/IP
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/imm
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/BType
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/MemToReg
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/RegWrite
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/MemWrite
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/MemRead
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/UpdateFlags
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/RegDistidx
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ALU_src
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ALU_op
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/IO_Write
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/isCall
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ra_val_in
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/rb_val_in
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ra
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/rb
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/BType_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/MemToReg_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/RegWrite_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/MemWrite_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/MemRead_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/UpdateFlags_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/RegDistidx_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ALU_src_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ALU_op_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/IO_Write_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/isCall_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ra_val_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/rb_val_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/ra_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/rb_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/pc_plus1_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/IP_out
add wave -noupdate -group ID_EX /tb_CPU_FormatA_B/uut/id_ex_reg_inst/imm_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/pc_plus1
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/Rd2
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/IO_Write
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/RegDistidx
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/ALU_res
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/FW_value
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/MemWrite
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/MemToReg
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/RegWrite
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/IP
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/isCall
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/pc_plus1_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/Rd2_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/IO_Write_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/RegDistidx_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/ALU_res_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/FW_value_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/MemWrite_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/MemToReg_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/RegWrite_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/IP_out
add wave -noupdate -group Ex-Mem /tb_CPU_FormatA_B/uut/ex_mem_reg_inst/isCall_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/pc_plus1
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/RegDistidx
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/Rd2
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/ALU_res
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/data_B
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/MemToReg
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/RegWrite
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/IP
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/IO_Write
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/pc_plus1_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/RegDistidx_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/Rd2_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/ALU_res_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/data_B_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/MemToReg_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/RegWrite_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/IP_out
add wave -noupdate -group MEM-WB /tb_CPU_FormatA_B/uut/mem_wb_reg_inst/IO_Write_out
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/addr_a
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/data_out_a
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/addr_b
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/data_out_b
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/we_b
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/write_data_b
add wave -noupdate -group Mem /tb_CPU_FormatA_B/uut/mem_inst/mem
add wave -noupdate -group ALU -radix unsigned /tb_CPU_FormatA_B/uut/alu_inst/A
add wave -noupdate -group ALU -radix unsigned /tb_CPU_FormatA_B/uut/alu_inst/B
add wave -noupdate -group ALU -radix unsigned /tb_CPU_FormatA_B/uut/alu_inst/sel
add wave -noupdate -group ALU -radix unsigned /tb_CPU_FormatA_B/uut/alu_inst/cin
add wave -noupdate -group ALU /tb_CPU_FormatA_B/uut/alu_inst/out
add wave -noupdate -group ALU /tb_CPU_FormatA_B/uut/alu_inst/Z
add wave -noupdate -group ALU /tb_CPU_FormatA_B/uut/alu_inst/N
add wave -noupdate -group ALU /tb_CPU_FormatA_B/uut/alu_inst/C
add wave -noupdate -group ALU /tb_CPU_FormatA_B/uut/alu_inst/V
add wave -noupdate -group ALU /tb_CPU_FormatA_B/uut/alu_inst/flag_mask
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/RegWrite_Ex_MEM
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/RegWrite_Mem_WB
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/Rs_EX
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/Rt_EX
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/Rd_MEM
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/Rd_WB
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/ForwardA
add wave -noupdate -expand -group FU /tb_CPU_FormatA_B/uut/fu_inst/ForwardB
add wave -noupdate -group OUT_Mux /tb_CPU_FormatA_B/uut/output_port_mux/d0
add wave -noupdate -group OUT_Mux /tb_CPU_FormatA_B/uut/output_port_mux/d1
add wave -noupdate -group OUT_Mux /tb_CPU_FormatA_B/uut/output_port_mux/sel
add wave -noupdate -group OUT_Mux /tb_CPU_FormatA_B/uut/output_port_mux/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {263731 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 225
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
WaveRestoreZoom {0 ps} {281180 ps}
