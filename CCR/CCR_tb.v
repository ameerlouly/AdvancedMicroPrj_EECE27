module CCR_tb();
    reg clk, rst;
    reg Z, N, C, V;
    reg flag_en;
    wire [3:0] CCR_reg;
    
    CCR uut(
        .clk(clk),
        .rst(rst),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V),
        .flag_en(flag_en),
        .CCR_reg(CCR_reg)
    );
    
    // Clock generation
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    initial begin
        // Test 1: Reset
        rst = 1;
        flag_en = 0;
        Z = 0; N = 0; C = 0; V = 0;
        #10;
        rst = 0;
        $display("Test 1 - After Reset: CCR_reg = %b (Expected: 0000)", CCR_reg);
        
        // Test 2: Set all flags
        #10;
        flag_en = 1;
        Z = 1; N = 1; C = 1; V = 1;
        #10;
        $display("Test 2 - All Flags Set: CCR_reg = %b (Expected: 1111)", CCR_reg);
        
        // Test 3: Clear all flags
        Z = 0; N = 0; C = 0; V = 0;
        #10;
        $display("Test 3 - All Flags Clear: CCR_reg = %b (Expected: 0000)", CCR_reg);
        
        // Test 4: Set only Z and N (result from addition)
        Z = 1; N = 0; C = 1; V = 0;
        #10;
        $display("Test 4 - Z=1, N=0, C=1, V=0: CCR_reg = %b (Expected: 0101)", CCR_reg);
        
        // Test 5: Disable flag_en (flags should not change)
        flag_en = 0;
        Z = 0; N = 0; C = 0; V = 0;
        #10;
        $display("Test 5 - flag_en=0 (no update): CCR_reg = %b (Expected: 0101)", CCR_reg);
        
        // Test 6: Re-enable flag_en
        flag_en = 1;
        Z = 0; N = 0; C = 0; V = 0;
        #10;
        $display("Test 6 - flag_en=1 (update): CCR_reg = %b (Expected: 0000)", CCR_reg);
        
        // Test 7: Reset during operation
        Z = 1; N = 1; C = 1; V = 1;
        #10;
        rst = 1;
        #10;
        $display("Test 7 - After Reset with flags set: CCR_reg = %b (Expected: 0000)", CCR_reg);
        
        $stop;
    end
endmodule
