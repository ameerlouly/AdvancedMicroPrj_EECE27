// control_unit_A.v
// Control unit for A-format instructions only (based on provided table).
// - Instruction format: [7:4] opcode, [3:2] ra, [1:0] rb
// - Outputs provide hints for pipeline: reg_write, wb_sel, mem_read/write hints, alu_sel, op2_sel, dest_reg
// - flag_mask: which flags should be updated (bit0=Z, bit1=N, bit2=C, bit3=V)
// - For multi-function opcodes (6,7,8) the 'ra' subfield selects the specific operation.
module control_unit_A (
    input  wire [7:0] ir,

    // control outputs (combinational)
    output reg        reg_write,    // write to register file at WB
    output reg  [1:0] dst_reg,      // destination register index (for writeback)
    output reg  [3:0] alu_sel,      // ALU operation code
    output reg  [1:0] op2_sel,      // 00 = reg(rb) (A-format uses register)
    output reg  [1:0] wb_sel,       // 00=ALU, 01=MEM/IO, 10=PC+2 (unused here), 11=reserved
    output reg        mem_read,     // hint: this instruction will read memory (POP / IN)
    output reg        mem_write,    // hint: this instruction will write memory (PUSH / OUT)
    output reg        flag_en,      // whether flags are affected (global enable)
    output reg  [3:0] flag_mask     // bit mask: [V C N Z] or chosen order (here we use Z,N,C,V bits)
);

    // field extraction
    wire [3:0] opcode = ir[7:4];
    wire [1:0] ra     = ir[3:2];
    wire [1:0] rb     = ir[1:0];

    // ALU encodings (localparam)
    localparam ALU_NOP  = 4'h0;
    localparam ALU_PASS = 4'h1; // MOV - pass source
    localparam ALU_ADD  = 4'h2;
    localparam ALU_SUB  = 4'h3;
    localparam ALU_AND  = 4'h4;
    localparam ALU_OR   = 4'h5;
    localparam ALU_RLC  = 4'h6;
    localparam ALU_RRC  = 4'h7;
    localparam ALU_SETC = 4'h8; // pseudo-op (set C flag)
    localparam ALU_CLRC = 4'h9; // pseudo-op (clear C)
    localparam ALU_NOT  = 4'hA;
    localparam ALU_NEG  = 4'hB;
    localparam ALU_INC  = 4'hC;
    localparam ALU_DEC  = 4'hD;
    // others reserved

    // opcode numeric constants (from your table)
    localparam OP_NOP  = 4'd0;
    localparam OP_MOV  = 4'd1;
    localparam OP_ADD  = 4'd2;
    localparam OP_SUB  = 4'd3;
    localparam OP_AND  = 4'd4;
    localparam OP_OR   = 4'd5;
    localparam OP_CARRY_POP_GROUP = 4'd6; // 6 => RLC/RRC/SETC/CLRC (subselected by ra)
    localparam OP_PUSHPOP_GROUP    = 4'd7; // 7 => PUSH/POP/OUT/IN (ra selects)
    localparam OP_NOTNEG_INCDEC    = 4'd8; // 8 => NOT/NEG/INC/DEC (ra selects)

    // flag_mask bit mapping (for clarity):
    // flag_mask[0] = Z enable
    // flag_mask[1] = N enable
    // flag_mask[2] = C enable
    // flag_mask[3] = V enable
    // set to 0 if that flag should not be modified by this instruction

    // combinational decode
    always @(*) begin
        // defaults (safe)
        reg_write  = 1'b0;
        dst_reg    = 2'b00;
        alu_sel    = ALU_NOP;
        op2_sel    = 2'b00;  // register operand (rb)
        wb_sel     = 2'b00;  // ALU by default
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        flag_en    = 1'b0;
        flag_mask  = 4'b0000;

        case (opcode)
            OP_NOP: begin
                // NOP: PC <- PC+1 (control not here), no reg write, no flags
                reg_write = 1'b0;
            end

            OP_MOV: begin
                // MOV : R[ra] <- R[rb]
                reg_write = 1'b1;
                dst_reg   = ra;
                alu_sel   = ALU_PASS;
                wb_sel    = 2'b00; // ALU pass-through
                flag_en   = 1'b0;  // MOV does NOT change flags (table shows PC <- PC+1 only)
            end

            OP_ADD: begin
                reg_write = 1'b1;
                dst_reg   = ra;
                alu_sel   = ALU_ADD;
                wb_sel    = 2'b00;
                flag_en   = 1'b1;
                // According to table ADD changes C and V as well as Z,N
                // enable Z,N,C,V all (mask bits Z,N,C,V)
                flag_mask = 4'b1111;
            end

            OP_SUB: begin
                reg_write = 1'b1;
                dst_reg   = ra;
                alu_sel   = ALU_SUB;
                wb_sel    = 2'b00;
                flag_en   = 1'b1;
                flag_mask = 4'b1111;
            end

            OP_AND: begin
                reg_write = 1'b1;
                dst_reg   = ra;
                alu_sel   = ALU_AND;
                wb_sel    = 2'b00;
                flag_en   = 1'b1;
                // logical ops usually affect Z and maybe N; C,V typically cleared or unchanged;
                // Table shows change of Z and N; set mask accordingly (Z,N)
                flag_mask = 4'b0011; // Z,N
            end

            OP_OR: begin
                reg_write = 1'b1;
                dst_reg   = ra;
                alu_sel   = ALU_OR;
                wb_sel    = 2'b00;
                flag_en   = 1'b1;
                flag_mask = 4'b0011; // Z,N
            end

            OP_CARRY_POP_GROUP: begin
                // opcode 6 - subfunctions selected by ra:
                // ra==0 : RLC (rotate left through carry)    -> write back to R[rb]
                // ra==1 : RRC (rotate right through carry)   -> write back to R[rb]
                // ra==2 : SETC (set carry)                   -> no reg write, set C
                // ra==3 : CLRC (clear carry)                 -> no reg write, clear C
                case (ra)
                    2'b00: begin // RLC
                        reg_write = 1'b1;
                        dst_reg   = rb;    // result goes to R[rb]
                        alu_sel   = ALU_RLC;
                        wb_sel    = 2'b00;
                        flag_en   = 1'b1;
                        flag_mask = 4'b0100; // C only (and maybe Z/N per table if specified; adjust if you want)
                    end
                    2'b01: begin // RRC
                        reg_write = 1'b1;
                        dst_reg   = rb;
                        alu_sel   = ALU_RRC;
                        wb_sel    = 2'b00;
                        flag_en   = 1'b1;
                        flag_mask = 4'b0100;
                    end
                    2'b10: begin // SETC
                        reg_write = 1'b0;
                        alu_sel   = ALU_SETC;
                        flag_en   = 1'b1;
                        flag_mask = 4'b0100; // set C
                    end
                    2'b11: begin // CLRC
                        reg_write = 1'b0;
                        alu_sel   = ALU_CLRC;
                        flag_en   = 1'b1;
                        flag_mask = 4'b0100; // clear C
                    end
                endcase
            end

            OP_PUSHPOP_GROUP: begin
                // opcode 7 - subfunctions by ra:
                // ra==0 : PUSH  -> memory write (push R[rb] onto stack)
                // ra==1 : POP   -> memory read (pop -> R[rb])
                // ra==2 : OUT   -> port output (treat as mem_write/IO)
                // ra==3 : IN    -> port input (read -> R[rb])
                case (ra)
                    2'b00: begin // PUSH
                        reg_write = 1'b0;
                        mem_write = 1'b1;
                        // we do NOT set dst_reg; push doesn't write register
                        wb_sel    = 2'b00;
                        flag_en   = 1'b0;
                    end
                    2'b01: begin // POP
                        reg_write = 1'b1;
                        dst_reg   = rb;      // destination is R[rb]
                        mem_read  = 1'b1;
                        wb_sel    = 2'b01;   // WB source is from memory read
                        flag_en   = 1'b1;
                        // According to table POP sets flags; enable at least Z,N
                        flag_mask = 4'b0011; // Z,N (adjust as table requires)
                    end
                    2'b10: begin // OUT (port write)
                        reg_write = 1'b0;
                        mem_write = 1'b1;    // treat IO write like mem write (top-level will route)
                        flag_en   = 1'b0;
                    end
                    2'b11: begin // IN (port read -> R[rb])
                        reg_write = 1'b1;
                        dst_reg   = rb;
                        mem_read  = 1'b1;    // treat IO read like mem read
                        wb_sel    = 2'b01;   // data source: memory/IO
                        flag_en   = 1'b0;    // table shows PC <- PC + 1, not necessarily flags
                    end
                endcase
            end

            OP_NOTNEG_INCDEC: begin
                // opcode 8 - subfunctions by ra:
                // ra==0 : NOT   -> R[rb] = ~R[rb]
                // ra==1 : NEG   -> R[rb] = 2's complement
                // ra==2 : INC   -> R[rb] = R[rb] + 1
                // ra==3 : DEC   -> R[rb] = R[rb] - 1
                case (ra)
                    2'b00: begin // NOT
                        reg_write = 1'b1;
                        dst_reg   = rb;
                        alu_sel   = ALU_NOT;
                        wb_sel    = 2'b00;
                        flag_en   = 1'b1;
                        flag_mask = 4'b0011; // Z,N (and maybe C if table says)
                    end
                    2'b01: begin // NEG
                        reg_write = 1'b1;
                        dst_reg   = rb;
                        alu_sel   = ALU_NEG;
                        wb_sel    = 2'b00;
                        flag_en   = 1'b1;
                        flag_mask = 4'b1111; // all flags affected by NEG per table (C,V included)
                    end
                    2'b10: begin // INC
                        reg_write = 1'b1;
                        dst_reg   = rb;
                        alu_sel   = ALU_INC;
                        wb_sel    = 2'b00;
                        flag_en   = 1'b1;
                        flag_mask = 4'b1111;
                    end
                    2'b11: begin // DEC
                        reg_write = 1'b1;
                        dst_reg   = rb;
                        alu_sel   = ALU_DEC;
                        wb_sel    = 2'b00;
                        flag_en   = 1'b1;
                        flag_mask = 4'b1111;
                    end
                endcase
            end

            default: begin
                // undefined opcode -> treat as NOP (safe)
                reg_write = 1'b0;
                alu_sel   = ALU_NOP;
            end
        endcase
    end

endmodule
