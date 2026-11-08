module PixelAddress (
    input        clk,
    input        greset,
    output [9:0] hcount, // current column position (0-799)
    output [9:0] vcount, // current row position (0-524)
    output       active, // high when pixel is inside the 640x480 visible screen area
    output       frame   // pulses high for exactly 1 clock cycle per frame
);

    // hcount_inc and vcount_inc hold the next counter values.
    // Adding two 10-bit numbers normally produces 11 bits, but since
    // we reset before reaching 800 or 525 the 11th bit is always 0,
    // so truncating back to 10 bits is safe here.
    wire [9:0] hcount_inc = hcount + 10'd1;
    wire [9:0] vcount_inc = vcount + 10'd1;

    // h_end is true on the last pixel of every row (column 799).
    // v_end is true on the last row of every frame (row 524).
    wire h_end = (hcount == 10'd799);
    wire v_end = (vcount == 10'd524);

    // hcount resets to 0 at the end of each row, otherwise increments every clock.
    wire [9:0] hcount_d = h_end ? 10'd0 : hcount_inc;

    // vcount only changes at the end of each row (when h_end is high).
    // At the end of the last row of the frame it resets to 0,
    // otherwise it increments to move to the next row.
    wire [9:0] vcount_d = (h_end & v_end) ? 10'd0      :
                           h_end           ? vcount_inc :
                                             vcount;

    // hcount register - one FDRE per bit, synchronously reset to 0 on greset.
    FDRE #(.INIT(1'b0)) hc9 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[9]),.Q(hcount[9]));
    FDRE #(.INIT(1'b0)) hc8 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[8]),.Q(hcount[8]));
    FDRE #(.INIT(1'b0)) hc7 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[7]),.Q(hcount[7]));
    FDRE #(.INIT(1'b0)) hc6 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[6]),.Q(hcount[6]));
    FDRE #(.INIT(1'b0)) hc5 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[5]),.Q(hcount[5]));
    FDRE #(.INIT(1'b0)) hc4 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[4]),.Q(hcount[4]));
    FDRE #(.INIT(1'b0)) hc3 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[3]),.Q(hcount[3]));
    FDRE #(.INIT(1'b0)) hc2 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[2]),.Q(hcount[2]));
    FDRE #(.INIT(1'b0)) hc1 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[1]),.Q(hcount[1]));
    FDRE #(.INIT(1'b0)) hc0 (.C(clk),.CE(1'b1),.R(greset),.D(hcount_d[0]),.Q(hcount[0]));

    // vcount register - same structure as hcount.
    FDRE #(.INIT(1'b0)) vc9 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[9]),.Q(vcount[9]));
    FDRE #(.INIT(1'b0)) vc8 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[8]),.Q(vcount[8]));
    FDRE #(.INIT(1'b0)) vc7 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[7]),.Q(vcount[7]));
    FDRE #(.INIT(1'b0)) vc6 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[6]),.Q(vcount[6]));
    FDRE #(.INIT(1'b0)) vc5 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[5]),.Q(vcount[5]));
    FDRE #(.INIT(1'b0)) vc4 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[4]),.Q(vcount[4]));
    FDRE #(.INIT(1'b0)) vc3 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[3]),.Q(vcount[3]));
    FDRE #(.INIT(1'b0)) vc2 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[2]),.Q(vcount[2]));
    FDRE #(.INIT(1'b0)) vc1 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[1]),.Q(vcount[1]));
    FDRE #(.INIT(1'b0)) vc0 (.C(clk),.CE(1'b1),.R(greset),.D(vcount_d[0]),.Q(vcount[0]));

    // active is high only when the current pixel falls within the 640x480 visible area.
    // Pixels outside this region are in the sync/blanking zones and must output black RGB.
    assign active = (hcount < 10'd640) & (vcount < 10'd480);

    // frame pulses high for exactly one clock cycle per frame.
    // It is placed at (640, 480) which is just outside the active region,
    // ensuring game logic (player movement, apple falling, etc.) never
    // updates mid-frame and causes visible tearing.
    assign frame = (hcount == 10'd640) & (vcount == 10'd480);

endmodule