`timescale 1ns / 1ps

module tb_Advanced_Instructions;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // Internal Debug Signals
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3]; // SP
    
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
    // 4. Program Loading & Execution
    // ========================================================================
    initial begin
        rstn = 0;
        I_Port = 0;
        int_sig = 0;

        $display("Loading Advanced Instruction Test into Memory...");

        // 5. Release Reset and Run
        #20 rstn = 1;
        
        // --------------------------------------------------------------------
        // SECTION 1: LOOP TEST (R0 = Counter, R1 = Target Address)
        // --------------------------------------------------------------------
        // 0x00: LDM R0, 0x03 (Loop Counter = 3)
        // Op: 12 (1100), ra:00, rb:00 -> C0
        uut.mem_inst.mem[0] = 8'hC0; 
        uut.mem_inst.mem[1] = 8'h03;

        // 0x02: LDM R1, 0x04 (Target Address for Loop)
        // Op: 12 (1100), ra:00, rb:01 -> C1
        uut.mem_inst.mem[2] = 8'hC1;
        uut.mem_inst.mem[3] = 8'h04;

        // 0x04: NOP (Loop Body - effectively does nothing but burn a cycle)
        uut.mem_inst.mem[4] = 8'h00;

        // 0x05: LOOP R0, R1 (Dec R0, Jump to [R1] if R0 != 0)
        // Op: 10 (1010), ra:00 (Counter), rb:01 (Target Reg) -> A1
        uut.mem_inst.mem[5] = 8'hA1;

        // --------------------------------------------------------------------
        // [cite_start]// SECTION 2: MEMORY TEST (LDD, STD, LDI, STI) [cite: 107, 108]
        // --------------------------------------------------------------------
        // 0x06: LDM R2, 0xAA (Data to Store)
        uut.mem_inst.mem[6] = 8'hC2;
        uut.mem_inst.mem[7] = 8'hAA;

        // 0x08: STD R2, 0xF0 (Store Direct: Mem[0xF0] = R2)
        // Op: 12 (1100), ra:10 (STD), rb:10 (R2) -> CA
        uut.mem_inst.mem[8] = 8'hCA;
        uut.mem_inst.mem[9] = 8'hF0;

        // 0x0A: LDM R2, 0x00 (Clear R2 to verify load)
        uut.mem_inst.mem[10] = 8'hC2;
        uut.mem_inst.mem[11] = 8'h00;

        // 0x0C: LDD R2, 0xF0 (Load Direct: R2 = Mem[0xF0] -> Should be 0xAA)
        // Op: 12 (1100), ra:01 (LDD), rb:10 (R2) -> C6
        uut.mem_inst.mem[12] = 8'hC6;
        uut.mem_inst.mem[13] = 8'hF0;

        // 0x0E: LDM R1, 0xF0 (Load Pointer Address into R1)
        uut.mem_inst.mem[14] = 8'hC1;
        uut.mem_inst.mem[15] = 8'hF0;

        // 0x10: LDI R3, R1 (Load Indirect: R3 = Mem[R1] -> R3 = Mem[0xF0] -> 0xAA)
        // Op: 13 (1101), ra:01 (Ptr R1), rb:11 (Dest R3) -> D7
        uut.mem_inst.mem[16] = 8'hD7;

        // --------------------------------------------------------------------
        // [cite_start]// SECTION 3: CALL TEST [cite: 86, 87]
        // --------------------------------------------------------------------
        // 0x11: LDM R0, 0x20 (Target Address for Call)
        uut.mem_inst.mem[17] = 8'hC0;
        uut.mem_inst.mem[18] = 8'h20;

        // 0x13: CALL R0 (Push PC, Jump to [R0])
        // Op: 11 (1011), brx:01 (CALL), rb:00 (Addr Reg) -> B4
        uut.mem_inst.mem[19] = 8'hB4;

        // 0x14: LDM R2, 0xBAD (Should NOT execute if CALL works)
        uut.mem_inst.mem[20] = 8'hC2;
        uut.mem_inst.mem[21] = 8'hBD;
        
        // --------------------------------------------------------------------
        // SUBROUTINE (At Address 0x20)
        // --------------------------------------------------------------------
        // 0x20: LDM R3, 0x99 (Marker that we are in Subroutine)
        uut.mem_inst.mem[32] = 8'hC3;
        uut.mem_inst.mem[33] = 8'h99;

        // --------------------------------------------------------------------
        // [cite_start]// SECTION 4: BRANCH TEST (JZ) [cite: 87]
        // --------------------------------------------------------------------
        // 0x22: SUB R3, R3 (R3 = R3 - R3 = 0 -> Sets Z Flag)
        // Op: 3 (0011), ra:11, rb:11 -> 3F
        uut.mem_inst.mem[34] = 8'h3F;

        // 0x23: LDM R1, 0x28 (Jump Target)
        uut.mem_inst.mem[35] = 8'hC1;
        uut.mem_inst.mem[36] = 8'h28;

        // 0x25: JZ R1 (Jump to [R1] if Z=1)
        // Op: 9 (1001), brx:00 (JZ), rb:01 (Target) -> 91
        uut.mem_inst.mem[37] = 8'h91;
        
        // 0x26: NOP (Should be skipped)
        uut.mem_inst.mem[38] = 8'h00;
        
        // 0x28: LDM R0, 0x77 (Success Marker)
        uut.mem_inst.mem[40] = 8'hC0;
        uut.mem_inst.mem[41] = 8'h77;
        
        // Stop
        uut.mem_inst.mem[42] = 8'h00;

        
        // Run long enough to finish loops and jumps
        #500;
        
        $display("-------------------------------------------------------------");
        $display("FINAL CHECK:");
        $display("R0 (Loop Left/Success): %h (Expect 77)", R0);
        $display("R2 (Mem Read):          %h (Expect AA)", R2);
        $display("R3 (Indir Read/Sub):    %h (Expect 00 after SUB)", R3);
        $display("SP (Stack Ptr):         %h (Expect 254 if CALL pushed)", R3);
        $display("PC:                     %d", PC);
        $display("-------------------------------------------------------------");
        $stop;
    end

    // ========================================================================
    // 5. Monitor
    // ========================================================================
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%4t | PC:%2d | IR:%h | R0:%h R1:%h R2:%h R3:%h | Flags:%b", 
                     $time, PC, uut.IR, R0, R1, R2, R3, uut.ccr_inst.CCR_reg);
        end
    end

endmodule