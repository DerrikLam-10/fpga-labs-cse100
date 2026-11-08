// ============================================================
// game_fsm.v
// CSE 100/L Lab 6 - Newton Game
// Top-level game state machine
//
// States:
//   IDLE      (2'b00) - game paused, waiting for btnC
//   PLAYING   (2'b01) - normal gameplay
//   GAME_OVER (2'b10) - lives == 0, waiting for reset
//
// Mealy machine: score_inc and lives_dec depend on BOTH
// current state AND caught/missed inputs simultaneously.
//
// Constraints: assign statements + FDREs only.
//              No always blocks, no generate, no genvar,
//              no module parameters.
// ============================================================

module game_fsm (
    input  clk,        // 25MHz system clock
    input  greset,     // global reset (btnU)
    input  btnC,       // start game
    input  lives_zero, // high when lives register == 0
    input  caught,     // pulse: apple caught this frame
    input  missed,     // pulse: apple missed this frame
    output game_active,// high only in PLAYING
    output game_over,  // high only in GAME_OVER
    output dp_on,      // decimal points on (GAME_OVER only)
    output score_inc,  // Mealy: increment score
    output lives_dec   // Mealy: decrement lives
);

    // ??? State registers (2 FDREs) ?????????????????????????????
    wire [1:0] state;
    wire [1:0] ns;

    FDRE #(.INIT(1'b0)) state_reg1 (
        .C(clk), .CE(1'b1), .R(greset), .D(ns[1]), .Q(state[1])
    );
    FDRE #(.INIT(1'b0)) state_reg0 (
        .C(clk), .CE(1'b1), .R(greset), .D(ns[0]), .Q(state[0])
    );

    // ??? Current-state decode ??????????????????????????????????
    wire in_idle     = ~state[1] & ~state[0]; // 2'b00
    wire in_playing  = ~state[1] &  state[0]; // 2'b01
    wire in_gameover =  state[1] & ~state[0]; // 2'b10

    // ??? Next-state logic ??????????????????????????????????????
    //
    // ns[1]: go to / stay in GAME_OVER (state = 2'b10)
    //   PLAYING -> GAME_OVER : in_playing & lives_zero
    //   GAME_OVER stays      : in_gameover (greset R-pin handles reset to IDLE)
    //
    assign ns[1] = (in_playing  & lives_zero)
                 |  in_gameover;

    // ns[0]: go to / stay in PLAYING (state = 2'b01)
    //   IDLE    -> PLAYING   : in_idle & btnC
    //   PLAYING stays        : in_playing & ~lives_zero
    //
    assign ns[0] = (in_idle    &  btnC      )
                 | (in_playing & ~lives_zero);

    // ??? Moore outputs (depend only on state) ??????????????????
    assign game_active = in_playing;
    assign game_over   = in_gameover;
    assign dp_on       = in_gameover;

    // ??? Mealy outputs (depend on state AND inputs) ?????????????
    // These labels go on the ARROWS in your state diagram,
    // not inside the state bubbles.
    assign score_inc = in_playing & caught;
    assign lives_dec = in_playing & missed;

endmodule