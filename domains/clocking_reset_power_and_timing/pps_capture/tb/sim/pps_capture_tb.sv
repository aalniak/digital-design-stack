`timescale 1ns/1ps

module pps_capture_tb;
    reg clk;
    reg rst_n;
    reg enable;
    reg pps_in;
    reg clear_flags;
    reg [15:0] timestamp_in;

    wire capture_valid;
    wire [15:0] captured_timestamp;
    wire interval_valid;
    wire [15:0] interval_delta;
    wire first_capture_seen;
    wire selected_edge_pulse;
    wire glitch_reject_pulse;
    wire glitch_reject_sticky;
    wire qualified_level;

    wire fall_capture_valid;
    wire [15:0] fall_captured_timestamp;
    wire fall_first_capture_seen;

    pps_capture #(
        .TIMESTAMP_WIDTH(16),
        .EDGE_MODE(0),
        .FILTER_EN(1),
        .FILTER_CYCLES(2),
        .INTERVAL_MEASURE_EN(1),
        .CDC_MODE(0)
    ) dut_rise (
        .timestamp_in(timestamp_in),
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .pps_in(pps_in),
        .clear_flags(clear_flags),
        .capture_valid(capture_valid),
        .captured_timestamp(captured_timestamp),
        .interval_valid(interval_valid),
        .interval_delta(interval_delta),
        .first_capture_seen(first_capture_seen),
        .selected_edge_pulse(selected_edge_pulse),
        .glitch_reject_pulse(glitch_reject_pulse),
        .glitch_reject_sticky(glitch_reject_sticky),
        .qualified_level(qualified_level)
    );

    pps_capture #(
        .TIMESTAMP_WIDTH(16),
        .EDGE_MODE(1),
        .FILTER_EN(0),
        .FILTER_CYCLES(1),
        .INTERVAL_MEASURE_EN(0),
        .CDC_MODE(0)
    ) dut_fall (
        .timestamp_in(timestamp_in),
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .pps_in(pps_in),
        .clear_flags(clear_flags),
        .capture_valid(fall_capture_valid),
        .captured_timestamp(fall_captured_timestamp),
        .interval_valid(),
        .interval_delta(),
        .first_capture_seen(fall_first_capture_seen),
        .selected_edge_pulse(),
        .glitch_reject_pulse(),
        .glitch_reject_sticky(),
        .qualified_level()
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timestamp_in <= 16'd0;
        end
        else begin
            timestamp_in <= timestamp_in + 16'd1;
        end
    end

    task automatic wait_for_rise_capture;
        input expected_interval_valid;
        integer timeout_cycles;
        begin
            timeout_cycles = 0;
            while (timeout_cycles < 20) begin
                @(negedge clk);
                if (capture_valid) begin
                    if (!selected_edge_pulse) begin
                        $fatal(1, "capture_valid should align with selected_edge_pulse");
                    end
                    if (interval_valid !== expected_interval_valid) begin
                        $fatal(1, "interval_valid mismatch on rising-edge capture");
                    end
                    disable wait_for_rise_capture;
                end
                timeout_cycles = timeout_cycles + 1;
            end
            $fatal(1, "timeout waiting for rising-edge capture");
        end
    endtask

    task automatic wait_for_glitch_reject;
        integer timeout_cycles;
        begin
            timeout_cycles = 0;
            while (timeout_cycles < 12) begin
                @(negedge clk);
                if (glitch_reject_pulse) begin
                    if (!glitch_reject_sticky) begin
                        $fatal(1, "glitch_reject_pulse should set sticky state");
                    end
                    disable wait_for_glitch_reject;
                end
                timeout_cycles = timeout_cycles + 1;
            end
            $fatal(1, "timeout waiting for glitch rejection");
        end
    endtask

    task automatic wait_for_fall_capture;
        integer timeout_cycles;
        begin
            timeout_cycles = 0;
            while (timeout_cycles < 12) begin
                @(negedge clk);
                if (fall_capture_valid) begin
                    disable wait_for_fall_capture;
                end
                timeout_cycles = timeout_cycles + 1;
            end
            $fatal(1, "timeout waiting for falling-edge capture");
        end
    endtask

    initial begin
        rst_n = 1'b0;
        enable = 1'b1;
        pps_in = 1'b0;
        clear_flags = 1'b0;
        timestamp_in = 16'd0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        repeat (2) @(posedge clk);
        if (capture_valid || interval_valid || first_capture_seen) begin
            $fatal(1, "module should remain idle before the first PPS edge");
        end

        pps_in = 1'b1;
        @(posedge clk);
        pps_in = 1'b0;
        wait_for_glitch_reject();

        clear_flags = 1'b1;
        @(posedge clk);
        @(posedge clk);
        clear_flags = 1'b0;
        if (glitch_reject_sticky) begin
            $fatal(1, "clear_flags should clear the sticky glitch indicator");
        end

        pps_in = 1'b1;
        wait_for_rise_capture(1'b0);
        if (!first_capture_seen) begin
            $fatal(1, "first qualified rising edge should set first_capture_seen");
        end

        pps_in = 1'b0;
        repeat (5) @(posedge clk);

        pps_in = 1'b1;
        wait_for_rise_capture(1'b1);
        if (interval_delta == 16'd0) begin
            $fatal(1, "interval delta should be non-zero after consecutive captures");
        end

        pps_in = 1'b0;
        wait_for_fall_capture();
        if (!fall_capture_valid || !fall_first_capture_seen) begin
            $fatal(1, "falling-edge profile should capture on the raw falling edge");
        end

        enable = 1'b0;
        repeat (2) @(posedge clk);
        enable = 1'b1;
        if (first_capture_seen) begin
            $fatal(1, "disabling the module should clear first-capture history");
        end

        $display("pps_capture_tb passed");
        $finish;
    end
endmodule
