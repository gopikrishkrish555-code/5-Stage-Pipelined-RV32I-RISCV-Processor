`timescale 1ns / 1ps

module tb_reg_file;
    reg         clk;
    reg         rst_n;
    reg         we;
    reg  [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg  [31:0] wr_data;
    wire [31:0] rs1_data, rs2_data;

    reg_file uut (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .wr_data(wr_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 100 MHz clock generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/reg_file_wave.vcd");
        $dumpvars(0, tb_reg_file);

        // Initialize signals
        clk = 0;
        rst_n = 0;
        we = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        wr_data = 0;

        // Apply reset
        #15 rst_n = 1;

        // Test 1: Write 0x12345678 to register x1
        @(posedge clk);
        we = 1; rd_addr = 5'd1; wr_data = 32'h12345678;
        @(posedge clk);
        we = 0;

        // Test 2: Write 0xABCDEF00 to register x2
        @(posedge clk);
        we = 1; rd_addr = 5'd2; wr_data = 32'hABCDEF00;
        @(posedge clk);
        we = 0;

        // Test 3: Attempt write to x0 (must remain 0)
        @(posedge clk);
        we = 1; rd_addr = 5'd0; wr_data = 32'hFFFFFFFF;
        @(posedge clk);
        we = 0;

        // Test 4: Dual-port simultaneous read (Read x1 on Port 1, Read x2 on Port 2)
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #2;
        if (rs1_data !== 32'h12345678 || rs2_data !== 32'hABCDEF00) begin
            $display("[FAIL] Dual read failed! rs1=%h, rs2=%h", rs1_data, rs2_data);
            $stop;
        end

        // Test 5: Check that x0 stayed 0
        rs1_addr = 5'd0;
        #2;
        if (rs1_data !== 32'h00000000) begin
            $display("[FAIL] x0 register is not zero! rs1=%h", rs1_data);
            $stop;
        end

        $display("\n==============================================");
        $display("   [PASS] ALL REGISTER FILE TESTS PASSED!    ");
        $display("==============================================\n");

        #20;
        $finish;
    end
endmodule