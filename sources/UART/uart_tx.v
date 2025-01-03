`timescale 1ns/1ps

module UART_tx (
    input clk,
    input baud_rate_tick,
    input reset,
    input start,
    input [7:0] i_tx_data,

    output o_tx_data,
    output tx_done,
    output tx_busy
);

    reg [1:0] state, next_state;
    reg r_tx_data, r_tx_data_next;
    reg [4:0] trigger_counter, trigger_counter_next;
    reg [2:0] bit_counter, bit_counter_next;
    reg r_tx_busy, r_tx_busy_next;
    reg r_tx_done, r_tx_done_next;

    localparam IDLE = 2'b00, START = 2'b01, SEND = 2'b10, STOP = 2'b11;

    assign o_tx_data = r_tx_data;
    assign tx_busy   = r_tx_busy;
    assign tx_done   = r_tx_done;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state           <= IDLE;
            trigger_counter <= 0;
            bit_counter     <= 0;
            r_tx_data       <= 1;
            r_tx_done       <= 0;
            r_tx_busy       <= 0;
        end else begin
            state           <= next_state;
            trigger_counter <= trigger_counter_next;
            bit_counter     <= bit_counter_next;
            r_tx_data       <= r_tx_data_next;
            r_tx_done       <= r_tx_done_next;
            r_tx_busy       <= r_tx_busy_next;
        end
    end


    always @(*) begin
        next_state           = state;
        trigger_counter_next = trigger_counter;
        bit_counter_next     = bit_counter;
        r_tx_data_next       = r_tx_data;     
        r_tx_done_next       = r_tx_done;     
        r_tx_busy_next       = r_tx_busy;     


        case (state)

            IDLE: begin
                if (start) begin
                    next_state           = START;
                    trigger_counter_next = 0;
                    bit_counter_next     = 0;
                end else begin
                    next_state           = IDLE;
            end
            end

            START: begin
                if (baud_rate_tick) begin
                    if (trigger_counter == (16 - 1)) begin
                        next_state           = SEND;
                        trigger_counter_next = 0;
                        bit_counter_next     = 0;
                    end else begin
                        next_state = START;
                        trigger_counter_next = trigger_counter + 1;
                    end
                end 
            end

            SEND: begin
                if (baud_rate_tick) begin
                    if (trigger_counter == (16 - 1)) begin
                        trigger_counter_next = 0;

                        if (bit_counter == (8 - 1)) begin
                            next_state           = STOP;
                            trigger_counter_next = 0;
                            bit_counter_next     = 0;
                        end else begin
                            next_state           = SEND;
                            bit_counter_next     = bit_counter + 1;
                        end

                    end else begin
                        trigger_counter_next = trigger_counter + 1;
                    end
                end
            end


            STOP: begin
                if (baud_rate_tick) begin
                    if (trigger_counter == (16 - 1)) begin
                        next_state           = IDLE;
                        trigger_counter_next = 0;
                    end else begin
                        next_state = STOP;
                        trigger_counter_next = trigger_counter + 1;
                    end
                end
            end

            default: next_state = IDLE;
        endcase


        case (state)

            IDLE: begin
                r_tx_data_next = 1'b1;
                r_tx_busy_next = 1'b0; 
                r_tx_done_next = 1'b0;
            end

            START: begin
                r_tx_data_next = 1'b0;
                r_tx_busy_next = 1'b1;
                r_tx_done_next = 1'b0;
            end


            SEND: begin
                r_tx_data_next = i_tx_data[bit_counter];
                r_tx_busy_next = 1'b1;
                r_tx_done_next = 1'b0;
            end

            STOP: begin
                r_tx_data_next = 1'b1;
                r_tx_busy_next = 1'b0;
                r_tx_done_next = 1'b1;
            end

            default: begin
                r_tx_data_next = 1'b0;
                r_tx_busy_next = 1'b0;
                r_tx_done_next = 1'b0;
            end
        endcase

    end







endmodule