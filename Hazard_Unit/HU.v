module HU(
    input [1:0] if_id_ra,
    input [1:0] if_id_rb,
    input [1:0] id_ex_rd,
    input       id_ex_mem_read, // NEW: High if instruction in EX is LDD, LDI, or POP
    input       BT,             // Branch Taken
    output reg  pc_en,
    output reg  if_id_en,
    output reg  flush,
);

    always @(*) begin
        // 1. Set Defaults (Prevents Latches)
        pc_en = 1;
        if_id_en = 1;
        flush = 0;

        // 2. Load-Use Hazard Detection
        // Stall only if the instruction in EX is a Load AND it writes to a register we need now.
        if ((id_ex_mem_read && (id_ex_rd == if_id_ra || id_ex_rd == if_id_rb))) begin
            pc_en = 0;      // Freeze PC
            if_id_en = 0;   // Freeze IF/ID Pipeline Reg
            flush = 0;    
        end

        // 3. Control Hazard (Branching)
        // If a branch is taken, the instruction currently in Fetch/Decode is wrong.
        if (BT) begin
            flush = 1;      // flush if/id, id/ex reg
        end
    end

endmodule
