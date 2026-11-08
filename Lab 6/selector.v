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
    input [3:0] ring_out,
    input [15:0] sel_in,
    output [3:0] sel_out
    );
    
  wire [3:0] h0 = sel_in[3:0]    & {4{ring_out[0]}};   
  wire [3:0] h1 = sel_in[7:4]    & {4{ring_out[1]}};   
  wire [3:0] h2 = sel_in[11:8]   & {4{ring_out[2]}};   
  wire [3:0] h3 = sel_in[15:12]  & {4{ring_out[3]}};   
  
  assign sel_out = h0 | h1 | h2 | h3;
    
endmodule