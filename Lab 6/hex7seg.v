`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 12:33:58 PM
// Design Name: 
// Module Name: hex7seg
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
module hex7seg	
    
    (input [3:0] sel_out
    ,output [6:0] seg_in
    );
    
assign seg_in[0] = (~sel_out[3]& ~sel_out[2] & ~sel_out[1] &  sel_out[0]) | (~sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | ( sel_out[3] & ~sel_out[2] &  sel_out[1] &  sel_out[0]) | ( sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] & ~sel_out[1] &  sel_out[0]);
assign seg_in[1] = (~sel_out[3] & ~sel_out[2] & ~sel_out[1] &  sel_out[0]) | (~sel_out[3] &  sel_out[2] & ~sel_out[1] &  sel_out[0]) | (~sel_out[3] &  sel_out[2] &  sel_out[1] & ~sel_out[0]) | ( sel_out[3] & ~sel_out[2] &  sel_out[1] &  sel_out[0]) | ( sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] &  sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] &  sel_out[1] &  sel_out[0]);
assign seg_in[2] = (~sel_out[3] & ~sel_out[2] & ~sel_out[1] &  sel_out[0]) | (~sel_out[3] & ~sel_out[2] &  sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] &  sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] &  sel_out[1] &  sel_out[0]);
assign seg_in[3] = (~sel_out[3] & ~sel_out[2] & ~sel_out[1] &  sel_out[0]) | ( ~sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | (~sel_out[3] &  sel_out[2] &  sel_out[1] &  sel_out[0]) | ( sel_out[3] & ~sel_out[2] & ~sel_out[1] &  sel_out[0]) | ( sel_out[3] & ~sel_out[2] &  sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] &  sel_out[1] &  sel_out[0]);
assign seg_in[4] = (~sel_out[3] & ~sel_out[2] &  sel_out[1] &  sel_out[0]) | (~sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | (~sel_out[3] &  sel_out[2] & ~sel_out[1] &  sel_out[0]) | (~sel_out[3] &  sel_out[2] &  sel_out[1] &  sel_out[0]) | ( sel_out[3] & ~sel_out[2] & ~sel_out[1] &  sel_out[0]);
assign seg_in[5] = (~sel_out[3] & ~sel_out[2] &  sel_out[1] & ~sel_out[0]) | (~sel_out[3] & ~sel_out[2] &  sel_out[1] &  sel_out[0]) | (~sel_out[3] &  sel_out[2] &  sel_out[1] &  sel_out[0]) | ( sel_out[3] &  sel_out[2] & ~sel_out[1] & ~sel_out[0]) | ( sel_out[3] &  sel_out[2] & ~sel_out[1] &  sel_out[0]);
assign seg_in[6] = (~sel_out[3] & ~sel_out[2] & ~sel_out[1] & ~sel_out[0]) | (~sel_out[3] & ~sel_out[2] & ~sel_out[1] &  sel_out[0]);
    
endmodule