`timescale 1ns / 1ps

module tb_ALU_Sequence;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // --- Internal Debug Signals ---
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] PC = uut.PC.pc_current;
    wire [3:0] CCR = uut.ccr_inst.CCR; 

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
        
        // --- Execute ---
        #20 rstn = 1;

        $display("Loading ALU Sequence Program...");

        // Memory Setup: Reset Vector at 0x00
        uut.mem_inst.mem[0] = 8'h00; 

        // 0x00: LDM R0, 20
        // Op: 12 (1100), ra:00, rb:00 -> C0
        uut.mem_inst.mem[0] = 8'hC0; 
        uut.mem_inst.mem[1] = 8'd20;
        
        // 0x02: LDM R1, 40
        // Op: 12 (1100), ra:00, rb:01 -> C1
        uut.mem_inst.mem[2] = 8'hC1; 
        uut.mem_inst.mem[3] = 8'd40;
        
        // 0x04: ADD R1, R0 (R1 = 40 + 20 = 60)
        // Op: 2 (0010), ra:01, rb:00 -> 24
        uut.mem_inst.mem[4] = 8'h24;
        
        // 0x05: ADD R2, R1 (R2 = R2_init + 60)
        // Note: R2 is typically 0 after reset. Result = 60.
        // Op: 2 (0010), ra:10, rb:01 -> 29
        uut.mem_inst.mem[5] = 8'h29;
        
        // 0x06: AND R1, R2 (R1 = 60 & 60 = 60)
        // Op: 4 (0100), ra:01 (AND), rb:10 -> 46
        uut.mem_inst.mem[6] = 8'h46;

        // 0x07: STOP (NOP)
        uut.mem_inst.mem[7] = 8'h00;

        

        // Run for 30 cycles to allow all instructions to traverse the pipeline
        repeat (30) @(posedge clk);

        // Final settle time for Write-Back
        #5;

        $display("-------------------------------------------------------------");
        $display("ALU SEQUENCE TEST REPORT");
        $display("-------------------------------------------------------------");
        $display("PC Final Value: %h", PC);
        $display("R0 (Expected 20): %d", R0);
        $display("R1 (Expected 60): %d", R1);
        $display("R2 (Expected 60): %d", R2);
        $display("CCR (Flags)     : %b", CCR);
        
        if (R1 == 8'd60 && R2 == 8'd60)
            $display("[SUCCESS] ALU sequence executed correctly.");
        else
            $display("[FAILURE] Result mismatch.");
            
        $display("-------------------------------------------------------------");
        $stop;
    end

    // --- Monitoring ---
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time:%t | PC:%h | IR:%h | R0:%d | R1:%d | R2:%d", 
                     $time, PC, uut.IR, R0, R1, R2);
        end
    end

endmodule