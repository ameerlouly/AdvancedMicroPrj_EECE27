`timescale 1ns / 1ps

module tb_Control_unit;

    // ============================================================
    // 1. INPUTS & OUTPUTS
    // ============================================================
    reg clk;
    reg rst;
    reg INTR;
    reg [3:0] opcode;
    reg [1:0] ra;

    // Outputs
    wire PC_Write_En;
    wire IF_ID_Write_En;
    wire Inject_Bubble;
    wire Inject_Int;
    wire RegWrite;
    wire RegDist;
    wire SP_SEL;
    wire SP_EN;
    wire SP_OP;
    wire [3:0] Alu_Op;
    wire [2:0] BTYPE;
    wire Alu_src;
    wire IS_CALL;
    wire UpdateFlags;
    wire [1:0] MemToReg;
    wire MemWrite;
    wire MemRead;
    wire IO_Write;

    // Verification Variables
    integer error_count = 0;

    // ============================================================
    // 2. INSTANTIATE THE UNIT UNDER TEST (UUT)
    // ============================================================
    Control_unit uut (
        .clk(clk), 
        .rst(rst), 
        .INTR(INTR), 
        .opcode(opcode), 
        .ra(ra), 
        .PC_Write_En(PC_Write_En), 
        .IF_ID_Write_En(IF_ID_Write_En), 
        .Inject_Bubble(Inject_Bubble), 
        .Inject_Int(Inject_Int), 
        .RegWrite(RegWrite), 
        .RegDist(RegDist), 
        .SP_SEL(SP_SEL), 
        .SP_EN(SP_EN), 
        .SP_OP(SP_OP), 
        .Alu_Op(Alu_Op), 
        .BTYPE(BTYPE), 
        .Alu_src(Alu_src), 
        .IS_CALL(IS_CALL), 
        .UpdateFlags(UpdateFlags), 
        .MemToReg(MemToReg), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .IO_Write(IO_Write)
    );

    // ============================================================
    // 3. CLOCK GENERATION
    // ============================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns Clock Period
    end

    // ============================================================
    // 4. TEST SCENARIOS
    // ============================================================
    initial begin
        // Initialize Inputs
        rst = 1; // Active High Reset
        INTR = 0;
        opcode = 0;
        ra = 0;

        // Wait 100 ns for global reset to finish
        #20;
        rst = 0; // Release Reset
        #10;

        $display("---------------------------------------------------");
        $display("STARTING CONTROL UNIT VERIFICATION");
        $display("---------------------------------------------------");

        // --------------------------------------------------------
        // TEST CASE 1: Standard ALU Instruction (ADD)
        // --------------------------------------------------------
        opcode = 4'b0010; // ADD
        ra = 2'b00;       // Don't care for decoder logic
        #10; // Wait for combinational logic
        
        if (RegWrite !== 1 || Alu_Op !== 4'b0010 || UpdateFlags !== 1) begin
            $display("ERROR: ADD Instruction failed.");
            error_count = error_count + 1;
        end else begin
            $display("PASS: ADD Instruction correct.");
        end

        // --------------------------------------------------------
        // TEST CASE 2: Stack PUSH (Opcode 7, ra=0)
        // --------------------------------------------------------
        opcode = 4'b0111;
        ra = 2'b00; // PUSH
        #10;
        
        // Checks: MemWrite=1, SP_EN=1, SP_OP=0 (Dec), SP_SEL=1 (Force R3)
        if (MemWrite !== 1 || SP_EN !== 1 || SP_OP !== 0 || SP_SEL !== 1) begin
            $display("ERROR: PUSH Instruction failed.");
            error_count = error_count + 1;
        end else begin
            $display("PASS: PUSH Instruction correct.");
        end

        // --------------------------------------------------------
        // TEST CASE 3: RET Instruction (Opcode 11, ra=2)
        // --------------------------------------------------------
        opcode = 4'b1011;
        ra = 2'b10; // RET
        #10;
        
        // Checks: BTYPE=BR_RET(7), MemRead=1, SP_EN=1, SP_OP=1 (Inc)
        if (BTYPE !== 3'b111 || MemRead !== 1 || SP_EN !== 1 || SP_OP !== 1) begin
            $display("ERROR: RET Instruction failed. BTYPE=%b", BTYPE);
            error_count = error_count + 1;
        end else begin
            $display("PASS: RET Instruction correct.");
        end

        // --------------------------------------------------------
        // TEST CASE 4: 2-Byte Instruction Stall (LDD - Opcode 12)
        // --------------------------------------------------------
        // Cycle 1: Fetch Opcode
        opcode = 4'b1100; // LDD/LDM family
        ra = 2'b01;       // LDD
        
        // Allow FSM to see input on clock edge
        @(posedge clk); 
        #1; // Wait a tiny bit after edge for outputs to settle
        
        // Checks during Cycle 1 (Detection):
        // FSM should output: IF_ID_Write_En=0 (Freeze), Inject_Bubble=1
        if (IF_ID_Write_En !== 0 || Inject_Bubble !== 1) begin
            $display("ERROR: 2-Byte Stall Start failed. IF_ID_En=%b, Bubble=%b", IF_ID_Write_En, Inject_Bubble);
            error_count = error_count + 1;
        end else begin
            $display("PASS: 2-Byte Stall Initiated correctly.");
        end

        // Cycle 2: The Stall Cycle (Fetching Immediate)
        @(posedge clk);
        #1; 
        
        // Now in FETCH_IMM state. FSM should auto-transition back to FETCH next.
        // We verify the outputs returned to normal (or specific state behavior).
        // Technically in your code, FETCH_IMM just sets next_state = FETCH.
        // Outputs depend on current_state. 
        // Let's check that we are Back to Normal in the NEXT cycle.
        
        @(posedge clk); // Cycle 3 (Back to Fetch)
        #1;
        if (IF_ID_Write_En !== 1 && Inject_Bubble !== 0) begin
             $display("ERROR: 2-Byte Stall did not finish correctly.");
             error_count = error_count + 1;
        end else begin
             $display("PASS: 2-Byte Stall Finished correctly.");
        end

        // --------------------------------------------------------
        // TEST CASE 5: Interrupt Sequence
        // --------------------------------------------------------
        opcode = 4'b0000; // NOP
        INTR = 1;         // Assert Interrupt
        #5;               // Wait before clock edge
        
        @(posedge clk);   // Clock edge hits, FSM sees INTR
        #1;
        
        // FSM is now in S_INTR state (combinational output check)
        // Your code sets next_state = S_INTR inside FETCH.
        // So at this exact moment (after 1 posedge), state is S_INTR?
        // Wait... in your code: if (INTR) next_state = S_INTR.
        // So we need ONE MORE clock for `current_state` to become `S_INTR`.
        
        @(posedge clk); // Now current_state is S_INTR
        #1;

        // Checks: Inject_Int=1 (implied by logic, but actually in your code 
        // 'Inject_Int' is set in combinational logic of FETCH state, 
        // OR phantom override in Decoder logic).
        // In your decoder: if (state == S_INTR) -> MemWrite=1, SP_Enable=1, IS_CALL=1
        
        if (MemWrite !== 1 || SP_EN !== 1 || IS_CALL !== 1) begin
            $display("ERROR: Interrupt Phantom Instruction failed.");
            error_count = error_count + 1;
        end else begin
            $display("PASS: Interrupt Phantom Instruction Injection correct.");
        end

        INTR = 0; // Release Interrupt

        // --------------------------------------------------------
        // FINAL REPORT
        // --------------------------------------------------------
        #20;
        $display("---------------------------------------------------");
        if (error_count == 0) begin
            $display("SUCCESS: ALL TESTS PASSED");
        end else begin
            $display("FAILURE: %d TESTS FAILED", error_count);
        end
        $display("---------------------------------------------------");
        $finish;
    end

endmodule