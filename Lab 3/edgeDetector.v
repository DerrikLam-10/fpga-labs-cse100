`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 01:34:14 PM
// Design Name: 
// Module Name: edgeDetector
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


module edgeDetector(
    input  clk,
    input  reset,
    input  button,
    output edge_o
);

    wire q_prev;
    wire q_curr;

    FDRE ff0 (.C(clk), .CE(1'b1), .R(reset), .D(button), .Q(q_curr));
    FDRE ff1 (.C(clk), .CE(1'b1), .R(reset), .D(q_curr), .Q(q_prev));

    assign edge_o = q_curr & ~q_prev;

endmodule

