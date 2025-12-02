module MEM_Arbit_tb ();

    reg  clk;
    reg  reset;

    // IF Side
    reg    req_if,
            if_read_in;
    reg [7 : 0]  if_addr_in;

    // MEM Side
    reg     req_mem,
            mem_read_in,
            mem_write_in;
    reg [7 : 0]  mem_wdata_in;
    reg [7 : 0]  mem_addr_in;

    // Outputs to Memory
    wire [7 : 0]    mem_addr;
    wire [7 : 0]    mem_wdata;
    wire    mem_read,
            mem_write;

    // Status
    wire granted_to_if;
    wire granted_to_mem;

    // Control
    wire stall_if;

    MEM_arbit dut(
        .clk(clk),
        .reset(reset),
        .req_if(req_if),
        .if_read_in(if_read_in),
        .if_addr_in(if_addr_in),
        .req_mem(req_mem),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .mem_wdata_in(mem_wdata_in),
        .mem_addr_in(mem_addr_in),
        .mem_addr(mem_addr),
        .mem_write(mem_write),
        .granted_to_if(granted_to_if),
        .granted_to_mem(granted_to_mem),
        .stall_if(stall_if)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        
    end

endmodule;
