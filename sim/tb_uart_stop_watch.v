`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2024 09:34:55 AM
// Design Name: 
// Module Name: tb_uart_stop_watch
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


module tb_uart_stop_watch;

reg i_clk, i_reset, i_rx;
wire o_tx, o_tx_busy;

TOP_WATCH_STOP_WATCH DUT(
    .clk(i_clk),
    .reset(i_reset),
    .RX(i_rx),
    .btn_run_stop(), .btn_clear(), .btn_mode(),

    .TX(o_tx),
    .fnd_com(),
    .fnd_font(),
    .tx_busy(o_tx_busy)
);


always
    #5 i_clk = ~i_clk;



initial begin

i_clk = 0;
i_reset = 1;
i_rx = 1;

#10 i_reset = 0;

#104175 i_rx = 0;

#104175 i_rx = 1;
#104175 i_rx = 0;
#104175 i_rx = 1;
#104175 i_rx = 1;
#104175 i_rx = 0;
#104175 i_rx = 1;
#104175 i_rx = 1;
#104175 i_rx = 0;
// SENDING ASCII CODE 'm'
#104175 i_rx = 1;
#100000000 $finish;


end



endmodule
