`timescale 1ns / 1ps

module uart_tx #(
    parameter CLKS_PER_BIT = 234 // 27,000,000 Hz / 115200 baud
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_active,
    output reg        tx_serial,
    output reg        tx_done
);

    localparam IDLE         = 3'b000;
    localparam START_BIT    = 3'b001;
    localparam DATA_BITS    = 3'b010;
    localparam STOP_BIT     = 3'b011;
    localparam CLEANUP      = 3'b100;

    reg [2:0]  state     = IDLE;
    reg [15:0] clk_count = 16'd0;
    reg [2:0]  bit_index = 3'd0;
    reg [7:0]  data_reg  = 8'd0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx_serial <= 1'b1;
            tx_active <= 1'b0;
            tx_done   <= 1'b0;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    tx_done   <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (tx_start) begin
                        tx_active <= 1'b1;
                        data_reg  <= tx_data;
                        state     <= START_BIT;
                    end else begin
                        tx_active <= 1'b0;
                    end
                end

                START_BIT: begin
                    tx_serial <= 1'b0; // Start bit: 0
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'd0;
                        state     <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx_serial <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'd0;
                        if (bit_index < 3'd7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 3'd0;
                            state     <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx_serial <= 1'b1; // Stop bit: 1
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        tx_done   <= 1'b1;
                        clk_count <= 16'd0;
                        state     <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    tx_active <= 1'b0;
                    state     <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule