`timescale 1ns/1ps

module event_counter_tb;
    localparam integer WRAP_WIDTH = 4;
    localparam integer SAT_WIDTH = 3;

    reg clk;
    reg rst_n;

    reg wrap_event_pulse;
    reg wrap_count_enable;
    reg wrap_clear;
    reg wrap_snapshot;
    wire [WRAP_WIDTH-1:0] wrap_count_value;
    wire [WRAP_WIDTH-1:0] wrap_snapshot_value;
    wire wrap_overflow_sticky;
    wire wrap_threshold_reached;

    reg sat_event_pulse;
    reg sat_count_enable;
    reg sat_clear;
    reg sat_snapshot;
    wire [SAT_WIDTH-1:0] sat_count_value;
    wire [SAT_WIDTH-1:0] sat_snapshot_value;
    wire sat_overflow_sticky;
    wire sat_threshold_reached;

    reg [WRAP_WIDTH-1:0] wrap_model_count;
    reg [WRAP_WIDTH-1:0] wrap_model_snapshot;
    reg wrap_model_overflow;

    reg [SAT_WIDTH-1:0] sat_model_count;
    reg [SAT_WIDTH-1:0] sat_model_snapshot;
    reg sat_model_overflow;

    integer failures;
    integer idx;

    event_counter #(
        .COUNT_WIDTH(WRAP_WIDTH),
        .SATURATE(1'b0),
        .THRESHOLD_EN(1'b1),
        .THRESHOLD_VALUE(4),
        .SNAPSHOT_EN(1'b1),
        .CLEAR_PRIORITY(1'b1),
        .RESET_VALUE({WRAP_WIDTH{1'b0}})
    ) dut_wrap (
        .clk(clk),
        .rst_n(rst_n),
        .event_pulse(wrap_event_pulse),
        .count_enable(wrap_count_enable),
        .clear(wrap_clear),
        .snapshot(wrap_snapshot),
        .count_value(wrap_count_value),
        .snapshot_value(wrap_snapshot_value),
        .overflow_sticky(wrap_overflow_sticky),
        .threshold_reached(wrap_threshold_reached)
    );

    event_counter #(
        .COUNT_WIDTH(SAT_WIDTH),
        .SATURATE(1'b1),
        .THRESHOLD_EN(1'b1),
        .THRESHOLD_VALUE(5),
        .SNAPSHOT_EN(1'b1),
        .CLEAR_PRIORITY(1'b0),
        .RESET_VALUE({SAT_WIDTH{1'b0}})
    ) dut_sat (
        .clk(clk),
        .rst_n(rst_n),
        .event_pulse(sat_event_pulse),
        .count_enable(sat_count_enable),
        .clear(sat_clear),
        .snapshot(sat_snapshot),
        .count_value(sat_count_value),
        .snapshot_value(sat_snapshot_value),
        .overflow_sticky(sat_overflow_sticky),
        .threshold_reached(sat_threshold_reached)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic step_both(
        input reg next_wrap_event,
        input reg next_wrap_enable,
        input reg next_wrap_clear,
        input reg next_wrap_snapshot,
        input reg next_sat_event,
        input reg next_sat_enable,
        input reg next_sat_clear,
        input reg next_sat_snapshot
    );
        reg [WRAP_WIDTH-1:0] wrap_base;
        reg [WRAP_WIDTH-1:0] wrap_next_count;
        reg [WRAP_WIDTH-1:0] wrap_next_snapshot;
        reg wrap_event_overflow;
        reg wrap_next_overflow;
        reg wrap_count_now;

        reg [SAT_WIDTH-1:0] sat_base;
        reg [SAT_WIDTH-1:0] sat_next_count;
        reg [SAT_WIDTH-1:0] sat_next_snapshot;
        reg sat_event_overflow;
        reg sat_next_overflow;
        reg sat_count_now;
        begin
            @(negedge clk);
            wrap_event_pulse = next_wrap_event;
            wrap_count_enable = next_wrap_enable;
            wrap_clear = next_wrap_clear;
            wrap_snapshot = next_wrap_snapshot;
            sat_event_pulse = next_sat_event;
            sat_count_enable = next_sat_enable;
            sat_clear = next_sat_clear;
            sat_snapshot = next_sat_snapshot;

            wrap_count_now = next_wrap_enable && next_wrap_event && (!next_wrap_clear || !1'b1);
            wrap_base = next_wrap_clear ? {WRAP_WIDTH{1'b0}} : wrap_model_count;
            wrap_next_count = wrap_base;
            wrap_event_overflow = 1'b0;
            if (wrap_count_now) begin
                wrap_next_count = wrap_base + 1'b1;
                wrap_event_overflow = (wrap_base == {WRAP_WIDTH{1'b1}});
            end
            wrap_next_overflow = (next_wrap_clear ? 1'b0 : wrap_model_overflow) | wrap_event_overflow;
            if (next_wrap_snapshot) begin
                wrap_next_snapshot = wrap_next_count;
            end
            else if (next_wrap_clear) begin
                wrap_next_snapshot = {WRAP_WIDTH{1'b0}};
            end
            else begin
                wrap_next_snapshot = wrap_model_snapshot;
            end

            sat_count_now = next_sat_enable && next_sat_event && (!next_sat_clear || !1'b0);
            sat_base = next_sat_clear ? {SAT_WIDTH{1'b0}} : sat_model_count;
            sat_next_count = sat_base;
            sat_event_overflow = 1'b0;
            if (sat_count_now) begin
                if (sat_base == {SAT_WIDTH{1'b1}}) begin
                    sat_next_count = {SAT_WIDTH{1'b1}};
                    sat_event_overflow = 1'b1;
                end
                else begin
                    sat_next_count = sat_base + 1'b1;
                end
            end
            sat_next_overflow = (next_sat_clear ? 1'b0 : sat_model_overflow) | sat_event_overflow;
            if (next_sat_snapshot) begin
                sat_next_snapshot = sat_next_count;
            end
            else if (next_sat_clear) begin
                sat_next_snapshot = {SAT_WIDTH{1'b0}};
            end
            else begin
                sat_next_snapshot = sat_model_snapshot;
            end

            @(posedge clk);
            #1;

            if (wrap_count_value !== wrap_next_count) begin
                $display("EVENT_COUNTER_TB_FAIL wrap count expected=0x%0h got=0x%0h at time %0t", wrap_next_count, wrap_count_value, $time);
                failures = failures + 1;
            end
            if (wrap_snapshot_value !== wrap_next_snapshot) begin
                $display("EVENT_COUNTER_TB_FAIL wrap snapshot expected=0x%0h got=0x%0h at time %0t", wrap_next_snapshot, wrap_snapshot_value, $time);
                failures = failures + 1;
            end
            if (wrap_overflow_sticky !== wrap_next_overflow) begin
                $display("EVENT_COUNTER_TB_FAIL wrap overflow expected=%0b got=%0b at time %0t", wrap_next_overflow, wrap_overflow_sticky, $time);
                failures = failures + 1;
            end
            if (wrap_threshold_reached !== (wrap_next_count >= 4)) begin
                $display("EVENT_COUNTER_TB_FAIL wrap threshold mismatch at time %0t", $time);
                failures = failures + 1;
            end

            if (sat_count_value !== sat_next_count) begin
                $display("EVENT_COUNTER_TB_FAIL sat count expected=0x%0h got=0x%0h at time %0t", sat_next_count, sat_count_value, $time);
                failures = failures + 1;
            end
            if (sat_snapshot_value !== sat_next_snapshot) begin
                $display("EVENT_COUNTER_TB_FAIL sat snapshot expected=0x%0h got=0x%0h at time %0t", sat_next_snapshot, sat_snapshot_value, $time);
                failures = failures + 1;
            end
            if (sat_overflow_sticky !== sat_next_overflow) begin
                $display("EVENT_COUNTER_TB_FAIL sat overflow expected=%0b got=%0b at time %0t", sat_next_overflow, sat_overflow_sticky, $time);
                failures = failures + 1;
            end
            if (sat_threshold_reached !== (sat_next_count >= 5)) begin
                $display("EVENT_COUNTER_TB_FAIL sat threshold mismatch at time %0t", $time);
                failures = failures + 1;
            end

            wrap_model_count = wrap_next_count;
            wrap_model_snapshot = wrap_next_snapshot;
            wrap_model_overflow = wrap_next_overflow;
            sat_model_count = sat_next_count;
            sat_model_snapshot = sat_next_snapshot;
            sat_model_overflow = sat_next_overflow;
        end
    endtask

    initial begin
        rst_n = 1'b0;
        wrap_event_pulse = 1'b0;
        wrap_count_enable = 1'b0;
        wrap_clear = 1'b0;
        wrap_snapshot = 1'b0;
        sat_event_pulse = 1'b0;
        sat_count_enable = 1'b0;
        sat_clear = 1'b0;
        sat_snapshot = 1'b0;
        wrap_model_count = {WRAP_WIDTH{1'b0}};
        wrap_model_snapshot = {WRAP_WIDTH{1'b0}};
        wrap_model_overflow = 1'b0;
        sat_model_count = {SAT_WIDTH{1'b0}};
        sat_model_snapshot = {SAT_WIDTH{1'b0}};
        sat_model_overflow = 1'b0;
        failures = 0;

        repeat (2) @(posedge clk);
        #1;
        if (wrap_count_value !== 0 || wrap_snapshot_value !== 0 || wrap_overflow_sticky !== 0) begin
            $display("EVENT_COUNTER_TB_FAIL wrap instance not reset cleanly at time %0t", $time);
            failures = failures + 1;
        end
        if (sat_count_value !== 0 || sat_snapshot_value !== 0 || sat_overflow_sticky !== 0) begin
            $display("EVENT_COUNTER_TB_FAIL sat instance not reset cleanly at time %0t", $time);
            failures = failures + 1;
        end

        rst_n = 1'b1;

        step_both(1, 1, 0, 0, 1, 1, 0, 0);
        step_both(1, 1, 0, 0, 1, 1, 0, 0);
        step_both(1, 1, 0, 0, 1, 1, 0, 0);
        step_both(1, 1, 0, 1, 1, 1, 0, 1);
        step_both(1, 1, 1, 0, 1, 1, 1, 0);

        for (idx = 0; idx < 20; idx = idx + 1) begin
            step_both(1, 1, 0, 0, 1, 1, 0, 0);
        end

        step_both(0, 0, 1, 0, 0, 0, 1, 0);
        step_both(0, 0, 0, 0, 0, 0, 0, 0);

        if (failures != 0) begin
            $display("EVENT_COUNTER_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "EVENT_COUNTER_TB_PASS wrap_count=0x%0h sat_count=0x%0h wrap_overflow=%0b sat_overflow=%0b",
            wrap_count_value,
            sat_count_value,
            wrap_overflow_sticky,
            sat_overflow_sticky
        );
        $finish;
    end

    initial begin
        #10000;
        $display("EVENT_COUNTER_TB_FAIL timeout failures=%0d", failures);
        $finish_and_return(1);
    end
endmodule
