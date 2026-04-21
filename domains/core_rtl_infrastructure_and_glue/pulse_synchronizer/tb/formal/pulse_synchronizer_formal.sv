module pulse_synchronizer_formal;
    reg [4:0] formal_ticks;
    reg prev_src_clk;
    reg prev_dst_clk;
    reg prev_dst_pulse_sampled;

    wire src_clk = formal_ticks[0];
    wire dst_clk = formal_ticks[1];
    wire src_rst_n = (formal_ticks >= 5'd3);
    wire dst_rst_n = (formal_ticks >= 5'd5);

    (* anyseq *) reg src_pulse;
    wire src_busy;
    wire dst_pulse;

    wire src_rise = (!prev_src_clk && src_clk);
    wire dst_rise = (!prev_dst_clk && dst_clk);

    pulse_synchronizer #(
        .SYNC_STAGES(2)
    ) dut (
        .src_clk(src_clk),
        .src_rst_n(src_rst_n),
        .src_pulse(src_pulse),
        .src_busy(src_busy),
        .dst_clk(dst_clk),
        .dst_rst_n(dst_rst_n),
        .dst_pulse(dst_pulse)
    );

    initial begin
        formal_ticks = 5'd0;
        prev_src_clk = 1'b0;
        prev_dst_clk = 1'b0;
        prev_dst_pulse_sampled = 1'b0;
    end

    always @($global_clock) begin
        prev_src_clk <= src_clk;
        prev_dst_clk <= dst_clk;
        formal_ticks <= formal_ticks + 1'b1;

        if (!src_rst_n) begin
            assume(!src_pulse);
            assert(!src_busy);
        end
        if (!dst_rst_n) begin
            assert(!dst_pulse);
        end

        if (!dst_rst_n) begin
            prev_dst_pulse_sampled <= 1'b0;
        end
        else if (dst_rise) begin
            assert(!(prev_dst_pulse_sampled && dst_pulse));
            prev_dst_pulse_sampled <= dst_pulse;
        end
    end
endmodule
