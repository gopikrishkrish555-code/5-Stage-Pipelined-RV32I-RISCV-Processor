`timescale 1ns / 1ps

module tb_riscv_core;
    reg clk;
    reg rst_n;

    riscv_core uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // 10ns clock period (100MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/core_wave.vcd");
        $dumpvars(0, tb_riscv_core);

        clk   = 0;
        rst_n = 0;

        // Apply reset for 2 cycles
        #15;
        rst_n = 1;

        // Run for 35 clock cycles (350ns) to allow the 5-iteration loop to finish
        #350;

        $display("\n==============================================");
        $display("       LOOP PROGRAM EXECUTION RESULTS         ");
        $display("==============================================");
        $display("x1 (initial i)         : %0d", uut.u_reg_file.registers[1]);
        $display("x2 (counter reached 0) : %0d", uut.u_reg_file.registers[2]);
        $display("x3 (final sum 1..5)    : %0d", uut.u_reg_file.registers[3]);
        $display("DMEM[0] (stored sum)   : %0d", uut.u_dmem.ram[0]);

        if (uut.u_reg_file.registers[2] === 32'd0  &&
            uut.u_reg_file.registers[3] === 32'd15 &&
            uut.u_dmem.ram[0] === 32'd15) begin
            $display("\n[PASS] LOOP & BRANCH VERIFICATION SUCCESSFUL!");
        end else begin
            $display("\n[FAIL] Loop execution mismatch!");
            $stop;
        end
        $display("==============================================\n");

        #10;
        $finish;
    end
endmodule