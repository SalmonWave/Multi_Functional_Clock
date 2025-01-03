`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 01:50:25 PM
// Design Name: 
// Module Name: TOP_10000_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP_WATCH_STOP_WATCH(
    input clk,
    input reset,
    input RX,
    input btn_run_stop, btn_clear, btn_mode,

    output TX,
    output [3:0] fnd_com,
    output [7:0] fnd_font,
    output tx_busy
);

    wire [13:0] w_seg_data_stop_watch;
    wire [13:0] w_seg_data_clock_hm;
    wire [13:0] w_seg_data_clock_sms;
    reg [13:0] w_seg_data;
    wire w_tick_100hz_STOP_WATCH;
    wire w_tick_1hz_CLOCK;
    wire w_tick_100hz_CLOCK_SMS;
    wire w_mode, w_run_stop, w_clear;
    wire w_mode_BUTTON, w_mode_UART;
    wire w_run_stop_BUTTON, w_run_stop_UART;
    wire w_clear_BUTTON, w_clear_UART;

    assign w_run_stop = (w_run_stop_BUTTON || w_run_stop_UART);
    assign w_mode = (w_mode_BUTTON || w_mode_UART);
    assign w_clear = (w_clear_BUTTON || w_clear_UART);


//================= UART CONTROL =======================//

    uart_stop_watch_control U_UART_CONTROL(
    .clk(clk), .reset(reset), .TX(TX), .RX(RX),
    .run_stop_flag(w_run_stop_UART), .clear_flag(w_clear_UART), .mode_flag(w_mode_UART), .tx_busy(tx_busy)
    );

//================= BUTTON CONTROL =====================//

    button_control U_BUTTON_CONTROL (
        .clk(clk),
        .reset(reset),
        .btn_run_stop(btn_run_stop),
        .btn_clear(btn_clear),
        .btn_mode(btn_mode),
        .run_stop_flag(w_run_stop_BUTTON),
        .clear_flag(w_clear_BUTTON),
        .mode_flag(w_mode_BUTTON)
    );

//================== STOP WATCH ==================//

    tick_10ms_stop_watch U_Clk_Div_100hz_STOP_WATCH (
        .clk(clk),
        .reset(reset),
        .mode_flag(w_mode),
        .run_stop_flag(w_run_stop),
        .tick_100hz(w_tick_100hz_STOP_WATCH)
    );

    counter_6000_stop_watch U_Counter_6000_STOP_WATCH (
        .clk(clk),
        .i_tick(w_tick_100hz_STOP_WATCH),
        .clear_flag(w_clear),
        .mode_flag(w_mode),
        .reset(reset),
        .o_bcd(w_seg_data_stop_watch)
    );

//================== CLOCK H/M ==================//

    tick_1Hz_clock U_TICK_1S_CLOCK_HM (
        .clk(clk),
        .reset(reset),
        .tick_1hz(w_tick_1hz_CLOCK)
    );

    counter_minute_count_clock U_HM (
        .clk(clk),
        .i_tick(w_tick_1hz_CLOCK),
        .reset(reset),
        .o_bcd(w_seg_data_clock_hm)
    );

//================== CLOCK S/mS ==================//


    tick_10ms_clock U_TICK_10MS_CLOCK_SMS (
        .clk(clk),
        .reset(reset),
        .tick_100hz(w_tick_100hz_CLOCK_SMS)
    );

    counter_6000_clock U_Counter_6000_CLOCK_SMS (
        .clk(clk),
        .i_tick(w_tick_100hz_CLOCK_SMS),
        .reset(reset),
        .o_bcd(w_seg_data_clock_sms)
    );







//================== FND CONTROL ==================//
    always @(*) begin
        if(w_mode)begin
        w_seg_data = w_seg_data_stop_watch;
        
        end else if (!w_mode) begin
            if(w_run_stop) begin
            w_seg_data = w_seg_data_clock_sms;
            end else begin
            w_seg_data = w_seg_data_clock_hm;
            end
        end
    end
/*
assign w_seg_data = (w_mode) ? w_seg_data_stop_watch : (w_run_stop) ? w_seg_data_clock_sms : w_seg_data_clock_hm;
*/



    fnd_controller U_FND_Controller (
        .clk(clk),
        .reset(reset),
        .seg_data(w_seg_data),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );

endmodule









