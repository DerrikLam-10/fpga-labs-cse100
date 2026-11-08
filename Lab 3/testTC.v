`timescale 1ns/1ps
// Verilog code to test UTC and DTC of your 15 bit counter
// Fall 2022



module testTC();
  reg clkin, btnR, btnC, btnU, btnD, btnL;
  reg [15:0] sw;
  wire [15:0] led;
  wire [6:0] seg;
  wire [3:0] an;
  wire dp, UTC, DTC;
  
  top_m  // replace with your top level module's name
   UUT (
      .clkin(clkin),
      .btnR(btnR),
      .btnU(btnU),
      .btnD(btnD),
      .btnL(btnL),
      .btnC(btnC),
      .sw(sw),
      .seg(seg),
      .dp(dp),
      .led(led),
      .an(an)
      );   

integer TX_ERROR = 0;
    assign UTC = led[15];
    assign DTC = led[0];	

// Run this simulation for 3ms. If correct TX_ERROR should be 0 at the end.
// UTC should be high and then go low at 2,705us and go low at 2,706.3us.

    parameter PERIOD = 10;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET = 2;
	 

	initial    // Clock process for clkin
	begin
	  btnC = 1'bx;
	  btnR = 1'b0;
	  btnU = 1'bx;
	  btnD = 1'bx;
	  btnL = 1'bx;
    
       #OFFSET
		clkin = 1'b1;
       forever
         begin
            #(PERIOD-(PERIOD*DUTY_CYCLE)) clkin = ~clkin;
         end
	  end
	
	initial
	begin
     #2000;
	 btnC=1'b0;
	 btnU=1'b0;
	 btnD=1'b0;
	 btnL=1'b0;
	 btnR=1'b0;
	 sw = 16'h9034;
	 #200;
	 btnR = 1'b1;
	 #500 btnR = 1'b0;
	 #300 btnC=1'b1;
	 btnR = 1'b0;
	 #1330000 btnC=1'b0;
	 #200; btnU=1'b1;
	 #600; btnU=1'b0;
	 #200; btnU=1'b1;
	 #700; btnU=1'b0;
	 #200; btnU=1'b1;
	 #800; btnU=1'b0;
	 CHECK_UTC(1'b1); CHECK_DTC(1'b0);
	 #400;
	 CHECK_UTC(1'b1); CHECK_DTC(1'b0);
	 #200; 
	 btnU=1'b1;
	 #200; 
	 btnU=1'b0;
	 #100;
	 CHECK_UTC(1'b0); CHECK_DTC(1'b1);
	 #200; btnU=1'b0;
	 #200; btnU=1'b1;
	 #100;
	 CHECK_UTC(1'b0);  CHECK_DTC(1'b0);
	 #300 btnD=1'b1;
	 #200;
	 CHECK_UTC(1'b0);  CHECK_DTC(1'b1);
	 #200; btnD=1'b0;
     #200; btnD=1'b1;
     #100;
	 CHECK_UTC(1'b1); CHECK_DTC(1'b0);
	 #200; btnD=1'b0;
     #200; btnD=1'b1;
     #100;
     CHECK_UTC(1'b0); CHECK_DTC(1'b0);
     #200; btnU=1'b0;
     #200; btnU=1'b1;
     #100;
     CHECK_UTC(1'b1); CHECK_DTC(1'b0);
     #200; btnU=1'b0;
     #200; btnU=1'b1;
     #100;
     CHECK_UTC(1'b0); CHECK_DTC(1'b1);
     #100;
     
	end
	
	task CHECK_UTC;
        input good_TC;

        #0 begin
            if (good_TC !== UTC) begin
                TX_ERROR = TX_ERROR + 1;
            end
        end
    endtask
    
	task CHECK_DTC;
        input good_TC;
    
       #0 begin
           if (good_TC !== DTC) begin
               TX_ERROR = TX_ERROR + 1;
           end
       end
    endtask
        
endmodule

