`timescale 1ns / 1ps

module top(
    input clkin,
    input [15:0] sw,
    input btnU,
    input btnC,
    input btnR,
    output [3:0] an,
    output [6:0] seg,
    output [15:0] led,
    output dp
);

    wire clk;
    wire digsel;
    wire qsec;

    wire [7:0] lfsr_out;
    wire [5:0] time_count;
    wire [15:0] led_out;

    wire load_target;
    wire flash;
    wire reset_timer;
    wire load_numbers;
    wire shr;
    wire shl;
    wire good;
    wire lose;

    wire four_secs;
    wire two_secs;
    wire match;
    wire timeout;

    wire [3:0] target;

    wire [3:0] lfsr_half;
    assign lfsr_half = lsfr_out[3:0];
    
    
    wire [3:0] selected;
    wire [3:0] ring_out;
    wire reset;
    assign reset = 1'b0;
    wire [15:0] display;
    wire display_state;
    //assign display = ({lfsr_out[7:0], 8'd0} & display_state) | (good & {16'b1001_0000_0000_1101}) | (lose & {16'b0001_0000_0101_1110});
    wire [15:0] x,y,z;
    assign x = (good) ? 16'b1001_0000_0000_1101 : 16'd0;
    assign z = lose ? 16'b0001_0000_0101_1110 : 16'd0;
    assign y = display_state ? {lfsr_out[7:0], 8'd0} : 16'd0;
    assign display = x | z | y;

    qsec_clks quarter (
        .clkin(clkin),
        .greset(btnR),
        .clk(clk),
        .digsel(digsel),
        .qsec(qsec)
    );

    lfsr gen (
        .clk(clk),
        .reset(btnR),
        .Lfsr(lfsr_out)
    );

    time_counter timer (
        .clk(clk),
        .inc(qsec),
        .reset(reset_timer),
        .Count(time_count)
    );
    
    FDRE #(.INIT(1'b0)) ff[3:0]  (.C({4{clk}}), .R({4{btnR}}), .CE({4{load_target}}), .D(lfsr_half),  .Q(target));
    
    assign match = &(time_count[5:1] ~^ lfsr_out[7:4]);
    

    wire [5:0] two_temp;
    wire [5:0] two_inv;
    wire [5:0] four_temp;
    wire [5:0] four_inv;
    
    assign two_temp  = time_count ^ 6'b001000;
    assign two_inv   = ~two_temp;
    assign two_secs  = &two_inv;
    
    assign four_temp = time_count ^ 6'b010000;
    assign four_inv  = ~four_temp;
    assign four_secs = &four_inv;
    wire [4:0] curState;
    
    


    fsm machine(
        .clk(clk),
        .go(btnC),
        .stop(btnU),
        .four_secs(four_secs),
        .two_secs(two_secs),
        .match(match),
        .timeout(timeout),
        .load_target(load_target),
        .flash(flash),
        .reset_timer(reset_timer),
        .load_numbers(load_numbers),
        .shr(shr),
        .shl(shl),
        .good(good),
        .lose(lose),
        .display_state(display_state),
        .states(curState)
    );

    led_shifter shifter (
        .clk(clk),
        .inp(good),
        .shl(shl),
        .shr(shr),
        .reset(btnR),
        .Leds(led_out)
    );

    //assign led = led_out;

    ringCounter rc (
        .clk(clk),
        .advance(digsel),
        .Ring(ring_out),
        .reset(reset)
    );

    selector sel (
        .Sel(ring_out),
        .N(display),
        .H(selected)
    );

    hex7seg h7 (
        .N(selected),
        .Seg(seg)
    );

    assign dp = 1'b1;
    assign an = ~ring_out;
//    assign an  = (good | lose | display_state) ? ~ring_out  : 4'b0000;  // all digits off
    assign led[4:0] = machine.curState[4:0];

endmodule
