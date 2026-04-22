module wakeup_controller_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg sleep_armed;
    (* anyseq *) reg [3:0] source_level;
    (* anyseq *) reg [3:0] enable_mask;
    (* anyseq *) reg [3:0] edge_mask;
    (* anyseq *) reg [3:0] clear_pending_mask;

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
        formal_ticks = 6'd0;
        past_valid = 1'b0;
        prev_clk = 1'b0;
    end

    always @($global_clock) begin
        prev_clk <= clk;
        formal_ticks <= formal_ticks + 1'b1;
        past_valid <= 1'b1;

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(pending_mask == 4'b0000);
                assert(!wake_request);
                assert(!wake_pulse);
            end
            else begin
                assert(wake_request ? (sleep_armed && (|(pending_mask & enable_mask))) : 1'b1);
                assert((active_wake_mask & ~enable_mask) == 4'b0000);
            end
        end
    end
endmodule
