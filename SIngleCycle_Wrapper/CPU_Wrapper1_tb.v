`timescale 1ns/1ps

module CPU_Wrapper1_tb();

    // Clock / reset
    reg clk;
    reg rst;

    // DUT IO
    wire [7:0] mem_addr_a;
    wire [7:0] Instr_in;                // driven by memory instance (output port)
    wire       mem_write_enable;
    wire [7:0] mem_addr_b;
    wire [7:0] mem_write_data_b;
    wire [7:0] mem_data_out_b;          // driven by memory instance (output port)
    wire [3:0] CCR_out;

    // Instantiate DUT
    CPU_Wrapper1 uut (
        .clk(clk),
        .rst(rst),
        .CCR_out(CCR_out),
        .mem_addr_a(mem_addr_a),
        .Instr_in(Instr_in),
        .mem_write_enable(mem_write_enable),
        .mem_addr_b(mem_addr_b),
        .mem_write_data_b(mem_write_data_b),
        .mem_data_out_b(mem_data_out_b)
    );

    // Simple instruction memory (A-format only) and data memory
        // We'll use the project's synchronous dual-port memory instance for instruction fetch and data
        memory MEM_Dual (
            .clk(clk),
            .rst(rst),
            .addr_a(mem_addr_a),
            .instr_out(Instr_in),
            .we_b(mem_write_enable),
            .addr_b(mem_addr_b),
            .write_data_b(mem_write_data_b),
            .data_out_b(mem_data_out_b)
        );
    // Testbench-scoped variables (declare at module scope for Verilog compatibility)
    integer i;
    reg [7:0] exp_R0 [0:31];
    reg [7:0] exp_R1 [0:31];
    reg       exp_valid [0:31];
    integer errors;
    integer pc;
    reg [7:0] r0; reg [7:0] r1;

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz-ish for simulation convenience
    end

    // Helper: show registers every cycle
    task dump_regs();
        begin
            $display("TIME=%0t PC=%0d IR=%02h CCR=%b memB_addr=%0d memB_data=%02h", $time, mem_addr_a, Instr_in, CCR_out, mem_addr_b, mem_write_data_b);
            $display("  regs: R0=%0d R1=%0d R2=%0d R3=%0d", uut.Register_File.regs[0], uut.Register_File.regs[1], uut.Register_File.regs[2], uut.Register_File.regs[3]);
        end
    endtask

    // Initialize memories and DUT state (self-checking)
    initial begin

        // clear memory (initialize all 256 bytes)
        for (i = 0; i < 256; i = i + 1) MEM_Dual.mem[i] = 8'h00;

        // Example A-format program (opcode[7:4], ra[3:2], rb[1:0])
        MEM_Dual.mem[0]  = 8'h00; // NOP
        MEM_Dual.mem[1]  = 8'h21; // ADD  R0, R1   (opcode=2 ra=0 rb=1)
        MEM_Dual.mem[2]  = 8'h31; // SUB  R0, R1
        MEM_Dual.mem[3]  = 8'h41; // AND  R0, R1
        MEM_Dual.mem[4]  = 8'h51; // OR   R0, R1
        MEM_Dual.mem[5]  = 8'h61; // RLC  (group6 ra=0 -> RLC on R1)
        MEM_Dual.mem[6]  = 8'h65; // RRC  (group6 ra=1 -> RRC on R1)
        MEM_Dual.mem[7]  = 8'h81; // NOT  (group8 ra=0 on R1)
        MEM_Dual.mem[8]  = 8'h85; // NEG  (group8 ra=1 on R1)
        MEM_Dual.mem[9]  = 8'h89; // INC  (group8 ra=2 on R1)
        MEM_Dual.mem[10] = 8'h8D; // DEC  (group8 ra=3 on R1)
        MEM_Dual.mem[11] = 8'h00; // NOP

        // preset register values (use hierarchical access to Register_file regs)
        rst = 0;

        #20; // hold reset for a few cycles
        rst = 1;

        // Initialize registers to known non-zero values for observable ALU ops
        uut.Register_File.regs[0] = 8'd5;   // R0 = 5
        uut.Register_File.regs[1] = 8'd3;   // R1 = 3
        uut.Register_File.regs[2] = 8'd0;   // R2 = 0
        uut.Register_File.regs[3] = 8'd255; // SP = 255 (as per reset semantics)

        // default: invalid
        for (i = 0; i < 32; i = i + 1) begin
            exp_R0[i] = 8'hxx;
            exp_R1[i] = 8'hxx;
            exp_valid[i] = 1'b0;
        end

        // initial state (after reset, before PC 0 executes)
        // After executing instruction at PC=0 (NOP) registers unchanged
        exp_R0[0] = 8'd5; exp_R1[0] = 8'd3; exp_valid[0] = 1'b1;
        // After PC=1 (ADD R0,R1) -> R0 = 5+3 = 8
        exp_R0[1] = 8'd8; exp_R1[1] = 8'd3; exp_valid[1] = 1'b1;
        // After PC=2 (SUB R0,R1) -> R0 = 8-3 = 5
        exp_R0[2] = 8'd5; exp_R1[2] = 8'd3; exp_valid[2] = 1'b1;
        // After PC=3 (AND R0,R1) -> R0 = 5 & 3 = 1
        exp_R0[3] = 8'd1; exp_R1[3] = 8'd3; exp_valid[3] = 1'b1;
        // After PC=4 (OR R0,R1) -> R0 = 1 | 3 = 3
        exp_R0[4] = 8'd3; exp_R1[4] = 8'd3; exp_valid[4] = 1'b1;
        // After PC=5 (RLC R1) -> R1 = 2
        exp_R0[5] = 8'd3; exp_R1[5] = 8'd2; exp_valid[5] = 1'b1;
        // After PC=6 (RRC R1) -> R1 = 1
        exp_R0[6] = 8'd3; exp_R1[6] = 8'd1; exp_valid[6] = 1'b1;
        // After PC=7 (NOT R1) -> R1 = ~1 = 254
        exp_R0[7] = 8'd3; exp_R1[7] = 8'd254; exp_valid[7] = 1'b1;
        // After PC=8 (NEG R1) -> R1 = 2
        exp_R0[8] = 8'd3; exp_R1[8] = 8'd2; exp_valid[8] = 1'b1;
        // After PC=9 (INC R1) -> R1 = 3
        exp_R0[9] = 8'd3; exp_R1[9] = 8'd3; exp_valid[9] = 1'b1;
        // After PC=10 (DEC R1) -> R1 = 2
        exp_R0[10] = 8'd3; exp_R1[10] = 8'd2; exp_valid[10] = 1'b1;

        // run for a number of cycles and self-check
        #10;

        errors = 0;

        for (i = 0; i < 20; i = i + 1) begin
            @(posedge clk);
            dump_regs();

            // sample PC (fetch address used during cycle)
            pc = mem_addr_a;

            if (exp_valid[pc]) begin
                // read current regs via hierarchical access
                r0 = uut.Register_File.regs[0];
                r1 = uut.Register_File.regs[1];
                if (r0 !== exp_R0[pc]) begin
                    $display("[FAIL] PC=%0d: R0 expected=%0d actual=%0d", pc, exp_R0[pc], r0);
                    errors = errors + 1;
                end
                if (r1 !== exp_R1[pc]) begin
                    $display("[FAIL] PC=%0d: R1 expected=%0d actual=%0d", pc, exp_R1[pc], r1);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display("SELF-CHECK PASS: All expected register values matched");
        end else begin
            $display("SELF-CHECK FAIL: %0d mismatches detected", errors);
        end

        $display("Testbench finished");
        if (errors) $fatal(1);
        $finish;
    end

    // Memory instance `MEM_Dual` now drives `Instr_in` and `mem_data_out_b`,
    // and handles writes when `mem_write_enable` is asserted by the DUT.

endmodule
// `timescale 1ns/1ps

