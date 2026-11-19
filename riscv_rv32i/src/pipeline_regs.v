`timescale 1ns / 1ps

// -------------------------------------------------------------
// 1. IF / ID Pipeline Register
// -------------------------------------------------------------
module if_id_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] if_pc,
    input  wire [31:0] if_inst,
    output reg  [31:0] id_pc,
    output reg  [31:0] id_inst
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc   <= 32'd0;
            id_inst <= 32'h00000013; // NOP (addi x0, x0, 0)
        end else if (flush) begin
            id_pc   <= 32'd0;
            id_inst <= 32'h00000013; // Flush with NOP
        end else if (!stall) begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule

// -------------------------------------------------------------
// 2. ID / EX Pipeline Register
// -------------------------------------------------------------
module id_ex_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    
    // Control signals from ID
    input  wire        id_reg_write,
    input  wire        id_mem_to_reg,
    input  wire        id_mem_read,
    input  wire        id_mem_write,
    input  wire        id_alu_src,
    input  wire [3:0]  id_alu_ctrl,
    input  wire        id_branch,
    input  wire        id_jump,

    // Datapath signals from ID
    input  wire [31:0] id_pc,
    input  wire [31:0] id_rs1_data,
    input  wire [31:0] id_rs2_data,
    input  wire [31:0] id_imm,
    input  wire [2:0]  id_funct3,
    input  wire [6:0]  id_opcode,
    input  wire [4:0]  id_rs1,
    input  wire [4:0]  id_rs2,
    input  wire [4:0]  id_rd,

    // Registered outputs to EX
    output reg         ex_reg_write,
    output reg         ex_mem_to_reg,
    output reg         ex_mem_read,
    output reg         ex_mem_write,
    output reg         ex_alu_src,
    output reg  [3:0]  ex_alu_ctrl,
    output reg         ex_branch,
    output reg         ex_jump,
    output reg  [31:0] ex_pc,
    output reg  [31:0] ex_rs1_data,
    output reg  [31:0] ex_rs2_data,
    output reg  [31:0] ex_imm,
    output reg  [2:0]  ex_funct3,
    output reg  [6:0]  ex_opcode,
    output reg  [4:0]  ex_rs1,
    output reg  [4:0]  ex_rs2,
    output reg  [4:0]  ex_rd
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            ex_reg_write  <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_mem_read   <= 1'b0;
            ex_mem_write  <= 1'b0;
            ex_alu_src    <= 1'b0;
            ex_alu_ctrl   <= 4'd0;
            ex_branch     <= 1'b0;
            ex_jump       <= 1'b0;
            ex_pc         <= 32'd0;
            ex_rs1_data   <= 32'd0;
            ex_rs2_data   <= 32'd0;
            ex_imm        <= 32'd0;
            ex_funct3     <= 3'd0;
            ex_opcode     <= 7'd0;
            ex_rs1        <= 5'd0;
            ex_rs2        <= 5'd0;
            ex_rd         <= 5'd0;
        end else begin
            ex_reg_write  <= id_reg_write;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_mem_read   <= id_mem_read;
            ex_mem_write  <= id_mem_write;
            ex_alu_src    <= id_alu_src;
            ex_alu_ctrl   <= id_alu_ctrl;
            ex_branch     <= id_branch;
            ex_jump       <= id_jump;
            ex_pc         <= id_pc;
            ex_rs1_data   <= id_rs1_data;
            ex_rs2_data   <= id_rs2_data;
            ex_imm        <= id_imm;
            ex_funct3     <= id_funct3;
            ex_opcode     <= id_opcode;
            ex_rs1        <= id_rs1;
            ex_rs2        <= id_rs2;
            ex_rd         <= id_rd;
        end
    end

endmodule

// -------------------------------------------------------------
// 3. EX / MEM Pipeline Register
// -------------------------------------------------------------
module ex_mem_reg (
    input  wire        clk,
    input  wire        rst_n,

    // Control signals from EX
    input  wire        ex_reg_write,
    input  wire        ex_mem_to_reg,
    input  wire        ex_mem_read,
    input  wire        ex_mem_write,
    
    // Datapath signals from EX
    input  wire [31:0] ex_alu_result,
    input  wire [31:0] ex_rs2_data,
    input  wire [4:0]  ex_rd,

    // Registered outputs to MEM
    output reg         mem_reg_write,
    output reg         mem_mem_to_reg,
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_rs2_data,
    output reg  [4:0]  mem_rd
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_reg_write  <= 1'b0;
            mem_mem_to_reg <= 1'b0;
            mem_mem_read   <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_alu_result <= 32'd0;
            mem_rs2_data   <= 32'd0;
            mem_rd         <= 5'd0;
        end else begin
            mem_reg_write  <= ex_reg_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_alu_result <= ex_alu_result;
            mem_rs2_data   <= ex_rs2_data;
            mem_rd         <= ex_rd;
        end
    end

endmodule

// -------------------------------------------------------------
// 4. MEM / WB Pipeline Register
// -------------------------------------------------------------
module mem_wb_reg (
    input  wire        clk,
    input  wire        rst_n,

    // Control signals from MEM
    input  wire        mem_reg_write,
    input  wire        mem_mem_to_reg,

    // Datapath signals from MEM
    input  wire [31:0] mem_read_data,
    input  wire [31:0] mem_alu_result,
    input  wire [4:0]  mem_rd,

    // Registered outputs to WB
    output reg         wb_reg_write,
    output reg         wb_mem_to_reg,
    output reg  [31:0] wb_read_data,
    output reg  [31:0] wb_alu_result,
    output reg  [4:0]  wb_rd
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_reg_write  <= 1'b0;
            wb_mem_to_reg <= 1'b0;
            wb_read_data  <= 32'd0;
            wb_alu_result <= 32'd0;
            wb_rd         <= 5'd0;
        end else begin
            wb_reg_write  <= mem_reg_write;
            wb_mem_to_reg <= mem_mem_to_reg;
            wb_read_data  <= mem_read_data;
            wb_alu_result <= mem_alu_result;
            wb_rd         <= mem_rd;
        end
    end

endmodule