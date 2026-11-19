`timescale 1ns / 1ps

module tb_pc;
    reg         clk;
    reg         rst_n;
    reg  [31:0] pc_next;
    wire [31:0] pc;

    pc uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );

    // 10ns clock period (100MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/pc_wave.vcd");
        $dumpvars(0, tb_pc);

        clk     = 0;
        rst_n   = 0;
        pc_next = 32'h0000_0004;

        // Hold reset for two cycles
        #15;
        if (pc !== 32'h0000_0000) begin
            $display("[FAIL] Reset state failed! Expected 0, got: 0x%h", pc);
            $stop;
        end

        // Release reset
        rst_n = 1;
        #10;
        if (pc !== 32'h0000_0004) begin
            $display("[FAIL] PC update failed! Expected 0x4, got: 0x%h", pc);
            $stop;
        end

        // Test sequential step
        pc_next = 32'h0000_0008;
        #10;
        if (pc !== 32'h0000_0008) begin
            $display("[FAIL] PC sequential update failed! Expected 0x8, got: 0x%h", pc);
            $stop;
        end

        // Test non-sequential branch/jump address
        pc_next = 32'h0000_0040;
        #10;
        if (pc !== 32'h0000_0040) begin
            $display("[FAIL] PC branch jump target failed! Expected 0x40, got: 0x%h", pc);
            $stop;
        end

        $display("\n==============================================");
        $display("         [PASS] ALL PC TESTS PASSED!          ");
        $display("==============================================\n");

        #10;
        $finish;
    end
endmodule