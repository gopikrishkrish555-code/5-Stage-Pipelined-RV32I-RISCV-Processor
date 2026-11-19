`timescale 1ns / 1ps
`include "riscv_defs.vh"

module imm_gen (
    input  wire [31:0] inst,    // 32-bit instruction word
    output reg  [31:0] imm_out  // Sign-extended 32-bit immediate
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-Type: Arithmetic with immediate, Loads, JALR
            `OPCODE_I_TYPE,
            `OPCODE_LOAD,
            `OPCODE_JALR: begin
                imm_out = {{20{inst[31]}}, inst[31:20]};
            end

            // S-Type: Stores (SW, SH, SB)
            `OPCODE_STORE: begin
                imm_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            // B-Type: Conditional Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            `OPCODE_BRANCH: begin
                imm_out = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            // U-Type: LUI, AUIPC (Upper 20 bits, lower 12 bits zeroed)
            `OPCODE_LUI,
            `OPCODE_AUIPC: begin
                imm_out = {inst[31:12], 12'b0};
            end

            // J-Type: JAL (Jump and Link)
            `OPCODE_JAL: begin
                imm_out = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            default: begin
                imm_out = 32'b0;
            end
        endcase
    end

endmodule