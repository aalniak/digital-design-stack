module clock_fail_detector_tb;
    reg ref_clk;
    reg rst_n;
    reg enable;
    reg mon_clk;
    reg mon_run;
    reg sticky_clear_fault;
    reg auto_clear_fault;

    integer mon_half_period;
    integer guard;

    wire sticky_fault;
    wire sticky_healthy;
    wire sticky_timeout_event;
    wire sticky_window_event;
    wire sticky_monitored_edge_pulse;
    wire [3:0] sticky_window_edge_count;

    wire auto_fault;
    wire auto_healthy;
    wire auto_timeout_event;
    wire auto_window_event;
    wire auto_monitored_edge_pulse;
    wire [3:0] auto_window_edge_count;

    clock_fail_detector #(
        .WINDOW_CYCLES(12),
        .TIMEOUT_CYCLES(10),
        .MIN_EDGES(3),
        .MAX_EDGES(5),
        .FILTER_DEPTH(1),
        .STICKY_FAULT_EN(1),
        .AUTO_RECOVER_EN(0)
    ) sticky_dut (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .enable(enable),
        .mon_clk(mon_clk),
        .clear_fault(sticky_clear_fault),
        .fault(sticky_fault),
        .healthy(sticky_healthy),
        .timeout_event(sticky_timeout_event),
        .window_event(sticky_window_event),
        .monitored_edge_pulse(sticky_monitored_edge_pulse),
        .window_edge_count(sticky_window_edge_count)
    );

    clock_fail_detector #(
        .WINDOW_CYCLES(12),
        .TIMEOUT_CYCLES(10),
        .MIN_EDGES(3),
        .MAX_EDGES(5),
        .FILTER_DEPTH(1),
        .STICKY_FAULT_EN(0),
        .AUTO_RECOVER_EN(1)
    ) auto_dut (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .enable(enable),
        .mon_clk(mon_clk),
        .clear_fault(auto_clear_fault),
        .fault(auto_fault),
        .healthy(auto_healthy),
        .timeout_event(auto_timeout_event),
        .window_event(auto_window_event),
        .monitored_edge_pulse(auto_monitored_edge_pulse),
        .window_edge_count(auto_window_edge_count)
    );

    always #5 ref_clk = ~ref_clk;

    initial begin
        mon_clk = 1'b0;
        forever begin
            wait (mon_run == 1'b1);
            #(mon_half_period);
            if (mon_run) begin
                mon_clk = ~mon_clk;
            end
        end
    end

    task automatic fail;
        input [1023:0] message;
        begin
            $display("CLOCK_FAIL_DETECTOR_TB_FAIL %0s", message);
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

`define WAIT_FOR_SIGNAL_HIGH(signal_value, max_cycles, message_text) \
    begin \
        guard = 0; \
        while (((signal_value) !== 1'b1) && (guard < (max_cycles))) begin \
            step_ref(); \
            guard = guard + 1; \
        end \
        if ((signal_value) !== 1'b1) begin \
            fail(message_text); \
        end \
    end

    initial begin
        ref_clk = 1'b0;
        rst_n = 1'b0;
        enable = 1'b0;
        mon_clk = 1'b0;
        mon_run = 1'b0;
        mon_half_period = 15;
        sticky_clear_fault = 1'b0;
        auto_clear_fault = 1'b0;

        repeat (3) begin
            @(negedge ref_clk);
            if (sticky_fault !== 1'b0 || auto_fault !== 1'b0) begin
                fail("fault outputs must stay low during reset");
            end
            if (sticky_healthy !== 1'b0 || auto_healthy !== 1'b0) begin
                fail("healthy outputs must stay low during reset");
            end
            if (sticky_timeout_event !== 1'b0 || sticky_window_event !== 1'b0 ||
                auto_timeout_event !== 1'b0 || auto_window_event !== 1'b0) begin
                fail("event outputs must stay low during reset");
            end
            if (sticky_window_edge_count !== 4'd0 || auto_window_edge_count !== 4'd0) begin
                fail("edge counters must reset to zero");
            end
        end

        @(negedge ref_clk);
        rst_n = 1'b1;
        enable = 1'b1;
        mon_run = 1'b1;
        mon_half_period = 15;

        wait_ref_cycles(30);
        if (sticky_fault !== 1'b0 || auto_fault !== 1'b0) begin
            fail("healthy monitored clock must not trip fault");
        end
        if (sticky_healthy !== 1'b1 || auto_healthy !== 1'b1) begin
            fail("healthy outputs should assert during valid monitored activity");
        end
        if (sticky_monitored_edge_pulse !== 1'b1 && auto_monitored_edge_pulse !== 1'b1 &&
            sticky_window_edge_count == 4'd0) begin
            fail("monitored activity should be visible in the reference domain");
        end

        @(negedge ref_clk);
        mon_run = 1'b0;
        mon_clk = 1'b0;
        `WAIT_FOR_SIGNAL_HIGH(sticky_timeout_event, 20, "timeout event did not assert after monitored clock stopped");
        if (sticky_fault !== 1'b1 || auto_fault !== 1'b1) begin
            fail("both instances should fault after timeout");
        end
        if (sticky_healthy !== 1'b0 || auto_healthy !== 1'b0) begin
            fail("healthy outputs should deassert after timeout fault");
        end

        @(negedge ref_clk);
        mon_half_period = 15;
        mon_run = 1'b1;
        wait_ref_cycles(8);
        if (sticky_fault !== 1'b1) begin
            fail("sticky fault must remain asserted until clear");
        end
        if (auto_fault !== 1'b0 || auto_healthy !== 1'b1) begin
            fail("auto-recover instance should clear after healthy activity returns");
        end

        @(negedge ref_clk);
        sticky_clear_fault = 1'b1;
        step_ref();
        if (sticky_fault !== 1'b0 || sticky_healthy !== 1'b1) begin
            fail("clear_fault should release sticky fault when activity is healthy");
        end
        @(negedge ref_clk);
        sticky_clear_fault = 1'b0;

        @(negedge ref_clk);
        mon_half_period = 35;
        `WAIT_FOR_SIGNAL_HIGH(sticky_window_event, 30, "slow monitored clock did not trigger window fault");
        if (sticky_fault !== 1'b1) begin
            fail("slow monitored clock should raise sticky fault");
        end

        @(negedge ref_clk);
        mon_half_period = 15;
        sticky_clear_fault = 1'b1;
        step_ref();
        @(negedge ref_clk);
        sticky_clear_fault = 1'b0;
        wait_ref_cycles(12);
        if (sticky_fault !== 1'b0) begin
            fail("sticky fault should stay clear after restore and explicit clear");
        end

        @(negedge ref_clk);
        mon_half_period = 9;
        `WAIT_FOR_SIGNAL_HIGH(sticky_window_event, 30, "fast monitored clock did not trigger window fault");
        if (sticky_fault !== 1'b1) begin
            fail("fast monitored clock should raise sticky fault");
        end

        @(negedge ref_clk);
        mon_half_period = 15;
        sticky_clear_fault = 1'b1;
        step_ref();
        @(negedge ref_clk);
        sticky_clear_fault = 1'b0;
        wait_ref_cycles(12);
        if (sticky_fault !== 1'b0 || auto_fault !== 1'b0) begin
            fail("both instances should be healthy again after restoring monitored activity");
        end

        $display("CLOCK_FAIL_DETECTOR_TB_PASS");
        $finish;
    end
endmodule
