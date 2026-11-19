`timescale 1ns / 1ps
`include "riscv_defs.vh"

module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] debug_reg3,
    output wire [31:0] out_mem_addr,
    output wire [31:0] out_mem_wdata,
    output wire        out_mem_wen,
    input  wire [31:0] in_mmio_rdata
);

    // =============================================================
    // Hazard & Forwarding Control Wires
    // =============================================================
    wire        pc_stall;
    wire        if_id_stall;
    wire        if_id_flush;
    wire        id_ex_flush;
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;

    // =============================================================
    // Stage 1: Instruction Fetch (IF)
    // =============================================================
    wire [31:0] if_pc;
    wire [31:0] if_pc_next;
    wire [31:0] if_pc_plus_4 = if_pc + 32'd4;
    (* syn_keep = 1 *) wire [31:0] if_inst;
    wire [31:0] ex_pc_target;
    wire        ex_pc_sel;

    assign if_pc_next = (ex_pc_sel) ? ex_pc_target : if_pc_plus_4;

    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .stall(pc_stall),
        .pc_next(if_pc_next),
        .pc(if_pc)
    );

    imem u_imem (
        .addr(if_pc),
        .inst(if_inst)
    );

    // --- IF/ID Register ---
    wire [31:0] id_pc;
    wire [31:0] id_inst;

    if_id_reg u_if_id_reg (
        .clk(clk),
        .rst_n(rst_n),
        .stall(if_id_stall),
        .flush(if_id_flush),
        .if_pc(if_pc),
        .if_inst(if_inst),
        .id_pc(id_pc),
        .id_inst(id_inst)
    );

    // =============================================================
    // Stage 2: Instruction Decode (ID)
    // =============================================================
    wire [6:0] id_opcode = id_inst[6:0];
    wire [2:0] id_funct3 = id_inst[14:12];
    wire [6:0] id_funct7 = id_inst[31:25];
    wire [4:0] id_rs1    = id_inst[19:15];
    wire [4:0] id_rs2    = id_inst[24:20];
    wire [4:0] id_rd     = id_inst[11:7];

    wire       id_reg_write;
    wire       id_mem_to_reg;
    wire       id_mem_read;
    wire       id_mem_write;
    wire       id_alu_src;
    wire [3:0] id_alu_ctrl;
    wire       id_branch;
    wire       id_jump;

    control_unit u_control (
        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7),
        .reg_write(id_reg_write),
        .mem_to_reg(id_mem_to_reg),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .alu_src(id_alu_src),
        .alu_ctrl(id_alu_ctrl),
        .branch(id_branch),
        .jump(id_jump)
    );

    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;
    (* syn_keep = 1 *) wire        wb_reg_write;
    (* syn_keep = 1 *) wire [4:0]  wb_rd;
    (* syn_keep = 1 *) wire [31:0] wb_final_data;

    reg_file u_reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(id_rs1),
        .rs2_addr(id_rs2),
        .rd_addr(wb_rd),
        .reg_write(wb_reg_write),
        .rd_data(wb_final_data),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .debug_x3(debug_reg3)
    );

    wire [31:0] id_imm;
    imm_gen u_imm_gen (
        .inst(id_inst),
        .imm_out(id_imm)
    );

    // --- ID/EX Register ---
    wire        ex_reg_write;
    wire        ex_mem_to_reg;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_alu_src;
    wire [3:0]  ex_alu_ctrl;
    wire        ex_branch;
    wire        ex_jump;
    wire [31:0] ex_pc;
    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [31:0] ex_imm;
    wire [2:0]  ex_funct3;
    wire [6:0]  ex_opcode;
    wire [4:0]  ex_rs1;
    wire [4:0]  ex_rs2;
    wire [4:0]  ex_rd;

    id_ex_reg u_id_ex_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(id_ex_flush),
        .id_reg_write(id_reg_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_alu_src(id_alu_src),
        .id_alu_ctrl(id_alu_ctrl),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_pc(id_pc),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_imm(id_imm),
        .id_funct3(id_funct3),
        .id_opcode(id_opcode),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_alu_src(ex_alu_src),
        .ex_alu_ctrl(ex_alu_ctrl),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_pc(ex_pc),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm(ex_imm),
        .ex_funct3(ex_funct3),
        .ex_opcode(ex_opcode),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd)
    );

    // =============================================================
    // Stage 3: Execute (EX)
    // =============================================================
    (* syn_keep = 1 *) wire [31:0] mem_alu_result;

    wire [31:0] ex_alu_in1 = (forward_a == 2'b10) ? mem_alu_result :
                             (forward_a == 2'b01) ? wb_final_data  :
                                                    ex_rs1_data;

    wire [31:0] ex_fwd_rs2 = (forward_b == 2'b10) ? mem_alu_result :
                             (forward_b == 2'b01) ? wb_final_data  :
                                                    ex_rs2_data;

    wire [31:0] ex_alu_in2 = (ex_alu_src) ? ex_imm : ex_fwd_rs2;

    (* syn_keep = 1 *) wire [31:0] ex_alu_result;
    wire        ex_zero;

    alu u_alu (
        .a(ex_alu_in1),
        .b(ex_alu_in2),
        .alu_ctrl(ex_alu_ctrl),
        .result(ex_alu_result),
        .zero(ex_zero)
    );

    reg ex_branch_taken;
    always @(*) begin
        case (ex_funct3)
            3'b000: ex_branch_taken = ex_zero;
            3'b001: ex_branch_taken = ~ex_zero;
            3'b100: ex_branch_taken = ex_alu_result[0];
            3'b101: ex_branch_taken = ~ex_alu_result[0];
            default: ex_branch_taken = 1'b0;
        endcase
    end

    assign ex_pc_target = (ex_opcode == 7'b1100111) ? (ex_alu_in1 + ex_imm) : ($signed(ex_pc) +$signed(ex_imm));
    assign ex_pc_sel    = ex_jump | (ex_branch & ex_branch_taken);

    // --- EX/MEM Register ---
    wire        mem_reg_write;
    wire        mem_mem_to_reg;
    wire        mem_mem_read;
    wire        mem_mem_write;
    wire [31:0] mem_rs2_data;
    wire [4:0]  mem_rd;

    ex_mem_reg u_ex_mem_reg (
        .clk(clk),
        .rst_n(rst_n),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_alu_result(ex_alu_result),
        .ex_rs2_data(ex_fwd_rs2),
        .ex_rd(ex_rd),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_alu_result(mem_alu_result),
        .mem_rs2_data(mem_rs2_data),
        .mem_rd(mem_rd)
    );

    // =============================================================
    // Stage 4: Memory Access (MEM)
    // =============================================================
    wire [31:0] dmem_out;
    wire [31:0] mem_read_data = (mem_alu_result == 32'h0000_0104) ? in_mmio_rdata : dmem_out;

    dmem u_dmem (
        .clk(clk),
        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),
        .addr(mem_alu_result),
        .write_data(mem_rs2_data),
        .read_data(dmem_out)
    );

    // --- MEM/WB Register ---
    wire        wb_mem_to_reg;
    wire [31:0] wb_read_data;
    wire [31:0] wb_alu_result;

    mem_wb_reg u_mem_wb_reg (
        .clk(clk),
        .rst_n(rst_n),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_read_data(mem_read_data),
        .mem_alu_result(mem_alu_result),
        .mem_rd(mem_rd),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_read_data(wb_read_data),
        .wb_alu_result(wb_alu_result),
        .wb_rd(wb_rd)
    );

    // =============================================================
    // Stage 5: Writeback (WB)
    // =============================================================
    assign wb_final_data = (wb_mem_to_reg) ? wb_read_data : wb_alu_result;

    // =============================================================
    // Hazard & Forwarding Units Instantiation
    // =============================================================
    forwarding_unit u_forwarding_unit (
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd),
        .ex_mem_reg_write(mem_reg_write),
        .mem_wb_rd(wb_rd),
        .mem_wb_reg_write(wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    hazard_detection_unit u_hazard_unit (
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .id_ex_rd(ex_rd),
        .id_ex_mem_read(ex_mem_read),
        .branch_taken(ex_pc_sel),
        .pc_stall(pc_stall),
        .if_id_stall(if_id_stall),
        .if_id_flush(if_id_flush),
        .id_ex_flush(id_ex_flush)
    );

    // =============================================================
    // Memory-Mapped Peripheral Bus Outputs
    // =============================================================
    assign out_mem_addr  = mem_alu_result;
    assign out_mem_wdata = mem_rs2_data;
    assign out_mem_wen   = mem_mem_write;

endmodule