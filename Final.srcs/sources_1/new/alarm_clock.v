`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: alarm_clock
//////////////////////////////////////////////////////////////////////////////////


module alarm_clock(
input clk_100MHz, reset,
input b_alarm, b_snooze,
input b_ck_set, b_am_set, b_hour_inc, b_minute_inc,
output reg [1:0] dsel,
output [6:0] seg,
output [7:0] AN,
output dg_pm,
output rgb_alarm
    );
    
    parameter CLOCK = 2'b00, SET_C = 2'b01, SET_A = 2'b10, ALARM = 2'b11;
    reg [1:0] state, next_state;
    
    reg i_set_clock, i_set_alarm, i_hour_inc, i_minute_inc, i_snooze;
    
    wire clk_5MHz, clk_100Hz;
    reg [5:0] ck_hour, ck_minute, setck_hour, setck_minute, am_hour, am_minute, setam_hour, setam_minute;
    wire [6:0] ck_seg, setck_seg, setam_seg;
    wire [7:0] ck_AN, setck_AN, setam_AN;
    wire [5:0] dg_hour, dg_minute;
    reg ck_pm, setck_pm, am_pm, setam_pm, blink_on, set_clock_f, set_alarm_f;
    
    clk_wiz_0 clk_wiz_inst (.clk_5MHz(clk_5MHz), .clk_100MHz(clk_100MHz));
    clk_1Hz_module clk_inst (clk_5MHz, clk_100Hz);
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            state <= CLOCK;
        end else begin
            state <= next_state;
        end
    end
    
    reg [8:0] timeout;
    reg o_alarm;
    reg update_clock_f, update_alarm_f, inc_sc_hour_f, inc_sc_minute_f, inc_am_hour_f, inc_am_minute_f, snooze_f, clear_timeout_f, update_timeout_f, res_setck_f, res_setam_f;
    reg dis_clock_f, dis_set_clock_f, dis_set_alarm_f;
    
    wire alarm_on;
    assign alarm_on = (b_alarm && ck_hour == am_hour && ck_minute == am_minute && ck_pm == am_pm);
    assign rgb_alarm = (!timeout[5] & o_alarm & !timeout[0]);
    
    always @ (state or i_set_clock or i_set_alarm or timeout or i_hour_inc or i_minute_inc or alarm_on) begin
        next_state = CLOCK;
        update_clock_f = 0; update_alarm_f = 0;
        inc_sc_hour_f = 0; inc_sc_minute_f = 0;
        inc_am_hour_f = 0; inc_am_minute_f = 0;
        snooze_f = 0; update_timeout_f = 0; clear_timeout_f = 0;
        dis_clock_f = 0; dis_set_clock_f = 0; dis_set_alarm_f = 0;
        res_setck_f = 1; res_setam_f = 1;
        o_alarm = 0;
        case (state)
            CLOCK:  if (i_set_clock) begin
                        next_state = SET_C;
                        clear_timeout_f = 1;
                        dis_set_clock_f = 1;
                    end else if (i_set_alarm) begin
                        next_state = SET_A;
                        clear_timeout_f = 1;
                        dis_set_alarm_f = 1;
                    end else if (alarm_on) begin
                        next_state = ALARM;
                        clear_timeout_f = 1;
                        o_alarm = 1;
                    end
            SET_C:  begin res_setck_f = 0;
                    if (timeout >= 511 || !i_set_clock) begin
                        next_state = CLOCK;
                        update_clock_f = 1;
                        clear_timeout_f = 1;
                        dis_clock_f = 1;
                    end else if (i_hour_inc) begin
                        next_state = SET_C;
                        inc_sc_hour_f = 1;
                        clear_timeout_f = 1;
                    end else if (i_minute_inc) begin
                        next_state = SET_C;
                        inc_sc_minute_f = 1;
                        clear_timeout_f = 1;
                    end else begin
                        next_state = SET_C;
                        update_timeout_f = 1;
                    end end
            SET_A:  begin res_setam_f = 0;
                    if (timeout >= 511 || !i_set_alarm) begin
                        next_state = CLOCK;
                        update_alarm_f = 1;
                        clear_timeout_f = 1;
                        dis_clock_f = 1;
                    end else if (i_hour_inc) begin
                        next_state = SET_A;
                        inc_am_hour_f = 1;
                        clear_timeout_f = 1;
                    end else if (i_minute_inc) begin
                        next_state = SET_A;
                        inc_am_minute_f = 1;
                        clear_timeout_f = 1;
                    end else begin
                        next_state = SET_A;
                        update_timeout_f = 1;
                    end end
            ALARM:  begin res_setam_f = 0;
                    if (i_snooze) begin
                        next_state = CLOCK;
                        snooze_f = 1;
                        o_alarm = 0;
                    end else if (!b_alarm) begin
                        next_state = CLOCK;
                        o_alarm = 0;
                    end else begin
                        next_state = ALARM;
                        o_alarm = 1;
                        update_timeout_f = 1;
                    end end
            default: next_state = CLOCK;
        endcase
    end
    
//    always @ (*) begin
//        case (state)
//            CLOCK: begin dg_hour <= ck_hour; dg_minute <= ck_minute; dg_pm <= ck_pm; end
//            SET_C: begin dg_hour <= setck_hour; dg_minute <= setck_minute; dg_pm <= setck_pm; end
//            SET_A: begin dg_hour <= setam_hour; dg_minute <= setam_minute; dg_pm <= setam_pm; end
//            ALARM: begin dg_hour <= ck_hour; dg_minute <= ck_minute; dg_pm <= ck_pm; end
//            default: begin dg_hour <= ck_hour; dg_minute <= ck_minute; dg_pm <= ck_pm; end
//        endcase
//    end

//    assign seg = (state == CLOCK) ? ck_seg : (state == SET_C) ? setck_seg : (state == SET_A) ? setam_seg : ck_seg;
//    assign AN = (state == CLOCK) ? ck_AN : (state == SET_C) ? setck_AN : (state == SET_A) ? setam_AN : ck_AN;
//    assign dis = (state == CLOCK) ? 2'b00 : (state == SET_C) ? 2'b01 : (state == SET_A) ? 2'b10 : 2'b11;

    assign dg_hour = (dsel == 2'b00) ? ck_hour : (dsel == 2'b01) ? setck_hour : (dsel == 2'b10) ? setam_hour : am_hour;
    assign dg_minute = (dsel == 2'b00) ? ck_minute : (dsel == 2'b01) ? setck_minute : (dsel == 2'b10) ? setam_minute : am_minute;
    assign dg_pm = (dsel == 2'b00) ? ck_pm : (dsel == 2'b01) ? setck_pm : (dsel == 2'b10) ? setam_pm : am_pm;
    
    reg [15:0] minute_count;
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) dsel <= 2'b00;
        else if (dis_clock_f) dsel <= 2'b00;
        else if (dis_set_clock_f) dsel <= 2'b01;
        else if (dis_set_alarm_f) dsel <= 2'b10;
    end
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            minute_count <= 0;
            ck_hour <= 12; ck_minute <= 0; ck_pm <= 0;
        end else begin
            if (update_clock_f) begin
                ck_hour <= setck_hour; ck_minute <= setck_minute; ck_pm <= setck_pm;
            end else if (minute_count == 5999) begin
                minute_count <= 0;
                if (ck_minute == 59) begin
                    ck_minute <= 0;
                    if (ck_hour == 12) begin ck_hour <= 1; end
                    else if (ck_hour == 11) begin ck_pm <= ~ck_pm; ck_hour <= 12; end
                    else ck_hour <= ck_hour + 1;
                end else ck_minute <= ck_minute + 1;
            end else minute_count <= minute_count + 1;
        end
    end
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            am_hour <= 13; am_minute <= 0; am_pm <= 0;
        end else if (snooze_f) begin
            if (ck_minute > 50) begin
                am_minute <= ck_minute - 51;
                if (ck_hour == 12) begin am_hour <= 1; end
                else if (ck_hour == 11) begin am_pm <= ~ck_pm; am_hour <= 12; end
                else am_hour <= ck_hour + 1;
            end else am_minute <= ck_minute + 9;
        end else if (update_alarm_f) begin
            am_hour <= setam_hour; am_minute <= setam_minute; am_pm <= setam_pm;
        end
    end
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            setck_hour <= 12; setck_minute <= 0; setck_pm <= 0;
        end else if (inc_sc_hour_f) begin
            if (setck_hour == 12) begin setck_hour <= 1; end
            else if (setck_hour == 11) begin setck_pm <= ~setck_pm; setck_hour <= 12; end
            else setck_hour <= setck_hour + 1;
        end else if (inc_sc_minute_f) begin
            if (setck_minute == 59) begin
                setck_minute <= 0;
            end else setck_minute <= setck_minute + 1;
        end else if (res_setck_f) begin
           setck_hour <= ck_hour; setck_minute <= ck_minute; setck_pm <= ck_pm;
       end
    end
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            setam_hour <= 12; setam_minute <= 0; setam_pm <= 0;
        end else if (inc_am_hour_f) begin
            if (setam_hour == 12) begin setam_hour <= 1; end
            else if (setam_hour == 11) begin setam_pm <= ~setam_pm; setam_hour <= 12; end
            else setam_hour <= setam_hour + 1;
        end else if (inc_am_minute_f) begin
            if (setam_minute == 59) begin
                setam_minute <= 0;
            end else setam_minute <= setam_minute + 1;
        end else if (res_setam_f) begin
           if (am_hour > 12) setam_hour <= 12;
           else setam_hour <= am_hour;
           setam_minute <= am_minute; setam_pm <= am_pm;
       end
    end
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            timeout <= 0;
        end else if (update_timeout_f) begin
            timeout <= timeout + 1;
        end else if (clear_timeout_f) begin
            timeout <= 0;
        end
    end
    
    reg [7:0] ck_count;
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            i_set_clock <= 0;
            ck_count <= 0;
        end else if (b_ck_set) begin
            if (ck_count == 99) begin
                i_set_clock <= ~i_set_clock;
                ck_count <= 100;
            end else if (ck_count < 99) ck_count <= ck_count + 1;
        end else if (timeout >= 511) begin
            i_set_clock <= 0;
            ck_count <= 0;
        end else ck_count <= 0;
    end
    
    reg [7:0] am_count;
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            i_set_alarm <= 0;
            am_count <= 0;
        end else if (b_am_set) begin
            if (am_count == 99) begin
                i_set_alarm <= ~i_set_alarm;
                am_count <= 100;
            end else if (am_count < 99) am_count <= am_count + 1;
        end else if (timeout >= 511) begin
            i_set_alarm <= 0;
            am_count <= 0;
        end else am_count <= 0;
    end
    
    reg [4:0] hi_count;
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            i_hour_inc <= 0;
            hi_count <= 0;
        end else if (b_hour_inc && hi_count == 0) begin
            i_hour_inc <= 1;
            hi_count <= 20;
        end else if (hi_count > 0) begin
            i_hour_inc <= 0;
            hi_count <= hi_count - 1;
        end else begin
            i_hour_inc <= 0;
            hi_count <= 0;
        end
    end
    
    reg [4:0] mi_count;
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            i_minute_inc <= 0;
            mi_count <= 0;
        end else if (b_minute_inc && mi_count == 0) begin
            i_minute_inc <= 1;
            mi_count <= 20;
        end else if (mi_count > 0) begin
            i_minute_inc <= 0;
            mi_count <= mi_count - 1;
        end else begin
            i_minute_inc <= 0;
            mi_count <= 0;
        end
    end
    
    reg [4:0] snooze_count;
    
    always @ (posedge clk_100Hz or posedge reset) begin
        if (reset) begin
            i_snooze <= 0;
            snooze_count <= 0;
        end else if (b_snooze && snooze_count == 0) begin
            i_snooze <= 1;
            snooze_count <= 20;
        end else if (snooze_count > 0) begin
            i_snooze <= 0;
            snooze_count <= snooze_count - 1;
        end else begin
            i_snooze <= 0;
            snooze_count <= 0;
        end
    end
    
    display_led dis_inst0 (clk_5MHz, dg_minute, dg_hour, !timeout[6], seg, AN);
//    display_led dis_inst0 (clk_5MHz, ck_minute, ck_hour, 1'b1, ck_seg, ck_AN);
//    display_led dis_inst1 (clk_5MHz, setck_minute, setck_hour, 1'b1, setck_seg, setck_AN);
//    display_led dis_inst2 (clk_5MHz, setam_minute, setam_hour, 1'b1, setam_seg, setam_AN);
        
endmodule
