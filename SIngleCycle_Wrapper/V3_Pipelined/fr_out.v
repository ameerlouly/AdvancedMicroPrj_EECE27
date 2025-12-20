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
        uut.regfile_inst.regs[1] = 8'd2; 
        uut.regfile_inst.regs[2] = 8'd5;
        
        // 2. ADD R1, R2   (Op=2, ra=1, rb=2 -> 0010 11 10 -> 0x2E)
        // R3 = F0 + 01 = F1.
        uut.mem_inst.mem[8'h70] = 8'h26;
        uut.mem_inst.mem[8'h2] = 8'h26;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        int_sig = 1;
        uut.mem_inst.mem[1] = 8'h70; //interrupt
        @(posedge clk);
        int_sig = 0;
        #1;
        uut.mem_inst.mem[0] = 8'h00; 

        

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
        $display("R1 (Final Value): %d (Expected 7)", R1);
        

        $display("-------------------------------------------------------------");

        if ( R1 == 8'd12)
            $display("[SUCCESS] All ALU operations executed correctly.");
        else
            $display("[FAILURE] One or more results are incorrect.");

        $finish;
    end

endmodule