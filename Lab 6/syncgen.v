module SyncGen (
    input        clk,
    input        greset,
    input  [9:0] hcount,  // current pixel column (0-799)
    input  [9:0] vcount,  // current pixel row (0-524)
    output       Hsync,
    output       Vsync
);

    // Hsync tells the monitor when a new row is starting.
    // It stays HIGH normally, and goes LOW for 96 pixels at the
    // end of each row (columns 656-751) to signal the row reset.
    // If the board is being reset, keep it HIGH so the monitor
    // doesn't get confused.
    wire hsync_d = greset ? 1'b1
                          : ~((hcount >= 10'd656) & (hcount < 10'd752));

    // Vsync tells the monitor when a new frame is starting.
    // It stays HIGH normally, and goes LOW for 2 full rows
    // (rows 490 and 491) at the end of every frame.
    // Same as Hsync - hold HIGH during reset.
    wire vsync_d = greset ? 1'b1
                          : ~((vcount >= 10'd490) & (vcount < 10'd492));

    // Register both signals so they are synced to the clock edge.
    // INIT=1 so both signals start HIGH on power-up (correct default).
    // R pin is tied off - reset is already handled in the logic above.
    FDRE #(.INIT(1'b1)) hsync_reg (
        .C(clk), .CE(1'b1), .R(1'b0), .D(hsync_d), .Q(Hsync)
    );
    FDRE #(.INIT(1'b1)) vsync_reg (
        .C(clk), .CE(1'b1), .R(1'b0), .D(vsync_d), .Q(Vsync)
    );

endmodule