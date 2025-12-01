module EX_MEM_reg (
    input  wire       clk,
    input  wire       rst,            // active-low reset

    input  wire       write_en,       // 1 = update, 0 = stall
    input  wire       flush,          // 1 = cancel instruction (NOP)

    // ----- Inputs from EX stage -----
    input  wire [7:0] alu_result_in,  // ALU output (e.g. R[a] op R[b])
    input  wire [7:0] rb_in,          // Rb value (for store/push)
    input  wire [7:0] addr_in,        // effective address / SP
    input  wire [1:0] rd_in,          // destination register index

    // Control signals from EX/ID (decoder)
    input  wire       mem_read_in,    // 1: this instr will read from memory
    input  wire       mem_write_in,   // 1: this instr will write to memory
    input  wire       reg_write_in,   // 1: this instr will write back to regfile
    input  wire       flag_write_in,  // 1: this instr will update flags in WB

    // ----- Outputs to MEM stage -----
    output reg  [7:0] alu_result_out,
    output reg  [7:0] rb_out,
    output reg  [7:0] addr_out,
    output reg  [1:0] rd_out,

    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg        reg_write_out,
    output reg        flag_write_out
);

    // Sequential logic: update on clock
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset: clear pipeline (no valid instruction)
            alu_result_out <= 8'd0;
            rb_out         <= 8'd0;
            addr_out       <= 8'd0;
            rd_out         <= 2'd0;

            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            reg_write_out  <= 1'b0;
            flag_write_out <= 1'b0;
        end
        else if (flush) begin
            // Flush: cancel instruction (insert NOP into MEM stage)
            // أهم حاجة نصفر كنترول عشان مفيش memory ولا write-back تتعمل
            alu_result_out <= 8'd0;
            rb_out         <= 8'd0;
            addr_out       <= 8'd0;
            rd_out         <= 2'd0;

            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            reg_write_out  <= 1'b0;
            flag_write_out <= 1'b0;
        end
        else if (write_en) begin
            // Normal case: move values from EX → MEM
            alu_result_out <= alu_result_in;
            rb_out         <= rb_in;
            addr_out       <= addr_in;
            rd_out         <= rd_in;

            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            reg_write_out  <= reg_write_in;
            flag_write_out <= flag_write_in;
        end
        // else: write_en = 0 → stall → hold previous values
    end

endmodule
