`timescale 1ms / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Module Name: alarm_clock_tb
//////////////////////////////////////////////////////////////////////////////////


module alarm_clock_tb();

reg clk_100MHz, reset, b_alarm, b_snooze, b_ck_set, b_am_set, b_hour_inc, b_minute_inc;
wire [6:0] seg;
wire [7:0] AN;
wire [1:0] dsel;
wire o_alarm, dg_pm;

alarm_clock DUT (clk_100MHz, reset, b_alarm, b_snooze, b_ck_set, b_am_set, b_hour_inc, b_minute_inc, dsel, seg, AN, dg_pm, o_alarm);


initial begin
    b_ck_set = 0; b_hour_inc = 0; b_minute_inc = 0;
end

initial begin
    reset = 0;
    b_alarm = 1;
    b_snooze = 0;
    b_am_set = 0;
    #10 reset = 1;
    #20 reset = 0;
    #50 b_am_set = 1;
    #1010 b_am_set = 0;
    #200 b_minute_inc = 1;
    #100 b_minute_inc = 0;
    #120000 b_snooze = 1;
    #20 b_snooze = 0;
    
end

initial begin
    clk_100MHz = 0;
    forever #5 clk_100MHz = ~clk_100MHz;
end

endmodule
