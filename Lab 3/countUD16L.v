`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2026 12:47:13 PM
// Design Name: 
// Module Name: countUD16L
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


module countUD16L(
    input         clk,
    input         reset,
    input         up,
    input         dw,
    input         ld,
    input  [15:0] Din,
    output [15:0] Q,
    output        utc,
    output        dtc
);

    wire utc_lo, dtc_lo;
    wire utc_hi, dtc_hi;

    wire up_hi;
    wire dw_hi;

    assign up_hi = up & ~dw & ~ld & utc_lo;
    assign dw_hi = dw & ~up & ~ld & dtc_lo;

    countUD8L lo (
        .clk   (clk),
        .reset (reset),
        .up    (up),
        .dw    (dw),
        .ld    (ld),
        .Din   (Din[7:0]),
        .Q     (Q[7:0]),
        .utc   (utc_lo),
        .dtc   (dtc_lo)
    );

    countUD8L hi (
        .clk   (clk),
        .reset (reset),
        .up    (up_hi),
        .dw    (dw_hi),
        .ld    (ld),
        .Din   (Din[15:8]),
        .Q     (Q[15:8]),
        .utc   (utc_hi),
        .dtc   (dtc_hi)
    );

    assign utc = utc_hi & utc_lo;
    assign dtc = dtc_hi & dtc_lo;

endmodule

