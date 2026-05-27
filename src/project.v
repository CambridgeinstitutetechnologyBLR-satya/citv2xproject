/*
 * Copyright (c) 2026 Satya Roop Bankuru
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sandy_venky (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // 8-bit LFSR register
    reg [7:0] shift_reg;

    // XOR taps
    wire feedback;
    assign feedback =
        shift_reg[7] ^
        shift_reg[5] ^
        shift_reg[4] ^
        shift_reg[3];

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shift_reg <= 8'h01;
        else
            shift_reg <= {shift_reg[6:0], feedback};
    end

    // Only drive one physical output
    assign uo_out[0] = shift_reg[0];
    assign uo_out[7:1] = 7'b0000000;

    // Disable bidirectional IO
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Remove warnings
    wire [7:0] unused_inputs;
    assign unused_inputs = ui_in ^ uio_in;

    wire _unused;
    assign _unused = &{ena, unused_inputs, 1'b0};

endmodule

`default_nettype wire
