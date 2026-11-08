//checks when 2 seconds and 4 seconds have passed
//checks if the player stopped at the right time or ran out of time

module time_counter(
  input clk,
  input inc,
  input reset,
  output [5:0] Count
);
  wire [5:0] sum;
  wire [6:0] c;
  wire [5:0] d;
  
  assign c[0] = inc;
  
  assign sum[0] = Count[0] ^ c[0];
  assign c[1]   = Count[0] & c[0];
  
  assign sum[1] = Count[1] ^ c[1];
  assign c[2]   = Count[1] & c[1];
  
  assign sum[2] = Count[2] ^ c[2];
  assign c[3]   = Count[2] & c[2];
  
  assign sum[3] = Count[3] ^ c[3];
  assign c[4]   = Count[3] & c[3];
  
  assign sum[4] = Count[4] ^ c[4];
  assign c[5]   = Count[4] & c[4];
  
  assign sum[5] = Count[5] ^ c[5];
  assign c[6]   = Count[5] & c[5];
  
  assign d = sum & {6{~reset}};
  
  FDRE #(.INIT(1'b0)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[0]), .Q(Count[0]));
  FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[1]), .Q(Count[1]));
  FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[2]), .Q(Count[2]));
  FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[3]), .Q(Count[3]));
  FDRE #(.INIT(1'b0)) ff4 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[4]), .Q(Count[4]));
  FDRE #(.INIT(1'b0)) ff5 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[5]), .Q(Count[5]));
  //stores the count
  
  
endmodule