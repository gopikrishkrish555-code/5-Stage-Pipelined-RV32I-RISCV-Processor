`timescale 1ns / 1ps
`include "riscv_defs.vh"

module tb_control_unit;
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire       reg_write;
    wire       mem_to_reg;
    wire       mem_read;
    wire       mem_write;
    wire       alu_src;
    wire [3:0] alu_ctrl;
    wire       branch;
    wire       jump;

    control_unit uut (
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

    initial begin
        $dumpfile("sim/control_unit_wave.vcd");
        $dumpvars(0, tb_control_unit);

        // Test 1: R-Type ADD
        opcode = `OPCODE_R_TYPE; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        if (!reg_write || alu_src || alu_ctrl !== `ALU_ADD) begin
            $display("[FAIL] R-Type ADD control decoding failed!");
            $stop;
        end

        // Test 2: R-Type SUB
        opcode = `OPCODE_R_TYPE; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        if (!reg_write || alu_src || alu_ctrl !== `ALU_SUB) begin
            $display("[FAIL] R-Type SUB control decoding failed!");
            $stop;
        end

        // Test 3: I-Type ADDI
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        if (!reg_write || !alu_src || alu_ctrl !== `ALU_ADD) begin
            $display("[FAIL] I-Type ADDI control decoding failed!");
            $stop;
        end

        // Test 4: Load Word (LW)
        opcode = `OPCODE_LOAD; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        if (!reg_write || !mem_to_reg || !mem_read || !alu_src) begin
            $display("[FAIL] Load Word (LW) control decoding failed!");
            $stop;
        end

        // Test 5: Store Word (SW)
        opcode = `OPCODE_STORE; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        if (reg_write || !mem_write || !alu_src) begin
            $display("[FAIL] Store Word (SW) control decoding failed!");
            $stop;
        end

        // Test 6: Branch BEQ
        opcode = `OPCODE_BRANCH; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        if (reg_write || !branch || alu_src || alu_ctrl !== `ALU_SUB) begin
            $display("[FAIL] Branch BEQ control decoding failed!");
            $stop;
        end

        // Test 7: Jump JAL
        opcode = `OPCODE_JAL; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        if (!reg_write || !jump) begin
            $display("[FAIL] JAL control decoding failed!");
            $stop;
        end

        $display("\n==============================================");
        $display("    [PASS] ALL CONTROL UNIT TESTS PASSED!     ");
        $display("==============================================\n");

        #10;
        $finish;
    end
endmodule