// module CPU_Wrapper1_tb();

//     // Inputs
//     reg clk;
//     reg rst;

//     // Outputs
//     wire [3 : 0]    CCR_out;


//     // Instantiations

//     wire [7 : 0]    OutDataA,
//                     OutDataB;
    
//     wire mem_read;
//     wire mem_write;
//     wire [7:0] mem_addr_a;
//     reg  [7:0] Instr_in;
//     wire mem_write_enable;             // write enable for port B
//     wire [7:0] mem_addr_b;
//     wire [7:0] mem_write_data_b;
//     reg  [7:0] mem_data_out_b;

//     memory MEM_Dual (
//         // Inputs
//         .clk(clk),
//         .rst(rst),            
//         .addr_a(mem_addr_a),
//         .addr_b(mem_addr_b),
//         .we_b(cu_mem_write),             // write enable for port B
//         .write_data_b(mem_write_data_b),
//         // Ouputs
//         .instr_out(Instr_in),
//         .data_out_b(mem_data_out_b)
//     );

//     CPU_Wrapper1 CPU_UT (
//         .clk(clk),
//         .rst(rst),
//         .CCR_out(CCR_out),

//         // Interfacing with memory
//         .mem_addr_a(mem_addr_a),
//         .Instr_in(Instr_in),
//         .mem_write_enable(mem_write_enable),             // write enable for port B
//         .mem_addr_b(mem_addr_b),
//         .mem_write_data_b(mem_write_data_b),
//         .mem_data_out_b(mem_data_out_b)
//     );


//     // Clock generation: 10ns period
//     initial begin
//         clk = 0;
//         forever #1 clk = ~clk; // toggle every 5ns
//     end

//     // Stimulus block (empty for now)
//     initial begin
//         // Add your test vectors here
//         // Example:
//         // #10; // wait 10ns
//         // <drive signals>
        
//         #100; // simulation time placeholder
//         $finish;
//     end

// endmodule