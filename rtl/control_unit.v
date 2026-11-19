`timescale 1ns / 1ps
`include "riscv_defs.vh"

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    
    // Datapath control signals
    output reg        reg_write,      // Write to register file
    output reg        mem_to_reg,     // 0 = ALU result, 1 = Mem data
    output reg        mem_read,       // Read from data memory
    output reg        mem_write,      // Write to data memory
    output reg        alu_src,        // 0 = rs2, 1 = immediate
    output reg  [3:0] alu_ctrl,       // ALU operation code
    output reg        branch,         // 1 for branch instructions
    output reg        jump            // 1 for JAL/JALR
);

    always @(*) begin
        // Safe default assignments
        reg_write  = 1'b0;
        mem_to_reg = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        alu_ctrl   = `ALU_ADD;
        branch     = 1'b0;
        jump       = 1'b0;

        case (opcode)
            // R-Type: register-register arithmetic/logic
            `OPCODE_R_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
                    3'b001: alu_ctrl = `ALU_SLL;
                    3'b010: alu_ctrl = `ALU_SLT;
                    3'b011: alu_ctrl = `ALU_SLTU;
                    3'b100: alu_ctrl = `ALU_XOR;
                    3'b101: alu_ctrl = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_ctrl = `ALU_OR;
                    3'b111: alu_ctrl = `ALU_AND;
                    default: alu_ctrl = `ALU_ADD;
                endcase
            end

            // I-Type ALU: ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = `ALU_ADD;
                    3'b001: alu_ctrl = `ALU_SLL;
                    3'b010: alu_ctrl = `ALU_SLT;
                    3'b011: alu_ctrl = `ALU_SLTU;
                    3'b100: alu_ctrl = `ALU_XOR;
                    3'b101: alu_ctrl = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_ctrl = `ALU_OR;
                    3'b111: alu_ctrl = `ALU_AND;
                    default: alu_ctrl = `ALU_ADD;
                endcase
            end

            // Load: LW
            `OPCODE_LOAD: begin
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                alu_ctrl   = `ALU_ADD;
            end

            // Store: SW
            `OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = `ALU_ADD;
            end

            // Branches: BEQ, BNE, BLT, BGE
            `OPCODE_BRANCH: begin
                branch   = 1'b1;
                alu_src  = 1'b0;
                alu_ctrl = `ALU_SUB;
            end

            // JAL: Jump and Link
            `OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
            end

            // LUI: Load Upper Immediate
            `OPCODE_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = `ALU_ADD;
            end

            default: begin
            end
        endcase
    end

endmodule