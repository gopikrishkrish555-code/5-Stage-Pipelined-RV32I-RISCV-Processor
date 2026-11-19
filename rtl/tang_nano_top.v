`timescale 1ns / 1ps

module tang_nano_top (
    input  wire       clk_27m,   // Pin 4
    input  wire       btn1,      // Pin 88
    output wire [5:0] led        // Pins 15-20 (Active-low: 0 = ON, 1 = OFF)
);

    // Free-running 25-bit counter without any button reset dependency
    reg [24:0] counter = 25'd0;
    always @(posedge clk_27m) begin
        counter <= counter + 1'b1;
    end

    // Direct hardware diagnostics:
    // LED 0: Hardwired ON (Must turn ON immediately upon flashing)
    // LED 1: Hardwired OFF
    // LED 2: Button S1 indicator (lights up when you press S1)
    // LED 3: Fast blinker (~3.2 Hz)
    // LED 4: Medium blinker (~1.6 Hz)
    // LED 5: Slow blinker (~0.8 Hz)
    assign led[0] = 1'b0;          // 0 = ON on Tang Nano 20K
    assign led[1] = 1'b1;          // 1 = OFF
    assign led[2] = btn1;          // 0 when pressed (lights up)
    assign led[3] = ~counter[22];  // Blinks fast
    assign led[4] = ~counter[23];  // Blinks medium
    assign led[5] = ~counter[24];  // Blinks slow

endmodule