module rtc_block_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg enable;
    (* anyseq *) reg set_time;
    (* anyseq *) reg [7:0] set_time_value;
    (* anyseq *) reg set_alarm;
    (* anyseq *) reg [7:0] alarm_value_in;
    (* anyseq *) reg clear_alarm_pending;

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
        formal_ticks = 6'd0;
        past_valid = 1'b0;
        prev_clk = 1'b0;
    end

    always @($global_clock) begin
        prev_clk <= clk;
        formal_ticks <= formal_ticks + 1'b1;
        past_valid <= 1'b1;

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(rtc_time == 8'h00);
                assert(!alarm_enabled);
                assert(!second_tick);
                assert(!alarm_pulse);
                assert(!alarm_pending);
            end
            else begin
                assert(alarm_pulse ? alarm_pending : 1'b1);
            end
        end
    end
endmodule
