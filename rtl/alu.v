`timescale 1ns / 1ps
`include "riscv_defs.vh"

module alu (
    input  wire [31:0] a,          // Operand A (from rs1)
    input  wire [31:0] b,          // Operand B (from rs2 or immediate generator)
    input  wire [3:0]  alu_ctrl,   // 4-bit operation select from Control Unit
    output reg  [31:0] result,     // 32-bit computation output
    output wire        zero        // Active-high zero flag (used for branch decisions)
);

    // Assert zero flag if the calculation result is exactly zero
    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            `ALU_ADD:  result = a + b;                                      // Addition
            `ALU_SUB:  result = a - b;                                      // Subtraction
            `ALU_SLL:  result = a << b[4:0];                                // Shift Left Logical
            `ALU_SLT:  result = ($signed(a) <$signed(b)) ? 32'd1 : 32'd0;  // Signed Less Than
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;                    // Unsigned Less Than
            `ALU_XOR:  result = a ^ b;                                      // Bitwise XOR
            `ALU_SRL:  result = a >> b[4:0];                                // Shift Right Logical
            `ALU_SRA:  result = $signed(a) >>> b[4:0];                      // Shift Right Arithmetic
            `ALU_OR:   result = a | b;                                      // Bitwise OR
            `ALU_AND:  result = a & b;                                      // Bitwise AND
            default:   result = 32'b0;
        endcase
    end

endmodule