/*
 * Copyright (c) 2026 Satya Roop Bankuru
 * SPDX-License-Identifier: Apache-2.0
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

    // Internal state register for the 8-bit LFSR
    reg [7:0] shift_reg;

    // Taps at bit positions 7, 5, 4, and 3 create a maximal length sequence
    wire feedback = shift_reg[7] ^ shift_reg[5] ^ shift_reg[4] ^ shift_reg[3];

    // Sequential state processing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'h01; // Seed value
        end else begin
            shift_reg <= {shift_reg[6:0], feedback};
        end
    end

    // CRITICAL FIX: Multiplex all 8 bits of the LFSR onto a single output port (uo_out[0])
    // This removes the physical wiring congestion that forces the router to climb to Metal 5.
    // Use the lowest 3 bits of ui_in to select which register bit to read out.
    wire selected_bit = shift_reg[ui_in[2:0]];
    
    // Drive only a single output line; tie everything else hard to absolute ground
    assign uo_out[0] = selected_bit;
    assign uo_out[7:1] = 7'b0000000;

    // Completely deactivate the bi-directional I/O infrastructure routing
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Sink all remaining inputs to absolute zero to prevent floating ports
    wire [7:0] combined_inputs = ui_in ^ uio_in;
    wire _unused = &{ena, combined_inputs, 1'b0};

endmodule
