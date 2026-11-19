`timescale 1ns / 1ps
`include "riscv_defs.vh"

module tb_imm_gen;
    reg  [31:0] inst;
    wire [31:0] imm_out;

    imm_gen uut (
        .inst(inst),
        .imm_out(imm_out)
    );

    initial begin
        $dumpfile("sim/imm_gen_wave.vcd");
        $dumpvars(0, tb_imm_gen);

        // Test 1: I-Type
        inst = 32'hFFF00093;
        #10;
        if (imm_out !== 32'hFFFFFFFF) begin
            $display("[FAIL] I-type failed: %h", imm_out);
            $stop;
        end

        // Test 2: S-Type
        inst = 32'h0020A423;
        #10;
        if (imm_out !== 32'd8) begin
            $display("[FAIL] S-type failed: %h", imm_out);
            $stop;
        end

        // Test 3: B-Type
        inst = 32'hFE000EE3;
        #10;
        if ($signed(imm_out) !== -4) begin
            $display("[FAIL] B-type failed: %0d", $signed(imm_out));
            $stop;
        end

        // Test 4: U-Type
        inst = 32'h123450B7;
        #10;
        if (imm_out !== 32'h12345000) begin
            $display("[FAIL] U-type failed: %h", imm_out);
            $stop;
        end

        // Test 5: J-Type
        inst = 32'h010000EF;
        #10;
        if (imm_out !== 32'd16) begin
            $display("[FAIL] J-type failed: %0d", imm_out);
            $stop;
        end

        $display("\n==============================================");
        $display("     [PASS] ALL IMM_GEN TESTS PASSED!         ");
        $display("==============================================\n");

        #10;
        $finish;
    end
endmodule
