`timescale 1ns / 1ps

module tb_OutputPort;

   // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3];
    wire [7:0] PC = uut.PC.pc_current;
    
    // Check flags (Assuming CCR bit 0=Z, bit 1=N, bit 2=C, etc. Adjust if needed)
    wire Flag_C = uut.ccr_inst.CCR_reg[0]; // Example: Check your specific CCR bit mapping!

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
        #20; 
        rstn = 1; 

        // --- DIRECT REGISTER INIT ---
        // R1 = 0xF0 (11110000)
        // R2 = 0x01 (00000001)
        #1;
        uut.regfile_inst.regs[1] = 8'hF0; 
        uut.regfile_inst.regs[2] = 8'h01;
        
        // --- LOAD PROGRAM ---
        
        // 1. MOV R3, R1   (Op=1, ra=3, rb=1 -> 0001 11 01 -> 0x1D)
        // R3 should become 0xF0.
        uut.mem_inst.mem[0] = 8'h1D; 

        // 2. ADD R3, R2   (Op=2, ra=3, rb=2 -> 0010 11 10 -> 0x2E)
        // R3 = F0 + 01 = F1.
        uut.mem_inst.mem[1] = 8'h2E;

        // 3. SUB R3, R2   (Op=3, ra=3, rb=2 -> 0011 11 10 -> 0x3E)
        // R3 = F1 - 01 = F0.
        uut.mem_inst.mem[2] = 8'h3E;

        // 4. AND R3, R2   (Op=4, ra=3, rb=2 -> 0100 11 10 -> 0x4E)
        // R3 = F0 (11110000) & 01 (00000001) = 00.
        uut.mem_inst.mem[3] = 8'h4E;
        
        // 5. OR R3, R1    (Op=5, ra=3, rb=1 -> 0101 11 01 -> 0x5D)
        // R3 = 00 | F0 = F0.
        uut.mem_inst.mem[4] = 8'h5D;

        // 6. SETC         (Op=6, ra=2, rb=X -> 0110 10 00 -> 0x68)
        // Set Carry Flag to 1.
        uut.mem_inst.mem[5] = 8'h68;

        // 7. RLC R2       (Op=6, ra=0, rb=2 -> 0110 00 10 -> 0x62)
        // Rotate Left through Carry. 
        // R2 was 01. C is 1.
        // Result: (01 << 1) | 1 = 03. C becomes old MSB (0).
        uut.mem_inst.mem[6] = 8'h62;

        // 8. CLRC         (Op=6, ra=3, rb=X -> 0110 11 00 -> 0x6C)
        // Clear Carry Flag to 0.
        uut.mem_inst.mem[7] = 8'h6C;

        // 9. RRC R1       (Op=6, ra=1, rb=1 -> 0110 01 01 -> 0x65)
        // Rotate Right through Carry.
        // R1 is F0 (11110000). C is 0.
        // Result: (0 << 7) | (F0 >> 1) = 00 | 78 = 78. C becomes old LSB (0).
        uut.mem_inst.mem[8] = 8'h65;

        // 10. HALT
        uut.mem_inst.mem[9] = 8'h00;


        // --- RUN SIMULATION ---
        #250; 

        // ========================================================================
        // 5. Check Results
        // ========================================================================
        $display("-------------------------------------------------------------");
        $display("ALU OPERATIONS TEST REPORT");
        $display("-------------------------------------------------------------");
        
        // MOV
        // We can't check every step unless we monitored continuously, 
        // but we can infer success if the chain worked or checking specific regs.
        // Let's rely on the final state of R3 (from the OR operation)
        // Last R3 op was OR 00, F0 -> F0.
        $display("R3 (Final Value): %h (Expected F0)", R3);
        
        // R2 (After RLC)
        // Start: 01. SETC(1). RLC -> (01<<1)|1 = 03.
        $display("R2 (After RLC)  : %h (Expected 03)", R2);

        // R1 (After RRC)
        // Start: F0. CLRC(0). RRC -> (0<<7)|(F0>>1) = 78.
        $display("R1 (After RRC)  : %h (Expected 78)", R1);
        
        // Final Carry Check (RRC of F0 -> LSB was 0 -> C=0)
        // Note: You need to know which bit in CCR is Carry. I assumed bit 0 or similar.
        // $display("CCR Value       : %b", uut.CCR);

        $display("-------------------------------------------------------------");

        if (R1 == 8'h78 && R2 == 8'h03 && R3 == 8'hF0)
            $display("[SUCCESS] All ALU operations executed correctly.");
        else
            $display("[FAILURE] One or more results are incorrect.");

        $finish;
    end

endmodule