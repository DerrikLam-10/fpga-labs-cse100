module fulladder
(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    wire axb;

    assign axb = a ^ b;
    assign sum = axb ^ cin;
    assign cout = (a & b) | (cin & axb);
endmodule


module AddSub8
(
    input  [7:0] A,
    input  [7:0] B,
    input        sub,
    output [7:0] S,
    output       ovfl
);

    wire [7:0] B_eff;
    assign B_eff = B ^ {8{sub}};   // XOR with 00000000 or 11111111

    wire [8:0] c;                  // carry chain
    assign c[0] = sub;             // add 1 when subtracting

    fulladder fa0(.a(A[0]), .b(B_eff[0]), .cin(c[0]), .sum(S[0]), .cout(c[1]));
    fulladder fa1(.a(A[1]), .b(B_eff[1]), .cin(c[1]), .sum(S[1]), .cout(c[2]));
    fulladder fa2(.a(A[2]), .b(B_eff[2]), .cin(c[2]), .sum(S[2]), .cout(c[3]));
    fulladder fa3(.a(A[3]), .b(B_eff[3]), .cin(c[3]), .sum(S[3]), .cout(c[4]));
    fulladder fa4(.a(A[4]), .b(B_eff[4]), .cin(c[4]), .sum(S[4]), .cout(c[5]));
    fulladder fa5(.a(A[5]), .b(B_eff[5]), .cin(c[5]), .sum(S[5]), .cout(c[6]));
    fulladder fa6(.a(A[6]), .b(B_eff[6]), .cin(c[6]), .sum(S[6]), .cout(c[7]));
    fulladder fa7(.a(A[7]), .b(B_eff[7]), .cin(c[7]), .sum(S[7]), .cout(c[8]));

endmodule
