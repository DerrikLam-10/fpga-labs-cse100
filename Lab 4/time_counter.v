module time_counter(

    input clk,
    input inc,
    input reset,
    output [5:0] Count

);

    wire [5:0] Q;      
    wire [5:0] sum;
    wire [6:0] c;
    wire [5:0] d;
    
    assign c[0] = inc;
    
    
    assign sum[0] = Q[0] ^ c[0];
    assign c[1]   = Q[0] & c[0];
    
    assign sum[1] = Q[1] ^ c[1];
    assign c[2]   = Q[1] & c[1];
    
    assign sum[2] = Q[2] ^ c[2];
    assign c[3]   = Q[2] & c[2];
    
    assign sum[3] = Q[3] ^ c[3];
    assign c[4]   = Q[3] & c[3];
    
    assign sum[4] = Q[4] ^ c[4];
    assign c[5]   = Q[4] & c[4];
    
    assign sum[5] = Q[5] ^ c[5];
    assign c[6]   = Q[5] & c[5];
    
    assign d = reset ? 6'b000000 : sum;
    
    FDRE #(.INIT(1'b0)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[0]), .Q(Q[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[1]), .Q(Q[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[2]), .Q(Q[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[3]), .Q(Q[3]));
    FDRE #(.INIT(1'b0)) ff4 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[4]), .Q(Q[4]));
    FDRE #(.INIT(1'b0)) ff5 (.C(clk), .R(1'b0), .CE(1'b1), .D(d[5]), .Q(Q[5]));
    
    assign Count = Q;

endmodule
