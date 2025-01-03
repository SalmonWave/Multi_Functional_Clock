
`timescale 1ns / 1ps

//============================= CLOCK SMS ================================//

module counter_6000_clock (
    input                       clk,
    input                       i_tick,
    input                       reset,
    output [$clog2(6_000)-1:0] o_bcd
);

    //    parameter IDLE = 2'b00, COUNT10000 = 2'b01;
    reg [$clog2(6_000)-1:0] count, count_next;

    // 1. state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            count <= count_next;
        end
    end

    // 2. combinational state next
    always @(*) begin

        count_next = count;


        if (i_tick) begin
            if (count == 6_000) begin
                count_next = 0;
            end else begin
                count_next = count + 1;
            end
        end

    end

    // 3. combination output
    assign o_bcd = count;

endmodule


module tick_10ms_clock (
    input clk,
    input reset,
    output reg tick_100hz
);
    reg [$clog2(
1_000_000
)-1:0] r_counter;  //1_000_000의 비트수를 추출하기 위해 넣은 식

    always @(posedge clk, posedge reset) begin


        if (reset) begin
            r_counter  <= 0;
            tick_100hz <= 0;


        end else begin
            if (r_counter == 1_000_000) begin
                r_counter  <= 0;
                tick_100hz <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1;
                tick_100hz <= 1'b0;
            end
        end




    end

endmodule

//============================= CLOCK HM ================================//


module counter_minute_count_clock (
    input clk,
    input i_tick,
    input reset,
    output [$clog2(60)-1:0] o_bcd
);

    //    parameter IDLE = 2'b00, COUNT10000 = 2'b01;
    reg [$clog2(60)-1:0] count, count_next;
    reg [$clog2(1_000)-1:0] minute_counter, minute_counter_next;
    // 1. state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            minute_counter <= 0;
        end else begin
            count <= count_next;
            minute_counter <= minute_counter_next;
        end
    end

    // 2. combinational state next
    always @(*) begin

        count_next = count;
        minute_counter_next = minute_counter;

        if (i_tick) begin
            if (count == 59) begin
                count_next = 0;
                minute_counter_next = minute_counter + 1;
                if(minute_counter == 1_000) begin
                    minute_counter_next = 0;
                end

            end else begin
                count_next = count + 1;
            end
        end
    end


    // 3. combination output
    assign o_bcd = minute_counter;

endmodule


module tick_1Hz_clock (
    input clk,
    input reset,
    output reg tick_1hz
);
    reg [$clog2(
100_000_000
)-1:0] r_counter;  //1_000_000의 비트수를 추출하기 위해 넣은 식

    always @(posedge clk, posedge reset) begin

        if (reset) begin
            r_counter  <= 0;
            tick_1hz <= 0;


        end else begin
            if (r_counter == 100_000_000) begin
                r_counter  <= 0;
                tick_1hz <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1;
                tick_1hz <= 1'b0;
            end
        end
    end


endmodule
