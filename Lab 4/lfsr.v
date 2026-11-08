module lfsr(
  input clk,
  input reset,
  output [7:0] Lfsr
);

  wire feedback;
  wire [7:0] d;

  assign feedback = Lfsr[0] ^ Lfsr[5] ^ Lfsr[6] ^ Lfsr[7];

  assign d[0] = reset ? 1'b1 : feedback;
  assign d[1] = reset ? 1'b0 : Lfsr[0];
  assign d[2] = reset ? 1'b0 : Lfsr[1];
  assign d[3] = reset ? 1'b0 : Lfsr[2];
  assign d[4] = reset ? 1'b0 : Lfsr[3];
  assign d[5] = reset ? 1'b0 : Lfsr[4];
  assign d[6] = reset ? 1'b0 : Lfsr[5];
  assign d[7] = reset ? 1'b0 : Lfsr[6];

  FDRE #(.INIT(1'b1)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[0]), .Q(Lfsr[0]));
  FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[1]), .Q(Lfsr[1]));
  FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[2]), .Q(Lfsr[2]));
  FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[3]), .Q(Lfsr[3]));
  FDRE #(.INIT(1'b0)) ff4 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[4]), .Q(Lfsr[4]));
  FDRE #(.INIT(1'b0)) ff5 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[5]), .Q(Lfsr[5]));
  FDRE #(.INIT(1'b0)) ff6 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[6]), .Q(Lfsr[6]));
  FDRE #(.INIT(1'b0)) ff7 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[7]), .Q(Lfsr[7]));

endmodule


