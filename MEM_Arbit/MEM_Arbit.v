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
    output wire [7 : 0]    mem_addr,
    output wire [7 : 0]    mem_wdata,
    output wire mem_read,
                mem_write

    // Status
    output wire granted_to_if,
    output wire granted_to_mem,

    // Control
    output wire stall_if
);







endmodule