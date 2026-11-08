`timescale 1ns / 1ps

module top(
    input clkin,
    input [15:0] sw,
    input btnD,
    input btnC,
    input btnR,
    input btnL,
    output [3:0] an,
    output [6:0] seg,
    output [15:0] led,
    output dp
);

    // Clock Generation
    wire clk;
    wire digsel;
    wire qsec;

    qsec_clks slowit (
        .clkin(clkin),
        .greset(btnD),
        .clk(clk),
        .digsel(digsel),
        .qsec(qsec)
    );

    // LFSR
    wire [7:0] lfsr_out;

    lfsr random_gen (
        .clk(clk),
        .reset(btnD),
        .Lfsr(lfsr_out)
    );

    // Target Register
    wire [3:0] target;
    wire load_target;

    FDRE #(.INIT(1'b0)) target_ff0 (.C(clk), .R(1'b0), .CE(load_target), .D(lfsr_out[0]), .Q(target[0]));
    FDRE #(.INIT(1'b0)) target_ff1 (.C(clk), .R(1'b0), .CE(load_target), .D(lfsr_out[1]), .Q(target[1]));
    FDRE #(.INIT(1'b0)) target_ff2 (.C(clk), .R(1'b0), .CE(load_target), .D(lfsr_out[2]), .Q(target[2]));
    FDRE #(.INIT(1'b0)) target_ff3 (.C(clk), .R(1'b0), .CE(load_target), .D(lfsr_out[3]), .Q(target[3]));

    // Time Counter
    wire [5:0] time_count;
    wire reset_timer;

    time_counter timer (
        .clk(clk),
        .inc(qsec),
        .reset(reset_timer),
        .Count(time_count)
    );

    // Timing Signals
    wire [5:0] two_temp;
    wire two_secs;
    wire [5:0] four_temp;
    wire four_secs;

    assign two_temp  = time_count ^ 6'b001000;
    assign two_secs  = &(~two_temp);

    assign four_temp = time_count ^ 6'b010000;
    assign four_secs = &(~four_temp);

    // Match Logic
    wire [5:0] target_qsec;
    wire match;

    assign target_qsec = {target, 2'b00};  //quarter second
    assign match = &(time_count[5:1] ~^ target_qsec[5:1]);  //gives .25 window

    // Timeout Logic
    wire [5:0] timeout_threshold;
    wire c2, c3, c4, c5;

    assign timeout_threshold[0] = target_qsec[0];
    assign timeout_threshold[1] = ~target_qsec[1];
    assign c2 = target_qsec[1];
    assign timeout_threshold[2] = target_qsec[2] ^ c2;
    assign c3 = target_qsec[2] & c2;
    assign timeout_threshold[3] = target_qsec[3] ^ c3;
    assign c4 = target_qsec[3] & c3;
    assign timeout_threshold[4] = target_qsec[4] ^ c4;
    assign c5 = target_qsec[4] & c4;
    assign timeout_threshold[5] = target_qsec[5] ^ c5;

    wire [5:0] eq_t;
    wire timeout;

    assign eq_t = ~(time_count ^ timeout_threshold);
    assign timeout =
        ( time_count[5] & ~timeout_threshold[5]) |
        ( eq_t[5] &  time_count[4] & ~timeout_threshold[4]) |
        ( &eq_t[5:4] &  time_count[3] & ~timeout_threshold[3]) |
        ( &eq_t[5:3] &  time_count[2] & ~timeout_threshold[2]) |
        ( &eq_t[5:2] &  time_count[1] & ~timeout_threshold[1]) |
        ( &eq_t[5:1] &  time_count[0] & ~timeout_threshold[0]) |
        ( &eq_t[5:0] );

    // LED Shifters
    wire rincr, lincr, rdecr, ldecr;
    wire [5:0] left_leds;
    wire [5:0] right_leds;

    led_shifter left_score (
        .clk(clk),
        .inp(1'b1),
        .shl(ldecr),
        .shr(lincr),
        .reset(btnD),
        .Leds(left_leds)
    );

    led_shifter right_score (
        .clk(clk),
        .inp(1'b1),
        .shl(rdecr),
        .shr(rincr),
        .reset(btnD),
        .Leds(right_leds)
    );

    // Gameover Detection
    wire left_six  = &left_leds;
    wire left_zero = ~(|left_leds);
    wire right_six = &right_leds;
    wire right_zero = ~(|right_leds);

    wire both_zero = left_zero & right_zero;
    wire over = left_six | right_six | (left_zero & ~both_zero) | (right_zero & ~both_zero);

    // FSM
    wire show_target, good, lose, flash, lflash, rflash, gameover;
    wire [7:0] cur_state;

    fsm state_machine (
        .clk(clk),
        .go(btnC),
        .left(btnL),
        .right(btnR),
        .four_sec(four_secs),
        .two_sec(two_secs),
        .match(match),
        .timeout(timeout),
        .over(over),
        .show_target(show_target),
        .load_target(load_target),
        .reset_timer(reset_timer),
        .rincr(rincr),
        .lincr(lincr),
        .rdecr(rdecr),
        .ldecr(ldecr),
        .good(good),
        .lose(lose),
        .flash(flash),
        .lflash(lflash),
        .rflash(rflash),
        .gameover(gameover),
        .states(cur_state)
    );

    // LED Outputs
    wire flash_beat = time_count[2];

    assign led[15]  = lflash ? (left_leds[5] & flash_beat) : left_leds[5];
    assign led[14]  = lflash ? (left_leds[4] & flash_beat) : left_leds[4];
    assign led[13]  = lflash ? (left_leds[3] & flash_beat) : left_leds[3];
    assign led[12]  = lflash ? (left_leds[2] & flash_beat) : left_leds[2];
    assign led[11]  = lflash ? (left_leds[1] & flash_beat) : left_leds[1];
    assign led[10]  = lflash ? (left_leds[0] & flash_beat) : left_leds[0];
    assign led[9:6] = 4'b0000;
    assign led[5]   = rflash ? (right_leds[0] & flash_beat) : right_leds[0];
    assign led[4]   = rflash ? (right_leds[1] & flash_beat) : right_leds[1];
    assign led[3]   = rflash ? (right_leds[2] & flash_beat) : right_leds[2];
    assign led[2]   = rflash ? (right_leds[3] & flash_beat) : right_leds[3];
    assign led[1]   = rflash ? (right_leds[4] & flash_beat) : right_leds[4];
    assign led[0]   = rflash ? (right_leds[5] & flash_beat) : right_leds[5];

    // Display Logic
    wire cheat;
    wire [3:0] elapsed_secs;
    wire [15:0] target_display;
    wire [15:0] time_display;
    wire [15:0] win_display;
    wire [15:0] lose_display;
    wire [15:0] display_data;

    assign cheat        = cur_state[2] & sw[15];
    assign elapsed_secs = time_count[5:2];

    assign target_display = {target, 12'h000} & {16{show_target}};
    assign time_display   = {elapsed_secs, 12'h000} & {16{cheat}};
    assign win_display    = 16'h900D & {16{good}};
    assign lose_display   = 16'h105E & {16{lose}};

    assign display_data = target_display | time_display | win_display | lose_display;

    // Ring Counter
    wire [3:0] ring_out;

    ringCounter display_mux (
        .clk(clk),
        .advance(digsel),
        .reset(1'b0),
        .ring_out(ring_out)
    );

    // Selector & Hex Decoder
    wire [3:0] selected_digit;
    wire [6:0] seg_decoded;  // add this intermediate wire

    selector digit_select (
        .ring_out(ring_out),
        .sel_in(display_data),
        .sel_out(selected_digit)
    );

    hex7seg decoder (
        .sel_out(selected_digit),
        .seg_in(seg_decoded)  // decode into intermediate wire
    );

    assign seg = gameover ? 7'b1111111 : seg_decoded;

    // Anode Control
    wire enable_flash;
    wire [3:0] anodes;

    assign enable_flash = flash & flash_beat;

    assign anodes = gameover      ? 4'b1111 :   //blank dec
                    (show_target | cheat) ? 4'b1000 :  //left cheat
                    (good | lose) ? 4'b1111 :  //mess
                    4'b0000; //blank idle wait

    assign an = enable_flash ? 4'b1111 : ~(ring_out & anodes);

    // Decimal Point
    assign dp = ~gameover;

endmodule