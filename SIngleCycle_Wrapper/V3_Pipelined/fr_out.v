`timescale 1ns / 1ps

module tb_OutputPort;

    // ========================================================================
    // 1. Resources
    // ========================================================================
    reg clk, rstn, int_sig;
    reg [7:0] I_Port;
    wire [7:0] O_Port;

    // --- SPY Signals ---
    wire [7:0] R0 = uut.regfile_inst.regs[0]; // Pointer Register
    wire [7:0] R1 = uut.regfile_inst.regs[1]; // Data Register
    wire [7:0] PC = uut.PC.pc_current;
    
    // Direct Access to Memory for verification
    wire [7:0] Target_Mem_Cell = uut.mem_inst.mem[100]; 

    // ========================================================================
    // 2. Instantiate CPU
    // ========================================================================
    CPU_WrapperV3 uut (
        .clk(clk), .rstn(rstn), .I_Port(I_Port), .int_sig(int_sig), .O_Port(O_Port)
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
        // --- Init ---
        I_Port = 0; int_sig = 0; rstn = 0; 
        // --- START SIMULATION ---
        #20 rstn = 1;
        
        $display("-------------------------------------------------------------");
        $display(" STI (Store Indirect) INSTRUCTION TEST");
        $display("-------------------------------------------------------------");

        // ====================================================================
        // PROGRAM MEMORY
        // ====================================================================

        // 1. LDM R0, 100 (Set Pointer Address)
        // Op:12 (C), ra:0, rb:0 -> C0
        // Imm: 100 (0x64)
        uut.mem_inst.mem[0] = 8'hC0; 
        uut.mem_inst.mem[1] = 8'h64;

        // 2. LDM R1, 0x55 (Set Data Payload)
        // Op:12 (C), ra:0, rb:1 -> C1
        // Imm: 0x55 (85 decimal)
        uut.mem_inst.mem[2] = 8'hC1; 
        uut.mem_inst.mem[3] = 8'h55;

        // 3. STI R0, R1 (Store Indirect)
        // Definition: M[R[ra]] <- R[rb]
        // Opcode: 14 (0x0E) [1110]
        // ra = 0 (00), rb = 1 (01)
        // Binary: 1110 00 01 -> Hex: E1
        uut.mem_inst.mem[4] = 8'hE1;

        // 4. HALT
        uut.mem_inst.mem[5] = 8'h00;


        
        // Wait for execution (LDM=2 cycles, STI=1 cycle + pipeline stages)
        #100;

        // ========================================================================
        // 5. CHECK RESULTS
        // ========================================================================
        $display("-------------------------------------------------------------");
        $display(" FINAL RESULTS");
        $display("-------------------------------------------------------------");
        
        $display("Pointer (R0): %d (Expected 100)", R0);
        $display("Data    (R1): %h (Expected 55)", R1);
        $display("Memory[100] : %h (Expected 55)", Target_Mem_Cell);

        if (Target_Mem_Cell == 8'h55) begin
            $display("[SUCCESS] STI verified. Data 0x55 was written to Address 100.");
        end else begin
            $display("[FAILURE] Memory Write Failed. Found %h at Address 100.", Target_Mem_Cell);
            if (Target_Mem_Cell === 8'hxx) 
                $display("          (Value is XX - likely Write Enable never triggered)");
        end

        $display("-------------------------------------------------------------");
        $stop;
    end

    // Clock-by-clock tracing
    always @(posedge clk) begin
        if (rstn) begin
            $display("PC:%2h | IR:%2h | R0:%2d R1:%2h | Mem[100]:%2h", 
                     PC, uut.IR, R0, R1, Target_Mem_Cell);
        end
    end

endmodule