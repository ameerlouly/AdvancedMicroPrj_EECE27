`timescale 1ns/1ps

module memory_tb;

    // DUT signals
    reg        clk;
    reg        rst;          // active-low reset
    reg  [7:0] address;
    reg        mem_read;
    reg        mem_write;
    reg  [7:0] write_data;
    wire [7:0] out_data;

    // counters
    integer errors  = 0;
    integer tests   = 0;

    // Instantiate DUT
    memory dut (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .write_data (write_data),
        .out_data   (out_data)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------- TASKS ----------
    task write_mem(
        input [7:0] addr,
        input [7:0] data
    );
    begin
        @(negedge clk);      
        mem_write  = 1'b1;
        mem_read   = 1'b0;
        address    = addr;
        write_data = data;
        @(posedge clk);     

      
        @(negedge clk);
        mem_write  = 1'b0;
        write_data = 8'd0;
    end
    endtask


    task read_check(
        input [7:0] addr,
        input [7:0] expected
    );
    begin
        tests = tests + 1;

        
        @(negedge clk);
        address  = addr;
        mem_read = 1'b1;
        mem_write= 1'b0;

        #1; 

        if (out_data !== expected) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: addr=%0h expected=%0h got=%0h",
                     tests, addr, expected, out_data);
        end
        else begin
            $display("TEST %0d PASSED: addr=%0h value=%0h",
                     tests, addr, out_data);
        end

        
        @(negedge clk);
        mem_read = 1'b0;
    end
    endtask


    // ---------- MAIN STIMULUS ----------
    initial begin
        // init signals
        address    = 8'd0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        write_data = 8'd0;

        // reset
        rst = 1'b0;      // active-low
        #20;
        rst = 1'b1;
        #10;

        // Test 1: write/read 0xAA at address 0x10
        write_mem (8'h10, 8'hAA);
        read_check(8'h10, 8'hAA);

        // Test 2: write/read 0x55 at address 0x20
        write_mem (8'h20, 8'h55);
        read_check(8'h20, 8'h55);

        // Test 3: overwrite same address
        write_mem (8'h10, 8'h0F);
        read_check(8'h10, 8'h0F);

        // Test 4: check address not written (should be 0)
        read_check(8'h30, 8'h00);

        // ---------- FINAL RESULT ----------
        if (errors == 0) begin
            $display("======================================");
            $display("  ALL %0d TESTS PASSED ", tests);
            $display("======================================");
        end
        else begin
            $display("======================================");
            $display("  TESTBENCH FAILED ");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
            $display("======================================");
        end

        $stop;
    end

endmodule
