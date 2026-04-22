module frequency_meter_tb;
    reg ref_clk;
    reg rst_n;

    reg one_shot_enable;
    reg one_shot_start;
    reg one_shot_measured_clk;
    reg one_shot_run;
    integer one_shot_half_cycles;

    reg continuous_enable;
    reg continuous_start;
    reg continuous_measured_clk;
    reg continuous_run;
    integer continuous_half_cycles;

    integer guard;
    integer sample_seen;

    wire [7:0] one_shot_measured_count;
    wire [7:0] one_shot_average_count;
    wire       one_shot_result_valid;
    wire       one_shot_sample_valid;
    wire       one_shot_busy;
    wire       one_shot_below_range;
    wire       one_shot_above_range;
    wire       one_shot_out_of_range;

    wire [7:0] continuous_measured_count;
    wire [7:0] continuous_average_count;
    wire       continuous_result_valid;
    wire       continuous_sample_valid;
    wire       continuous_busy;
    wire       continuous_below_range;
    wire       continuous_above_range;
    wire       continuous_out_of_range;

    frequency_meter #(
        .COUNTER_WIDTH(8),
        .WINDOW_CYCLES(16),
        .CONTINUOUS_MODE(0),
        .RANGE_CHECK_EN(1),
        .AVERAGING_EN(0),
        .AVERAGE_SHIFT(1)
    ) one_shot_dut (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .enable(one_shot_enable),
        .start(one_shot_start),
        .measured_clk(one_shot_measured_clk),
        .min_acceptable_count(8'd3),
        .max_acceptable_count(8'd5),
        .measured_count(one_shot_measured_count),
        .average_count(one_shot_average_count),
        .result_valid(one_shot_result_valid),
        .sample_valid(one_shot_sample_valid),
        .busy(one_shot_busy),
        .below_range(one_shot_below_range),
        .above_range(one_shot_above_range),
        .out_of_range(one_shot_out_of_range)
    );

    frequency_meter #(
        .COUNTER_WIDTH(8),
        .WINDOW_CYCLES(16),
        .CONTINUOUS_MODE(1),
        .RANGE_CHECK_EN(1),
        .AVERAGING_EN(1),
        .AVERAGE_SHIFT(1)
    ) continuous_dut (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .enable(continuous_enable),
        .start(continuous_start),
        .measured_clk(continuous_measured_clk),
        .min_acceptable_count(8'd3),
        .max_acceptable_count(8'd5),
        .measured_count(continuous_measured_count),
        .average_count(continuous_average_count),
        .result_valid(continuous_result_valid),
        .sample_valid(continuous_sample_valid),
        .busy(continuous_busy),
        .below_range(continuous_below_range),
        .above_range(continuous_above_range),
        .out_of_range(continuous_out_of_range)
    );

    always #5 ref_clk = ~ref_clk;

    initial begin
        one_shot_measured_clk = 1'b0;
        forever begin
            wait (one_shot_run == 1'b1);
            repeat (one_shot_half_cycles) begin
                @(negedge ref_clk);
            end
            if (one_shot_run) begin
                one_shot_measured_clk = ~one_shot_measured_clk;
            end
        end
    end

    initial begin
        continuous_measured_clk = 1'b0;
        forever begin
            wait (continuous_run == 1'b1);
            repeat (continuous_half_cycles) begin
                @(negedge ref_clk);
            end
            if (continuous_run) begin
                continuous_measured_clk = ~continuous_measured_clk;
            end
        end
    end

    task automatic fail;
        input [1023:0] message;
        begin
            $display("FREQUENCY_METER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic step_ref;
        begin
            @(posedge ref_clk);
            #1;
        end
    endtask

    task automatic wait_ref_cycles;
        input integer count;
        integer idx;
        begin
            for (idx = 0; idx < count; idx = idx + 1) begin
                step_ref();
            end
        end
    endtask

`define WAIT_FOR_HIGH(signal_name, max_cycles, message_text) \
    begin \
        guard = 0; \
        while (((signal_name) !== 1'b1) && (guard < (max_cycles))) begin \
            step_ref(); \
            guard = guard + 1; \
        end \
        if ((signal_name) !== 1'b1) begin \
            fail(message_text); \
        end \
    end

    task automatic pulse_one_shot_start;
        begin
            @(negedge ref_clk);
            one_shot_start = 1'b1;
            step_ref();
            one_shot_start = 1'b0;
        end
    endtask

    task automatic reset_one_shot_clock;
        input integer half_cycles;
        begin
            @(negedge ref_clk);
            one_shot_run = 1'b0;
            one_shot_measured_clk = 1'b0;
            one_shot_half_cycles = half_cycles;
            @(negedge ref_clk);
            one_shot_run = 1'b1;
        end
    endtask

    task automatic reset_continuous_clock;
        input integer half_cycles;
        begin
            @(negedge ref_clk);
            continuous_run = 1'b0;
            continuous_measured_clk = 1'b0;
            continuous_half_cycles = half_cycles;
            @(negedge ref_clk);
            continuous_run = 1'b1;
        end
    endtask

    task automatic wait_for_continuous_sample;
        input integer max_cycles;
        input [1023:0] message;
        begin
            `WAIT_FOR_HIGH(continuous_sample_valid, max_cycles, message);
        end
    endtask

    initial begin
        ref_clk = 1'b0;
        rst_n = 1'b0;
        one_shot_enable = 1'b0;
        one_shot_start = 1'b0;
        one_shot_run = 1'b0;
        one_shot_half_cycles = 2;
        continuous_enable = 1'b0;
        continuous_start = 1'b0;
        continuous_run = 1'b0;
        continuous_half_cycles = 2;

        wait_ref_cycles(3);
        if (one_shot_measured_count !== 8'd0 || one_shot_average_count !== 8'd0 ||
            continuous_measured_count !== 8'd0 || continuous_average_count !== 8'd0) begin
            fail("measurement outputs must reset to zero");
        end
        if (one_shot_result_valid !== 1'b0 || one_shot_sample_valid !== 1'b0 || one_shot_busy !== 1'b0 ||
            continuous_result_valid !== 1'b0 || continuous_sample_valid !== 1'b0 || continuous_busy !== 1'b0) begin
            fail("valid and busy outputs must stay low during reset");
        end
        if (one_shot_out_of_range !== 1'b0 || continuous_out_of_range !== 1'b0) begin
            fail("range outputs must stay low during reset");
        end

        @(negedge ref_clk);
        rst_n = 1'b1;

        one_shot_enable = 1'b1;
        reset_one_shot_clock(2);
        pulse_one_shot_start();
        `WAIT_FOR_HIGH(one_shot_busy, 2, "one-shot meter did not enter busy state after start");
        `WAIT_FOR_HIGH(one_shot_sample_valid, 24, "one-shot in-range measurement did not complete");
        if (one_shot_measured_count !== 8'd4 || one_shot_average_count !== 8'd4) begin
            fail("one-shot in-range measurement should report 4 measured edges");
        end
        if (one_shot_below_range !== 1'b0 || one_shot_above_range !== 1'b0 || one_shot_out_of_range !== 1'b0) begin
            fail("in-range one-shot sample must not assert threshold flags");
        end
        if (one_shot_result_valid !== 1'b1 || one_shot_busy !== 1'b0) begin
            fail("one-shot result_valid should latch after sample completion");
        end

        reset_one_shot_clock(1);
        pulse_one_shot_start();
        `WAIT_FOR_HIGH(one_shot_sample_valid, 24, "one-shot above-range measurement did not complete");
        if (one_shot_measured_count !== 8'd8) begin
            fail("fast one-shot measurement should report 8 measured edges");
        end
        if (one_shot_above_range !== 1'b1 || one_shot_out_of_range !== 1'b1) begin
            fail("fast one-shot measurement should assert above-range status");
        end

        @(negedge ref_clk);
        one_shot_run = 1'b0;
        one_shot_measured_clk = 1'b0;
        pulse_one_shot_start();
        `WAIT_FOR_HIGH(one_shot_sample_valid, 24, "stopped-clock one-shot measurement did not complete");
        if (one_shot_measured_count !== 8'd0) begin
            fail("stopped-clock one-shot measurement should report zero edges");
        end
        if (one_shot_below_range !== 1'b1 || one_shot_out_of_range !== 1'b1) begin
            fail("stopped-clock one-shot measurement should assert below-range status");
        end

        reset_continuous_clock(2);
        @(negedge ref_clk);
        continuous_enable = 1'b1;
        wait_for_continuous_sample(24, "continuous meter did not produce first sample");
        if (continuous_measured_count !== 8'd4 || continuous_average_count !== 8'd4) begin
            fail("continuous first sample should report 4 measured edges");
        end
        if (continuous_below_range !== 1'b0 || continuous_above_range !== 1'b0) begin
            fail("continuous in-range sample must not assert threshold flags");
        end

        @(negedge ref_clk);
        continuous_run = 1'b0;
        continuous_measured_clk = 1'b0;
        continuous_half_cycles = 1;
        @(negedge ref_clk);
        continuous_run = 1'b1;
        wait_for_continuous_sample(24, "continuous meter did not produce post-step sample");
        if (continuous_measured_count !== 8'd7 || continuous_average_count !== 8'd5) begin
            fail("first post-step continuous sample should reflect transitional synchronized measurement behavior");
        end
        if (continuous_above_range !== 1'b1 || continuous_out_of_range !== 1'b1) begin
            fail("transitional post-step sample should already assert above-range status");
        end

        step_ref();
        wait_for_continuous_sample(24, "continuous meter did not produce settled post-step sample");
        if (continuous_measured_count !== 8'd8) begin
            fail("settled continuous sample should report 8 measured edges");
        end
        if (continuous_average_count !== 8'd6) begin
            fail("continuous average should move from 5 toward 8 with shift=1 on the settled sample");
        end
        if (continuous_above_range !== 1'b1 || continuous_out_of_range !== 1'b1) begin
            fail("settled continuous sample should assert above-range status");
        end

        @(negedge ref_clk);
        continuous_enable = 1'b0;
        wait_ref_cycles(2);
        if (continuous_result_valid !== 1'b0 || continuous_busy !== 1'b0) begin
            fail("continuous meter should clear busy and result_valid when disabled");
        end
        if (continuous_out_of_range !== 1'b0) begin
            fail("continuous range flags should clear when disabled");
        end

        $display("FREQUENCY_METER_TB_PASS");
        $finish;
    end
endmodule
