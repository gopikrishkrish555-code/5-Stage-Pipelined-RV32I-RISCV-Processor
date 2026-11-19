`timescale 1ns / 1ps

module imem (
    input  wire [31:0] addr,
    output wire [31:0] inst
);

    reg [31:0] mem [0:63];

    initial begin
        // Base Setup
        // x1: UART Data Port = 0x100
        mem[0]  = 32'h10000093; // 0x00: addi x1, x0, 256

        // ------------------ 'R' ------------------
        mem[1]  = 32'h05200113; // 0x04: addi x2, x0, 82 ('R')
        mem[2]  = 32'h0020a023; // 0x08: sw   x2, 0(x1)
        // Delay: x7 = 3000
        mem[3]  = 32'hbb800393; // 0x0C: addi x7, x0, 3000
        mem[4]  = 32'hfff38393; // 0x10: addi x7, x7, -1
        mem[5]  = 32'h00000013; // 0x14: nop (pipeline bubble pad)
        mem[6]  = 32'hfe039ce3; // 0x18: bne  x7, x0, -8 (jump back to 0x10)

        // ------------------ 'I' ------------------
        mem[7]  = 32'h04900113; // 0x1C: addi x2, x0, 73 ('I')
        mem[8]  = 32'h0020a023; // 0x20: sw   x2, 0(x1)
        mem[9]  = 32'hbb800393; // 0x24: addi x7, x0, 3000
        mem[10] = 32'hfff38393; // 0x28: addi x7, x7, -1
        mem[11] = 32'h00000013; // 0x2C: nop
        mem[12] = 32'hfe039ce3; // 0x30: bne  x7, x0, -8 (jump back to 0x28)

        // ------------------ 'S' ------------------
        mem[13] = 32'h05300113; // 0x34: addi x2, x0, 83 ('S')
        mem[14] = 32'h0020a023; // 0x38: sw   x2, 0(x1)
        mem[15] = 32'hbb800393; // 0x3C: addi x7, x0, 3000
        mem[16] = 32'hfff38393; // 0x40: addi x7, x7, -1
        mem[17] = 32'h00000013; // 0x44: nop
        mem[18] = 32'hfe039ce3; // 0x48: bne  x7, x0, -8

        // ------------------ 'C' ------------------
        mem[19] = 32'h04300113; // 0x4C: addi x2, x0, 67 ('C')
        mem[20] = 32'h0020a023; // 0x50: sw   x2, 0(x1)
        mem[21] = 32'hbb800393; // 0x54: addi x7, x0, 3000
        mem[22] = 32'hfff38393; // 0x58: addi x7, x7, -1
        mem[23] = 32'h00000013; // 0x5C: nop
        mem[24] = 32'hfe039ce3; // 0x60: bne  x7, x0, -8

        // ------------------ '-' ------------------
        mem[25] = 32'h02d00113; // 0x64: addi x2, x0, 45 ('-')
        mem[26] = 32'h0020a023; // 0x68: sw   x2, 0(x1)
        mem[27] = 32'hbb800393; // 0x6C: addi x7, x0, 3000
        mem[28] = 32'hfff38393; // 0x70: addi x7, x7, -1
        mem[29] = 32'h00000013; // 0x74: nop
        mem[30] = 32'hfe039ce3; // 0x78: bne  x7, x0, -8

        // ------------------ 'V' ------------------
        mem[31] = 32'h05600113; // 0x7C: addi x2, x0, 86 ('V')
        mem[32] = 32'h0020a023; // 0x80: sw   x2, 0(x1)
        mem[33] = 32'hbb800393; // 0x84: addi x7, x0, 3000
        mem[34] = 32'hfff38393; // 0x88: addi x7, x7, -1
        mem[35] = 32'h00000013; // 0x8C: nop
        mem[36] = 32'hfe039ce3; // 0x90: bne  x7, x0, -8

        // ------------------ '!' ------------------
        mem[37] = 32'h02100113; // 0x94: addi x2, x0, 33 ('!')
        mem[38] = 32'h0020a023; // 0x98: sw   x2, 0(x1)
        mem[39] = 32'hbb800393; // 0x9C: addi x7, x0, 3000
        mem[40] = 32'hfff38393; // 0xA0: addi x7, x7, -1
        mem[41] = 32'h00000013; // 0xA4: nop
        mem[42] = 32'hfe039ce3; // 0xA8: bne  x7, x0, -8

        // ------------------ '\n' ------------------
        mem[43] = 32'h00a00113; // 0xAC: addi x2, x0, 10 ('\n')
        mem[44] = 32'h0020a023; // 0xB0: sw   x2, 0(x1)

        // Done: Turn on all 4 LEDs and halt
        mem[45] = 32'h00f00193; // 0xB4: addi x3, x0, 15
        mem[46] = 32'h0000006f; // 0xB8: jal  x0, 0
    end

    assign inst = mem[addr[7:2]];

endmodule