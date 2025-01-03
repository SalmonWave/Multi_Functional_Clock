`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 01:27:32 PM
// Design Name: 
// Module Name: clock_9600Hz
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


module tick_clock #(
    parameter CLOCK_FREQ = 100_000_000,  
    parameter TARGET_FREQ = 9600         
)
(
    input clk, reset,
    output reg tick
);

    localparam COUNTER_MAX = CLOCK_FREQ / TARGET_FREQ - 1;
    reg [$clog2(COUNTER_MAX):0] r_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick <= 0;
            r_counter <= 0;
        end else begin
            if (r_counter == COUNTER_MAX) begin
                r_counter <= 0;
                tick <= 1;
            end else begin
                r_counter <= r_counter + 1;
                tick <= 0;
            end
        end
    end

endmodule