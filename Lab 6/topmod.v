module topmod (
    input         clkin,
    input         btnU,    // global reset
    input         btnC,    // start game (unused at Milestone 1)
    input         btnL,    // move player left
    input         btnR,    // move player right
    input  [15:0] sw,
    output        Hsync,
    output        Vsync,
    output [3:0]  vgaRed,
    output [3:0]  vgaGreen,
    output [3:0]  vgaBlue,
    output [3:0]  an,
    output [6:0]  seg,
    output [15:0] led
);

    // =========================================================
    // CLOCK
    // labVGA_clks generates clk (25MHz) and digsel.
    // btnU is wired to greset inside labVGA_clks.
    // digsel advances the RingCounter for 7-seg - do NOT use as clock.
    // =========================================================
    wire clk, digsel;
    labVGA_clks not_so_slow (
        .clkin (clkin),
        .greset(btnU),
        .clk   (clk),
        .digsel(digsel)
    );

    // =========================================================
    // PIXEL ADDRESS COUNTERS
    // hcount: 0-799 (columns), vcount: 0-524 (rows)
    // Traverses the full 800x525 VGA grid one pixel per clock.
    // =========================================================
    wire [9:0] hcount, vcount;

    // Adding two 10-bit values yields 11 bits. Since we reset
    // before reaching 800 or 525, the 11th bit is always 0 so
    // truncating back to 10 bits is safe.
    wire [9:0] hcount_inc = hcount + 10'd1;
    wire [9:0] vcount_inc = vcount + 10'd1;

    // h_end: last column of every row (799)
    // v_end: last row of every frame (524)
    wire h_end = (hcount == 10'd799);
    wire v_end = (vcount == 10'd524);

    // hcount resets to 0 at end of each row, otherwise counts up every clock.
    wire [9:0] hcount_d = h_end ? 10'd0 : hcount_inc;

    // vcount only changes at end of each row.
    // Resets to 0 at end of frame, otherwise increments to next row.
    wire [9:0] vcount_d = (h_end & v_end) ? 10'd0      :
                           h_end           ? vcount_inc :
                                             vcount;

    // hcount FDREs - synchronously reset to 0 on greset
    FDRE #(.INIT(1'b0)) hc9 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[9]),.Q(hcount[9]));
    FDRE #(.INIT(1'b0)) hc8 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[8]),.Q(hcount[8]));
    FDRE #(.INIT(1'b0)) hc7 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[7]),.Q(hcount[7]));
    FDRE #(.INIT(1'b0)) hc6 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[6]),.Q(hcount[6]));
    FDRE #(.INIT(1'b0)) hc5 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[5]),.Q(hcount[5]));
    FDRE #(.INIT(1'b0)) hc4 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[4]),.Q(hcount[4]));
    FDRE #(.INIT(1'b0)) hc3 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[3]),.Q(hcount[3]));
    FDRE #(.INIT(1'b0)) hc2 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[2]),.Q(hcount[2]));
    FDRE #(.INIT(1'b0)) hc1 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[1]),.Q(hcount[1]));
    FDRE #(.INIT(1'b0)) hc0 (.C(clk),.CE(1'b1),.R(btnU),.D(hcount_d[0]),.Q(hcount[0]));

    // vcount FDREs - same structure as hcount
    FDRE #(.INIT(1'b0)) vc9 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[9]),.Q(vcount[9]));
    FDRE #(.INIT(1'b0)) vc8 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[8]),.Q(vcount[8]));
    FDRE #(.INIT(1'b0)) vc7 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[7]),.Q(vcount[7]));
    FDRE #(.INIT(1'b0)) vc6 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[6]),.Q(vcount[6]));
    FDRE #(.INIT(1'b0)) vc5 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[5]),.Q(vcount[5]));
    FDRE #(.INIT(1'b0)) vc4 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[4]),.Q(vcount[4]));
    FDRE #(.INIT(1'b0)) vc3 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[3]),.Q(vcount[3]));
    FDRE #(.INIT(1'b0)) vc2 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[2]),.Q(vcount[2]));
    FDRE #(.INIT(1'b0)) vc1 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[1]),.Q(vcount[1]));
    FDRE #(.INIT(1'b0)) vc0 (.C(clk),.CE(1'b1),.R(btnU),.D(vcount_d[0]),.Q(vcount[0]));

    // active: high only when inside the 640x480 visible area.
    // RGB must be 0 outside active region.
    wire active = (hcount < 10'd640) & (vcount < 10'd480);

    // frame: 1-cycle pulse per frame, placed just outside active region.
    // All per-frame game logic (movement, counters) must gate on this signal.
    // Placing it outside active ensures sprites never update mid-draw.
    wire frame = (hcount == 10'd640) & (vcount == 10'd480);

    // =========================================================
    // SYNC SIGNALS
    // Hsync: low for hcount 656-751 (96 pixels per row)
    // Vsync: low for vcount 490-491 (2 rows per frame)
    // Both are registered to match the RGB pipeline depth.
    // greset handled in D logic (not R pin) so sync stays high
    // during reset and does not confuse the monitor.
    // =========================================================
    wire hsync_d = btnU ? 1'b1 : ~((hcount >= 10'd656) & (hcount < 10'd752));
    wire vsync_d = btnU ? 1'b1 : ~((vcount >= 10'd490) & (vcount < 10'd492));

    // INIT=1 because sync signals are normally HIGH
    FDRE #(.INIT(1'b1)) hsync_reg (.C(clk),.CE(1'b1),.R(1'b0),.D(hsync_d),.Q(Hsync));
    FDRE #(.INIT(1'b1)) vsync_reg (.C(clk),.CE(1'b1),.R(1'b0),.D(vsync_d),.Q(Vsync));

    // =========================================================
    // PLAYER CONTROLLER
    // playerX tracks the left edge of the 10x10 yellow player square.
    // Moves 1px per frame on btnL / btnR.
    // Clamped to hcount 8 (left border) to 622 (640 - 8 - 10).
    // greset handled in D logic so player resets to center (315) not 0.
    // =========================================================
    wire [9:0] playerX;

    wire can_move_left  = (playerX > 10'd8);
    wire can_move_right = (playerX < 10'd622);

    // Only move on frame pulse so speed is exactly 1px per frame.
    // game_active tied to 1'b1 for Milestone 1 - replace with
    // game_fsm output wire in later milestones.
    wire move_left  = frame & 1'b1 & btnL & can_move_left;
    wire move_right = frame & 1'b1 & btnR & can_move_right;

    wire [9:0] playerX_d = btnU        ? 10'd315         :
                           move_left   ? playerX - 10'd1 :
                           move_right  ? playerX + 10'd1 :
                                         playerX;

    // R pin tied LOW because target reset value is 315, not 0.
    // Reset to 315 is handled via the btnU condition in playerX_d above.
    FDRE #(.INIT(1'b0)) px9 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[9]),.Q(playerX[9]));
    FDRE #(.INIT(1'b0)) px8 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[8]),.Q(playerX[8]));
    FDRE #(.INIT(1'b0)) px7 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[7]),.Q(playerX[7]));
    FDRE #(.INIT(1'b0)) px6 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[6]),.Q(playerX[6]));
    FDRE #(.INIT(1'b0)) px5 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[5]),.Q(playerX[5]));
    FDRE #(.INIT(1'b0)) px4 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[4]),.Q(playerX[4]));
    FDRE #(.INIT(1'b0)) px3 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[3]),.Q(playerX[3]));
    FDRE #(.INIT(1'b0)) px2 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[2]),.Q(playerX[2]));
    FDRE #(.INIT(1'b0)) px1 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[1]),.Q(playerX[1]));
    FDRE #(.INIT(1'b0)) px0 (.C(clk),.CE(1'b1),.R(1'b0),.D(playerX_d[0]),.Q(playerX[0]));

    // =========================================================
    // PIXEL RENDERER
    // Determines the color of each pixel based on its position.
    // Priority (highest first):
    //   1. Outside active region -> black (all 0)
    //   2. Border (8px all edges) -> red
    //   3. Player (10x10 yellow square) -> yellow
    //   4. Ground (20px tall platform) -> green
    //   5. Background -> black
    // RGB outputs are registered (1 FDRE stage) to match the
    // pipeline depth of the registered Hsync/Vsync signals.
    // =========================================================

    // Border: 8px strip on all four edges of the 640x480 screen
    wire is_border = (hcount < 10'd8)   | (hcount >= 10'd632) |
                     (vcount < 10'd8)   | (vcount >= 10'd472);

    // Ground: 20px tall green platform just above the bottom border
    // spans vcount 452-471, inside left and right borders
    wire is_ground = (vcount >= 10'd452) & (vcount < 10'd472) &
                     (hcount >= 10'd8)   & (hcount < 10'd632);

    // Player: 10x10 yellow square sitting on top of the ground
    // top edge = ground top (452) - player height (10) = 442
    wire [9:0] playerX_right = playerX + 10'd10;
    wire is_player = (vcount >= 10'd442)    & (vcount < 10'd452) &
                     (hcount >= playerX)    & (hcount < playerX_right);

    // Red:   full for border and player (yellow = red + green), 0 elsewhere
    wire [3:0] red_d   = ~active    ? 4'b0000 :
                          is_border ? 4'b1111 :
                          is_player ? 4'b1111 :
                                      4'b0000;

    // Green: full for player (yellow) and ground, 0 elsewhere
    wire [3:0] green_d = ~active    ? 4'b0000 :
                          is_border ? 4'b0000 :
                          is_player ? 4'b1111 :
                          is_ground ? 4'b1111 :
                                      4'b0000;

    // Blue:  nothing blue at Milestone 1
    wire [3:0] blue_d  = 4'b0000;

    // RGB output FDREs - registered to align with Hsync/Vsync pipeline
    FDRE #(.INIT(1'b0)) r3 (.C(clk),.CE(1'b1),.R(1'b0),.D(red_d[3]),.Q(vgaRed[3]));
    FDRE #(.INIT(1'b0)) r2 (.C(clk),.CE(1'b1),.R(1'b0),.D(red_d[2]),.Q(vgaRed[2]));
    FDRE #(.INIT(1'b0)) r1 (.C(clk),.CE(1'b1),.R(1'b0),.D(red_d[1]),.Q(vgaRed[1]));
    FDRE #(.INIT(1'b0)) r0 (.C(clk),.CE(1'b1),.R(1'b0),.D(red_d[0]),.Q(vgaRed[0]));

    FDRE #(.INIT(1'b0)) g3 (.C(clk),.CE(1'b1),.R(1'b0),.D(green_d[3]),.Q(vgaGreen[3]));
    FDRE #(.INIT(1'b0)) g2 (.C(clk),.CE(1'b1),.R(1'b0),.D(green_d[2]),.Q(vgaGreen[2]));
    FDRE #(.INIT(1'b0)) g1 (.C(clk),.CE(1'b1),.R(1'b0),.D(green_d[1]),.Q(vgaGreen[1]));
    FDRE #(.INIT(1'b0)) g0 (.C(clk),.CE(1'b1),.R(1'b0),.D(green_d[0]),.Q(vgaGreen[0]));

    FDRE #(.INIT(1'b0)) b3 (.C(clk),.CE(1'b1),.R(1'b0),.D(blue_d[3]),.Q(vgaBlue[3]));
    FDRE #(.INIT(1'b0)) b2 (.C(clk),.CE(1'b1),.R(1'b0),.D(blue_d[2]),.Q(vgaBlue[2]));
    FDRE #(.INIT(1'b0)) b1 (.C(clk),.CE(1'b1),.R(1'b0),.D(blue_d[1]),.Q(vgaBlue[1]));
    FDRE #(.INIT(1'b0)) b0 (.C(clk),.CE(1'b1),.R(1'b0),.D(blue_d[0]),.Q(vgaBlue[0]));

    // =========================================================
    // UNUSED OUTPUTS (tied off for Milestone 1)
    // an is active-low:   1111 = all 4 displays off
    // seg is active-low:  1111111 = all segments off
    // led: 0 = all LEDs off
    // =========================================================
    assign an  = 4'b1111;
    assign seg = 7'b1111111;
    assign led = 16'b0;

endmodule