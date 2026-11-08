module SignChanger
(input [7:0] A,
,input sign,
,output [7:0] D,
,output ovfl
);

    wire do_negate;
    assign do_negate = sign & ~A[7];  
    wire [7:0] negA;
    wire       negOvfl;

    AddSub8 negator(
        .A(8'b00000000),
        .B(A),
        .sub(1'b1),
        .S(negA),
        .ovfl(negOvfl)
    );

    assign D = ({8{~do_negate}} & A) | ({8{do_negate}} & negA);
    assign ovfl = do_negate & negOvfl;

endmodule
