`timescale 1ns/1ps

module CPU_Wrapper1_tb();

    // Clock signal
    reg clk;
    reg rst;


    // Instantiations

    wire [7 : 0]    OutDataA,
                    OutDataB;
    memory MEM_Dual (
        // Inputs
        .clk(clk),
        .rst(rst),            
        .addr_a(pc_current),
        .addr_b(rb_data),
        .we_b(cu_mem_write),             // write enable for port B
        .write_data_b(AlU_out),
        // Ouputs
        .instr_out(OutDataA),
        .data_out_b(OutDataB)
    );

    CPU_Wrapper1 CPU_UT (
        .clk(clk),
        .rst(rst),
        output reg [3 : 0] CCR_out,

        // Interfacing with memory
        output mem_read, mem_write,
        output  wire [7:0]  mem_addr_a,
        input   reg  [7:0]  Instr_in,
        output  wire        mem_write_enable,             // write enable for port B
        output  wire [7:0]  mem_addr_b,
        output wire [7:0]   mem_write_data_b,
        input reg  [7:0]    mem_data_out_b
    );


    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // toggle every 5ns
    end

    // Stimulus block (empty for now)
    initial begin
        // Add your test vectors here
        // Example:
        // #10; // wait 10ns
        // <drive signals>
        
        #100; // simulation time placeholder
        $finish;
    end

endmodule