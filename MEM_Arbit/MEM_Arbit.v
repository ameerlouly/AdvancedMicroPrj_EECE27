module MEM_Arbit (
    input wire  clk,
    input wire  reset,

    // IF Side
    input wire  req_if,
                if_read_in,
    input wire [7 : 0]  if_addr_in,

    // MEM Side
    input wire  req_mem,
                mem_read_in,
                mem_write_in,
    input wire [7 : 0]  mem_wdata_in,
    input wire [7 : 0]  mem_addr_in,

    // Outputs to Memory
    output reg [7 : 0]    mem_addr,
    output reg [7 : 0]    mem_wdata,
    output reg  mem_read,
                mem_write,

    // Status
    output reg granted_to_if,
    output reg granted_to_mem,

    // Control
    output reg stall_if
);

    always @(posedge clk) begin
        if(req_mem) begin
            granted_to_mem <= 1;
            mem_addr <= mem_addr_in;
            mem_wdata <= mem_wdata_in;
            mem_read <= mem_read_in;
            mem_write <= mem_write_in;
            stall_if <= 1;
        end
        else if(req_if) begin
            granted_to_if <= 1;
            mem_addr <= if_addr_in;
            mem_read <= if_read_in;
            mem_write <= 0;
        end
    end

endmodule