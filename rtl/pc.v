`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        rst_n,      // Active-low asynchronous/synchronous reset
    input  wire [31:0] pc_next,    // Next program counter from datapath mux
    output reg  [31:0] pc          // Current program counter
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= pc_next;
        end
    end

endmodule