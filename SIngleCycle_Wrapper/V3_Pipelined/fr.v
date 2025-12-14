`timescale 1ns / 1ps

module tb_LDD_Only;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals (Using YOUR hierarchy) ---
    wire [7:0] R1 = uut.regfile_inst.regs[1]; // We are testing LDD R1
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
        // --- Initialize Inputs ---
        rstn = 0;
        I_Port = 0;
        int_sig = 0;
        
        // --- Clear Memory (Optional but good practice) ---
        // (Assuming simulation memory initializes to X or 0, clearer to be explicit)
        // integer i;
        // for (i=0; i<256; i=i+1) uut.mem_inst.mem[i] = 8'h00;

        // -----------------------------------------------------------------
        // TEST PROGRAM: LDD R1, [0xF0]
        // -----------------------------------------------------------------
        
        // 1. Load the Instruction at Address 0
        // Opcode 12 (1100), ra=1 (LDD mode), rb=1 (Dest R1) -> 11000101 -> 0xC5
        uut.mem_inst.mem[0] = 8'hC5; 
        
        // 2. Load the Memory Address Operand at Address 1
        // We want to read from address 0xF0 (240)
        uut.mem_inst.mem[1] = 8'hF0; 

        // 3. Load the DATA at the Target Address (0xF0)
        // This is the value we expect to see in R1 later.
        uut.mem_inst.mem[240] = 8'hAA; // 0xAA = 10101010


        // --- Release Reset ---
        #20 rstn = 1;
        
        // --- Run Simulation ---
        // LDD is a 2-byte instruction. 
        // Cycles: Fetch(1) -> Decode(2) -> Execute(3) -> Memory(4) -> Writeback(5)
        // We run for 100ns (10 cycles) to be safe.
        #100; 
        
        // -----------------------------------------------------------------
        // 5. Check Results
        // -----------------------------------------------------------------
        $display("-------------------------------------------------------------");
        $display("LDD SINGLE INSTRUCTION TEST");
        $display("-------------------------------------------------------------");
        $display("Memory[0xF0] contains : %h (Expected AA)", uut.mem_inst.mem[240]);
        $display("R1 Value              : %h (Expected AA)", R1);
        $display("PC Value              : %d (Expected 2 or 3)", PC);
        $display("-------------------------------------------------------------");
        
        if(R1 == 8'hAA) 
            $display("[SUCCESS] LDD R1, [0xF0] worked correctly.");
        else 
            $display("[FAILURE] R1 did not load the correct value.");

        $finish;
    end

endmodule
