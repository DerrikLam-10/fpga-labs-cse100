`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 12:36:56 PM
// Design Name: 
// Module Name: selector
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


module selector(
    input [3:0] Sel,
    input [15:0] N,
    output [3:0] H
    );
    
  wire [3:0] h0 = N[3:0]    & {4{Sel[0]}};   
  wire [3:0] h1 = N[7:4]    & {4{Sel[1]}};   
  wire [3:0] h2 = N[11:8]   & {4{Sel[2]}};   
  wire [3:0] h3 = N[15:12]  & {4{Sel[3]}};   

  assign H = h0 | h1 | h2 | h3;

    
endmodule
