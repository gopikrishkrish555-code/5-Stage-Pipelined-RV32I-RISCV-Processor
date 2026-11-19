`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,       // When 1, PC freezes its current value
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'd0;
        end else if (!stall) begin
            pc <= pc_next;
        end
    end

endmodule