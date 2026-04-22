module clock_mux_controller_tb;
    reg clk;
    reg rst_n;
    reg request_valid;
    reg [1:0] requested_source;
    reg [2:0] source_healthy;
    reg inhibit_switch;
    reg clear_sticky;

    integer guard;

    wire [1:0] mux_select;
    wire [1:0] active_source;
    wire [1:0] pending_source;
    wire pending_source_valid;
    wire switch_in_progress;
    wire hold_request;
    wire active_source_healthy;
    wire request_reject_pulse;
    wire switch_done_pulse;
    wire auto_failover_pulse;
    wire fault_status;
    wire auto_failover_status;

    clock_mux_controller #(
        .NUM_SOURCES(3),
        .DEFAULT_SOURCE(0),
        .WAIT_FOR_STABLE_EN(1),
        .STABLE_CYCLES(2),
        .AUTO_FAILOVER_EN(1),
        .HOLD_CYCLES(2),
        .STATUS_STICKY_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .request_valid(request_valid),
        .requested_source(requested_source),
        .source_healthy(source_healthy),
        .inhibit_switch(inhibit_switch),
        .clear_sticky(clear_sticky),
        .mux_select(mux_select),
        .active_source(active_source),
        .pending_source(pending_source),
        .pending_source_valid(pending_source_valid),
        .switch_in_progress(switch_in_progress),
        .hold_request(hold_request),
        .active_source_healthy(active_source_healthy),
        .request_reject_pulse(request_reject_pulse),
        .switch_done_pulse(switch_done_pulse),
        .auto_failover_pulse(auto_failover_pulse),
        .fault_status(fault_status),
        .auto_failover_status(auto_failover_status)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("CLOCK_MUX_CONTROLLER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic step_clk;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task automatic wait_clk_cycles;
        input integer count;
        integer idx;
        begin
            for (idx = 0; idx < count; idx = idx + 1) begin
                step_clk();
            end
        end
    endtask

`define WAIT_FOR_HIGH(signal_name, max_cycles, message_text) \
    begin \
        guard = 0; \
        while (((signal_name) !== 1'b1) && (guard < (max_cycles))) begin \
            step_clk(); \
            guard = guard + 1; \
        end \
        if ((signal_name) !== 1'b1) begin \
            fail(message_text); \
        end \
    end

`define WAIT_FOR_LOW(signal_name, max_cycles, message_text) \
    begin \
        guard = 0; \
        while (((signal_name) !== 1'b0) && (guard < (max_cycles))) begin \
            step_clk(); \
            guard = guard + 1; \
        end \
        if ((signal_name) !== 1'b0) begin \
            fail(message_text); \
        end \
    end

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        request_valid = 1'b0;
        requested_source = 2'd0;
        source_healthy = 3'b001;
        inhibit_switch = 1'b0;
        clear_sticky = 1'b0;

        wait_clk_cycles(3);
        if (active_source !== 2'd0 || mux_select !== 2'd0) begin
            fail("reset must select default source 0");
        end
        if (pending_source_valid !== 1'b0 || switch_in_progress !== 1'b0 || hold_request !== 1'b0) begin
            fail("reset must clear pending and progress state");
        end
        if (request_reject_pulse !== 1'b0 || switch_done_pulse !== 1'b0 || auto_failover_pulse !== 1'b0) begin
            fail("reset must suppress pulse outputs");
        end
        if (active_source_healthy !== 1'b0 || fault_status !== 1'b0 || auto_failover_status !== 1'b0) begin
            fail("status outputs must stay quiet during reset");
        end

        @(negedge clk);
        #1;
        rst_n = 1'b1;

        wait_clk_cycles(2);
        if (active_source !== 2'd0 || active_source_healthy !== 1'b1) begin
            fail("source 0 should be active and healthy after reset release");
        end

        @(negedge clk);
        #1;
        request_valid = 1'b1;
        requested_source = 2'd2;

        wait_clk_cycles(2);
        if (active_source !== 2'd0) begin
            fail("controller must not switch to an unhealthy target while waiting for stability");
        end
        if (pending_source_valid !== 1'b1 || pending_source !== 2'd2) begin
            fail("controller should track the pending source while waiting for health");
        end

        @(negedge clk);
        #1;
        source_healthy = 3'b101;

        `WAIT_FOR_HIGH(switch_done_pulse, 4, "controller did not switch once the requested source became stable");
        if (active_source !== 2'd2 || mux_select !== 2'd2) begin
            fail("controller should commit to source 2 after stable qualification");
        end
        if (pending_source_valid !== 1'b0) begin
            fail("pending state should clear after switch commit");
        end
        `WAIT_FOR_HIGH(switch_in_progress, 1, "post-switch hold window did not assert");
        `WAIT_FOR_LOW(switch_in_progress, 3, "post-switch hold window did not expire");
        request_valid = 1'b0;

        @(negedge clk);
        #1;
        request_valid = 1'b1;
        requested_source = 2'd3;
        `WAIT_FOR_HIGH(request_reject_pulse, 2, "out-of-range manual request did not pulse reject");
        if (active_source !== 2'd2) begin
            fail("invalid request must not change active source");
        end
        request_valid = 1'b0;

        @(negedge clk);
        #1;
        request_valid = 1'b1;
        requested_source = 2'd1;
        inhibit_switch = 1'b1;
        source_healthy = 3'b111;
        `WAIT_FOR_HIGH(request_reject_pulse, 2, "inhibited manual request did not pulse reject");
        if (active_source !== 2'd2) begin
            fail("inhibited request must not change active source");
        end
        request_valid = 1'b0;
        inhibit_switch = 1'b0;

        @(negedge clk);
        #1;
        source_healthy = 3'b010;
        `WAIT_FOR_HIGH(auto_failover_pulse, 4, "automatic failover did not trigger when active source became unhealthy");
        if (active_source !== 2'd1 || mux_select !== 2'd1) begin
            fail("auto failover should select the lowest-index healthy alternate source");
        end
        if (auto_failover_status !== 1'b1) begin
            fail("sticky auto-failover status should latch after automatic failover");
        end
        `WAIT_FOR_LOW(switch_in_progress, 3, "post-failover hold window did not expire");

        @(negedge clk);
        #1;
        source_healthy = 3'b000;
        `WAIT_FOR_HIGH(fault_status, 2, "fault status did not assert when no healthy source remained");
        if (active_source_healthy !== 1'b0) begin
            fail("active_source_healthy must deassert when the active source is unhealthy");
        end

        @(negedge clk);
        #1;
        clear_sticky = 1'b1;
        source_healthy = 3'b010;
        step_clk();
        clear_sticky = 1'b0;
        if (fault_status !== 1'b0) begin
            fail("fault status should clear after clear_sticky and healthy restoration");
        end
        if (auto_failover_status !== 1'b0) begin
            fail("auto failover sticky status should clear after clear_sticky");
        end

        $display("CLOCK_MUX_CONTROLLER_TB_PASS");
        $finish;
    end
endmodule
