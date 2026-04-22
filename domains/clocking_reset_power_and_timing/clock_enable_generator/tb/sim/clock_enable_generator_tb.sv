module clock_enable_generator_tb;
    reg clk;
    reg rst_n;

    reg base_enable;
    reg base_bypass;
    reg base_load_period;
    reg [7:0] base_period_value;
    wire base_enable_pulse;
    wire [7:0] base_active_period;
    wire [7:0] base_phase_count;
    wire base_pending_update;
    wire base_running;

    reg width_enable;
    reg width_bypass;
    reg width_load_period;
    reg [7:0] width_period_value;
    wire width_enable_pulse;
    wire [7:0] width_active_period;
    wire [7:0] width_phase_count;
    wire width_pending_update;
    wire width_running;

    reg restart_enable;
    reg restart_bypass;
    reg restart_load_period;
    reg [7:0] restart_period_value;
    wire restart_enable_pulse;
    wire [7:0] restart_active_period;
    wire [7:0] restart_phase_count;
    wire restart_pending_update;
    wire restart_running;

    integer cycle_idx;
    integer pulse_seen;

    clock_enable_generator #(
        .DEFAULT_PERIOD(4),
        .PERIOD_WIDTH(8),
        .PULSE_WIDTH(1),
        .PROGRAMMABLE_EN(1),
        .RESTART_ON_WRITE(0),
        .BYPASS_EN(1)
    ) base_dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(base_enable),
        .bypass(base_bypass),
        .load_period(base_load_period),
        .period_value(base_period_value),
        .enable_pulse(base_enable_pulse),
        .active_period(base_active_period),
        .phase_count(base_phase_count),
        .pending_update(base_pending_update),
        .running(base_running)
    );

    clock_enable_generator #(
        .DEFAULT_PERIOD(5),
        .PERIOD_WIDTH(8),
        .PULSE_WIDTH(2),
        .PROGRAMMABLE_EN(0),
        .RESTART_ON_WRITE(0),
        .BYPASS_EN(0)
    ) width_dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(width_enable),
        .bypass(width_bypass),
        .load_period(width_load_period),
        .period_value(width_period_value),
        .enable_pulse(width_enable_pulse),
        .active_period(width_active_period),
        .phase_count(width_phase_count),
        .pending_update(width_pending_update),
        .running(width_running)
    );

    clock_enable_generator #(
        .DEFAULT_PERIOD(6),
        .PERIOD_WIDTH(8),
        .PULSE_WIDTH(1),
        .PROGRAMMABLE_EN(1),
        .RESTART_ON_WRITE(1),
        .BYPASS_EN(0)
    ) restart_dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(restart_enable),
        .bypass(restart_bypass),
        .load_period(restart_load_period),
        .period_value(restart_period_value),
        .enable_pulse(restart_enable_pulse),
        .active_period(restart_active_period),
        .phase_count(restart_phase_count),
        .pending_update(restart_pending_update),
        .running(restart_running)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("CLOCK_ENABLE_GENERATOR_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic step_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        base_enable = 1'b0;
        base_bypass = 1'b0;
        base_load_period = 1'b0;
        base_period_value = 8'd0;

        width_enable = 1'b0;
        width_bypass = 1'b0;
        width_load_period = 1'b0;
        width_period_value = 8'd0;

        restart_enable = 1'b0;
        restart_bypass = 1'b0;
        restart_load_period = 1'b0;
        restart_period_value = 8'd0;

        repeat (3) begin
            @(negedge clk);
            if (base_enable_pulse !== 1'b0 || width_enable_pulse !== 1'b0 || restart_enable_pulse !== 1'b0) begin
                fail("all enable outputs must stay low during reset");
            end
            if (base_running !== 1'b0 || width_running !== 1'b0 || restart_running !== 1'b0) begin
                fail("running must stay low during reset");
            end
            if (base_pending_update !== 1'b0 || width_pending_update !== 1'b0 || restart_pending_update !== 1'b0) begin
                fail("pending_update must stay low during reset");
            end
            if (base_active_period !== 8'd4 || width_active_period !== 8'd5 || restart_active_period !== 8'd6) begin
                fail("default periods should be visible during reset");
            end
            if (base_phase_count !== 8'd0 || width_phase_count !== 8'd0 || restart_phase_count !== 8'd0) begin
                fail("phase counters should reset to zero");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;

        base_enable = 1'b1;
        pulse_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 8; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (base_running !== 1'b1) begin
                fail("base instance should report running when enabled");
            end
            if (base_active_period !== 8'd4) begin
                fail("base active period should remain at the default before reprogramming");
            end
            if (base_enable_pulse) begin
                pulse_seen = pulse_seen + 1;
                if ((cycle_idx != 4) && (cycle_idx != 8)) begin
                    fail("base period-4 pulse spacing is wrong");
                end
            end
        end
        if (pulse_seen != 2) begin
            fail("base period-4 configuration should produce two pulses across eight cycles");
        end

        @(negedge clk);
        base_period_value = 8'd5;
        base_load_period = 1'b1;
        step_clock();
        if (base_pending_update !== 1'b1) begin
            fail("deferred update should queue while base instance is running");
        end
        if (base_active_period !== 8'd4) begin
            fail("deferred update must not apply immediately");
        end
        if (base_enable_pulse !== 1'b0) begin
            fail("loading a deferred update must not create a spurious pulse");
        end

        @(negedge clk);
        base_load_period = 1'b0;
        step_clock();
        if (base_pending_update !== 1'b1) begin
            fail("pending update should stay asserted until the period wraps");
        end
        step_clock();
        if (base_enable_pulse !== 1'b0) begin
            fail("deferred update must not shorten the current period");
        end
        step_clock();
        if (base_enable_pulse !== 1'b1) begin
            fail("base instance should still emit the old terminal pulse before applying the new period");
        end
        if (base_active_period !== 8'd5 || base_pending_update !== 1'b0) begin
            fail("new base period should apply exactly at the old boundary");
        end

        pulse_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 5; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (base_enable_pulse) begin
                pulse_seen = pulse_seen + 1;
                if (cycle_idx != 5) begin
                    fail("base period-5 configuration should pulse on the fifth cycle");
                end
            end
        end
        if (pulse_seen != 1) begin
            fail("base period-5 configuration should produce one pulse across five cycles");
        end

        @(negedge clk);
        base_enable = 1'b0;
        repeat (3) begin
            step_clock();
            if (base_enable_pulse !== 1'b0 || base_running !== 1'b0 || base_phase_count !== 8'd0) begin
                fail("disabled base instance should stay quiescent and reset phase");
            end
        end

        @(negedge clk);
        base_enable = 1'b1;
        base_bypass = 1'b1;
        base_period_value = 8'd3;
        base_load_period = 1'b1;
        step_clock();
        if (base_enable_pulse !== 1'b1) begin
            fail("bypass mode should assert enable every enabled cycle");
        end
        if (base_active_period !== 8'd3 || base_pending_update !== 1'b0) begin
            fail("period load should apply immediately while bypassed");
        end
        if (base_phase_count !== 8'd0) begin
            fail("bypass mode should hold phase at zero");
        end

        @(negedge clk);
        base_load_period = 1'b0;
        step_clock();
        if (base_enable_pulse !== 1'b1) begin
            fail("bypass mode should keep enable asserted");
        end

        @(negedge clk);
        base_bypass = 1'b0;
        pulse_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 3; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (base_enable_pulse) begin
                pulse_seen = pulse_seen + 1;
                if (cycle_idx != 3) begin
                    fail("base period-3 configuration should pulse on the third cycle after leaving bypass");
                end
            end
        end
        if (pulse_seen != 1) begin
            fail("base period-3 configuration should produce one pulse across three cycles");
        end

        @(negedge clk);
        base_enable = 1'b0;
        width_enable = 1'b1;
        pulse_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 10; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (width_enable_pulse) begin
                pulse_seen = pulse_seen + 1;
                if ((cycle_idx != 4) && (cycle_idx != 5) && (cycle_idx != 9) && (cycle_idx != 10)) begin
                    fail("width instance pulse window is wrong");
                end
            end
        end
        if (pulse_seen != 4) begin
            fail("width instance should emit two-cycle pulses at the end of each five-cycle period");
        end

        @(negedge clk);
        width_enable = 1'b0;
        restart_enable = 1'b1;
        step_clock();
        step_clock();
        if (restart_enable_pulse !== 1'b0) begin
            fail("restart instance should not pulse before the programmed period elapses");
        end

        @(negedge clk);
        restart_period_value = 8'd3;
        restart_load_period = 1'b1;
        step_clock();
        if (restart_active_period !== 8'd3 || restart_pending_update !== 1'b0) begin
            fail("restart-on-write should apply the new period immediately");
        end
        if (restart_enable_pulse !== 1'b0 || restart_phase_count !== 8'd0) begin
            fail("restart-on-write should restart phase without producing a write-cycle pulse");
        end

        @(negedge clk);
        restart_load_period = 1'b0;
        pulse_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 3; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (restart_enable_pulse) begin
                pulse_seen = pulse_seen + 1;
                if (cycle_idx != 3) begin
                    fail("restart instance should pulse on the third cycle after immediate restart");
                end
            end
        end
        if (pulse_seen != 1) begin
            fail("restart instance should produce one pulse across three cycles after restart");
        end

        $display("CLOCK_ENABLE_GENERATOR_TB_PASS");
        $finish;
    end
endmodule
