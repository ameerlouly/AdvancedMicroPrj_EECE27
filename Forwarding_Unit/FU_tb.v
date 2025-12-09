`timescale 1ns/1ps

/*
 * FU_tb.v - Forwarding Unit Testbench
 * 
 * Tests the data forwarding logic for eliminating RAW (Read-After-Write) hazards
 * in a pipelined CPU.
 * 
 * Forwarding priorities:
 *   1. MEM -> EX: Forward from EX/MEM register (newest data)
 *   2. WB -> EX:  Forward from MEM/WB register (older data)
 *   3. None:      Use original operand from ID/EX register
 */

module FU_tb;

    // DUT Signals
    reg         RegWrite_Ex_MEM;
    reg  [1:0]  Rs_EX;
    reg  [1:0]  Rt_EX;
    reg  [1:0]  Rd_MEM;
    reg  [1:0]  Rd_WB;
    
    wire [1:0]  ForwardA;
    wire [1:0]  ForwardB;
    
    integer tests = 0;
    integer errors = 0;
    
    // Instantiate DUT
    FU dut (
        .RegWrite_Ex_MEM (RegWrite_Ex_MEM),
        .Rs_EX           (Rs_EX),
        .Rt_EX           (Rt_EX),
        .Rd_MEM          (Rd_MEM),
        .Rd_WB           (Rd_WB),
        .ForwardA        (ForwardA),
        .ForwardB        (ForwardB)
    );
    
    // Task to check forwarding outputs
    task check_forward(
        input [1:0]  exp_forwardA,
        input [1:0]  exp_forwardB,
        input [255*8:0] msg
    );
    begin
        tests = tests + 1;
        
        if (ForwardA !== exp_forwardA || ForwardB !== exp_forwardB) begin
            errors = errors + 1;
            $display("TEST %0d FAILED: %s", tests, msg);
            $display("  Expected: ForwardA=%b, ForwardB=%b", 
                     exp_forwardA, exp_forwardB);
            $display("  Got:      ForwardA=%b, ForwardB=%b", 
                     ForwardA, ForwardB);
            $display("  Inputs: RegWrite=%b, Rs=%b, Rt=%b, Rd_MEM=%b, Rd_WB=%b",
                     RegWrite_Ex_MEM, Rs_EX, Rt_EX, Rd_MEM, Rd_WB);
        end else begin
            $display("TEST %0d PASSED: %s", tests, msg);
        end
    end
    endtask
    
    // Main stimulus
    initial begin
        $display("\n=== FORWARDING UNIT TESTBENCH ===\n");
        
        // ====================================================================
        // TEST GROUP 1: No Forwarding (RegWrite_Ex_MEM = 0)
        // ====================================================================
        $display("--- Test Group 1: No Forwarding ---");
        
        RegWrite_Ex_MEM = 1'b0;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b00;
        Rd_WB = 2'b01;
        #1;
        check_forward(2'b00, 2'b00, 
                      "No writes enabled: both forwards should be 00");
        
        // ====================================================================
        // TEST GROUP 2: MEM -> EX Forwarding (MEM stage has result)
        // ====================================================================
        $display("\n--- Test Group 2: MEM -> EX Forwarding ---");
        
        // Test 2.1: MEM result matches Rs_EX (ForwardA should be 10)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b00;  // MEM writes to R0
        Rd_WB = 2'b10;   // WB writes to R2
        #1;
        check_forward(2'b10, 2'b00,
                      "MEM->EX ForwardA: Rs_EX=00 matches Rd_MEM=00");
        
        // Test 2.2: MEM result matches Rt_EX (ForwardB should be 10)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b01;  // MEM writes to R1
        Rd_WB = 2'b10;
        #1;
        check_forward(2'b00, 2'b10,
                      "MEM->EX ForwardB: Rt_EX=01 matches Rd_MEM=01");
        
        // Test 2.3: MEM result matches both Rs_EX and Rt_EX
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b11;
        Rt_EX = 2'b11;
        Rd_MEM = 2'b11;  // MEM writes to R3
        Rd_WB = 2'b10;
        #1;
        check_forward(2'b10, 2'b10,
                      "MEM->EX Forward Both: Rs_EX=11, Rt_EX=11 match Rd_MEM=11");
        
        // ====================================================================
        // TEST GROUP 3: WB -> EX Forwarding (WB stage has result)
        // ====================================================================
        $display("\n--- Test Group 3: WB -> EX Forwarding ---");
        
        // Test 3.1: WB result matches Rs_EX (ForwardA should be 01)
        // MEM doesn't match, so check WB
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b10;  // MEM writes to R2 (no match)
        Rd_WB = 2'b00;   // WB writes to R0 (matches Rs_EX)
        #1;
        check_forward(2'b01, 2'b00,
                      "WB->EX ForwardA: Rs_EX=00 matches Rd_WB=00 (MEM no match)");
        
        // Test 3.2: WB result matches Rt_EX (ForwardB should be 01)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b10;  // MEM writes to R2 (no match)
        Rd_WB = 2'b01;   // WB writes to R1 (matches Rt_EX)
        #1;
        check_forward(2'b00, 2'b01,
                      "WB->EX ForwardB: Rt_EX=01 matches Rd_WB=01 (MEM no match)");
        
        // Test 3.3: WB result matches both Rs_EX and Rt_EX
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b11;
        Rt_EX = 2'b11;
        Rd_MEM = 2'b00;  // MEM writes to R0 (no match)
        Rd_WB = 2'b11;   // WB writes to R3 (matches both)
        #1;
        check_forward(2'b01, 2'b01,
                      "WB->EX Forward Both: Rs_EX=11, Rt_EX=11 match Rd_WB=11 (MEM no match)");
        
        // ====================================================================
        // TEST GROUP 4: Priority Test (MEM > WB)
        // ====================================================================
        $display("\n--- Test Group 4: Forwarding Priority (MEM > WB) ---");
        
        // Test 4.1: Both MEM and WB write to same register as Rs_EX
        // Should forward from MEM (higher priority, 2'b10)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b00;  // MEM writes to R0
        Rd_WB = 2'b00;   // WB also writes to R0
        #1;
        check_forward(2'b10, 2'b00,
                      "Priority: MEM Rs match > WB Rs match (ForwardA=10, not 01)");
        
        // Test 4.2: Both MEM and WB write to same register as Rt_EX
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b01;  // MEM writes to R1
        Rd_WB = 2'b01;   // WB also writes to R1
        #1;
        check_forward(2'b00, 2'b10,
                      "Priority: MEM Rt match > WB Rt match (ForwardB=10, not 01)");
        
        // ====================================================================
        // TEST GROUP 5: No Hazard (No Register Match)
        // ====================================================================
        $display("\n--- Test Group 5: No Hazard (No Matches) ---");
        
        // Test 5.1: MEM and WB write to different registers than EX reads
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b10;  // MEM writes to R2
        Rd_WB = 2'b11;   // WB writes to R3
        #1;
        check_forward(2'b00, 2'b00,
                      "No hazard: Rs_EX=00, Rt_EX=01, Rd_MEM=10, Rd_WB=11");
        
        // ====================================================================
        // TEST GROUP 6: Edge Cases
        // ====================================================================
        $display("\n--- Test Group 6: Edge Cases ---");
        
        // Test 6.1: Only Rs_EX in use (Rt_EX different)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b10;
        Rd_MEM = 2'b00;  // Matches Rs_EX only
        Rd_WB = 2'b11;
        #1;
        check_forward(2'b10, 2'b00,
                      "Only Rs_EX hazard: ForwardA=10, ForwardB=00");
        
        // Test 6.2: Only Rt_EX in use (Rs_EX different)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b10;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b11;
        Rd_WB = 2'b01;   // Matches Rt_EX only
        #1;
        check_forward(2'b00, 2'b01,
                      "Only Rt_EX hazard: ForwardA=00, ForwardB=01");
        
        // Test 6.3: Rs_EX = Rt_EX = same register
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b00;
        Rd_MEM = 2'b00;
        Rd_WB = 2'b10;
        #1;
        check_forward(2'b10, 2'b10,
                      "Same source register: both forward from MEM");
        
        // Test 6.4: All registers are R0 (boundary condition)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b00;
        Rt_EX = 2'b00;
        Rd_MEM = 2'b00;
        Rd_WB = 2'b00;
        #1;
        check_forward(2'b10, 2'b10,
                      "All R0: forward from MEM (higher priority)");
        
        // Test 6.5: All registers are R3/SP (boundary condition)
        RegWrite_Ex_MEM = 1'b1;
        Rs_EX = 2'b11;
        Rt_EX = 2'b11;
        Rd_MEM = 2'b11;
        Rd_WB = 2'b11;
        #1;
        check_forward(2'b10, 2'b10,
                      "All R3: forward from MEM (higher priority)");
        
        // ====================================================================
        // TEST GROUP 7: Write Enable Variations
        // ====================================================================
        $display("\n--- Test Group 7: Write Enable Variations ---");
        
        // Test 7.1: MEM matches but RegWrite_Ex_MEM disabled
        RegWrite_Ex_MEM = 1'b0;
        Rs_EX = 2'b00;
        Rt_EX = 2'b01;
        Rd_MEM = 2'b00;  // Would match but write disabled
        Rd_WB = 2'b01;   // Would match
        #1;
        check_forward(2'b00, 2'b00,
                      "Write disabled: no forwarding regardless of matches");
        
        // Print summary
        $display("\n");
        $display("======================================");
        if (errors == 0) begin
            $display("  ALL %0d FORWARDING UNIT TESTS PASSED", tests);
        end else begin
            $display("  FORWARDING UNIT TESTBENCH FAILED");
            $display("  %0d out of %0d TESTS FAILED", errors, tests);
        end
        $display("======================================\n");
        
        $stop;
    end

endmodule
