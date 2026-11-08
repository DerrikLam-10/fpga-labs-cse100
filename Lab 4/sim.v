`timescale 1ns / 1ps

module sim;

    reg clk;
    reg go;
    reg stop;
    reg four_secs;
    reg two_secs;
    reg match;
    reg timeout;
    
    wire load_target;
    wire reset_timer;
    wire load_numbers;
    wire shr;
    wire shl;
    wire good;
    wire lose;
    wire flash;
    
    fsm DUT (
        .clk(clk),
        .go(go),
        .stop(stop),
        .four_secs(four_secs),
        .two_secs(two_secs),
        .match(match),
        .timeout(timeout),
        .load_target(load_target),
        .reset_timer(reset_timer),
        .load_numbers(load_numbers),
        .shr(shr),
        .shl(shl),
        .good(good),
        .lose(lose),
        .flash(flash)
    );
    
    parameter PERIOD = 10;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET = 2;
	 

	initial    // Clock process for clkin
	begin
    
       #OFFSET
		clk = 0'b0;
       forever
         begin
            #(PERIOD-(PERIOD*DUTY_CYCLE)) clk = ~clk;
         end
	  end

    
    initial 
    begin
        go = 1'b0;
        stop = 1'b0;
        four_secs = 1'b0;
        two_secs = 1'b0;
        match = 1'b0;
        timeout = 1'b0;
    
        #100;
    
        // WIN CASE
        go = 1;  #20;  go = 0;
        #50;
        two_secs = 1; #20 two_secs = 0;
        match = 1;
        stop = 1;  
        #20;  
        match = 0;
        stop = 0;
        #20;
        four_secs = 1; #20 four_secs = 0;
        #200;
    
        // LOSE CASE
        go = 1; #20; go = 0;
        #50;
        two_secs = 1; #20 two_secs = 0;
        #20
        match = 0;  
        stop = 1; 
        #20; 
        stop = 0;
        #20;
        four_secs = 1; #20; four_secs = 0;
        #200;
    
        // TIMEOUT CASE
        go = 1; #20; go = 0;
        #50;
        two_secs = 1; #20 two_secs = 0;
        #20
        timeout = 1; #20; timeout = 0;
        #20;
        stop = 1; #20; stop = 0;
        #20;
        four_secs = 1; #20 four_secs = 0;
        #200;
    
        #200;
        
end

endmodule
