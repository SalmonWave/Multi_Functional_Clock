`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 07:19:43 PM
// Design Name: 
// Module Name: uart_stop_watch_control
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


module uart_stop_watch_control (
    input  clk,
    reset,
    RX,
    output TX,
    run_stop_flag,
    clear_flag,
    mode_flag,
    tx_busy
);


    localparam CLOCK_HM = 3'b000;
    localparam CLOCK_SMS = 3'b001;
    localparam RUN = 3'b011;
    localparam STOP = 3'b010;
    localparam CLEAR = 3'b100;

    wire [7:0] RX_8BIT;
    wire rx_done_stop_watch; 

    reg [2:0] state, next_state;
    reg r_mode, r_run_stop, r_clear;
    reg done_flag;
    reg prev_flag;

    top_uart U_UART_MODULE (
        .clk(clk),
        .reset(reset),
        .RX(RX),
        .TX(TX),
        .tx_busy(tx_busy),
        .RX_8BIT(RX_8BIT),
        .rx_done_stop_watch(rx_done_stop_watch)
    );

    always@(posedge clk, posedge reset)begin
        if(reset)begin
            done_flag <= 0;
            prev_flag <= 0;
        end
        else begin
            if(rx_done_stop_watch)begin
                prev_flag <= 1;
            end else begin
                if(prev_flag == 1)begin
                    done_flag <= 1;
                    prev_flag <= 0;
                end else begin
                    done_flag <= 0;
                    prev_flag <= 0;
                end
            end
        end
    end


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= CLOCK_HM;
        end else begin
            state <= next_state;
        end

    end


    always @(*) begin
        
        next_state = state;

        if(done_flag)begin
            case (state)

                CLOCK_HM:

                if (RX_8BIT == 8'h72) begin
                    next_state = CLOCK_SMS;
                end else if (RX_8BIT == 8'h6d) begin
                    next_state = STOP;
                end else begin
                    next_state = state;
                end

                CLOCK_SMS:
                if (RX_8BIT == 8'h72) begin
                    next_state = CLOCK_HM;
                end else begin
                    next_state = state;
                end

                RUN:
                if (RX_8BIT == 8'h72) begin
                    next_state = STOP;
                end else begin
                    next_state = state;
                end


                STOP:
                if (RX_8BIT == 8'h6d) begin
                    next_state = CLOCK_HM;
                end else if (RX_8BIT == 8'h63) begin
                    next_state = CLEAR;
                end else if (RX_8BIT == 8'h72) begin
                    next_state = RUN;
                end else begin
                    next_state = state;
                end


                CLEAR: next_state = STOP;


                default: next_state = CLOCK_HM;
            endcase
        end
    end

    always @(*) begin


        case (state)

            CLOCK_HM: begin
                r_mode = 0;
                r_run_stop = 0;
                r_clear = 0;
            end

            CLOCK_SMS: begin
                r_mode = 0;
                r_run_stop = 1;
                r_clear = 0;
            end

            RUN: begin
                r_mode = 1;
                r_run_stop = 1;
                r_clear = 0;
            end
            STOP: begin
                r_mode = 1;
                r_run_stop = 0;
                r_clear = 0;
            end
            CLEAR: begin
                r_mode = 1;
                r_run_stop = 0;
                r_clear = 1;
            end
            default: begin
                r_mode = 0;
                r_run_stop = 0;
                r_clear = 0;
            end
        endcase
    end

    assign mode_flag = r_mode;
    assign run_stop_flag = r_run_stop;
    assign clear_flag = r_clear;

endmodule




