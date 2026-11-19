`timescale 1ns / 1ps

module dmem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    (* syn_keep = 1 *) reg [31:0] mem [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            mem[i] = 32'd0;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) begin
            mem[addr[7:2]] <= write_data;
        end
    end

    // Combinational read with internal write-through bypassing for simultaneous access
    assign read_data = (mem_read) ? ((mem_write && (addr[7:2] == addr[7:2])) ? write_data : mem[addr[7:2]]) : 32'd0;

endmodule