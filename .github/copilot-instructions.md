# Copilot / AI Agent Instructions for AdvancedMicroPrj_EECE27

Purpose

- Help AI coding agents be productive in this Verilog single-cycle CPU repository.

Big picture (short)

- This is a small single-cycle CPU implementation in Verilog. The top-level wrapper for quick integration and tests is `SIngleCycle_Wrapper/CPU_Wrapper1.v` which instantiates the Control Unit, ALU, Register File, CCR (condition-code register), PC logic and memory interface.
- Control logic: `Control Unit/control_unit.v` performs combinational decode (opcode fields in `ir[7:4]`, ra= `ir[3:2]`, rb=`ir[1:0]`). ALU behavior is implemented in `ALU/ALU.v`. Registers are in `Register File/Register_file.v`. Flags are managed by `CCR/CCR.v`.

Key dataflows & interfaces (concrete examples)

- Instruction fetch: `CPU_Wrapper1.v` sets `mem_addr_a = pc_current` and `ir = Instr_in`. PC increments by `pc_plus1 = pc_current + 1` and `pc_src` selects the next PC.
- Register file: asynchronous reads (`assign ra_date = regs[ra];`) and synchronous writes on `posedge clk` / `negedge rst` with active-low reset. Stack pointer `R3` initialized to 255.
- WB source encodings (used by `cpu_wrapper` and `control_unit`): `wb_sel` bits map to sources (00=ALU, 01=MEM/IO, 10=PC+2, 11=reserved). See `control_unit.v` and `CPU_Wrapper1.v` for use.
- Flags: `flag_mask` mapping used throughout: bit0 = Z, bit1 = N, bit2 = C, bit3 = V (as used by `control_unit.v` and `CCR/CCR.v`). Keep this bit-order when adding logic that updates flags.

Project-specific conventions

- Instruction encoding: 8-bit instruction where opcode is `ir[7:4]`, operands `ir[3:2]` (ra) and `ir[1:0]` (rb). Look at `Control Unit/control_unit.v` for examples of sub-opcode selection driven by `ra`.
- Combinational logic uses `always @(*)` (e.g., control unit) and sequential uses `always @(posedge clk or negedge rst)` with an active-low reset (e.g., `Register_file`, `CCR`). Follow this when adding modules.
- Testbench naming: simulations are provided as `*_tb.v` files (see many directories such as `ALU/ALU_tb.v`, `Register File/Register_file_tb.v`). Use those for targeted unit simulation.
- Quartus / vendor artifacts: some modules contain `work/` directories and `.qdb`, `.mpf`, `.cr.mti` files (e.g., `MEM_Arbit/`, `SIngleCycle_Wrapper/`). These indicate Quartus projects / synthesis workflows — prefer running simulations in a separate simulator (ModelSim/Questa) if you need RTL waveforms before synthesis.

How to add/modify instructions (concrete checklist)

- Add decode → edit `Control Unit/control_unit.v` combinational case for `opcode` and set `alu_sel`, `reg_write`, `dst_reg`, `wb_sel`, `mem_read`/`mem_write`, `flag_en`, and `flag_mask`.
- Implement or extend ALU behavior in `ALU/ALU.v` to match `alu_sel` encodings; test with `ALU/ALU_tb.v`.
- Ensure flags are driven into `CCR/CCR.v` (respect `flag_mask` bits) so conditional logic and flag reads remain consistent.
- Update `CPU_Wrapper1.v` wiring only if new signals are needed; prefer to keep port names consistent (e.g., `mem_addr_a`, `mem_addr_b`, `mem_write_data_b`).

Recommended developer workflows (discoverable from repo)

- Run targeted simulation for a module by launching its `_tb.v` in your HDL simulator (ModelSim/Questa or vendor simulator). Example: run `Register_file/Register_file_tb.v` in simulator to verify register behavior.
- For synthesis or board flows, open the Quartus project files under the relevant folder (they're present as `.mpf` / `.qdb` artifacts). The repo does not include an explicit build script.

Patterns to preserve

- Keep `flag_mask` bit-order (Z,N,C,V) consistent across control unit and CCR.
- Keep `wb_sel` mapping consistent (00=ALU, 01=MEM/IO, 10=PC+2, 11=reserved).
- Maintain read-asynchronous / write-synchronous register semantics used in `Register_file.v`.

Files to inspect when changing behavior (quick references)

- Top-level: `SIngleCycle_Wrapper/CPU_Wrapper1.v`
- Control decode: `Control Unit/control_unit.v`
- ALU: `ALU/ALU.v` and `ALU/ALU_tb.v`
- Registers: `Register File/Register_file.v` and `Register_file_tb.v`
- Flags: `CCR/CCR.v`
- Memory & arbitration: `MEM_Arbit/`, `Memory/Memory.v`, `Memory/Memory_tb.v`

If anything is unclear

- Ask for the intended ISA table or desired instruction behavior (examples in `control_unit.v` are based on an instruction table; if you change semantics, provide the updated table).

End of instructions — request feedback below.
