`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 02:19:21 PM
// Design Name: 
// Module Name: fnd_controller
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

module fnd_controller (
    input         clk,
    input         reset,
    input  [13:0] seg_data,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_font
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [1:0] w_sel;
    wire [3:0] w_bcd_data;
    wire w_tic_1Khz;

    tick_gen U_Tick_Gen (
        .clk(clk),
        .reset(reset),
        .tic_1Khz(w_tic_1Khz)
    );

    counter_4 U_Counter_4 (
        .clk  (w_tic_1Khz),
        .reset(reset),
        .o_sel(w_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .btn(w_sel),
        .fnd_com(fnd_com)
    );

    watch_splitter U_Digit_Splitter (
        .seg_data(seg_data),
        .digit_sec_10ms(w_digit_1),
        .digit_sec_100ms(w_digit_10),
        .digit_sec_1s(w_digit_100),
        .digit_sec_10s(w_digit_1000)
    );

    mux_4x1 U_Mux_4x1 (
        .digit_sel(w_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd_data(w_bcd_data)
    );

    bcd_decoder U_Bcd_Decoder (
        .bcd_data(w_bcd_data),
        .sel(w_sel),
        .fnd_font(fnd_font)
    );

endmodule

module tick_gen (
    input clk,
    input reset,
    output reg tic_1Khz
);

    reg [$clog2(100_000)-1:0] r_tick_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_tick_counter = 0;
        end else begin
            if (r_tick_counter == 100_000) begin
                r_tick_counter <= 0;
                tic_1Khz <= 1'b1;
            end else begin
                r_tick_counter <= r_tick_counter + 1;
                tic_1Khz <= 1'b0;
            end
        end
    end

endmodule

module counter_4 (
    input        clk,
    input        reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;

    assign o_sel = r_counter;

    //always 안에서는 순차회로는 nonblock : <=    조합논리에는 block (패드에 자세한 설명 있음)

    always @(posedge clk, posedge reset) begin
        if (reset) begin  //reset이 high이면,
            //            o_sel = 2'b00;
            r_counter <= 2'b00;
        end else begin
            r_counter <= r_counter + 1;

        end
    end

endmodule


module watch_splitter (
    input [$clog2(10_000) - 1 : 0] seg_data,
    output [3:0] digit_sec_10ms,
    digit_sec_100ms,
    digit_sec_1s,
    digit_sec_10s
);

    assign digit_sec_10ms = seg_data % 10;
    assign digit_sec_100ms = (seg_data / 10) % 10;
    assign digit_sec_1s = (seg_data / 100) % 10;
    assign digit_sec_10s = (seg_data / 1000) % 6;

endmodule

module mux_4x1 (
    input      [1:0] digit_sel,
    input      [3:0] digit_1,
    input      [3:0] digit_10,
    input      [3:0] digit_100,
    input      [3:0] digit_1000,
    output reg [3:0] bcd_data
);

    always @(digit_sel) begin
        case (digit_sel)
            2'b00:   bcd_data = digit_1;
            2'b01:   bcd_data = digit_10;
            2'b10:   bcd_data = digit_100;
            2'b11:   bcd_data = digit_1000;
            default: bcd_data = digit_1;
        endcase
    end

endmodule


module bcd_decoder (
    input [3:0] bcd_data,
    input [1:0] sel,
    output reg [7:0] fnd_font

);



    always @(bcd_data, sel) begin

        case (sel)


            2'b00:
            case (bcd_data)
                4'h0: fnd_font = 8'hc0;
                4'h1: fnd_font = 8'hf9;
                4'h2: fnd_font = 8'ha4;
                4'h3: fnd_font = 8'hb0;
                4'h4: fnd_font = 8'h99;
                4'h5: fnd_font = 8'h92;
                4'h6: fnd_font = 8'h82;
                4'h7: fnd_font = 8'hf8;
                4'h8: fnd_font = 8'h80;
                4'h9: fnd_font = 8'h90;
                4'ha: fnd_font = 8'h88;
                4'hb: fnd_font = 8'h83;
                4'hc: fnd_font = 8'hc6;
                4'hd: fnd_font = 8'ha1;
                4'he: fnd_font = 8'h86;
                4'hf: fnd_font = 8'h8e;
                default: fnd_font = 8'hc0;
            endcase


            2'b01:
            case (bcd_data)
                4'h0: fnd_font = 8'hc0;
                4'h1: fnd_font = 8'hf9;
                4'h2: fnd_font = 8'ha4;
                4'h3: fnd_font = 8'hb0;
                4'h4: fnd_font = 8'h99;
                4'h5: fnd_font = 8'h92;
                4'h6: fnd_font = 8'h82;
                4'h7: fnd_font = 8'hf8;
                4'h8: fnd_font = 8'h80;
                4'h9: fnd_font = 8'h90;
                4'ha: fnd_font = 8'h88;
                4'hb: fnd_font = 8'h83;
                4'hc: fnd_font = 8'hc6;
                4'hd: fnd_font = 8'ha1;
                4'he: fnd_font = 8'h86;
                4'hf: fnd_font = 8'h8e;
                default: fnd_font = 8'hc0;
            endcase


            2'b10:
            case (bcd_data)
                4'h0: fnd_font = 8'hc0 - 8'h80;
                4'h1: fnd_font = 8'hf9 - 8'h80;
                4'h2: fnd_font = 8'ha4 - 8'h80;
                4'h3: fnd_font = 8'hb0 - 8'h80;
                4'h4: fnd_font = 8'h99 - 8'h80;
                4'h5: fnd_font = 8'h92 - 8'h80;
                4'h6: fnd_font = 8'h82 - 8'h80;
                4'h7: fnd_font = 8'hf8 - 8'h80;
                4'h8: fnd_font = 8'h80 - 8'h80;
                4'h9: fnd_font = 8'h90 - 8'h80;
                4'ha: fnd_font = 8'h88 - 8'h80;
                4'hb: fnd_font = 8'h83 - 8'h80;
                4'hc: fnd_font = 8'hc6 - 8'h80;
                4'hd: fnd_font = 8'ha1 - 8'h80;
                4'he: fnd_font = 8'h86 - 8'h80;
                4'hf: fnd_font = 8'h8e - 8'h80;
                default: fnd_font = 8'hc0 - 8'h80;
            endcase


            2'b11:
            case (bcd_data)
                4'h0: fnd_font = 8'hc0;
                4'h1: fnd_font = 8'hf9;
                4'h2: fnd_font = 8'ha4;
                4'h3: fnd_font = 8'hb0;
                4'h4: fnd_font = 8'h99;
                4'h5: fnd_font = 8'h92;
                4'h6: fnd_font = 8'h82;
                4'h7: fnd_font = 8'hf8;
                4'h8: fnd_font = 8'h80;
                4'h9: fnd_font = 8'h90;
                4'ha: fnd_font = 8'h88;
                4'hb: fnd_font = 8'h83;
                4'hc: fnd_font = 8'hc6;
                4'hd: fnd_font = 8'ha1;
                4'he: fnd_font = 8'h86;
                4'hf: fnd_font = 8'h8e;
                default: fnd_font = 8'hc0;
            endcase

        endcase
    end


endmodule

module decoder_2x4 (
    input [1:0] btn,
    output reg [3:0] fnd_com
);

    always @(btn) begin

        case (btn)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase

    end

endmodule
