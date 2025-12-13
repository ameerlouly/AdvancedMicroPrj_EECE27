module memory (
    input  wire        clk,
    input  wire        rst,            

    /**** Port A Instruction Fetch *****/
    input  wire [7:0]  addr_a,
    output reg  [7:0]  data_out_a,

    ///// Port B Data Memory /////
    input  wire [7:0]  addr_b,
    output reg  [7:0]  data_out_b,
    input  wire        we_b,             // write enable for port B
    input  wire [7:0]  write_data_b
);

    // memory 
    reg [7:0] mem [0:255];

   
    // initial begin
    //     $readmemh("program.hex", mem); // create program.hex for sim
    // end

    // Synchronous behavior: read/write on posedge clk
    always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
        begin
            
            data_out_a  <= 8'd0;
            data_out_b <= 8'd0;
            
        end
        else 
        begin
            // If a write to addr_b happens this cycle, we want deterministic behavior:
            // - data_out_b should return the newly written value (read-after-write).
            // - data_out_a should reflect the new value if fetch address equals addr_b (addr_a == addr_b).
            if (we_b) 
            begin
                mem[addr_b] <= write_data_b;   // perform write
                data_out_b  <= write_data_b;   // read-after-write deterministic
                // instruction fetch sees the new data if it's the same address
                if (addr_a == addr_b)
                    data_out_a <= write_data_b;
                else
                    data_out_a <= mem[addr_a];
            end

            data_out_b <= mem[addr_b];
            data_out_a  <= mem[addr_a];
        end
    end

endmodule
