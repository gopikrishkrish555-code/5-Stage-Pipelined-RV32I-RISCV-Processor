`timescale 1ns / 1ps

module imem (
    input  wire [31:0] addr,    // 32-bit byte address from PC
    output wire [31:0] inst     // 32-bit instruction out
);

    // 1024 words (4 KB) instruction memory
    reg [31:0] mem [0:1023];

    // Hardcode the loop program directly so synthesis never loses it
    initial begin
        mem[0] = 32'h00000093; // addi x1, x0, 0
        mem[1] = 32'h00500113; // addi x2, x0, 5
        mem[2] = 32'h00000193; // addi x3, x0, 0
        mem[3] = 32'h002181B3; // loop: add  x3, x3, x2
        mem[4] = 32'hFFF10113; //       addi x2, x2, -1
        mem[5] = 32'hFE011CE3; //       bne  x2, x0, loop (-8 bytes)
        mem[6] = 32'h00302023; //       sw   x3, 0(x0)
    end

    // Word address: byte address divided by 4
    wire [9:0] word_addr = addr[11:2];

    assign inst = mem[word_addr];

endmodule