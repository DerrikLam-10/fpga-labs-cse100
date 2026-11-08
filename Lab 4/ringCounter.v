`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 12:37:32 PM
// Design Name: 
// Module Name: ringCounter
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


module ringCounter(
    input        clk,
    input        advance,
    input        reset,
    output [3:0] Ring
);

    wire [3:0] D;

    assign D[3] = (~reset & ((advance & Ring[0]) | (~advance & Ring[3])));
    assign D[2] = (~reset & ((advance & Ring[3]) | (~advance & Ring[2])));
    assign D[1] = (~reset & ((advance & Ring[2]) | (~advance & Ring[1])));
    assign D[0] = ( reset) | (~reset & ((advance & Ring[1]) | (~advance & Ring[0])));

    FDRE #(.INIT(1'b0)) Q0_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[3]), .Q(Ring[3]));
    FDRE #(.INIT(1'b0)) Q1_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[2]), .Q(Ring[2]));
    FDRE #(.INIT(1'b0)) Q2_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[1]), .Q(Ring[1]));
    FDRE #(.INIT(1'b1)) Q3_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[0]), .Q(Ring[0]));
    

endmodule

