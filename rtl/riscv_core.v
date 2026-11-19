`timescale 1ns / 1ps
`include "riscv_defs.vh"

module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] debug_reg3
);

    // -------------------------------------------------------------
    // Fetch Stage & Program Counter Logic
    // -------------------------------------------------------------
    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_target;
    wire [31:0] inst;

    assign pc_plus_4 = pc + 32'd4;

    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );

    imem u_imem (
        .addr(pc),
        .inst(inst)
    );

    // -------------------------------------------------------------
    // Decode Stage & Control Lines
    // -------------------------------------------------------------
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    wire [4:0] rs1    = inst[19:15];
    wire [4:0] rs2    = inst[24:20];
    wire [4:0] rd     = inst[11:7];

    wire       reg_write;
    wire       mem_to_reg;
    wire       mem_read;
    wire       mem_write;
    wire       alu_src;
    wire [3:0] alu_ctrl;
    wire       branch;
    wire       jump;

    control_unit u_control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .branch(branch),
        .jump(jump)
    );

    wire [31:0] imm_out;

    imm_gen u_imm_gen (
        .inst(inst),
        .imm_out(imm_out)
    );

    // -------------------------------------------------------------
    // Register File & Operand Selection
    // -------------------------------------------------------------
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] reg_write_data;

    reg_file u_reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(rd),
        .reg_write(reg_write),
        .rd_data(reg_write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Expose register x3 directly to hardware top level
    assign debug_reg3 = u_reg_file.registers[3];

    // ALU Source 2 MUX
    wire [31:0] alu_in2 = (alu_src) ? imm_out : rs2_data;

    // -------------------------------------------------------------
    // Execute Stage (ALU) & Branch Calculation
    // -------------------------------------------------------------
    wire [31:0] alu_result;
    wire        zero;

    alu u_alu (
        .a(rs1_data),
        .b(alu_in2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    // Branch condition resolution
    reg branch_taken;
    always @(*) begin
        case (funct3)
            3'b000: branch_taken = zero;            // BEQ
            3'b001: branch_taken = ~zero;           // BNE
            3'b100: branch_taken = alu_result[0];   // BLT
            3'b101: branch_taken = ~alu_result[0];  // BGE
            default: branch_taken = 1'b0;
        endcase
    end

    // Branch & Jump Target calculation
    assign pc_target = (opcode == 7'b1100111) ? (rs1_data + imm_out) : ($signed(pc) +$signed(imm_out));

    // Next PC selection logic
    wire pc_sel = jump | (branch & branch_taken);
    assign pc_next = (pc_sel) ? pc_target : pc_plus_4;

    // -------------------------------------------------------------
    // Memory Stage
    // -------------------------------------------------------------
    wire [31:0] mem_read_data;

    dmem u_dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );

    // -------------------------------------------------------------
    // Writeback Stage
    // -------------------------------------------------------------
    assign reg_write_data = (jump)       ? pc_plus_4 :
                            (mem_to_reg) ? mem_read_data :
                                           alu_result;

endmodule