module halfadder(
    input  A,
    input  B,
    output S,
    output cout
);
    assign S    = A ^ B;
    assign cout = A & B;
endmodule

module fulladder(
    input  A,
    input  B,
    input  cin,
    output S,
    output cout,
    output ovfl
);
    wire s1, c1, c2;

    halfadder ha0(.A(A),  .B(B),   .S(s1), .cout(c1));
    halfadder ha1(.A(s1), .B(cin), .S(S),  .cout(c2));

    assign cout = c1 | c2;

    assign ovfl = cin ^ cout;
endmodule

module adder8
    (input  [7:0] A,
    input  [7:0] B,
    input        cin,
    output [7:0] S,
    output       ovfl,
    output       cout
);
    wire [7:0] c;  // c[i] = carry out of bit i

    fulladder fa0(.A(A[0]), .B(B[0]), .cin(cin),  .S(S[0]), .cout(c[0]), .ovfl());
    fulladder fa1(.A(A[1]), .B(B[1]), .cin(c[0]), .S(S[1]), .cout(c[1]), .ovfl());
    fulladder fa2(.A(A[2]), .B(B[2]), .cin(c[1]), .S(S[2]), .cout(c[2]), .ovfl());
    fulladder fa3(.A(A[3]), .B(B[3]), .cin(c[2]), .S(S[3]), .cout(c[3]), .ovfl());
    fulladder fa4(.A(A[4]), .B(B[4]), .cin(c[3]), .S(S[4]), .cout(c[4]), .ovfl());
    fulladder fa5(.A(A[5]), .B(B[5]), .cin(c[4]), .S(S[5]), .cout(c[5]), .ovfl());
    fulladder fa6(.A(A[6]), .B(B[6]), .cin(c[5]), .S(S[6]), .cout(c[6]), .ovfl());
    fulladder fa7(.A(A[7]), .B(B[7]), .cin(c[6]), .S(S[7]), .cout(c[7]), .ovfl(ovfl));

    assign cout = c[7];
endmodule
