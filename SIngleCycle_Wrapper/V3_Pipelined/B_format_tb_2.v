`timescale 1ns / 1ps

module tb_B_Format_Calls;

    // 1. Signals
    reg clk, rstn, int_sig;
    reg [7:0] I_Port;
    wire [7:0] O_Port;

    // Hierarchical Links
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] SP = uut.regfile_inst.regs[3]; // R3 is SP

    // 2. Memory Peek Arrays
    wire [7:0] stack_peek [0:3];
    wire [7:0] code_peek  [0:3];

    genvar i;
    generate
        // Peek at the very top of memory (Stack space)
        for (i = 0; i < 4; i = i + 1) begin : stack_mon
            assign stack_peek[i] = uut.mem_inst.mem[255-i];
        end
        // Peek at the program start
        for (i = 0; i < 4; i = i + 1) begin : code_mon
            assign code_peek[i] = uut.mem_inst.mem[8'h10 + i];
        end
    endgenerate

    // 3. DUT Instantiation
    CPU_WrapperV3 uut (
        .clk(clk), .rstn(rstn), .I_Port(I_Port), .int_sig(int_sig), .O_Port(O_Port)
    );

    // 4. Clock and Loading
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rstn = 0; I_Port = 0; int_sig = 0;
        #20 rstn = 1;
        
        // LOAD PROGRAM FROM HEX FILE
        $display("Loading B_tb_program_0.hex into memory...");
        $readmemh("B_tb_program_0.hex", uut.mem_inst.mem);

        // Safety timeout
        #2500;
        $display("TIMEOUT: Program did not reach finish line.");
        $stop;
    end

    // 5. Execution Monitor
    always @(posedge clk) begin
        if (rstn) begin
            $display("T:%0t | PC:%h | IR:%h | Rs: %h, %h, %h, %h | Stack: %h %h %h %h", 
                     $time, PC, uut.IR, R0, R1, R2, SP, stack_peek[3], stack_peek[2], stack_peek[1], stack_peek[0]);

            // Detect End of Simulation
            if (PC == 8'h41) begin
                #200; // Final cycle
                $display("-------------------------------------------------------");
                if (R0 == 8'hFF) 
                    $display("SUCCESS: B-Format tests passed. Final R0: %h", R0);
                else 
                    $display("FAILURE: Expected R0=FF, got %h", R0);
                $display("-------------------------------------------------------");
                $stop;
            end
        end
    end

endmodule