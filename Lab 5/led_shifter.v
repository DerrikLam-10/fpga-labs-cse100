`timescale 1ns / 1ps

module led_shifter(
    input clk,
    input inp,
    input shl,
    input shr,
    input reset,
    output [5:0] Leds
);
    wire [5:0] left_shift;
    wire [5:0] right_shift;
    wire [5:0] next_leds;
    
    assign left_shift  = {Leds[4:0], 1'b0};  //4 bit to 0, slide left add 0
    assign right_shift = {inp, Leds[5:1]};  //5 bit to 1, inp always 1 on left
    
    wire do_reset = reset;
    wire do_shl   = ~reset & shl & ~shr;
    wire do_shr   = ~reset & ~shl & shr;
    wire do_hold  = ~reset & ~(shl ^ shr);
    
    assign next_leds = ({6{do_reset}} & 6'b111000)  //3 pts
                     | ({6{do_shl}}   & left_shift)  //L 1
                     | ({6{do_shr}}   & right_shift)  //G 1
                     | ({6{do_hold}}  & Leds);  //none
                     
    FDRE #(.INIT(1'b0)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[0]), .Q(Leds[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[1]), .Q(Leds[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[2]), .Q(Leds[2]));
    FDRE #(.INIT(1'b1)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[3]), .Q(Leds[3]));
    FDRE #(.INIT(1'b1)) ff4 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[4]), .Q(Leds[4]));
    FDRE #(.INIT(1'b1)) ff5 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[5]), .Q(Leds[5]));
    
endmodule