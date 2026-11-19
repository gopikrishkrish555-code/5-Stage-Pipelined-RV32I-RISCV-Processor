`timescale 1ns / 1ps

module hazard_detection_unit (
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    input  wire [4:0] id_ex_rd,
    input  wire       id_ex_mem_read,
    input  wire       branch_taken,
    output reg        pc_stall,
    output reg        if_id_stall,
    output reg        if_id_flush,
    output reg        id_ex_flush
);

    always @(*) begin
        pc_stall    = 1'b0;
        if_id_stall = 1'b0;
        if_id_flush = 1'b0;
        id_ex_flush = 1'b0;

        // 1. Control hazard: Flush fetched instructions when branch/jump taken
        if (branch_taken) begin
            if_id_flush = 1'b1;
            id_ex_flush = 1'b1;
        end
        // 2. Load-Use hazard: 1-cycle stall bubble if next instruction depends on LW result
        else if (id_ex_mem_read && (id_ex_rd != 5'd0) &&
                ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            pc_stall    = 1'b1;
            if_id_stall = 1'b1;
            id_ex_flush = 1'b1; // Turn the ID/EX instruction into a NOP bubble
        end
    end

endmodule