`timescale 1ns / 1ps

module topsim;

    reg clkin;
    reg [15:0] sw;
    reg btnU;
    reg btnC;
    reg btnR;

    wire [3:0] an;
    wire [6:0] seg;
    wire [15:0] led;
    wire dp;

    top DUT (
        .clkin(clkin),
        .sw(sw),
        .btnU(btnU),
        .btnC(btnC),
        .btnR(btnR),
        .an(an),
        .seg(seg),
        .led(led),
        .dp(dp)
    );

    parameter PERIOD = 10;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET = 2;

    initial
    begin
        #OFFSET
        clkin = 1'b0;
        forever
        begin
            #(PERIOD-(PERIOD*DUTY_CYCLE)) clkin = ~clkin;
        end
    end

    initial
    begin
        sw   = 16'h0000;
        btnU = 1'b0;
        btnC = 1'b0;
        btnR = 1'b0;

        #100;

        btnR = 1'b1;
        #50;
        btnR = 1'b0;

        #200;

        // WIN CASE
        btnC = 1'b1; #20; btnC = 1'b0;
        #700;
        btnU = 1'b1; #20; btnU = 1'b0;
        #2000;

        // LOSE CASE (press stop at a different time)
        btnC = 1'b1; #20; btnC = 1'b0;
        #200;
        btnU = 1'b1; #20; btnU = 1'b0;
        #2000;

        // TIMEOUT CASE (never press stop until after it should have timed out)
        btnC = 1'b1; #20; btnC = 1'b0;
        #3000;
        btnU = 1'b1; #20; btnU = 1'b0;
        #2000;

        #500;
        $finish;
    end

endmodule
