`timescale 1ns / 1ps

//rand num generator that feeds into target module
module lfsr(
    input        clk,
    input        reset,
    output [7:0] Lfsr
);

    wire feedback;
    wire [7:0] d;

    assign feedback = Lfsr[0] ^ Lfsr[5] ^ Lfsr[6] ^ Lfsr[7]; //positions chosen to ensure LSFR cycles through 225 non zero statees 
    
    assign d = (reset & 8'b0000_0001) | (~reset & {Lfsr[6:0], feedback});
    //resets and waits for game to be played 
    //doesnt reset and generates a new value

    FDRE #(.INIT(1'b1)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[0]), .Q(Lfsr[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[1]), .Q(Lfsr[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[2]), .Q(Lfsr[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[3]), .Q(Lfsr[3]));
    FDRE #(.INIT(1'b0)) ff4 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[4]), .Q(Lfsr[4]));
    FDRE #(.INIT(1'b0)) ff5 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[5]), .Q(Lfsr[5]));
    FDRE #(.INIT(1'b0)) ff6 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[6]), .Q(Lfsr[6]));
    FDRE #(.INIT(1'b0)) ff7 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[7]), .Q(Lfsr[7]));
    //eight flip flops hold LSFR state and captures new values on clock edge
    
endmodule