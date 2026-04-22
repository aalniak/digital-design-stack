module rtc_block #(
    parameter integer COUNTER_WIDTH = 32,
    parameter integer PRESCALE_CYCLES = 100
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire                     set_time,
    input  wire [COUNTER_WIDTH-1:0] set_time_value,
    input  wire                     set_alarm,
    input  wire [COUNTER_WIDTH-1:0] alarm_value_in,
    input  wire                     clear_alarm_pending,
    output reg  [COUNTER_WIDTH-1:0] rtc_time,
    output reg  [COUNTER_WIDTH-1:0] alarm_value,
    output reg                      alarm_enabled,
    output reg                      second_tick,
    output reg                      alarm_pulse,
    output reg                      alarm_pending
);
    localparam integer PRESCALE_WIDTH = (PRESCALE_CYCLES < 2) ? 1 : $clog2(PRESCALE_CYCLES);

    reg [PRESCALE_WIDTH-1:0] prescale_count_q;
    reg [COUNTER_WIDTH-1:0] next_time;
    reg next_second_tick;
    reg next_time_event;

    initial begin
        if (COUNTER_WIDTH < 1) begin
            $fatal(1, "rtc_block requires COUNTER_WIDTH >= 1");
        end
        if (PRESCALE_CYCLES < 1) begin
            $fatal(1, "rtc_block requires PRESCALE_CYCLES >= 1");
        end
    end

    always @(*) begin
        next_time = rtc_time;
        next_second_tick = 1'b0;
        next_time_event = 1'b0;

        if (set_time) begin
            next_time = set_time_value;
            next_time_event = 1'b1;
        end
        else if (enable) begin
            if (PRESCALE_CYCLES == 1) begin
                next_time = rtc_time + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
                next_second_tick = 1'b1;
                next_time_event = 1'b1;
            end
            else if (prescale_count_q == (PRESCALE_CYCLES - 1)) begin
                next_time = rtc_time + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
                next_second_tick = 1'b1;
                next_time_event = 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rtc_time <= {COUNTER_WIDTH{1'b0}};
            alarm_value <= {COUNTER_WIDTH{1'b0}};
            alarm_enabled <= 1'b0;
            second_tick <= 1'b0;
            alarm_pulse <= 1'b0;
            alarm_pending <= 1'b0;
            prescale_count_q <= {PRESCALE_WIDTH{1'b0}};
        end
        else begin
            second_tick <= next_second_tick;
            alarm_pulse <= 1'b0;
            rtc_time <= next_time;

            if (set_time) begin
                prescale_count_q <= {PRESCALE_WIDTH{1'b0}};
            end
            else if (enable) begin
                if (PRESCALE_CYCLES == 1) begin
                    prescale_count_q <= {PRESCALE_WIDTH{1'b0}};
                end
                else if (prescale_count_q == (PRESCALE_CYCLES - 1)) begin
                    prescale_count_q <= {PRESCALE_WIDTH{1'b0}};
                end
                else begin
                    prescale_count_q <= prescale_count_q + {{(PRESCALE_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            if (set_alarm) begin
                alarm_value <= alarm_value_in;
                alarm_enabled <= 1'b1;
            end

            if (clear_alarm_pending) begin
                alarm_pending <= 1'b0;
            end

            if (alarm_enabled && next_time_event && (next_time == alarm_value)) begin
                alarm_pulse <= 1'b1;
                alarm_pending <= 1'b1;
            end
        end
    end
endmodule
