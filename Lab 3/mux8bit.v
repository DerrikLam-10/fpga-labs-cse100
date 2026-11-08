`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 12:35:21 PM
// Design Name: 
// Module Name: mux8bit
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


module mux8bit(
    input  [7:0] i0,
    input  [7:0] i1,
    input        sel,
    output [7:0] o
);

    assign o = ({8{~sel}} & i0) | ({8{sel}} & i1);

endmodule

