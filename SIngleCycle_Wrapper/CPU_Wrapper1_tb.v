`timescale 1ns/1ps

module CPU_Wrapper1_tb();

    // Inputs
    reg clk;
    reg rst;

    // Outputs
    wire [3 : 0]    CCR_out;


    // Instantiations

    wire [7 : 0]    OutDataA,
                    OutDataB;
    
    wire mem_read;
    wire mem_write;
    wire [7:0] mem_addr_a;
    reg  [7:0] Instr_in;
    wire mem_write_enable;             // write enable for port B
    wire [7:0] mem_addr_b;
    wire [7:0] mem_write_data_b;
    reg  [7:0] mem_data_out_b;

    memory MEM_Dual (
        // Inputs
        .clk(clk),
        .rst(rst),            
        .addr_a(mem_addr_a),
        .addr_b(mem_addr_b),
        .we_b(cu_mem_write),             // write enable for port B
        .write_data_b(mem_write_data_b),
        // Ouputs
        .instr_out(Instr_in),
        .data_out_b(mem_data_out_b)
    );

    CPU_Wrapper1 CPU_UT (
        .clk(clk),
        .rst(rst),
        .CCR_out(CCR_out),

        // Interfacing with memory
        .mem_addr_a(mem_addr_a),
        .Instr_in(Instr_in),
        .mem_write_enable(mem_write_enable),             // write enable for port B
        .mem_addr_b(mem_addr_b),
        .mem_write_data_b(mem_write_data_b),
        .mem_data_out_b(mem_data_out_b)
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