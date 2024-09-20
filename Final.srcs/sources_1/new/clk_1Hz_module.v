`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: clk_1Hz_module
//////////////////////////////////////////////////////////////////////////////////


module clk_1Hz_module(
    input clk_5MHz,
    output reg clk_100Hz);
    
    reg [15:0] count;
    
    
    always @ (posedge clk_5MHz) begin
        if (count == 24999) count <= 0;
        else count <= count + 1;
    end
    
    always @ (posedge clk_5MHz) begin
        if (count == 24999) clk_100Hz <= !clk_100Hz;
    end
    
endmodule
