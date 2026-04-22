module pps_capture_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg enable;
    (* anyseq *) reg pps_in;
    (* anyseq *) reg clear_flags;
    (* anyseq *) reg [7:0] timestamp_in;

    wire capture_valid;
    wire [7:0] captured_timestamp;
    wire interval_valid;
    wire [7:0] interval_delta;
    wire first_capture_seen;
    wire selected_edge_pulse;
    wire glitch_reject_pulse;
    wire glitch_reject_sticky;
    wire qualified_level;

    pps_capture #(
        .TIMESTAMP_WIDTH(8),
        .EDGE_MODE(0),
        .FILTER_EN(1),
        .FILTER_CYCLES(2),
        .INTERVAL_MEASURE_EN(1),
        .CDC_MODE(1)
    ) dut (
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

    initial begin
        formal_ticks = 6'd0;
        past_valid = 1'b0;
        prev_clk = 1'b0;
    end

    always @($global_clock) begin
        prev_clk <= clk;
        formal_ticks <= formal_ticks + 1'b1;
        past_valid <= 1'b1;

        if (!past_valid) begin
            assume(!clear_flags);
        end

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(!capture_valid);
                assert(!interval_valid);
                assert(!selected_edge_pulse);
                assert(!glitch_reject_pulse);
                assert(!glitch_reject_sticky);
                assert(!first_capture_seen);
            end
            else begin
                assert(interval_valid ? first_capture_seen : 1'b1);
                assert(capture_valid == selected_edge_pulse);
                assert(glitch_reject_pulse ? glitch_reject_sticky : 1'b1);
            end
        end
    end
endmodule
