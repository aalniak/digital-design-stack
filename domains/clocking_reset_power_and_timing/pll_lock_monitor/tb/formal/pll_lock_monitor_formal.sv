module pll_lock_monitor_formal;
    localparam integer ASSERT_FILTER = 3;
    localparam integer DEASSERT_FILTER = 2;
    localparam integer RELOCK_HOLDOFF = 2;

    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg enable;
    (* anyseq *) reg raw_lock;
    (* anyseq *) reg ref_ok;
    (* anyseq *) reg reconfig_busy;
    (* anyseq *) reg clear_sticky;
    (* anyseq *) reg bypass_force_ready;

    wire filtered_lock;
    wire stable_ready;
    wire sticky_loss;
    wire qualifying;
    wire holdoff_active;
    wire lock_acquired_pulse;
    wire lock_lost_pulse;
    wire [1:0] qualify_count;
    wire [1:0] holdoff_count;

    pll_lock_monitor #(
        .ASSERT_FILTER(ASSERT_FILTER),
        .DEASSERT_FILTER(DEASSERT_FILTER),
        .STICKY_LOSS_EN(1),
        .RELOCK_HOLDOFF(RELOCK_HOLDOFF),
        .BYPASS_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .raw_lock(raw_lock),
        .ref_ok(ref_ok),
        .reconfig_busy(reconfig_busy),
        .clear_sticky(clear_sticky),
        .bypass_force_ready(bypass_force_ready),
        .filtered_lock(filtered_lock),
        .stable_ready(stable_ready),
        .sticky_loss(sticky_loss),
        .qualifying(qualifying),
        .holdoff_active(holdoff_active),
        .lock_acquired_pulse(lock_acquired_pulse),
        .lock_lost_pulse(lock_lost_pulse),
        .qualify_count(qualify_count),
        .holdoff_count(holdoff_count)
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
            assume(!clear_sticky);
        end

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(!filtered_lock);
                assert(!stable_ready);
                assert(!sticky_loss);
                assert(!lock_acquired_pulse);
                assert(!lock_lost_pulse);
            end
            else begin
                assert(!(lock_acquired_pulse && lock_lost_pulse));
                assert(holdoff_active ? !stable_ready : 1'b1);
                assert(qualifying ? enable : 1'b1);

                if (bypass_force_ready) begin
                    assert(filtered_lock);
                    assert(stable_ready);
                end
            end
        end
    end
endmodule
