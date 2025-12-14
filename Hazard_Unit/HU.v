module HU(
    // Inputs from ID Stage (Current Instruction)
    input  wire [1:0] if_id_ra,     // Source A
    input  wire [1:0] if_id_rb,     // Source B

    // Inputs from EX Stage (Previous Instruction)
    input  wire [1:0] id_ex_rd,     // Dest Register in EX
    input  wire       id_ex_mem_read, // Load Instruction in EX?

    // Inputs from Logic
    input  wire [1:0] BT,           // Branch Taken (from Branch Unit)

    // Outputs
    output reg        pc_en,        // PC write enable
    output reg        if_id_en,     // IF/ID register write enable
    output reg        flush         // Flush signal for control hazards
);

    always @(*) begin

@@ -17,7 +18,7 @@ module HU(

        // 2. Load-Use Hazard Detection
        // Stall only if the instruction in EX is a Load AND it writes to a register we need now.
        if ((id_ex_mem_read && (id_ex_rd == if_id_ra || id_ex_rd == if_id_rb))) begin
            pc_en = 0;      // Freeze PC
            if_id_en = 0;   // Freeze IF/ID Pipeline Reg
            flush = 0;   
