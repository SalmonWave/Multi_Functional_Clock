`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 04:49:56 PM
// Design Name: 
// Module Name: debounce
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


module debounce (
    input  clk,
    reset,
    i_btn,
    output o_btn
);

    reg [3:0] r_debounce;
    reg r_d_ff;
    reg w_debounce_clk;
    reg [$clog2(100_000) - 1 : 0] counter;

    wire w_debounce;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            w_debounce_clk <= 0;
        end else if (counter == 100_000) begin
            counter <= 0;
            w_debounce_clk <= 1;
        end else begin
            counter <= counter + 1;
            w_debounce_clk <= 0;
        end
    end



    always @(posedge w_debounce_clk, posedge reset) begin
        if (reset) begin
            r_debounce <= 0;
        end else begin
            r_debounce <= {i_btn, r_debounce[3:1]};
        end

    end

    assign w_debounce = &r_debounce;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_d_ff <= 0;
        end else begin
            r_d_ff <= w_debounce;
        end
    end

    assign o_btn = w_debounce & ~r_d_ff;

endmodule
