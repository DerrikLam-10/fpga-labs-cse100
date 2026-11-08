`timescale 1ns / 1ps

module fsm(
    input clk,
    input go,
    input stop,
    input four_secs,
    input two_secs,
    input match,
    input timeout,
    output load_target,
    output reset_timer,
    output load_numbers,
    output shr,
    output shl,
    output good,
    output lose,
    output display_state,
    output flash,
    output [4:0] states
);

wire [4:0] curState;
wire [4:0] nextState;

FDRE #(.INIT(1'b1)) Q0_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[0]), .Q(curState[0]));
FDRE #(.INIT(1'b0)) Q1_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[1]), .Q(curState[1]));
FDRE #(.INIT(1'b0)) Q2_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[2]), .Q(curState[2]));
FDRE #(.INIT(1'b0)) Q3_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[3]), .Q(curState[3]));
FDRE #(.INIT(1'b0)) Q4_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(nextState[4]), .Q(curState[4]));

assign nextState[0] = (curState[0] & ~go) | (curState[3] & four_secs) | (curState[4] & four_secs);
assign nextState[1] = (curState[0] & go) | (curState[1] & ~two_secs);
assign nextState[2] = (curState[2] & (~timeout & ~stop)) | (curState[1] & two_secs);
assign nextState[3] = (curState[2] & (match & stop)) | (curState[3] & ~four_secs);
assign nextState[4] = (curState[2] & (timeout | (stop & ~match))) | (curState[4] & ~four_secs);

assign load_target = (curState[0] & go);
assign reset_timer = (curState[0] & go) | (go & (match & stop)) | (go & (timeout | (stop & ~match)));
assign load_numbers = (curState[1] & ~two_secs);
assign shl = (curState[3] & four_secs);
assign shr = (curState[4] & four_secs);
assign good = (curState[3] & ~four_secs);
assign lose = (curState[4] & ~four_secs);
assign flash = (curState[3] & ~four_secs) | (curState[4] & ~four_secs);
assign display_state = curState;
assign states = curState;

endmodule
