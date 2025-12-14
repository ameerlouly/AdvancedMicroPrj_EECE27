`timescale 1ns / 1ps

module tb_CALL_Only;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] PC = uut.PC.pc_current;
    
    // Check your Stack Pointer path. 
    // IF SP is Register 3:
    wire [7:0] SP = uut.regfile_inst.regs[3]; 
    // IF SP is a dedicated register, change to: uut.SP.current_sp

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
        rstn = 0;
        I_Port = 0;
        int_sig = 0;

        // --- 1. SETUP STACK POINTER (Optional but recommended) ---
        // Let's set SP to 0xF0 so we know exactly where the Return Address goes.
        // Instruction: LDM SP, 0xF0 (Assuming SP is R3)
        // Op=12(1100), ra=0, rb=3(11) -> 0xC3
        uut.mem_inst.mem[0] = 8'hC3;
        uut.mem_inst.mem[1] = 8'hF0;


        // --- 2. THE CALL INSTRUCTION ---
        // Address 2: CALL 0x20
        // Opcode 10 (1010) is typical for CALL/JSR. 
        // Binary: 1010 00 00 -> 0xA0
        uut.mem_inst.mem[2] = 8'hA0; 
        
        // Address 3: Target Address (Where we jump TO)
        uut.mem_inst.mem[3] = 8'h20; // 32 decimal


        // --- 3. THE TARGET LOCATION (Address 0x20) ---
        // Put a dummy instruction here to prove we arrived.
        // LDM R1, 0xAA (Just a marker)
        uut.mem_inst.mem[32] = 8'hC1; 
        uut.mem_inst.mem[33] = 8'hAA;

        // --- Release Reset ---
        #20 rstn = 1;

        // --- Run Simulation ---
        // Cycles needed:
        // 1. LDM SP (5 cycles)
        // 2. CALL (Wait for WB stage to write to stack)
        #150; 

        // ========================================================================
        // 5. Check Results
        // ========================================================================
        $display("-------------------------------------------------------------");
        $display("CALL INSTRUCTION TEST");
        $display("-------------------------------------------------------------");
        
        // CHECK 1: Did we Jump?
        // PC should be at 0x20 (or 0x22 if it executed the instruction there)
        $display("Current PC      : %h (Expected 20 or 22)", PC);
        
        // CHECK 2: Is Return Address on Stack?
        // We did CALL at Addr 2 (2 bytes). Return Address should be 2 + 2 = 4.
        // Stack was 0xF0. Pushing usually decrements SP -> 0xEF.
        // So Mem[0xEF] (or 0xF0 depending on logic) should be 4.
        // Adjust index [SP] or [SP+1] based on your specific PUSH logic (Post-dec vs Pre-dec).
        $display("Stack Value (RA): %d (Expected 4)", uut.mem_inst.mem[SP]);
        
        // CHECK 3: Did SP Update?
        $display("Final SP        : %h (Expected EF or F1)", SP);

        $display("-------------------------------------------------------------");

        if(PC >= 8'h20 && PC < 8'h30) 
            $display("[SUCCESS] Jumped to Target Address 0x20.");
        else 
            $display("[FAILURE] PC did not reach target.");

        $finish;
    end

endmodule
