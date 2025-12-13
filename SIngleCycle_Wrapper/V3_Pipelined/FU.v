module FU (
    // Inputs from Pipeline Registers (Control Signals)
    input wire RegWrite_Ex_MEM,    // Write Enable of instruction in MEM
    input wire RegWrite_Mem_WB,    // <--- ADDED THIS (Critical for WB checks)

    // Inputs from Pipeline Registers (Register Addresses)
    input wire [1:0] Rs_EX,          // Source Register 1 address from ID/EX
    input wire [1:0] Rt_EX,          // Source Register 2 address from ID/EX
    input wire [1:0] Rd_MEM,         // Destination Register address from EX/MEM
    input wire [1:0] Rd_WB,          // Destination Register address from MEM/WB
    
    // Outputs to EX Stage ALU MUXes (ForwardA/B are 2-bit select lines)
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    // Combinational Logic for Forwarding
    always @(*) begin
        
        // Default: No forwarding (use ReadData from ID/EX)
        ForwardA = 2'b00; 
        ForwardB = 2'b00;

        // ==========================================================
        // Forwarding Logic for ALU Input A (Rs_EX)
        // ==========================================================
        
        // 1. Check for MEM -> EX Forwarding (Highest Priority)
        // If the instruction in MEM is writing AND matches source A
        if (RegWrite_Ex_MEM && (Rd_MEM == Rs_EX)) begin
            ForwardA = 2'b10; // Forward from EX/MEM Register (ALU_Out)
        end
        
        // 2. Check for WB -> EX Forwarding (Lower Priority)
        // FIX: Changed check to 'RegWrite_Mem_WB' instead of 'RegWrite_Ex_MEM'
        else if (RegWrite_Mem_WB && (Rd_WB == Rs_EX)) begin
            ForwardA = 2'b01; // Forward from MEM/WB Register (Final Result)
        end


        // ==========================================================
        // Forwarding Logic for ALU Input B (Rt_EX)
        // ==========================================================
        
        // 1. Check for MEM -> EX Forwarding (Highest Priority)
        if (RegWrite_Ex_MEM && (Rd_MEM == Rt_EX)) begin
            ForwardB = 2'b10; // Forward from EX/MEM Register (ALU_Out)
        end
        
        // 2. Check for WB -> EX Forwarding (Lower Priority)
        // FIX: Changed check to 'RegWrite_Mem_WB' instead of 'RegWrite_Ex_MEM'
        else if (RegWrite_Mem_WB && (Rd_WB == Rt_EX)) begin
            ForwardB = 2'b01; // Forward from MEM/WB Register (Final Result)
        end

    end

endmodule
