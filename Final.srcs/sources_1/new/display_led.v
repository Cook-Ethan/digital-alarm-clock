`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: display_led
//////////////////////////////////////////////////////////////////////////////////


module display_led(
    input clk_5MHz,
    input [5:0] minute,
    input [5:0] hour,
    input on,
    output [6:0] seg,
    output [7:0] AN);
    
    wire [1:0] seg_sel;
    wire [3:0] d0, d1, d2, d3;
    wire [6:0] seg0, seg1, seg2, seg3;
    wire [6:0] on_seg;
    wire [7:0] on_AN;
    
    led_display_500Hz_module seg_sel_module (clk_5MHz, seg_sel);
    
    dig_to_bcd dtb_mod0(minute, 1'b0, on, d0, d1);
    dig_to_bcd dtb_mod1(hour, 1'b1, on, d2, d3);
    
    bcd_to_seg bts0(d0, seg0);
    bcd_to_seg bts1(d1, seg1);
    bcd_to_seg bts2(d2, seg2);
    bcd_to_seg bts3(d3, seg3);
    
    seg_display disp_module (seg0, seg1, seg2, seg3, seg_sel, on_AN, on_seg);
    
    assign seg = (on) ? on_seg : 7'b1111111;
    assign AN = (on) ? on_AN : 8'b11111111;
    
endmodule

module dig_to_bcd(
    input [5:0] digit,
    input is_hour, on,
    output reg [3:0] bcd0,
    output reg [3:0] bcd1);
    
    always @ (*) begin
        bcd0 = 4'b0000; bcd1 = 4'b0000;
        if (!on) begin
            bcd0 = 4'b1111;
            bcd1 = 4'b1111;
        end else begin
            if (digit >= 50) begin
                bcd0 = digit-50;
                bcd1 = 4'b0101;
            end else if (digit >= 40) begin
                bcd0 = digit-40;
                bcd1 = 4'b0100;
            end else if (digit >= 30) begin
                bcd0 = digit-30;
                bcd1 = 4'b0011;
            end else if (digit >= 20) begin
                bcd0 = digit-20;
                bcd1 = 2'b0010;
            end else if (digit >= 10) begin
                bcd0 = digit-10;
                bcd1 = 2'b0001;
            end else begin
                bcd0 = digit;
                if (is_hour) bcd1 = 4'b1111;
                else bcd1 = 4'b0000;
            end
        end
    end

endmodule

module bcd_to_seg(
    input [3:0] bcd,
    output reg [6:0] seg);
    
    always @ (bcd) begin
        seg = 7'b1111111;
        case (bcd)
            0: seg = 7'b0000001;
            1: seg = 7'b1001111;
            2: seg = 7'b0010010;
            3: seg = 7'b0000110;
            4: seg = 7'b1001100;
            5: seg = 7'b0100100;
            6: seg = 7'b0100000;
            7: seg = 7'b0001111;
            8: seg = 7'b0000000;
            9: seg = 7'b0000100;
            default: seg=7'b1111111;
        endcase
    end
endmodule

module seg_display(
    input [6:0] seg0,
    input [6:0] seg1,
    input [6:0] seg2,
    input [6:0] seg3,
    input [1:0] seg_sel,
    output reg [7:0] AN,
    output reg [6:0] seg);
    
    always @ (*) begin
        seg = seg0;
        AN = 8'b11111111;
        if (seg_sel == 2'b00) begin
            seg = seg0;
            AN = 8'b11111110;
        end else if (seg_sel == 2'b01) begin
            seg = seg1;
            AN = 8'b11111101;
        end else if (seg_sel == 2'b10) begin
            seg = seg2;
            AN = 8'b11111011;
        end else begin
            seg = seg3;
            AN = 8'b11110111;
        end
    end
endmodule