`timescale 1ns / 1ps

module tb_Comprehensive_ALU;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] SP = uut.regfile_inst.regs[3]; // SP is R3
    wire [7:0] PC = uut.PC.pc_current;
    wire [3:0] CCR = uut.ccr_inst.CCR; // {V, C, N, Z}

    // ========================================================================
    // 2. DUT Instantiation
    // ========================================================================
    CPU_WrapperV3 uut (
        .clk(clk), 
        .rstn(rstn), 
        .I_Port(I_Port), 
        .int_sig(int_sig),
        .O_Port(O_Port)
    );

    // ========================================================================
    // 3. Clock Generation
    // ========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ========================================================================
    // 4. Test Sequence
    // ========================================================================
    initial begin
        // --- Initialize ---
        I_Port = 0;
        int_sig = 0;
        rstn = 0; 
        
        $display("Loading ALU, Rotate, and Stack Test Program...");

        
        // --- Execute ---
        #20 rstn = 1;

        // 0x00: LDM R0, 20
        uut.mem_inst.mem[0] = 8'hC0; uut.mem_inst.mem[1] = 8'd20;
        
        // 0x02: LDM R1, 50
        uut.mem_inst.mem[2] = 8'hC1; uut.mem_inst.mem[3] = 8'd50;
        
        // 0x04: NOP
        uut.mem_inst.mem[4] = 8'h00;
        
        // 0x05: ADD R1, R0 (R1 = 50 + 20 = 70) -> Op:2, ra:1, rb:0 -> 0x24
        uut.mem_inst.mem[5] = 8'h24;
        
        // 0x06: LDM R2, 80
        uut.mem_inst.mem[6] = 8'hC2; uut.mem_inst.mem[7] = 8'd80;
        
        // 0x08: NEG R2 (R2 = -80 = 0xB0) -> Op:8, ra:1, rb:2 -> 0x52
        uut.mem_inst.mem[8] = 8'h86;
        uut.mem_inst.mem[9] = 8'h00;
        
        // 0x0A: SUB R1, R2 (R1 = 70 - (-80) = 150) -> Op:3, ra:1, rb:2 -> 0x36
        uut.mem_inst.mem[10] = 8'h36;
        
        // 0x0B: RLC R0 (Rotate Left Carry R0: 20 << 1 = 40) -> Op:6, ra:0, rb:0 -> 0x60
        uut.mem_inst.mem[11] = 8'h60;
        
        // 0x0C: RRC R0 (Rotate Right Carry R0: 40 >> 1 = 20) -> Op:6, ra:1, rb:0 -> 0x70
        uut.mem_inst.mem[12] = 8'h64;
        
        // 0x0D: SETC (Set Carry flag) -> Op:6, ra:2 -> 0x10
        uut.mem_inst.mem[13] = 8'h68;
        
        // 0x0E: OR R2, R1 (R2 = 0xB0 | 0x96) -> Op:5, ra:2, rb:1 -> 0x49
        uut.mem_inst.mem[14] = 8'h59;
        
        // 0x0F: CLRC (Clear Carry flag) -> Op:6, ra:3 -> 0x11
        uut.mem_inst.mem[15] = 8'h6C;
        
        // 0x10: PUSH R2 (Store R2 on stack, SP--) -> Op:7, brx:00, rb:2 -> 0xB2
        uut.mem_inst.mem[16] = 8'h72;
        
        // 0x11: DEC R2 (Decrement R2) -> Op:8, ra:3, rb:2 -> 0x82
        uut.mem_inst.mem[17] = 8'h8E;
        
        // 0x12: DEC R2
        uut.mem_inst.mem[18] = 8'h8E;
        
        // 0x13: POP R2 (Restore R2 from stack, SP++) -> Op:11, brx:02, rb:2 -> 0xBA
        uut.mem_inst.mem[19] = 8'h76;
        
        // 0x14: NOT R0 (R0 = ~20) -> Op:4, ra:3, rb:0 -> 0x4C (NOT is ra=11, rb=dest)
        uut.mem_inst.mem[20] = 8'h80;

        // 0x15: STOP
        uut.mem_inst.mem[21] = 8'h00;

        

        #350;
        $display("-------------------------------------------------------------");
        $display("FINAL REGISTER STATE: R0:%h, R1:%d, R2:%h, SP:%h", R0, R1, R2, SP);
        $display("-------------------------------------------------------------");
        $stop;
    end

    // Clock-by-clock tracing
    always @(posedge clk) begin
        if (rstn) begin
            $display("PC:%2h | IR:%2h | R0:%2h R1:%2h R2:%2h SP:%2h | CCR:%b", 
                     PC, uut.IR, R0, R1, R2, SP, CCR);
        end
    end

endmodule