`timescale 1ns / 1ps
// States (one-hot):
//   S0  [0]  IDLE          - waiting for go
//   S1  [1]  SHOW          - display target briefly
//   S2  [2]  WAIT          - counting, awaiting press
//   S3  [3]  WINDOW        - good press, await timeout
//   S4  [4]  GOOD_FLASH    - flash 900d for 4s
//   S5  [5]  LOSE_FLASH    - flash 105E for 4s
//   S6  [6]  TIMEOUT_FLASH - both missed, flash 105E
//   S7  [7]  GOOD_HOLD     - hold 900d until go
//   S8  [8]  LOSE_HOLD     - hold 105E until go
//   S9  [9]  GAMEOVER      - game over, show dp

module fsm(
    input clk,
    input go,
    input left,
    input right,
    input four_sec,
    input two_sec,
    input match,
    input timeout,
    input over,

    output show_target,
    output load_target,
    output reset_timer,
    output rincr,
    output lincr,
    output rdecr,
    output ldecr,
    output good,
    output lose,
    output flash,
    output lflash,
    output rflash,
    output gameover,
    output [9:0] states
);

    wire [9:0] curState;
    wire [9:0] nextState;

    wire left_pressed_q, right_pressed_q;
    wire left_match_q,   right_match_q;

    wire left_press_event  = (curState[2] | curState[3]) & left  & ~left_pressed_q; 
    wire right_press_event = (curState[2] | curState[3]) & right & ~right_pressed_q;
    
    wire left_pressed_d  = (left_press_event  | left_pressed_q)  & ~(curState[0] | curState[1]);
    wire right_pressed_d = (right_press_event | right_pressed_q) & ~(curState[0] | curState[1]);
    wire left_match_d    = ((left_press_event  & match) | (left_match_q  & ~left_press_event))  & ~(curState[0] | curState[1]);
    wire right_match_d   = ((right_press_event & match) | (right_match_q & ~right_press_event)) & ~(curState[0] | curState[1]);

    FDRE #(.INIT(1'b0)) lp_ff (.C(clk), .R(1'b0), .CE(1'b1), .D(left_pressed_d),  .Q(left_pressed_q));
    FDRE #(.INIT(1'b0)) rp_ff (.C(clk), .R(1'b0), .CE(1'b1), .D(right_pressed_d), .Q(right_pressed_q));
    FDRE #(.INIT(1'b0)) lm_ff (.C(clk), .R(1'b0), .CE(1'b1), .D(left_match_d),    .Q(left_match_q));
    FDRE #(.INIT(1'b0)) rm_ff (.C(clk), .R(1'b0), .CE(1'b1), .D(right_match_d),   .Q(right_match_q));

    FDRE #(.INIT(1'b1)) Q0_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[0]), .Q(curState[0]));
    FDRE #(.INIT(1'b0)) Q1_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[1]), .Q(curState[1]));
    FDRE #(.INIT(1'b0)) Q2_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[2]), .Q(curState[2]));
    FDRE #(.INIT(1'b0)) Q3_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[3]), .Q(curState[3]));
    FDRE #(.INIT(1'b0)) Q4_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[4]), .Q(curState[4]));
    FDRE #(.INIT(1'b0)) Q5_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[5]), .Q(curState[5]));
    FDRE #(.INIT(1'b0)) Q6_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[6]), .Q(curState[6]));
    FDRE #(.INIT(1'b0)) Q7_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[7]), .Q(curState[7]));
    FDRE #(.INIT(1'b0)) Q8_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[8]), .Q(curState[8]));
    FDRE #(.INIT(1'b0)) Q9_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[9]), .Q(curState[9]));

    assign nextState[0] = (curState[0] & ~go)
                        | (curState[7] & ~go & ~over)
                        | (curState[8] & ~go & ~over);

    assign nextState[1] = ((curState[0] | (curState[7] & ~over) | (curState[8] & ~over)) & go)
                        | (curState[1] & ~two_sec);

    assign nextState[2] = (curState[1] & two_sec)
                        | (curState[2] & ~((left | right) & ~match & ~timeout)
                                       & ~((left | right) & match)
                                       & ~timeout);

    assign nextState[3] = (curState[2] & (left | right) & match)
                        | (curState[3] & ~timeout
                                       & ~((left & ~left_pressed_q | right & ~right_pressed_q) & ~match & ~timeout));

    assign nextState[4] = (curState[3] & timeout)
                        | (curState[2] & timeout & (left_match_q | right_match_q))
                        | (curState[4] & ~four_sec);

    assign nextState[5] = (curState[2] & (left | right) & ~match & ~timeout)
                        | (curState[3] & (left & ~left_pressed_q | right & ~right_pressed_q) & ~match & ~timeout)
                        | (curState[2] & timeout & ~(left_match_q | right_match_q) & (left_pressed_q | right_pressed_q))
                        | (curState[5] & ~four_sec);

    assign nextState[6] = (curState[2] & timeout & ~left_pressed_q & ~right_pressed_q)
                        | (curState[6] & ~four_sec);

    assign nextState[7] = (curState[4] & four_sec & ~over)
                        | (curState[7] & ~go & ~over);

    assign nextState[8] = ((curState[5] | curState[6]) & four_sec & ~over)
                        | (curState[8] & ~go & ~over);

    assign nextState[9] = ((curState[7] | curState[8]) & over)
                        | curState[9];

    assign load_target = (curState[0] | curState[7] | curState[8]) & go & ~over;

    assign reset_timer = ((curState[0] | curState[7] | curState[8]) & go & ~over)
                       | (curState[1] & two_sec)
                       | (curState[3] & timeout)
                       | (curState[2] & timeout & (left_match_q | right_match_q))
                       | (curState[2] & (left | right) & ~match & ~timeout)
                       | (curState[3] & (left & ~left_pressed_q | right & ~right_pressed_q) & ~match & ~timeout)
                       | (curState[2] & timeout & ~(left_match_q | right_match_q) & (left_pressed_q | right_pressed_q))
                       | (curState[2] & timeout & ~left_pressed_q & ~right_pressed_q);

    assign show_target = curState[1];

    assign good  = curState[4] | curState[7];
    assign lose  = curState[5] | curState[6] | curState[8];
    assign flash = curState[4] | curState[5] | curState[6];

    assign lflash = flash & left_pressed_q;
    assign rflash = flash & right_pressed_q;

    // Only increment a player if they matched AND the other did NOT match (spec 6b)
    assign lincr = curState[4] & four_sec & left_match_q  & ~right_match_q & ~over;
    assign rincr = curState[4] & four_sec & right_match_q & ~left_match_q  & ~over;

    assign ldecr = ((curState[5] & four_sec & left_pressed_q  & ~left_match_q) | (curState[6] & four_sec)) & ~over;
    assign rdecr = ((curState[5] & four_sec & right_pressed_q & ~right_match_q) | (curState[6] & four_sec)) & ~over;

    assign gameover = curState[9];
    assign states   = curState;

endmodule