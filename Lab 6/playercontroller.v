module PlayerController (
    input        clk,
    input        greset,      // btnU - resets player back to center of screen
    input        frame,       // 1-cycle pulse once per frame - used to limit movement to 1px/frame
    input        game_active, // game must be running for player to move (tie to 1'b1 for Milestone 1)
    input        btnL,        // move left button
    input        btnR,        // move right button
    output [9:0] playerX      // X position of the left edge of the player square
);

    wire [9:0] playerX_d;

    // Check if the player is allowed to move in each direction.
    // The screen has an 8px red border on each side so the player
    // must stay between column 8 (left border) and column 622
    // (640 screen width - 8 right border - 10 player width).
    wire can_move_left  = (playerX > 10'd8);
    wire can_move_right = (playerX < 10'd622);

    // Only actually move if: the frame pulse is happening, the game
    // is running, the button is pressed, AND movement is allowed.
    // Gating on frame ensures the player moves exactly 1 pixel per
    // frame (60 times per second) rather than every clock cycle.
    wire move_left  = frame & game_active & btnL & can_move_left;
    wire move_right = frame & game_active & btnR & can_move_right;

    // Every clock cycle, decide what the next X position should be:
    //   - greset pressed  -> jump to center of screen (column 315)
    //   - move_left true  -> subtract 1
    //   - move_right true -> add 1
    //   - otherwise       -> hold current position
    // Reset is done here in the D input rather than the FDRE R pin
    // because the R pin always resets to 0, but we want 315 (center).
    assign playerX_d = greset     ? 10'd315         :
                       move_left  ? playerX - 10'd1 :
                       move_right ? playerX + 10'd1 :
                                    playerX;

    // playerX is a 10-bit value so it needs 10 flip-flops, one per bit.
    // R is tied to 0 because reset is already handled in the D logic above.
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

endmodule