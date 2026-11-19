`timescale 1ns / 1ps
`include "riscv_defs.vh"

module tb_alu;
    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("sim/alu_wave.vcd");
        $dumpvars(0, tb_alu);

        // Test 1: Addition (15 + 27 = 42)
        a = 32'd15; b = 32'd27; alu_ctrl = `ALU_ADD; #10;
        if (result !== 32'd42) begin $display("[FAIL] ADD failed"); $stop; end

        // Test 2: Subtraction (100 - 35 = 65)
        a = 32'd100; b = 32'd35; alu_ctrl = `ALU_SUB; #10;
        if (result !== 32'd65) begin $display("[FAIL] SUB failed"); $stop; end

        // Test 3: Zero Flag detection (50 - 50 = 0)
        a = 32'd50; b = 32'd50; alu_ctrl = `ALU_SUB; #10;
        if (!zero || result !== 32'd0) begin $display("[FAIL] Zero flag failed"); $stop; end

        // Test 4: Signed Comparison SLT (-5 < 2 -> 1)
        a = -32'd5; b = 32'd2; alu_ctrl = `ALU_SLT; #10;
        if (result !== 32'd1) begin $display("[FAIL] Signed SLT failed"); $stop; end

        // Test 5: Arithmetic Shift Right SRA (-16 >>> 2 = -4)
        a = -32'd16; b = 32'd2; alu_ctrl = `ALU_SRA; #10;
        if (result !== -32'd4) begin $display("[FAIL] SRA failed"); $stop; end

        // Test 6: Bitwise Logical AND & OR
        a = 32'h0000FFFF; b = 32'hFF00FF00; alu_ctrl = `ALU_AND; #10;
        if (result !== 32'h0000FF00) begin $display("[FAIL] AND failed"); $stop; end

        a = 32'hF0F00000; b = 32'h0F0F0000; alu_ctrl = `ALU_OR; #10;
        if (result !== 32'hFFFF0000) begin $display("[FAIL] OR failed"); $stop; end

        $display("\n==============================================");
        $display("          [PASS] ALL ALU TESTS PASSED!        ");
        $display("==============================================\n");

        #10;
        $finish;
    end
endmodule