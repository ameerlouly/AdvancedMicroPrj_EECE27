`timescale 1ns/1ps

module memory_tb;

    reg clk;
    reg rst; // active-low reset as in your module

    // Port A (instruction)
    reg  [7:0] addr_a;
    wire [7:0] instr_out;

    // Port B (data)
    reg        we_b;
    reg  [7:0] addr_b;
    reg  [7:0] write_data_b;
    wire [7:0] data_out_b;

    // DUT
    memory uut (
        .clk(clk),
        .rst(rst),
        .addr_a(addr_a),
        .instr_out(instr_out),
        .we_b(we_b),
        .addr_b(addr_b),
        .write_data_b(write_data_b),
        .data_out_b(data_out_b)
    );

    // clock generator: period = 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("=== memory_tb start ===");
        // init
        rst = 0;       // assert reset (active-low)
        we_b = 0;
        addr_a = 8'd0;
        addr_b = 8'd0;
        write_data_b = 8'd0;

        #20;
        rst = 1;       // release reset
        #10;

        // ---------- Test 1: write @5, then read @5 (same addr) ----------
        $display("-- Test1: write 0xAA to addr 5 then read back --");
        we_b = 1;
        addr_b = 8'd5;
        write_data_b = 8'hAA;
        #10;                 // posedge: write happens, outputs update
        we_b = 0;
        // next cycle read
        addr_b = 8'd5;
        #10;
        $display("Read addr 5 => data_out_b = %h (expected AA)", data_out_b);

        // ---------- Test 2: write @5 and read different addr @10 (Port A) ----------
        $display("-- Test2: write addr 5 (PortB) and fetch instr from addr 10 (PortA) --");
        // first initialize mem[10] to known value via write
        we_b = 1; addr_b = 8'd10; write_data_b = 8'h33; #10; we_b = 0; #10;
        // now write to 5 while fetching addr 10
        we_b = 1; addr_b = 8'd5; write_data_b = 8'h55;
        addr_a = 8'd10;   // Port A reads addr 10
        #10; // posedge: write to addr5 happens, data_out_b becomes 0x55, instr_out becomes mem[10] (or previously written)
        we_b = 0;
        #10;
        $display("instr_out (addr10) = %h (expected 33)", instr_out);
        $display("data_out_b (addr5) = %h (expected 55)", data_out_b);

        // ---------- Test 3: read-after-write SAME address collision check ----------
        $display("-- Test3: RAW same address (addr=20) --");
        we_b = 1; addr_b = 8'd20; write_data_b = 8'hF0;
        addr_a = 8'd20; // same address for instruction fetch
        #10;  // posedge: write and fetch happen
        we_b = 0;
        #10;
        $display("instr_out = %h (expected F0)", instr_out);
        $display("data_out_b = %h (expected F0)", data_out_b);

        $display("=== memory_tb done ===");
        $stop;
    end

endmodule
