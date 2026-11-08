// ============================================================
// apple_fsm.v
// CSE 100/L Lab 6 - Newton Game
// Per-apple state machine  (instantiate 8 times)
//
// States:
//   RIPENING (2'b00) - apple turns green->red over 240 frames
//   RIPE     (2'b01) - fully red, waiting to be selected
//   FALLING  (2'b10) - dropping 1px per frame
//   FLASHING (2'b11) - flashing 2s (120 frames) after catch/miss
//
// Mealy machine: caught/missed depend on BOTH being in FALLING
// AND the collision/ground conditions simultaneously.
//
// Spawn position and ground Y are passed as regular input ports.
// Tie them to 10-bit constants at instantiation.
//
// Constraints: assign statements + FDREs only.
//              No always blocks, no generate, no genvar,
//              no module parameters.
// ============================================================

module apple_fsm (
    input        clk,        // 25MHz system clock
    input        greset,     // global reset (btnU)
    input        frame,      // 1-cycle pulse once per frame (outside active region)
    input        game_active,// from game_fsm
    input        selected,   // from apple selector: this apple chosen to fall
    input [9:0]  playerX,    // player left-edge X position
    input [9:0]  spawnX,     // this apple's fixed horizontal spawn (tie at instantiation)
    input [9:0]  spawnY,     // this apple's fixed vertical spawn   (tie at instantiation)
    input [9:0]  ground_y,   // top of ground platform              (tie at instantiation)
    output [9:0] appleX,     // always equals spawnX
    output [9:0] appleY,     // current Y (changes while falling)
    output [7:0] ripe_cnt,   // 0-239: drives color in pixel renderer
    output       caught,     // Mealy: collision with player
    output       missed,     // Mealy: hit the ground
    output       visible,    // for flashing blink effect
    output [1:0] state       // expose for renderer color logic
);

    // ??? State registers (2 FDREs) ?????????????????????????????
    wire [1:0] ns;

    FDRE #(.INIT(1'b0)) state_reg1 (
        .C(clk), .CE(1'b1), .R(greset), .D(ns[1]), .Q(state[1])
    );
    FDRE #(.INIT(1'b0)) state_reg0 (
        .C(clk), .CE(1'b1), .R(greset), .D(ns[0]), .Q(state[0])
    );

    // ??? Current-state decode ??????????????????????????????????
    wire in_ripening = ~state[1] & ~state[0]; // 2'b00
    wire in_ripe     = ~state[1] &  state[0]; // 2'b01
    wire in_falling  =  state[1] & ~state[0]; // 2'b10
    wire in_flashing =  state[1] &  state[0]; // 2'b11

    // ??? ripe_cnt: 8-bit ripeness counter ??????????????????????
    // Counts 0->239 in RIPENING. Resets to 0 when FLASHING->RIPENING.
    // 8 FDREs, manually instantiated.

    wire [7:0] ripe_cnt_d;
    wire [7:0] ripe_cnt_inc = ripe_cnt + 8'b0000_0001; // truncated naturally
    wire       ripe_done    = (ripe_cnt == 8'd239);

    // Increment in RIPENING each frame (if not done).
    // Reset to 0 when flash period ends.
    // Hold otherwise.
    assign ripe_cnt_d[7] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[7] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[7];
    assign ripe_cnt_d[6] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[6] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[6];
    assign ripe_cnt_d[5] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[5] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[5];
    assign ripe_cnt_d[4] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[4] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[4];
    assign ripe_cnt_d[3] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[3] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[3];
    assign ripe_cnt_d[2] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[2] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[2];
    assign ripe_cnt_d[1] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[1] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[1];
    assign ripe_cnt_d[0] = in_ripening & frame & ~ripe_done ? ripe_cnt_inc[0] :
                           in_flashing & flash_done & frame  ? 1'b0            :
                                                               ripe_cnt[0];

    FDRE #(.INIT(1'b0)) ripe7 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[7]),.Q(ripe_cnt[7]));
    FDRE #(.INIT(1'b0)) ripe6 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[6]),.Q(ripe_cnt[6]));
    FDRE #(.INIT(1'b0)) ripe5 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[5]),.Q(ripe_cnt[5]));
    FDRE #(.INIT(1'b0)) ripe4 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[4]),.Q(ripe_cnt[4]));
    FDRE #(.INIT(1'b0)) ripe3 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[3]),.Q(ripe_cnt[3]));
    FDRE #(.INIT(1'b0)) ripe2 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[2]),.Q(ripe_cnt[2]));
    FDRE #(.INIT(1'b0)) ripe1 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[1]),.Q(ripe_cnt[1]));
    FDRE #(.INIT(1'b0)) ripe0 (.C(clk),.CE(1'b1),.R(greset),.D(ripe_cnt_d[0]),.Q(ripe_cnt[0]));

    // ??? flash_cnt: 7-bit flash counter ????????????????????????
    // Counts 0->119 in FLASHING. 7 FDREs.

    wire [6:0] flash_cnt;
    wire [6:0] flash_cnt_d;
    wire [6:0] flash_cnt_inc = flash_cnt + 7'b000_0001;
    wire       flash_done    = (flash_cnt == 7'd119);

    // Start counting when entering FLASHING (caught or missed).
    // Increment each frame. Reset when done.
    assign flash_cnt_d[6] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[6] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[6];
    assign flash_cnt_d[5] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[5] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[5];
    assign flash_cnt_d[4] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[4] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[4];
    assign flash_cnt_d[3] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[3] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[3];
    assign flash_cnt_d[2] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[2] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[2];
    assign flash_cnt_d[1] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[1] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[1];
    assign flash_cnt_d[0] = in_falling  & (caught | missed)      ? 1'b0             :
                            in_flashing & frame & ~flash_done     ? flash_cnt_inc[0] :
                            in_flashing & frame &  flash_done     ? 1'b0             :
                                                                    flash_cnt[0];

    FDRE #(.INIT(1'b0)) flash6 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[6]),.Q(flash_cnt[6]));
    FDRE #(.INIT(1'b0)) flash5 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[5]),.Q(flash_cnt[5]));
    FDRE #(.INIT(1'b0)) flash4 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[4]),.Q(flash_cnt[4]));
    FDRE #(.INIT(1'b0)) flash3 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[3]),.Q(flash_cnt[3]));
    FDRE #(.INIT(1'b0)) flash2 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[2]),.Q(flash_cnt[2]));
    FDRE #(.INIT(1'b0)) flash1 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[1]),.Q(flash_cnt[1]));
    FDRE #(.INIT(1'b0)) flash0 (.C(clk),.CE(1'b1),.R(greset),.D(flash_cnt_d[0]),.Q(flash_cnt[0]));

    // ??? appleY: 10-bit falling position register ??????????????
    // Initialized to spawnY. Increments 1px per frame in FALLING.
    // Resets to spawnY on catch or miss.
    // 10 FDREs.

    wire [9:0] appleY_reg;
    wire [9:0] appleY_d;
    wire [9:0] appleY_inc = appleY_reg + 10'b00_0000_0001;

    // Collision detection (combinational, used in FALLING only)
    // Apple is 10px wide, player is 10px wide.
    // X overlap: apple left <= player right AND apple right >= player left
    wire x_overlap = (spawnX        <= playerX + 10'd9)
                   & (spawnX + 10'd9 >= playerX       );
    // Apple bottom reaches ground
    wire at_ground = (appleY_reg + 10'd10 >= ground_y);

    // Mealy outputs: only meaningful (and only fire) in FALLING state
    assign caught = in_falling & x_overlap & at_ground;
    assign missed = in_falling & ~x_overlap & at_ground;

    assign appleY_d[9] = in_falling & (caught | missed) ? spawnY[9]     :
                         in_falling & frame              ? appleY_inc[9] :
                                                           appleY_reg[9];
    assign appleY_d[8] = in_falling & (caught | missed) ? spawnY[8]     :
                         in_falling & frame              ? appleY_inc[8] :
                                                           appleY_reg[8];
    assign appleY_d[7] = in_falling & (caught | missed) ? spawnY[7]     :
                         in_falling & frame              ? appleY_inc[7] :
                                                           appleY_reg[7];
    assign appleY_d[6] = in_falling & (caught | missed) ? spawnY[6]     :
                         in_falling & frame              ? appleY_inc[6] :
                                                           appleY_reg[6];
    assign appleY_d[5] = in_falling & (caught | missed) ? spawnY[5]     :
                         in_falling & frame              ? appleY_inc[5] :
                                                           appleY_reg[5];
    assign appleY_d[4] = in_falling & (caught | missed) ? spawnY[4]     :
                         in_falling & frame              ? appleY_inc[4] :
                                                           appleY_reg[4];
    assign appleY_d[3] = in_falling & (caught | missed) ? spawnY[3]     :
                         in_falling & frame              ? appleY_inc[3] :
                                                           appleY_reg[3];
    assign appleY_d[2] = in_falling & (caught | missed) ? spawnY[2]     :
                         in_falling & frame              ? appleY_inc[2] :
                                                           appleY_reg[2];
    assign appleY_d[1] = in_falling & (caught | missed) ? spawnY[1]     :
                         in_falling & frame              ? appleY_inc[1] :
                                                           appleY_reg[1];
    assign appleY_d[0] = in_falling & (caught | missed) ? spawnY[0]     :
                         in_falling & frame              ? appleY_inc[0] :
                                                           appleY_reg[0];

    FDRE #(.INIT(1'b0)) ay9 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[9]),.Q(appleY_reg[9]));
    FDRE #(.INIT(1'b0)) ay8 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[8]),.Q(appleY_reg[8]));
    FDRE #(.INIT(1'b0)) ay7 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[7]),.Q(appleY_reg[7]));
    FDRE #(.INIT(1'b0)) ay6 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[6]),.Q(appleY_reg[6]));
    FDRE #(.INIT(1'b0)) ay5 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[5]),.Q(appleY_reg[5]));
    FDRE #(.INIT(1'b0)) ay4 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[4]),.Q(appleY_reg[4]));
    FDRE #(.INIT(1'b0)) ay3 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[3]),.Q(appleY_reg[3]));
    FDRE #(.INIT(1'b0)) ay2 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[2]),.Q(appleY_reg[2]));
    FDRE #(.INIT(1'b0)) ay1 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[1]),.Q(appleY_reg[1]));
    FDRE #(.INIT(1'b0)) ay0 (.C(clk),.CE(1'b1),.R(greset),.D(appleY_d[0]),.Q(appleY_reg[0]));

    // ??? Next-state logic ??????????????????????????????????????
    //
    // ns[1]: go to / stay in FALLING(10) or FLASHING(11)
    //   RIPE     -> FALLING  : in_ripe & selected & game_active & frame
    //   FALLING stays        : in_falling & ~(caught | missed)
    //   FALLING  -> FLASHING : in_falling & (caught | missed)   [ns[1] stays 1]
    //   FLASHING stays       : in_flashing & ~(flash_done & frame)
    //
    assign ns[1] = (in_ripe     & selected & game_active & frame   )
                 | (in_falling  & ~(caught | missed)               )
                 | (in_falling  &  (caught | missed)               )
                 | (in_flashing & ~(flash_done & frame)            );

    // Simplify ns[1] (in_falling terms merge):
    // assign ns[1] = (in_ripe & selected & game_active & frame)
    //              |  in_falling
    //              | (in_flashing & ~(flash_done & frame));

    // ns[0]: go to / stay in RIPE(01) or FLASHING(11)
    //   RIPENING -> RIPE     : in_ripening & ripe_done & frame
    //   RIPE stays           : in_ripe & ~(selected & game_active & frame)
    //   FALLING  -> FLASHING : in_falling & (caught | missed)
    //   FLASHING stays       : in_flashing & ~(flash_done & frame)
    //
    assign ns[0] = (in_ripening &  ripe_done & frame                      )
                 | (in_ripe     & ~(selected & game_active & frame)        )
                 | (in_falling  &  (caught | missed)                       )
                 | (in_flashing & ~(flash_done & frame)                    );

    // ??? Outputs ???????????????????????????????????????????????
    assign appleX  = spawnX;
    assign appleY  = appleY_reg;

    // Blink: use flash_cnt[3] to toggle visibility ~every 8 frames
    assign visible = ~in_flashing | flash_cnt[3];

endmodule