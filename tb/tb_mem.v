`timescale 1ns / 1ps

module tb_mem;
    reg         clk;
    reg         mem_read;
    reg         mem_write;
    reg  [31:0] dmem_addr;
    reg  [31:0] write_data;
    wire [31:0] read_data;

    reg  [31:0] imem_addr;
    wire [31:0] inst;

    imem uut_imem (
        .addr(imem_addr),
        .inst(inst)
    );

    dmem uut_dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(dmem_addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/mem_wave.vcd");
        $dumpvars(0, tb_mem);

        clk        = 0;
        mem_read   = 0;
        mem_write  = 0;
        dmem_addr  = 0;
        write_data = 0;
        imem_addr  = 0;

        #10;
        // Test 1: Verify first instruction loaded from hex file
        imem_addr = 32'h0000_0000;
        #5;
        if (inst !== 32'h00500093) begin
            $display("[FAIL] IMEM read at 0x0 failed! Got: 0x%h", inst);
            $stop;
        end

        // Test 2: Verify second instruction
        imem_addr = 32'h0000_0004;
        #5;
        if (inst !== 32'h00A00113) begin
            $display("[FAIL] IMEM read at 0x4 failed! Got: 0x%h", inst);
            $stop;
        end

        // Test 3: Write to DMEM at address 0x20
        dmem_addr  = 32'h0000_0020;
        write_data = 32'hCAFE1234;
        mem_write  = 1;
        #10; // Trigger posedge clk
        mem_write  = 0;

        // Test 4: Read back from DMEM
        mem_read   = 1;
        #5;
        if (read_data !== 32'hCAFE1234) begin
            $display("[FAIL] DMEM readback failed! Expected 0xCAFE1234, got: 0x%h", read_data);
            $stop;
        end

        $display("\n==============================================");
        $display("        [PASS] ALL MEMORY TESTS PASSED!       ");
        $display("==============================================\n");

        #10;
        $finish;
    end
endmodule