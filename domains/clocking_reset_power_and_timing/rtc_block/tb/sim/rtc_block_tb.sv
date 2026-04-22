`timescale 1ns/1ps

module rtc_block_tb;
    reg clk;
    reg rst_n;
    reg enable;
    reg set_time;
    reg [7:0] set_time_value;
    reg set_alarm;
    reg [7:0] alarm_value_in;
    reg clear_alarm_pending;
    wire [7:0] rtc_time;
    wire [7:0] alarm_value;
    wire alarm_enabled;
    wire second_tick;
    wire alarm_pulse;
    wire alarm_pending;

    rtc_block #(
        .COUNTER_WIDTH(8),
        .PRESCALE_CYCLES(2)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .set_time(set_time),
        .set_time_value(set_time_value),
        .set_alarm(set_alarm),
        .alarm_value_in(alarm_value_in),
        .clear_alarm_pending(clear_alarm_pending),
        .rtc_time(rtc_time),
        .alarm_value(alarm_value),
        .alarm_enabled(alarm_enabled),
        .second_tick(second_tick),
        .alarm_pulse(alarm_pulse),
        .alarm_pending(alarm_pending)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        enable = 1'b0;
        set_time = 1'b0;
        set_time_value = 8'h00;
        set_alarm = 1'b0;
        alarm_value_in = 8'h00;
        clear_alarm_pending = 1'b0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        if (rtc_time !== 8'h00 || alarm_enabled || second_tick || alarm_pulse || alarm_pending) begin
            $fatal(1, "rtc block should reset to zeroed time and quiet alarm status");
        end

        set_alarm = 1'b1;
        alarm_value_in = 8'h02;
        @(posedge clk);
        @(negedge clk);
        set_alarm = 1'b0;
        enable = 1'b1;
        repeat (4) @(posedge clk);
        @(negedge clk);
        if (rtc_time !== 8'h02 || !second_tick || !alarm_enabled || !alarm_pulse || !alarm_pending) begin
            $fatal(1, "rtc should prescale count and fire the programmed alarm");
        end

        clear_alarm_pending = 1'b1;
        @(posedge clk);
        @(negedge clk);
        clear_alarm_pending = 1'b0;
        if (alarm_pending) begin
            $fatal(1, "clear_alarm_pending should clear sticky alarm status");
        end

        set_time = 1'b1;
        set_time_value = 8'h05;
        @(posedge clk);
        @(negedge clk);
        set_time = 1'b0;
        if (rtc_time !== 8'h05) begin
            $fatal(1, "set_time should override normal counting");
        end

        set_alarm = 1'b1;
        alarm_value_in = 8'h06;
        @(posedge clk);
        @(negedge clk);
        set_alarm = 1'b0;
        wait (alarm_pending);
        @(negedge clk);
        if (rtc_time !== 8'h06 || !alarm_pulse || !alarm_pending) begin
            $fatal(1, "rtc should continue from the reprogrammed time and re-fire the new alarm");
        end

        $display("rtc_block_tb passed");
        $finish;
    end
endmodule
