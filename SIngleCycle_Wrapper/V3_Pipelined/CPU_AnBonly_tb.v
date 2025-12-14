`timescale 1ns / 1ps

module tb_CPU_FormatA_B;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // Internal Debug Signals (Peeking into the Register File and PC)
    // Note: Ensure these paths match your exact hierarchy
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] SP = uut.regfile_inst.regs[3]; 
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

        // --- Load Machine Code into Memory (Backdoor) ---
        // Note: Reset Vector is at M[0]. We set it to jump to 0x10.
        $display("Loading Format A & B Test Code into Memory...");

        // --- Main Program Starts at 0x10 ---

        // 1. IN R0 (Load R0 from Input Port) [Format A]
        // Op:7 (0111), ra:3 (11), rb:0 (00) -> 0x7C
        uut.mem_inst.mem[0] = 8'h7C;

        // 2. IN R1 (Load R1 from Input Port) [Format A]
        // Op:7 (0111), ra:3 (11), rb:1 (01) -> 0x7D
        uut.mem_inst.mem[1] = 8'h7D;

        // 3. ADD R0, R1 (R0 = R0 + R1) [Format A]
        // Op:2 (0010), ra:0 (00), rb:1 (01) -> 0x21
        uut.mem_inst.mem[2] = 8'h21;

        // 4. OUT R0 (Output result to O_Port) [Format A]
        // Op:7 (0111), ra:2 (10), rb:0 (00) -> 0x78
        uut.mem_inst.mem[3] = 8'h78;

        // 5. IN R2 (Load Jump Target address into R2) [Format A]
        // Op:7 (0111), ra:3 (11), rb:2 (10) -> 0x7E
        uut.mem_inst.mem[4] = 8'h7E;

        // 6. JMP R2 (Unconditional Jump to address in R2) [Format B]
        // Op:11 (1011), brx:0 (00), rb:2 (10) -> 0xB2
        uut.mem_inst.mem[5] = 8'hB2;

        // 7. INC R1 (Skipped Instruction - Should NOT execute) [Format A]
        // This is at 0x22 (decimal 34). If executed, R1 changes.
        uut.mem_inst.mem[6] = 8'h89;

        // 8. SUB R0, R1 (Target of Jump: R0 = R0 - R1) [Format A]
        // This is at 0x23 (decimal 35).
        // Op:3 (0011), ra:0 (00), rb:1 (01) -> 0x31
        uut.mem_inst.mem[7] = 8'h31;

        // 9. OUT R0 (Output final result) [Format A]
        // Op:7 (0111), ra:2 (10), rb:0 (00) -> 0x78
        uut.mem_inst.mem[8] = 8'h78;

        // 10. Loop Forever (JMP R2 where R2 still holds 0x23)
        uut.mem_inst.mem[9] = 8'hB2;


        // --- Simulation Execution Control ---
        
        // 1. Reset Pulse
        #20 rstn = 1;
        $display("[%0t] Reset Released.", $time);

        // 2. Drive I_Port for "IN R0" (Executes at 0x10)
        // We set value 5. 
        @(posedge clk);
        I_Port = 8'd5;
        $display("[%0t] I_Port set to 5 for R0", $time);

        // 3. Drive I_Port for "IN R1" (Executes at 0x11)
        // We set value 3.
        wait(PC == 8'h1);
        @(posedge clk);
        I_Port = 8'd3;
        $display("[%0t] I_Port set to 3 for R1", $time);

        // 4. Drive I_Port for "IN R2" (Executes at 0x14 / decimal 20)
        // We set target address 35 (0x23).
        wait(PC == 8'h4);
        I_Port = 8'h07; // Target address for JMP
        $display("[%0t] I_Port set to 0x23 for R2 (Jump Target)", $time);

        // Run until completion
        #400; 
        
        $display("-------------------------------------------------------------");
        $display("FINAL STATE:");
        $display("R0: %d (Expected 5 - Result of 8-3)", R0);
        $display("R1: %d (Expected 3)", R1);
        $display("O_Port: %d (Should match R0)", O_Port);
        $display("-------------------------------------------------------------");
        $stop;
    end

    // ========================================================================
    // 5. Monitor (Prints state every cycle)
    // ========================================================================
    always @(posedge clk) begin
        if (rstn) begin
            // Adjust 'uut.ccr_inst.CCR_reg' if your flag register is named differently
            $display("Time:%4t | PC:%h | R0:%d R1:%d R2:%h | I_Port:%d | O_Port:%d", 
                     $time, PC, R0, R1, R2, I_Port, O_Port);
        end
    end

endmodule