module mux8bit
  (input [7:0] A
  ,input [7:0] B
  ,input Sel
  ,output [7:0] C);

    assign C = ({8{~Sel}} & A) | ({8{Sel}} & B);

endmodule


