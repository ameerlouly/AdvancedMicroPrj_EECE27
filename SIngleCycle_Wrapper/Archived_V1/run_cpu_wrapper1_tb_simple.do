vlib work
vmap work work

# Compile RTL and testbench (absolute paths to avoid cwd issues)
vlog -sv "d:/Github/AdvancedMicroPrj_EECE27/Control Unit/control_unit.v" \
          "d:/Github/AdvancedMicroPrj_EECE27/ALU/ALU.v" \
          "d:/Github/AdvancedMicroPrj_EECE27/Register File/Register_file.v" \
          "d:/Github/AdvancedMicroPrj_EECE27/Memory/Memory.v" \
          "d:/Github/AdvancedMicroPrj_EECE27/CCR/CCR.v" \
          "d:/Github/AdvancedMicroPrj_EECE27/SIngleCycle_Wrapper/CPU_Wrapper1.v" \
          "d:/Github/AdvancedMicroPrj_EECE27/SIngleCycle_Wrapper/CPU_Wrapper1_tb.v"

# Launch simulator with accessibility for signal viewing
vsim -voptargs=+acc work.CPU_Wrapper1_tb

# Add all waves (matches your example)
add wave *

# Run until testbench finishes
run -all

# Quit simulator cleanly
quit -sim
