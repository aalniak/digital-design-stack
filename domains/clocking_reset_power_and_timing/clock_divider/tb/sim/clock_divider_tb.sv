module clock_divider_tb;
    reg clk;
    reg rst_n;
    reg enable;
    reg bypass;
    reg load_divisor;
    reg [7:0] divisor_value;

    wire clk_out;
    wire tick_pulse;
    wire [7:0] active_divisor;
    wire pending_update;
    wire running;

    integer cycle_idx;
    integer high_count;
    integer tick_seen;

    clock_divider #(
        .DEFAULT_DIVISOR(4),
        .DIVISOR_WIDTH(8),
        .PROGRAMMABLE_EN(1),
        .BYPASS_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .bypass(bypass),
        .load_divisor(load_divisor),
        .divisor_value(divisor_value),
        .clk_out(clk_out),
        .tick_pulse(tick_pulse),
        .active_divisor(active_divisor),
        .pending_update(pending_update),
        .running(running)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("CLOCK_DIVIDER_TB_FAIL %0s", message);
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
        enable = 1'b0;
        bypass = 1'b0;
        load_divisor = 1'b0;
        divisor_value = 8'd0;

        repeat (3) begin
            @(negedge clk);
            if (tick_pulse !== 1'b0 || clk_out !== 1'b0 || running !== 1'b0 || pending_update !== 1'b0) begin
                fail("outputs must remain idle during reset");
            end
            if (active_divisor !== 8'd4) begin
                fail("default divisor should be visible during reset");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;
        enable = 1'b1;

        high_count = 0;
        tick_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 8; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (running !== 1'b1) begin
                fail("running should reflect enable after reset release");
            end
            if (active_divisor !== 8'd4) begin
                fail("active divisor should stay at the default before reprogramming");
            end
            high_count = high_count + (clk_out ? 1 : 0);
            if (tick_pulse) begin
                tick_seen = tick_seen + 1;
                if ((cycle_idx != 4) && (cycle_idx != 8)) begin
                    fail("tick spacing for divide-by-4 is wrong");
                end
            end
        end
        if (tick_seen != 2) begin
            fail("divide-by-4 should produce exactly two ticks across eight cycles");
        end
        if (high_count != 4) begin
            fail("divide-by-4 should hold clk_out high for half the sampled cycles");
        end

        @(negedge clk);
        divisor_value = 8'd5;
        load_divisor = 1'b1;
        step_clock();
        if (pending_update !== 1'b1) begin
            fail("runtime divisor load should queue while actively dividing");
        end
        if (active_divisor !== 8'd4) begin
            fail("queued runtime divisor load must not apply immediately");
        end

        @(negedge clk);
        load_divisor = 1'b0;
        step_clock();
        if (pending_update !== 1'b1) begin
            fail("pending update should remain set until terminal count");
        end
        step_clock();
        if (tick_pulse !== 1'b0) begin
            fail("queued divisor update must not shorten the current divide period");
        end
        step_clock();
        if (tick_pulse !== 1'b1) begin
            fail("old divide ratio should still terminate before the new divisor applies");
        end
        if (active_divisor !== 8'd5 || pending_update !== 1'b0) begin
            fail("new divisor should apply exactly at the terminal-count boundary");
        end

        high_count = 0;
        tick_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 5; cycle_idx = cycle_idx + 1) begin
            step_clock();
            high_count = high_count + (clk_out ? 1 : 0);
            if (tick_pulse) begin
                tick_seen = tick_seen + 1;
                if (cycle_idx != 5) begin
                    fail("divide-by-5 should tick exactly every five cycles");
                end
            end
        end
        if (tick_seen != 1) begin
            fail("divide-by-5 should produce exactly one tick across five cycles");
        end
        if (high_count != 3) begin
            fail("divide-by-5 should keep clk_out high for three of five sampled cycles");
        end

        @(negedge clk);
        enable = 1'b0;
        repeat (3) begin
            step_clock();
            if (tick_pulse !== 1'b0 || clk_out !== 1'b0 || running !== 1'b0) begin
                fail("disabled divider should not generate tick or clock output");
            end
        end

        @(negedge clk);
        enable = 1'b1;
        bypass = 1'b1;
        divisor_value = 8'd3;
        load_divisor = 1'b1;
        @(posedge clk);
        #1;
        if (clk_out !== 1'b1 || tick_pulse !== 1'b1) begin
            fail("bypass mode should forward the source clock high phase and pulse every cycle");
        end
        @(negedge clk);
        #1;
        if (clk_out !== 1'b0) begin
            fail("bypass mode should forward the source clock low phase");
        end
        load_divisor = 1'b0;
        if (active_divisor !== 8'd3 || pending_update !== 1'b0) begin
            fail("runtime divisor load should apply immediately while bypassed");
        end

        @(negedge clk);
        bypass = 1'b0;
        tick_seen = 0;
        for (cycle_idx = 1; cycle_idx <= 3; cycle_idx = cycle_idx + 1) begin
            step_clock();
            if (tick_pulse) begin
                tick_seen = tick_seen + 1;
                if (cycle_idx != 3) begin
                    fail("divide-by-3 should tick on the third cycle after leaving bypass");
                end
            end
        end
        if (tick_seen != 1) begin
            fail("divide-by-3 should produce exactly one tick across three cycles");
        end

        $display("CLOCK_DIVIDER_TB_PASS");
        $finish;
    end
endmodule
