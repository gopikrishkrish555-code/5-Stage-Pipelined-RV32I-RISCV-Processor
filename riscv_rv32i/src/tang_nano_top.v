`timescale 1ns / 1ps

module tang_nano_top (
    input  wire       clk_27m,   // Onboard 27 MHz crystal (Pin 4)
    input  wire       btn1,      // S1 user button (Pin 88)
    output wire [5:0] led,       // 6 active-low LEDs
    output wire       uart_tx    // Serial TX out to USB BL702 (Pin 69)
);

    // Power-on reset sequence
    reg [7:0] rst_cnt = 8'd0;
    always @(posedge clk_27m) begin
        if (rst_cnt < 8'd255)
            rst_cnt <= rst_cnt + 1'b1;
    end
    wire rst_n = (rst_cnt == 8'd255);

    // Visual heartbeat LED (~1.6 Hz)
    reg [23:0] hb_counter = 24'd0;
    always @(posedge clk_27m) begin
        hb_counter <= hb_counter + 1'b1;
    end

    wire [31:0] reg3_val;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire        mem_wen;
    wire [31:0] mmio_rdata;
    wire        tx_busy;

    // CPU reads 0x104 to check UART busy status (1 = busy, 0 = ready)
    assign mmio_rdata = (mem_addr == 32'h0000_0104) ? {31'd0, tx_busy} : 32'd0;

    // 5-Stage RV32I Core running at 27 MHz
    riscv_core u_core (
        .clk(clk_27m),
        .rst_n(rst_n),
        .debug_reg3(reg3_val),
        .out_mem_addr(mem_addr),
        .out_mem_wdata(mem_wdata),
        .out_mem_wen(mem_wen),
        .in_mmio_rdata(mmio_rdata)
    );

    // Memory-mapped UART strobe on address 0x0000_0100
    wire uart_send_strobe = mem_wen && (mem_addr == 32'h0000_0100);

    uart_tx #(
        .CLKS_PER_BIT(234)
    ) u_uart_tx (
        .clk(clk_27m),
        .rst_n(rst_n),
        .tx_start(uart_send_strobe),
        .tx_data(mem_wdata[7:0]),
        .tx_active(tx_busy),
        .tx_serial(uart_tx),
        .tx_done()
    );

    // Onboard LED indicators
    assign led[5]   = ~hb_counter[23];
    assign led[4]   = rst_n;
    assign led[3:0] = ~reg3_val[3:0];

endmodule