module memory (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  address,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [7:0]  write_data,
    output wire [7:0]  out_data
);

reg [7:0] mem [0:255];
integer i;

// WRITE: synchronous
always @(posedge clk or negedge rst) begin
    if(!rst) 
    begin
        for (i = 0; i < 256; i = i + 1) 
        begin
            mem[i] <= 8'd0;
        end    
    end
    else if(mem_write) begin
        mem[address] <= write_data;
    end
end

// READ: asynchronous (best for Von Neumann)
assign out_data = (mem_read) ? mem[address] : 8'd0;

endmodule
