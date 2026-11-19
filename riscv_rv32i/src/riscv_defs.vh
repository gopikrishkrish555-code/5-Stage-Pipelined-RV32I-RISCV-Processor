// ============================================================================
// RISC-V RV32I Processor Constants and Opcodes
// ============================================================================

`ifndef RISCV_DEFS_VH
`define RISCV_DEFS_VH

// Standard RV32I Base Opcodes (inst[6:0])
`define OPCODE_R_TYPE       7'b0110011 // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
`define OPCODE_I_TYPE       7'b0010011 // ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI
`define OPCODE_LOAD         7'b0000011 // LB, LH, LW, LBU, LHU
`define OPCODE_STORE        7'b0100011 // SB, SH, SW
`define OPCODE_BRANCH       7'b1100011 // BEQ, BNE, BLT, BGE, BLTU, BGEU
`define OPCODE_JAL          7'b1101111 // Jump and Link
`define OPCODE_JALR         7'b1100111 // Jump and Link Register
`define OPCODE_LUI          7'b0110111 // Load Upper Immediate
`define OPCODE_AUIPC        7'b0010111 // Add Upper Immediate to PC
`define OPCODE_SYSTEM       7'b1110011 // ECALL, EBREAK, CSR

// ALU Control Operations (4-bit encoding)
`define ALU_ADD             4'b0000
`define ALU_SUB             4'b0001
`define ALU_SLL             4'b0010
`define ALU_SLT             4'b0011
`define ALU_SLTU            4'b0100
`define ALU_XOR             4'b0101
`define ALU_SRL             4'b0110
`define ALU_SRA             4'b0111
`define ALU_OR              4'b1000
`define ALU_AND             4'b1001

`endif // RISCV_DEFS_VH