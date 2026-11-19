`timescale 1ns / 1ps

module forwarding_unit (
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,
    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_reg_write,
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b
);

    // Forwarding codes:
    // 2'b00: No forward (use register value from ID/EX)
    // 2'b10: Forward from EX/MEM stage (ALU result)
    // 2'b01: Forward from MEM/WB stage (Writeback data / load result)

    // Operand A Forwarding
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01;
        end else begin
            forward_a = 2'b00;
        end
    end

    // Operand B Forwarding
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end

endmodule