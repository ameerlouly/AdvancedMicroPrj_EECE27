`timescale 1ns / 1ps

module tb_OutputPort;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    
    // OUTPUT PORT: This is what we are testing
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] R1 = uut.regfile_inst.regs[1]; // We will send R1 to Output
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

        #20 rstn = 1;


        uut.mem_inst.mem[0] = 8'h00;
        // --- 1. PREPARE DATA IN REGISTER R1 ---
        // We first load 0x55 (01010101) into R1 using LDM.
        // Op=12(1100), ra=0, rb=1 -> 0xC1
        uut.mem_inst.mem[1] = 8'hC1;
        uut.mem_inst.mem[2] = 8'h55; // The pattern we want to see on Output


        // --- 2. THE OUT INSTRUCTION ---
        // Instruction: OUT R1
        // (Assuming Opcode 7 is I/O. Please check your specific Hex Code for OUT).
        // If IN R1 is 0x7D (Op=7, ra=3, rb=1)...
        // OUT R1 might be Op=7, ra=1, rb=1? -> 0x75? 
        // **REPLACE 8'h75 WITH YOUR EXACT 'OUT R1' OPCODE IF DIFFERENT**
        uut.mem_inst.mem[3] = 8'h75; 

        // Addr 3: Halt/NOP
        uut.mem_inst.mem[4] = 8'h00;


        // --- Release Reset ---
        

        // --- Run Simulation ---
        // LDM takes 5 cycles. OUT usually takes 3-5 cycles.
        #100; 

        // ========================================================================
        // 5. Check Results
        // ========================================================================
        $display("-------------------------------------------------------------");
        $display("OUTPUT PORT TEST");
        $display("-------------------------------------------------------------");
        
        $display("Register R1 Value : %h (Expected 55)", R1);
        $display("Output Port Value : %h (Expected 55)", O_Port);
        
        if(O_Port == 8'h55) 
            $display("[SUCCESS] O_Port correctly updated to 0x55.");
        else 
            $display("[FAILURE] O_Port is %h (Expected 0x55). Check Opcode.", O_Port);

        $finish;
    end

endmodule
