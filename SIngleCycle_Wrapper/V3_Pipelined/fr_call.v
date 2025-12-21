`timescale 1ns / 1ps

module tb_Call_Indirect;

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
    wire [7:0] SP = uut.regfile_inst.regs[3]; // SP is R3
    wire [7:0] PC = uut.PC.pc_current;
    
    // To check if return address was pushed to stack
    wire [7:0] StackTop = uut.mem_inst.mem[SP - 1];

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
        
        $display("Loading Indirect Call Test Program...");
        
        // --- Execute ---
        #20 rstn = 1;

        // Memory Setup: Initialize target address in memory
        // Let's put the address 0x50 (80 decimal) into memory location 100
        uut.mem_inst.mem[100] = 8'h50;

        // 0x00: NOP
        uut.mem_inst.mem[0] = 8'h00; 

        // 0x01: LDD R1, 100 (Load R1 with the value at memory 100, which is 0x50)
        // Op: 12 (1100), ra:01 (LDD), rb:01 (R1) -> C5
        uut.mem_inst.mem[1] = 8'hC5; 
        uut.mem_inst.mem[2] = 8'd100;
        
        // 0x03: CALL R1 (Jump to address in R1, push PC+1 to stack)
        // Op: 11 (1011), brx:01 (CALL), rb:01 (R1) -> B5
        uut.mem_inst.mem[3] = 8'hB5;
        
        // 0x04: NOP (This is the return address: 0x04)
        uut.mem_inst.mem[4] = 8'h00;

        // 0x50: Target instruction (e.g., a NOP at the subroutine start)
        uut.mem_inst.mem[8'h50] = 8'h00;

        

        // Run for 30 cycles to allow the Call to complete and jump
        repeat (30) @(posedge clk);

        $display("-------------------------------------------------------------");
        $display("INDIRECT CALL TEST REPORT");
        $display("-------------------------------------------------------------");
        $display("R1 Value (Target Address): %h (Expected 50)", R1);
        $display("Final PC: %h (Expected 50 or 51)", PC);
        $display("Stack Pointer: %h", SP);
        $display("Value on Stack (Return Addr): %h (Expected 04)", StackTop);
        
        if (R1 == 8'h50 && PC >= 8'h50 && StackTop == 8'h04)
            $display("[SUCCESS] Indirect Call executed correctly.");
        else
            $display("[FAILURE] Call logic failed.");
            
        $display("-------------------------------------------------------------");
        $stop;
    end

    // --- Monitoring ---
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%t | PC:%h | IR:%h | R1:%h | SP:%h", 
                     $time, PC, uut.IR, R1, SP);
        end
    end

endmodule