`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 12:37:13 PM
// Design Name: 
// Module Name: countUD8L
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


module countUD8L(
    input        clk,
    input        reset,
    input        up,
    input        dw,
    input        ld,
    input  [7:0] Din,
    output [7:0] Q,
    output       utc,
    output       dtc
);

    wire en_ld;
    wire en_up;
    wire en_dw;
    wire en_hold;

    assign en_ld   = ld;
    assign en_up   = up & ~dw & ~ld;
    assign en_dw   = dw & ~up & ~ld;
    assign en_hold = ~(en_ld | en_up | en_dw);

    wire [7:0] inc;
    wire [7:0] c;

    assign inc[0] = ~Q[0];
    assign c[0]   =  Q[0];

    assign inc[1] = Q[1] ^ c[0];
    assign c[1]   = Q[1] & c[0];

    assign inc[2] = Q[2] ^ c[1];
    assign c[2]   = Q[2] & c[1];

    assign inc[3] = Q[3] ^ c[2];
    assign c[3]   = Q[3] & c[2];

    assign inc[4] = Q[4] ^ c[3];
    assign c[4]   = Q[4] & c[3];

    assign inc[5] = Q[5] ^ c[4];
    assign c[5]   = Q[5] & c[4];

    assign inc[6] = Q[6] ^ c[5];
    assign c[6]   = Q[6] & c[5];

    assign inc[7] = Q[7] ^ c[6];

    wire [7:0] dec;
    wire [7:0] b;

    assign dec[0] = ~Q[0];
    assign b[0]   = ~Q[0];

    assign dec[1] = Q[1] ^ b[0];
    assign b[1]   = (~Q[1]) & b[0];

    assign dec[2] = Q[2] ^ b[1];
    assign b[2]   = (~Q[2]) & b[1];

    assign dec[3] = Q[3] ^ b[2];
    assign b[3]   = (~Q[3]) & b[2];

    assign dec[4] = Q[4] ^ b[3];
    assign b[4]   = (~Q[4]) & b[3];

    assign dec[5] = Q[5] ^ b[4];
    assign b[5]   = (~Q[5]) & b[4];

    assign dec[6] = Q[6] ^ b[5];
    assign b[6]   = (~Q[6]) & b[5];

    assign dec[7] = Q[7] ^ b[6];

    wire [7:0] D;

    assign D =
        ({8{en_ld}}   & Din) |
        ({8{en_up}}   & inc) |
        ({8{en_dw}}   & dec) |
        ({8{en_hold}} & Q);

    FDRE ff0 (.C(clk), .CE(1'b1), .R(reset), .D(D[0]), .Q(Q[0]));
    FDRE ff1 (.C(clk), .CE(1'b1), .R(reset), .D(D[1]), .Q(Q[1]));
    FDRE ff2 (.C(clk), .CE(1'b1), .R(reset), .D(D[2]), .Q(Q[2]));
    FDRE ff3 (.C(clk), .CE(1'b1), .R(reset), .D(D[3]), .Q(Q[3]));
    FDRE ff4 (.C(clk), .CE(1'b1), .R(reset), .D(D[4]), .Q(Q[4]));
    FDRE ff5 (.C(clk), .CE(1'b1), .R(reset), .D(D[5]), .Q(Q[5]));
    FDRE ff6 (.C(clk), .CE(1'b1), .R(reset), .D(D[6]), .Q(Q[6]));
    FDRE ff7 (.C(clk), .CE(1'b1), .R(reset), .D(D[7]), .Q(Q[7]));

    assign utc = Q[0] & Q[1] & Q[2] & Q[3] & Q[4] & Q[5] & Q[6] & Q[7];

    wire any1;
    assign any1 = Q[0] | Q[1] | Q[2] | Q[3] | Q[4] | Q[5] | Q[6] | Q[7];
    assign dtc  = ~any1;

endmodule

