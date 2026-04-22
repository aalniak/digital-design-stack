`timescale 1ns/1ps

module timestamp_counter_tb;
    reg clk;
    reg rst_n;
    reg enable;
    reg clear;
    reg load;
    reg [7:0] load_value;
    reg capture_req;
    reg compare_enable;
    reg [7:0] compare_value;
    wire [7:0] timestamp;
    wire [7:0] capture_value;
    wire tick_pulse;
    wire capture_valid;
    wire compare_hit;
    wire overflow_pulse;

    timestamp_counter #(
        .COUNTER_WIDTH(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear(clear),
        .load(load),
        .load_value(load_value),
        .capture_req(capture_req),
        .compare_enable(compare_enable),
        .compare_value(compare_value),
        .timestamp(timestamp),
        .capture_value(capture_value),
        .tick_pulse(tick_pulse),
        .capture_valid(capture_valid),
        .compare_hit(compare_hit),
        .overflow_pulse(overflow_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        enable = 1'b0;
        clear = 1'b0;
        load = 1'b0;
        load_value = 8'h00;
        capture_req = 1'b0;
        compare_enable = 1'b0;
        compare_value = 8'h00;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        if (timestamp !== 8'h00 || tick_pulse || capture_valid || compare_hit || overflow_pulse) begin
            $fatal(1, "timestamp counter should reset to zero with quiet status outputs");
        end

        enable = 1'b1;
        repeat (3) @(posedge clk);
        @(negedge clk);
        if (timestamp !== 8'h03 || !tick_pulse) begin
            $fatal(1, "enabled counting should increment the timestamp");
        end

        capture_req = 1'b1;
        @(posedge clk);
        @(negedge clk);
        capture_req = 1'b0;
        if (!capture_valid || capture_value !== 8'h03 || timestamp !== 8'h04) begin
            $fatal(1, "capture should sample the pre-update timestamp value");
        end

        load = 1'b1;
        load_value = 8'h07;
        @(posedge clk);
        @(negedge clk);
        load = 1'b0;
        if (timestamp !== 8'h07) begin
            $fatal(1, "load should override normal incrementing");
        end

        compare_enable = 1'b1;
        compare_value = 8'h09;
        repeat (2) @(posedge clk);
        @(negedge clk);
        if (timestamp !== 8'h09 || !compare_hit) begin
            $fatal(1, "compare should hit when the updated timestamp matches the compare value");
        end

        load = 1'b1;
        load_value = 8'hFF;
        @(posedge clk);
        @(negedge clk);
        load = 1'b0;
        compare_enable = 1'b0;
        @(posedge clk);
        @(negedge clk);
        if (timestamp !== 8'h00 || !overflow_pulse) begin
            $fatal(1, "overflow should pulse when the counter wraps during increment");
        end

        $display("timestamp_counter_tb passed");
        $finish;
    end
endmodule
