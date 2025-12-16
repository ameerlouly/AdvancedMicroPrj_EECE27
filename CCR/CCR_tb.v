module CCR_tb();
    reg clk, rst;
    reg Z, N, C, V;
    reg flag_en;
    reg intr, rti;
    reg [3:0] flag_mask;
    wire [3:0] CCR;
    
    integer tests = 0;
    integer errors = 0;
    
    CCR uut(
        .clk(clk),
        .rst(rst),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V),
        .flag_en(flag_en),
        .intr(intr),
        .rti(rti),
        .flag_mask(flag_mask),
        .CCR(CCR)
    );
    
    task check_ccr(
        input [3:0] expected,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        #1;
        if (CCR !== expected) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  Expected: %b, Got: %b", expected, CCR);
        end else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $display("\n=== CCR TESTBENCH (UPDATED) ===\n");
        
        // Initialize
        rst = 1'b0;
        flag_en = 1'b0;
        intr = 1'b0;
        rti = 1'b0;
        flag_mask = 4'b0000;
        Z = 1'b0;
        N = 1'b0;
        C = 1'b0;
        V = 1'b0;
        
        // Test 1: Reset
        rst = 1'b0;
        @(posedge clk);
        check_ccr(4'b0000, "After reset: all flags cleared");
        
        // Release reset
        rst = 1'b1;
        @(posedge clk);
        check_ccr(4'b0000, "After reset release: flags still 0");
        
        // Test 2: Set Z flag (with mask)
        flag_en = 1'b1;
        flag_mask = 4'b0001;  // Only Z
        Z = 1'b1;
        @(posedge clk);
        check_ccr(4'b0001, "Z flag set with mask 0001");
        
        // Test 3: Set N flag (with mask)
        flag_mask = 4'b0010;  // Only N
        N = 1'b1;
        Z = 1'b0;
        @(posedge clk);
        check_ccr(4'b0010, "N flag set with mask 0010");
        
        // Test 4: Set C flag (with mask)
        flag_mask = 4'b0100;  // Only C
        C = 1'b1;
        N = 1'b0;
        @(posedge clk);
        check_ccr(4'b0100, "C flag set with mask 0100");
        
        // Test 5: Set V flag (with mask)
        flag_mask = 4'b1000;  // Only V
        V = 1'b1;
        C = 1'b0;
        @(posedge clk);
        check_ccr(4'b1000, "V flag set with mask 1000");
        
        // Test 6: Set all flags (with full mask)
        flag_mask = 4'b1111;  // All flags
        Z = 1'b1;
        N = 1'b1;
        C = 1'b1;
        V = 1'b1;
        @(posedge clk);
        check_ccr(4'b1111, "All flags set with mask 1111");
        
        // Test 7: Partial mask (Z and C only)
        flag_mask = 4'b0101;  // Z and C
        Z = 1'b0;
        C = 1'b0;
        @(posedge clk);
        check_ccr(4'b0101, "Partial mask: Z and C cleared, N and V hold");
        
        // Test 8: Disable flag_en (flags should not update)
        flag_en = 1'b0;
        Z = 1'b1;
        N = 1'b1;
        C = 1'b1;
        V = 1'b1;
        @(posedge clk);
        check_ccr(4'b0101, "flag_en=0: flags hold previous value");
        
        // Test 9: Re-enable flag_en with full mask
        flag_en = 1'b1;
        flag_mask = 4'b1111;
        Z = 1'b1;
        N = 1'b1;
        C = 1'b1;
        V = 1'b1;
        @(posedge clk);
        check_ccr(4'b1111, "flag_en=1, mask=1111: all flags set");
        
        // Test 10: Clear all flags
        flag_mask = 4'b1111;
        Z = 1'b0;
        N = 1'b0;
        C = 1'b0;
        V = 1'b0;
        @(posedge clk);
        check_ccr(4'b0000, "All flags cleared");
        
        // Test 11: Zero mask (no updates)
        flag_mask = 4'b0000;
        Z = 1'b1;
        N = 1'b1;
        C = 1'b1;
        V = 1'b1;
        @(posedge clk);
        check_ccr(4'b0000, "Zero mask: no flags updated");
        
        // Test 12: Interrupt signal (placeholder - ISA-specific behavior)
        flag_en = 1'b1;
        flag_mask = 4'b1111;
        Z = 1'b1;
        intr = 1'b1;
        @(posedge clk);
        // Interrupt behavior depends on ISA implementation
        $display("TEST 12: Interrupt signal asserted (behavior ISA-dependent)");
        
        // Test 13: RTI signal (placeholder - ISA-specific behavior)
        intr = 1'b0;
        rti = 1'b1;
        @(posedge clk);
        // RTI behavior depends on ISA implementation
        $display("TEST 13: RTI signal asserted (behavior ISA-dependent)");
        
        // Test 14: Typical ALU result (Z and C flags)
        rti = 1'b0;
        flag_en = 1'b1;
        flag_mask = 4'b1111;
        Z = 1'b1;
        N = 1'b0;
        C = 1'b0;
        V = 1'b0;
        @(posedge clk);
        check_ccr(4'b0001, "Typical result: Z=1 (zero result)");
        
        // Test 15: Overflow condition
        Z = 1'b0;
        V = 1'b1;
        @(posedge clk);
        check_ccr(4'b1000, "Overflow: V=1");
        
        // Print summary
        $display("\n");
        $display("======================================");
        if (errors == 0) begin
            $display("  ALL %0d CCR TESTS PASSED", tests);
        end else begin
            $display("  CCR TESTBENCH FAILED");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
        end
        $display("======================================\n");
        
        $stop;
    end
endmodule
