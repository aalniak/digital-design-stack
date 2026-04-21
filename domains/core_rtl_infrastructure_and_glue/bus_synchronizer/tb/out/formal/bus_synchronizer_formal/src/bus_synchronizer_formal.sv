module bus_synchronizer_formal;
    localparam integer DATA_WIDTH = 8;
    reg [4:0] formal_ticks;
    reg prev_dst_clk;
    reg prev_dst_pulse_sampled;

    wire src_clk = formal_ticks[0];
    wire dst_clk = formal_ticks[1];
    wire src_rst_n = (formal_ticks >= 5'd3);
    wire dst_rst_n = (formal_ticks >= 5'd5);

    (* anyseq *) reg [DATA_WIDTH-1:0] src_data;
    (* anyseq *) reg src_valid;
    wire src_ready;
    wire [DATA_WIDTH-1:0] dst_data;
    wire dst_valid;
    wire dst_pulse;
    (* anyseq *) reg dst_ready;

    wire dst_rise = (!prev_dst_clk && dst_clk);

    bus_synchronizer #(
        .DATA_WIDTH(DATA_WIDTH),
        .SYNC_STAGES(2),
        .RESET_VALUE({DATA_WIDTH{1'b0}})
    ) dut (
        .src_clk(src_clk),
        .src_rst_n(src_rst_n),
        .src_data(src_data),
        .src_valid(src_valid),
        .src_ready(src_ready),
        .dst_clk(dst_clk),
        .dst_rst_n(dst_rst_n),
        .dst_data(dst_data),
        .dst_valid(dst_valid),
        .dst_pulse(dst_pulse),
        .dst_ready(dst_ready)
    );

    initial begin
        formal_ticks = 5'd0;
        prev_dst_clk = 1'b0;
        prev_dst_pulse_sampled = 1'b0;
    end

    always @($global_clock) begin
        prev_dst_clk <= dst_clk;
        formal_ticks <= formal_ticks + 1'b1;

        if (!src_rst_n) begin
            assume(!src_valid);
            assert(src_ready);
        end

        if (!dst_rst_n) begin
            assert(!dst_valid);
            assert(!dst_pulse);
            assert(dst_data == {DATA_WIDTH{1'b0}});
            prev_dst_pulse_sampled <= 1'b0;
        end
        else if (dst_rise) begin
            if (dst_pulse) begin
                assert(dst_valid);
            end
            assert(!(prev_dst_pulse_sampled && dst_pulse));
            prev_dst_pulse_sampled <= dst_pulse;
        end
    end
endmodule
