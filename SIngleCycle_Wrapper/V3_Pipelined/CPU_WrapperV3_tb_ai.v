`timescale 1ns / 1ps

module tb_INST_TEST;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // Internal Debug Signals (Peeking into the Register File)
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] SP = uut.regfile_inst.regs[3]; // R3 is SP
    wire [7:0] PC = uut.PC.pc_current;
    
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
    // 3. Clock Generation (100 MHz)
    // ========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ========================================================================
    // 4. Program Loading & Execution
    // ========================================================================
    initial begin
        // --- Initialize Inputs ---
        rstn = 0;
        I_Port = 8'h00;
        int_sig = 0;

        // --- Release Reset ---
        #20 rstn = 1;

        // --- Load Machine Code into Memory (Backdoor) ---
        $display("Loading 'INST_TEST.txt' into Memory...");

        // 1. INC R0 (Op:8, ra:2, rb:0) -> 0x88
        uut.mem_inst.mem[0] = 8'h88;

        // 2. INC R1 (Op:8, ra:2, rb:1) -> 0x89
        uut.mem_inst.mem[1] = 8'h89;

        // 3. ADD R1, R0 (Maps to ADD R1, R1, R0) -> R1 = R1 + R0
        // Op:2, ra:1 (Dest), rb:0 (Src) -> 0x24
        uut.mem_inst.mem[2] = 8'h24;

        // 4. SUB R2, R1 (Maps to SUB R2, R1, R2) -> R2 = R2 - R1
        // Op:3, ra:2 (Dest), rb:1 (Src) -> 0x39
        uut.mem_inst.mem[3] = 8'h39;

        // 5. AND R2, R1 (Maps to AND R2, R1, R2) -> R2 = R2 & R1
        // Op:4, ra:2 (Dest), rb:1 (Src) -> 0x49
        uut.mem_inst.mem[4] = 8'h49;

        // 6. OR R2, R0  (Maps to OR R2, R1, R0) -> R2 = R2 | R0
        // Op:5, ra:2 (Dest), rb:0 (Src) -> 0x58
        uut.mem_inst.mem[5] = 8'h58;

        // 7. RLC R2 (Op:6, ra:0, rb:2) -> 0x62
        uut.mem_inst.mem[6] = 8'h62;

        // 8. RRC R0 (Op:6, ra:1, rb:0) -> 0x64
        uut.mem_inst.mem[7] = 8'h64;

        // 9. SETC (Op:6, ra:2, rb:0) -> 0x68
        uut.mem_inst.mem[8] = 8'h68;

        // 10. NOT R1 (Op:8, ra:0, rb:1) -> 0x81
        uut.mem_inst.mem[9] = 8'h81;

        // 11. INC R1 (Op:8, ra:2, rb:1) -> 0x89
        uut.mem_inst.mem[10] = 8'h89;

        // 12. CLRC (Op:6, ra:3, rb:0) -> 0x6C
        uut.mem_inst.mem[11] = 8'h6C;

        // 13. DEC R2 (Op:8, ra:3, rb:2) -> 0x8E
        uut.mem_inst.mem[12] = 8'h8E;

        // 14. PUSH R1 (Inferred R1 from context) 
        // Op:7, ra:0, rb:1 -> 0x71
        uut.mem_inst.mem[13] = 8'h71;

        // 15. INC R1 (Modify R1 to verify POP later)
        // Op:8, ra:2, rb:1 -> 0x89
        uut.mem_inst.mem[14] = 8'h89;

        // 16. POP R1 (Restore R1)
        // Op:7, ra:1, rb:1 -> 0x75
        uut.mem_inst.mem[15] = 8'h75;

        // 17. Stop/Loop (JMP 0x0F) - Prevent running into garbage memory
        // Op:11 (0xB), ra:0 (JMP), rb:0 (R0 is usually 0? No, R0 is modified)
        // Let's just put NOPs
        uut.mem_inst.mem[16] = 8'h00; 
        uut.mem_inst.mem[17] = 8'h00; 
        
        // --- Run Simulation ---
        #300; // Run enough time for all instructions
        
        $display("-------------------------------------------------------------");
        $display("FINAL STATE:");
        $display("R0: %h | R1: %h | R2: %h | SP: %h", R0, R1, R2, SP);
        $display("-------------------------------------------------------------");
        $stop;
    end

    // ========================================================================
    // 5. Monitor (Prints state every cycle)
    // ========================================================================
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%4t | PC:%2d | IR:%h | R0:%h R1:%h R2:%h SP:%h | Flags(ZNCV):%b", 
                     $time, PC, uut.IR, R0, R1, R2, SP, uut.ccr_inst.CCR_reg);
        end
    end

endmodule