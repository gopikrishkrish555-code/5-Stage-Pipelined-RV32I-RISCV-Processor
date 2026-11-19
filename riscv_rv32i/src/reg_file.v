`timescale 1ns / 1ps

module reg_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire        reg_write,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [31:0] debug_x3
);

    reg [31:0] registers [0:31];
    integer i;

    // Asynchronous read with internal bypassing (WB -> ID forward):
    // 1. x0 is always hardwired to 0.
    // 2. If reading the exact register being written in WB this cycle, forward rd_data immediately.
    // 3. Otherwise read from the register array.
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 :
                      (reg_write && (rs1_addr == rd_addr)) ? rd_data :
                      registers[rs1_addr];

    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 :
                      (reg_write && (rs2_addr == rd_addr)) ? rd_data :
                      registers[rs2_addr];

    // Hardware debug probe for register x3
    assign debug_x3 = registers[3];

    // Synchronous write on rising clock edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule