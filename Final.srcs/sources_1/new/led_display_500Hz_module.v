`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////: 
// Module Name: led_display_500Hz_module
//////////////////////////////////////////////////////////////////////////////////


module led_display_500Hz_module(
    input clk_5MHz,
    output [1:0] dig_sel);
    
    reg [15:0] refresh_count = 0;
    
    always @ (posedge clk_5MHz)
        refresh_count <= refresh_count + 1;
        
    assign dig_sel = refresh_count[15:14];
endmodule
