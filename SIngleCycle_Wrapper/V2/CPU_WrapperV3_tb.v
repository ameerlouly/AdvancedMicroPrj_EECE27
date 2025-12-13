module CPU_WrapperV3_tb ();

    reg             clk,
                    rstn,
                    int_sig;

    reg [7 : 0]     I_Port;
    wire [7 : 0]    O_Port;

    CPU_WrapperV3 DUT (
        .clk     (clk), // 1 bit, input
        .rstn    (rstn), // 1 bit, input
        .I_Port  (I_Port), // 8 bits, input
        .int_sig (int_sig), // 1 bit, input
        .O_Port  (O_Port)  // 8 bits, output
    );

    initial begin
        clk = 0;
        forever begin
        #1 clk = ~clk;
        end
    end

    initial begin
        // Reset sequence
        rstn = 0;
        int_sig = 0;
        I_Port = 8'h00;
        #10;  // Hold reset for 10 time units
        rstn = 1;

        // Preload instructions into memory (hierarchical access to DUT.mem_inst.mem)
        // Example A-format program: ADD R0, R1 (opcode 0x0, ra=00, rb=01) -> 8'b00000100
        // Followed by NOP (opcode 0xF) -> 8'b11110000
        // Adjust based on your ISA (see Control Unit/control_unit.v for opcode mappings)
        DUT.mem_inst.mem[0] = 8'b00000100;  // ADD R0, R1
        DUT.mem_inst.mem[1] = 8'b11110000;  // NOP
        DUT.mem_inst.mem[2] = 8'b00000100;  // Another ADD (loop or extend as needed)
        // Add more instructions here... e.g., DUT.mem_inst.mem[3] = 8'b...;

        // Run simulation for a fixed time or until a condition
        #100;  // Simulate for 100 time units (adjust based on program length)
        $finish;  // End simulation
    end

endmodule