`timescale 1ns/1ps

module pll_lock_monitor_tb;
    reg clk;
    reg rst_n;
    reg enable;
    reg raw_lock;
    reg ref_ok;
    reg reconfig_busy;
    reg clear_sticky;
    reg bypass_force_ready;
    wire filtered_lock;
    wire stable_ready;
    wire sticky_loss;
    wire qualifying;
    wire holdoff_active;
    wire lock_acquired_pulse;
    wire lock_lost_pulse;
    wire [1:0] qualify_count;
    wire [1:0] holdoff_count;

    pll_lock_monitor #(
        .ASSERT_FILTER(3),
        .DEASSERT_FILTER(2),
        .STICKY_LOSS_EN(1),
        .RELOCK_HOLDOFF(2),
        .BYPASS_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .raw_lock(raw_lock),
        .ref_ok(ref_ok),
        .reconfig_busy(reconfig_busy),
        .clear_sticky(clear_sticky),
        .bypass_force_ready(bypass_force_ready),
        .filtered_lock(filtered_lock),
        .stable_ready(stable_ready),
        .sticky_loss(sticky_loss),
        .qualifying(qualifying),
        .holdoff_active(holdoff_active),
        .lock_acquired_pulse(lock_acquired_pulse),
        .lock_lost_pulse(lock_lost_pulse),
        .qualify_count(qualify_count),
        .holdoff_count(holdoff_count)
    );

    integer acquired_pulses;
    integer lost_pulses;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic expect_state;
        input expected_filtered;
        input expected_ready;
        input expected_sticky;
        begin
            if (filtered_lock !== expected_filtered) begin
                $fatal(1, "filtered_lock mismatch: expected %0d got %0d", expected_filtered, filtered_lock);
            end
            if (stable_ready !== expected_ready) begin
                $fatal(1, "stable_ready mismatch: expected %0d got %0d", expected_ready, stable_ready);
            end
            if (sticky_loss !== expected_sticky) begin
                $fatal(1, "sticky_loss mismatch: expected %0d got %0d", expected_sticky, sticky_loss);
            end
        end
    endtask

    always @(negedge clk) begin
        if (lock_acquired_pulse) begin
            acquired_pulses = acquired_pulses + 1;
        end
        if (lock_lost_pulse) begin
            lost_pulses = lost_pulses + 1;
        end
    end

    initial begin
        rst_n = 1'b0;
        enable = 1'b1;
        raw_lock = 1'b0;
        ref_ok = 1'b1;
        reconfig_busy = 1'b0;
        clear_sticky = 1'b0;
        bypass_force_ready = 1'b0;
        acquired_pulses = 0;
        lost_pulses = 0;

        repeat (3) @(posedge clk);
        @(negedge clk);
        expect_state(1'b0, 1'b0, 1'b0);
        rst_n = 1'b1;

        @(posedge clk);
        @(negedge clk);
        expect_state(1'b0, 1'b0, 1'b0);

        raw_lock = 1'b1;
        repeat (2) @(posedge clk);
        @(negedge clk);
        expect_state(1'b0, 1'b0, 1'b0);
        if (!qualifying) begin
            $fatal(1, "qualifying should be high while assertion filter is accumulating");
        end

        raw_lock = 1'b0;
        @(posedge clk);
        @(negedge clk);
        expect_state(1'b0, 1'b0, 1'b0);

        raw_lock = 1'b1;
        repeat (3) @(posedge clk);
        @(negedge clk);
        if (!filtered_lock || lock_acquired_pulse !== 1'b1) begin
            $fatal(1, "filtered_lock should assert with an acquire pulse after three good samples");
        end
        if (stable_ready) begin
            $fatal(1, "stable_ready should still be held low during relock holdoff");
        end

        repeat (2) @(posedge clk);
        @(negedge clk);
        if (!stable_ready || holdoff_active) begin
            $fatal(1, "stable_ready should assert after the configured relock holdoff");
        end

        raw_lock = 1'b0;
        @(posedge clk);
        @(negedge clk);
        if (filtered_lock !== 1'b1) begin
            $fatal(1, "filtered_lock should remain asserted after a single bad sample");
        end
        if (stable_ready !== 1'b0) begin
            $fatal(1, "stable_ready should drop immediately on a bad sample");
        end

        raw_lock = 1'b1;
        repeat (2) @(posedge clk);
        @(negedge clk);
        if (!stable_ready) begin
            $fatal(1, "stable_ready should reassert after the relock holdoff completes");
        end

        raw_lock = 1'b0;
        repeat (2) @(posedge clk);
        @(negedge clk);
        if (filtered_lock || !sticky_loss || !lock_lost_pulse) begin
            $fatal(1, "qualified loss should clear filtered_lock and set sticky_loss");
        end

        clear_sticky = 1'b1;
        @(posedge clk);
        @(negedge clk);
        clear_sticky = 1'b0;
        if (sticky_loss) begin
            $fatal(1, "clear_sticky should clear sticky_loss");
        end

        raw_lock = 1'b1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        if (!filtered_lock || !stable_ready) begin
            $fatal(1, "lock and ready should return after reacquisition");
        end

        reconfig_busy = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (stable_ready) begin
            $fatal(1, "stable_ready should drop immediately during reconfiguration");
        end
        @(posedge clk);
        @(negedge clk);
        if (filtered_lock) begin
            $fatal(1, "filtered_lock should clear after the configured deassert filter during reconfiguration");
        end
        reconfig_busy = 1'b0;
        raw_lock = 1'b0;

        bypass_force_ready = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (!filtered_lock || !stable_ready) begin
            $fatal(1, "bypass_force_ready should override the filtered path");
        end

        bypass_force_ready = 1'b0;
        @(posedge clk);
        @(negedge clk);
        expect_state(1'b0, 1'b0, 1'b1);

        if (acquired_pulses < 2) begin
            $fatal(1, "expected multiple lock-acquired pulses across reacquisition scenarios");
        end
        if (lost_pulses < 2) begin
            $fatal(1, "expected multiple lock-lost pulses across loss scenarios");
        end

        $display("pll_lock_monitor_tb passed");
        $finish;
    end
endmodule
