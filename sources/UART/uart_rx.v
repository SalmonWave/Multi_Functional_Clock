
module UART_rx (
    input clk,
    input baud_rate_tick,
    input reset,
    input RX,
    output [7:0] o_rx_data,
    output o_rx_done,
    output o_rx_done_stop_watch,
    output o_rx_busy
);

    reg [1:0] state, next_state;
    reg [7:0] r_rx_data, r_rx_data_next;
    reg [4:0] trigger_counter, trigger_counter_next;
    reg [2:0] bit_counter, bit_counter_next;
    reg r_rx_done, r_rx_done_next;
    reg r_rx_busy, r_rx_busy_next;


    localparam IDLE = 2'b00, START = 2'b01, RECEIVE = 2'b10, STOP = 2'b11;

    assign o_rx_data = r_rx_data;
    assign o_rx_done = r_rx_done;
    assign o_rx_busy = r_rx_busy;
    assign o_rx_done_stop_watch = r_rx_done;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            trigger_counter <= 0;
            bit_counter     <= 0;
            r_rx_data       <= 0;
            r_rx_done       <= 0;
            r_rx_busy       <= 0;
        end else begin
            state           <= next_state;
            trigger_counter <= trigger_counter_next;
            bit_counter     <= bit_counter_next;
            r_rx_data       <= r_rx_data_next;
            r_rx_done       <= r_rx_done_next;
            r_rx_busy       <= r_rx_busy_next;
        end

    end

    always @(*) begin
        next_state = state;
        trigger_counter_next = trigger_counter;
        bit_counter_next     = bit_counter;

        case (state)

            IDLE: begin
                if(baud_rate_tick)begin
                    if (!RX) begin
                        next_state           = START;
                        trigger_counter_next = 0;
                        bit_counter_next     = 0;
                    end else begin
                        next_state = IDLE;
                    end
                end
            end


            START: begin
                if (baud_rate_tick) begin
                    if (trigger_counter == (16 - 1)) begin
                        next_state           = RECEIVE;
                        trigger_counter_next = 0;
                        bit_counter_next     = 0;
                    end else begin
                        next_state = START;
                        trigger_counter_next = trigger_counter + 1;
                    end
                end
            end


            RECEIVE: begin
                if (baud_rate_tick) begin
                    if (trigger_counter == (16 - 1)) begin
                        trigger_counter_next = 0;

                        if (bit_counter == (8 - 1)) begin
                            next_state           = STOP;
                            trigger_counter_next = 0;
                            bit_counter_next     = 0;
                        end else begin
                            next_state = RECEIVE;
                            bit_counter_next = bit_counter + 1;
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
                        bit_counter_next     = 0;
                    end else begin
                        next_state = STOP;
                        trigger_counter_next = trigger_counter + 1;
                    end
                end
            end


            default: next_state = IDLE;
        endcase

    end


    always @(*) begin
        r_rx_done_next = r_rx_done;
        r_rx_busy_next = r_rx_busy;
        r_rx_data_next = r_rx_data;
        case (state)

            IDLE: begin
                r_rx_busy_next = 1'b0;
                r_rx_done_next = 1'b0;
            end

            START: begin
                r_rx_busy_next = 1'b1;
                r_rx_done_next = 1'b0;
            end


            RECEIVE: begin
                if (trigger_counter == (8 - 1)) begin
                    r_rx_data_next[bit_counter] = RX;
                end  //  FOR CENTER CAPTURE
                
                r_rx_busy_next = 1'b1;
                r_rx_done_next = 1'b0;
            end
        
            STOP: begin
                r_rx_busy_next = 1'b0;
                r_rx_done_next = 1'b1;
            end


        endcase

    end



endmodule
