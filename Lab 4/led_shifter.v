module led_shifter(
    input        clk,
    input        inp,      // Value to shift in
    input        shl,      // Shift left
    input        shr,      // Shift right
    input        reset,
    output [15:0] Leds
);

    wire [15:0] left_shift;
    wire [15:0] right_shift;
    wire [15:0] next_leds;

    assign left_shift  = {Leds[14:0], inp};
    assign right_shift = {inp, Leds[15:1]};

    assign next_leds =
        reset            ? 16'b0      :
        (shl & ~shr)     ? left_shift :
        (shr & ~shl)     ? right_shift:
                           Leds;

    FDRE #(.INIT(1'b0)) ff0  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[0]),  .Q(Leds[0]));
    FDRE #(.INIT(1'b0)) ff1  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[1]),  .Q(Leds[1]));
    FDRE #(.INIT(1'b0)) ff2  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[2]),  .Q(Leds[2]));
    FDRE #(.INIT(1'b0)) ff3  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[3]),  .Q(Leds[3]));
    FDRE #(.INIT(1'b0)) ff4  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[4]),  .Q(Leds[4]));
    FDRE #(.INIT(1'b0)) ff5  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[5]),  .Q(Leds[5]));
    FDRE #(.INIT(1'b0)) ff6  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[6]),  .Q(Leds[6]));
    FDRE #(.INIT(1'b0)) ff7  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[7]),  .Q(Leds[7]));
    FDRE #(.INIT(1'b0)) ff8  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[8]),  .Q(Leds[8]));
    FDRE #(.INIT(1'b0)) ff9  (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[9]),  .Q(Leds[9]));
    FDRE #(.INIT(1'b0)) ff10 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[10]), .Q(Leds[10]));
    FDRE #(.INIT(1'b0)) ff11 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[11]), .Q(Leds[11]));
    FDRE #(.INIT(1'b0)) ff12 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[12]), .Q(Leds[12]));
    FDRE #(.INIT(1'b0)) ff13 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[13]), .Q(Leds[13]));
    FDRE #(.INIT(1'b0)) ff14 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[14]), .Q(Leds[14]));
    FDRE #(.INIT(1'b0)) ff15 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_leds[15]), .Q(Leds[15]));

endmodule
