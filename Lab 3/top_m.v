`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 12:22:47 PM
// Design Name: 
// Module Name: top_m
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_m(
    input        clkin,
    input        btnU,
    input        btnD,
    input        btnR,
    input        btnC,
    input        btnL,
    input  [15:0] sw,
    output [15:0] led,
    output [3:0]  an,
    output [6:0]  seg,
    output        dp
);

    wire clk;
    wire digsel;

    labCnt_clks slowit (
        .clkin (clkin),
        .greset(btnR),
        .clk   (clk),
        .digsel(digsel)
    );

    wire up_pulse;
    wire dw_pulse;

    edgeDetector edU (
        .clk    (clk),
        .reset  (1'b0),
        .button (btnU),
        .edge_o (up_pulse)
    );

    edgeDetector edD (
        .clk    (clk),
        .reset  (1'b0),
        .button (btnD),
        .edge_o (dw_pulse)
    );

    wire [15:0] Q;
    wire utc16, dtc16;

    wire ones_hi;
    assign ones_hi =
        Q[15] & Q[14] & Q[13] & Q[12] & Q[11] & Q[10] & Q[9]  & Q[8] &
        Q[7]  & Q[6]  & Q[5]  & Q[4]  & Q[3]  & Q[2];

    wire cont_up;
    assign cont_up = btnC & (~ones_hi);

    wire up_to_counter;
    assign up_to_counter = up_pulse | cont_up;

    countUD16L c16 (
        .clk  (clk),
        .reset(1'b0),
        .up   (up_to_counter),
        .dw   (dw_pulse),
        .ld   (btnL),
        .Din  (sw),
        .Q    (Q),
        .utc  (utc16),
        .dtc  (dtc16)
    );

    assign led[15]   = utc16;
    assign led[14:1] = 14'b0;
    assign led[0]    = dtc16;

    wire [3:0] Ring;

    ringCounter rc (
        .clk    (clk),
        .advance(digsel),
        .reset  (1'b0),
        .Ring   (Ring)
    );

    assign an = ~Ring;

    wire [3:0] H;

    selector sel (
        .Sel(Ring),
        .N  (Q),
        .H  (H)
    );

    hex7seg h7 (
        .N  (H),
        .Seg(seg)
    );

    assign dp = 1'b1;

endmodule

