module HU (
    // Inputs from ID Stage (Current Instruction)
    input  wire [3:0] opcode,       // Current Opcode
    input  wire [1:0] if_id_ra,     // Source A
    input  wire [1:0] if_id_rb,     // Source B (Used as Target for Branches)

    // Inputs from EX Stage (Previous Instruction)
    input  wire [1:0] id_ex_rd,     // Dest Register
    input  wire       id_ex_mem_read, // Load Instruction?
    input  wire       id_ex_reg_write,// NEW: Does EX instruction write to reg?
    input  wire [3:0] id_ex_opcode, // Opcode in EX (for 2-byte flush)

    // Inputs from MEM Stage (Instruction 2 cycles ago)
    input  wire [1:0] ex_mem_rd,    // NEW: Dest Register in MEM
    input  wire       ex_mem_reg_write, // NEW: Does MEM instruction write?

    // Inputs from Logic
    input  wire       branch_take,  // Branch Taken

    // Outputs
    output reg        pc_en,
    output reg        if_id_en,
    output reg        flush,
    output reg        bubble
);

    always @(*) begin
        // 1. Defaults
        pc_en    = 1'b1;
        if_id_en = 1'b1;
        flush    = 1'b0;
        bubble   = 1'b0;
        stall    = 1'b0;

        // ----------------------------------------------------
        // 2. Control Hazard (Branch Taken)
        // ----------------------------------------------------
        if (branch_take) begin
            flush = 1'b1; 
        end

        // ----------------------------------------------------
        // 3. Load-Use Hazard (Standard Data Dependency)
        // ----------------------------------------------------
        else if (id_ex_mem_read && (id_ex_rd == if_id_ra || id_ex_rd == if_id_rb)) begin
            pc_en    = 1'b0;
            if_id_en = 1'b0;
            bubble   = 1'b1;
        end

        // ----------------------------------------------------
        // 4. Branch-Target Hazard (NEW CRITICAL FIX)
        // ----------------------------------------------------
        // If we are branching (JZ, LOOP, JMP, CALL, etc) and the Target Register (Rb)
        // is being written by an instruction in EX or MEM, we must STALL.
        // Opcodes: 9 (Jumps), 10 (LOOP), 11 (JMP/CALL)
        else if ((opcode == 9 || opcode == 10 || opcode == 11) && 
                 ( (id_ex_reg_write && id_ex_rd == if_id_rb) || 
                   (ex_mem_reg_write && ex_mem_rd == if_id_rb) )) begin
             
             // Exception: CALL/RET/RTI (Op 11) might not use Rb or use Stack. 
             // But assuming JMP/CALL use Rb, stalling is safe.
             
             pc_en    = 1'b0; // Wait for writeback
             if_id_en = 1'b0;
             bubble   = 1'b1; // Insert NOP
        end

        // ----------------------------------------------------
        // 5. 2-Byte Instruction Handling
        // ----------------------------------------------------
        else if (id_ex_opcode == 4'd12) begin
            bubble = 1'b1; // Flush operand
        end

    end

endmodule
