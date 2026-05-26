/*
 * Copyright (c) 2026 Satya Roop Bankuru
 * SPDX-License-Identifier: Apache-2.0
 * Fresh Trigger: Forced pipeline rebuild sequence.
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // 8-bit internal shift register logic
    reg [7:0] shift_reg;
    wire feedback = shift_reg[7] ^ shift_reg[5] ^ shift_reg[4] ^ shift_reg[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'h01; // Seed value
        end else begin
            shift_reg <= {shift_reg[6:0], feedback};
        end
    end

    // LOW LAYER ROUTING: Drive only 1 external output pin (uo_out[0]).
    // Pins 1 through 7 are tied to 0 to prevent Metal 5 routing overhead.
    assign uo_out[0]   = shift_reg[0];
    assign uo_out[7:1] = 7'b0000000;

    // Turn off bidirectional infrastructure pins
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Clear compiler linter warnings cleanly
    wire [7:0] unused_inputs = ui_in ^ uio_in;
    wire _unused = &{ena, unused_inputs, 1'b0};

endmodule
