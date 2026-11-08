module PixelRenderer (
    input        clk,
    input  [9:0] hcount,      // current pixel column (0-639 in active region)
    input  [9:0] vcount,      // current pixel row (0-479 in active region)
    input        active,      // high when the current pixel is on screen
    input  [9:0] playerX,     // left edge of the player square
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue
);

    // Check if the current pixel belongs to each game object.
    // These are all combinational - they just look at hcount/vcount
    // and ask "is the beam currently drawing inside this object?"

    // Border: any pixel within 8 columns of the left/right edge
    // or within 8 rows of the top/bottom edge.
    wire is_border = (hcount < 10'd8)    | (hcount >= 10'd632) |
                     (vcount < 10'd8)    | (vcount >= 10'd472);

    // Ground platform: a 20px tall green strip sitting just above
    // the bottom border, spanning the full width between the borders.
    wire is_ground = (vcount >= 10'd452) & (vcount < 10'd472) &
                     (hcount >= 10'd8)   & (hcount < 10'd632);

    // Player: a 10x10 yellow square that sits on top of the ground.
    // Its top edge is at row 442 (ground top 452 minus player height 10).
    // playerX_right is pre-calculated as a wire to avoid accidentally
    // creating an 11-bit signal during the comparison.
    wire [9:0] playerX_right = playerX + 10'd10;
    wire is_player = (vcount >= 10'd442) & (vcount < 10'd452) &
                     (hcount >= playerX) & (hcount < playerX_right);

    // Decide the color of each channel for the current pixel.
    // Priority order matters: border is checked before player,
    // player is checked before ground, etc.
    // If the pixel is outside the active region, always output black
    // (the VGA spec requires RGB to be 0 outside the active area).

    // Red is ON for the border (red) and the player (yellow = red + green).
    wire [3:0] red_d   = ~active    ? 4'b0000 :
                          is_border ? 4'b1111 :
                          is_player ? 4'b1111 :
                                      4'b0000;

    // Green is ON for the player (yellow = red + green) and the ground.
    wire [3:0] green_d = ~active    ? 4'b0000 :
                          is_border ? 4'b0000 :
                          is_player ? 4'b1111 :
                          is_ground ? 4'b1111 :
                                      4'b0000;

    // Nothing is blue at Milestone 1.
    wire [3:0] blue_d  = 4'b0000;

    // Register the RGB outputs so they are one clock cycle delayed,
    // matching the pipeline depth of SyncGen. This keeps all signals
    // aligned when they arrive at the monitor.
    // R is tied off - going black outside the active region is already
    // handled above by the ~active check in the color logic.
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

endmodule