`timescale 1ns / 1ps

module dmem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,        // Byte address from ALU result
    input  wire [31:0] write_data,  // Data from rs2
    output wire [31:0] read_data    // Data sent back to RegFile mux
);

    // 1024 words (4 KB) data memory
    reg [31:0] ram [0:1023];

    wire [9:0] word_addr = addr[11:2];

    // Synchronous write on positive clock edge
    always @(posedge clk) begin
        if (mem_write) begin
            ram[word_addr] <= write_data;
        end
    end

    // Asynchronous read
    assign read_data = (mem_read) ? ram[word_addr] : 32'h0000_0000;

endmodule