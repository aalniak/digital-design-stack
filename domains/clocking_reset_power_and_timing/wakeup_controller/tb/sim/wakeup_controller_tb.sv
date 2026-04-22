`timescale 1ns/1ps

module wakeup_controller_tb;
    reg clk;
    reg rst_n;
    reg sleep_armed;
    reg [3:0] source_level;
    reg [3:0] enable_mask;
    reg [3:0] edge_mask;
    reg [3:0] clear_pending_mask;
    wire [3:0] pending_mask;
    wire [3:0] active_wake_mask;
    wire wake_request;
    wire wake_pulse;

    wakeup_controller #(
        .NUM_SOURCES(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .sleep_armed(sleep_armed),
        .source_level(source_level),
        .enable_mask(enable_mask),
        .edge_mask(edge_mask),
        .clear_pending_mask(clear_pending_mask),
        .pending_mask(pending_mask),
        .active_wake_mask(active_wake_mask),
        .wake_request(wake_request),
        .wake_pulse(wake_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        sleep_armed = 1'b0;
        source_level = 4'b0000;
        enable_mask = 4'b0000;
        edge_mask = 4'b0000;
        clear_pending_mask = 4'b0000;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        if (pending_mask !== 4'b0000 || wake_request || wake_pulse) begin
            $fatal(1, "reset should clear wake state");
        end

        sleep_armed = 1'b1;
        enable_mask = 4'b0001;
        source_level[0] = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (pending_mask !== 4'b0001 || active_wake_mask !== 4'b0001 || !wake_request || !wake_pulse) begin
            $fatal(1, "enabled level wake should latch pending state and request wake");
        end

        source_level[0] = 1'b0;
        @(posedge clk);
        @(negedge clk);
        if (pending_mask !== 4'b0001 || !wake_request) begin
            $fatal(1, "pending wake state should remain sticky after the source drops");
        end

        clear_pending_mask = 4'b0001;
        @(posedge clk);
        clear_pending_mask = 4'b0000;
        @(negedge clk);
        if (pending_mask !== 4'b0000 || wake_request) begin
            $fatal(1, "clear mask should remove the requested pending wake bit");
        end

        enable_mask = 4'b0010;
        edge_mask = 4'b0010;
        source_level[1] = 1'b0;
        @(posedge clk);
        @(negedge clk);
        source_level[1] = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (pending_mask !== 4'b0010 || !wake_request || !wake_pulse) begin
            $fatal(1, "enabled edge wake should trigger on a rising transition");
        end

        source_level[1] = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (wake_pulse) begin
            $fatal(1, "edge wake should not re-pulse while the source stays high");
        end

        clear_pending_mask = 4'b0010;
        enable_mask = 4'b0000;
        edge_mask = 4'b0000;
        source_level = 4'b0000;
        @(posedge clk);
        clear_pending_mask = 4'b0000;

        enable_mask = 4'b0100;
        source_level[3] = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (pending_mask !== 4'b0000 || wake_request || wake_pulse) begin
            $fatal(1, "masked sources should not create pending wake state");
        end

        $display("wakeup_controller_tb passed");
        $finish;
    end
endmodule
