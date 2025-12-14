`timescale 1ns / 1ps

module tb_PROJECT_ASM;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // Internal Debug Signals (Mapping specific to your hierarchy)
    // Adjust "uut.regfile_inst.regs" if your hierarchy names differ.
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] SP = uut.regfile_inst.regs[3]; 
    wire [7:0] PC = uut.PC.pc_current;
    
    // ========================================================================
    // 2. DUT Instantiation
    // ========================================================================
    // Ensure the module name matches your design (e.g., Processor, CPU_Wrapper)
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
        I_Port = 8'd10; // Set Input Port to 10 so IN R1 reads 10
        int_sig = 0;

        // --- Load Machine Code into Memory ---
        $display("Loading Assembly Binary into Memory...");

        // 0: LDM R2, 10 -> R2 becomes 10 (0x0A)
        uut.mem_inst.mem[0] = 8'hC2; 
        uut.mem_inst.mem[1] = 8'h0A;

        // 2: LDM R0, 0 -> R0 becomes 0
        uut.mem_inst.mem[2] = 8'hC0; 
        uut.mem_inst.mem[3] = 8'h00;

        // 4: IN R1 -> Reads I_Port (10) into R1
        uut.mem_inst.mem[4] = 8'h7D;

        // 5: SUB R2, R1 -> 10 - 10 = 0. Z-flag becomes 1.
        uut.mem_inst.mem[5] = 8'h39;

        // 6: JZ R2 -> Since Z=1, PC jumps to address in R2 (which is 10)
        uut.mem_inst.mem[6] = 8'h92;

        // 7, 8, 9: NOPs (Skipped by Jump)
        uut.mem_inst.mem[7] = 8'h00;
        uut.mem_inst.mem[8] = 8'h00;
        uut.mem_inst.mem[9] = 8'h00;

        // 10: LDM R0, 20 -> Executed after Jump. R0 becomes 20 (0x14)
        uut.mem_inst.mem[10] = 8'hC0;
        uut.mem_inst.mem[11] = 8'h14;

        // --- Release Reset ---
        #20 rstn = 1;
        
        // --- Run Simulation ---
        #500; 
        
        $display("-------------------------------------------------------------");
        $display("FINAL STATE CHECK:");
        $display("R0 (Should be 20/0x14): %h", R0);
        $display("R1 (Should be 10/0x0A): %h", R1);
        $display("R2 (Should be 10/0x0A): %h", R2);
        $display("PC (Should be > 11):    %d", PC);
        $display("-------------------------------------------------------------");
        
        if(R0 == 8'h14) $display("SUCCESS: Jump taken, R0 loaded with 20.");
        else $display("FAILURE: R0 incorrect.");

        $stop;
    end

    // ========================================================================
    // 5. Monitor
    // ========================================================================
    always @(posedge clk) begin
        if (rstn) begin
            // Adjust uut.CCR_inst.CCR_reg to match your CCR signal path
             $display("Time:%4t | PC:%2d | R0:%h R1:%h R2:%h", 
                      $time, PC, R0, R1, R2);
        end
    end

endmodule