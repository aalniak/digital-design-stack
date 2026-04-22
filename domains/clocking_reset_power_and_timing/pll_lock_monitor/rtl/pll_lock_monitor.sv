module pll_lock_monitor #(
    parameter integer ASSERT_FILTER = 3,
    parameter integer DEASSERT_FILTER = 2,
    parameter integer STICKY_LOSS_EN = 1,
    parameter integer RELOCK_HOLDOFF = 2,
    parameter integer BYPASS_EN = 1
) (
    input  wire                                                     clk,
    input  wire                                                     rst_n,
    input  wire                                                     enable,
    input  wire                                                     raw_lock,
    input  wire                                                     ref_ok,
    input  wire                                                     reconfig_busy,
    input  wire                                                     clear_sticky,
    input  wire                                                     bypass_force_ready,
    output wire                                                     filtered_lock,
    output wire                                                     stable_ready,
    output wire                                                     sticky_loss,
    output wire                                                     qualifying,
    output wire                                                     holdoff_active,
    output reg                                                      lock_acquired_pulse,
    output reg                                                      lock_lost_pulse,
    output wire [((ASSERT_FILTER < 1) ? 1 : $clog2(ASSERT_FILTER + 1))-1:0] qualify_count,
    output wire [((RELOCK_HOLDOFF < 1) ? 1 : $clog2(RELOCK_HOLDOFF + 1))-1:0] holdoff_count
);
    localparam integer ASSERT_COUNT_WIDTH = (ASSERT_FILTER < 1) ? 1 : $clog2(ASSERT_FILTER + 1);
    localparam integer DEASSERT_COUNT_WIDTH = (DEASSERT_FILTER < 1) ? 1 : $clog2(DEASSERT_FILTER + 1);
    localparam integer HOLDOFF_COUNT_WIDTH = (RELOCK_HOLDOFF < 1) ? 1 : $clog2(RELOCK_HOLDOFF + 1);
    localparam [ASSERT_COUNT_WIDTH-1:0] ONE_ASSERT = {{(ASSERT_COUNT_WIDTH-1){1'b0}}, 1'b1};
    localparam [DEASSERT_COUNT_WIDTH-1:0] ONE_DEASSERT = {{(DEASSERT_COUNT_WIDTH-1){1'b0}}, 1'b1};
    localparam [HOLDOFF_COUNT_WIDTH-1:0] ONE_HOLDOFF = {{(HOLDOFF_COUNT_WIDTH-1){1'b0}}, 1'b1};

    reg [ASSERT_COUNT_WIDTH-1:0] assert_count_q;
    reg [DEASSERT_COUNT_WIDTH-1:0] deassert_count_q;
    reg [HOLDOFF_COUNT_WIDTH-1:0] holdoff_count_q;
    reg filtered_lock_q;
    reg stable_ready_q;
    reg sticky_loss_q;

    wire sample_good;
    wire bypass_active;
    wire next_assert_reaches_lock;
    wire next_deassert_reaches_loss;
    wire next_holdoff_reaches_ready;

    assign sample_good = raw_lock && ref_ok && !reconfig_busy;
    assign bypass_active = rst_n && (BYPASS_EN != 0) && bypass_force_ready;

    assign next_assert_reaches_lock = ((assert_count_q + ONE_ASSERT) >= ASSERT_FILTER);
    assign next_deassert_reaches_loss = ((deassert_count_q + ONE_DEASSERT) >= DEASSERT_FILTER);
    assign next_holdoff_reaches_ready = (RELOCK_HOLDOFF == 0) || ((holdoff_count_q + ONE_HOLDOFF) >= RELOCK_HOLDOFF);

    assign filtered_lock = bypass_active ? 1'b1 : filtered_lock_q;
    assign stable_ready = bypass_active ? 1'b1 : stable_ready_q;
    assign sticky_loss = sticky_loss_q;
    assign qualifying = !bypass_active && enable && !filtered_lock_q && sample_good;
    assign holdoff_active = !bypass_active && enable && filtered_lock_q && !stable_ready_q;
    assign qualify_count = assert_count_q;
    assign holdoff_count = holdoff_count_q;

    initial begin
        if (ASSERT_FILTER < 1) begin
            $fatal(1, "pll_lock_monitor requires ASSERT_FILTER >= 1");
        end
        if (DEASSERT_FILTER < 1) begin
            $fatal(1, "pll_lock_monitor requires DEASSERT_FILTER >= 1");
        end
        if ((STICKY_LOSS_EN != 0) && (STICKY_LOSS_EN != 1)) begin
            $fatal(1, "pll_lock_monitor requires STICKY_LOSS_EN to be 0 or 1");
        end
        if (RELOCK_HOLDOFF < 0) begin
            $fatal(1, "pll_lock_monitor requires RELOCK_HOLDOFF >= 0");
        end
        if ((BYPASS_EN != 0) && (BYPASS_EN != 1)) begin
            $fatal(1, "pll_lock_monitor requires BYPASS_EN to be 0 or 1");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            assert_count_q <= {ASSERT_COUNT_WIDTH{1'b0}};
            deassert_count_q <= {DEASSERT_COUNT_WIDTH{1'b0}};
            holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};
            filtered_lock_q <= 1'b0;
            stable_ready_q <= 1'b0;
            sticky_loss_q <= 1'b0;
            lock_acquired_pulse <= 1'b0;
            lock_lost_pulse <= 1'b0;
        end
        else begin
            lock_acquired_pulse <= 1'b0;
            lock_lost_pulse <= 1'b0;

            if (clear_sticky) begin
                sticky_loss_q <= 1'b0;
            end

            if (bypass_active) begin
                assert_count_q <= {ASSERT_COUNT_WIDTH{1'b0}};
                deassert_count_q <= {DEASSERT_COUNT_WIDTH{1'b0}};
                holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};
            end
            else if (!enable) begin
                assert_count_q <= {ASSERT_COUNT_WIDTH{1'b0}};
                deassert_count_q <= {DEASSERT_COUNT_WIDTH{1'b0}};
                holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};
                filtered_lock_q <= 1'b0;
                stable_ready_q <= 1'b0;

                if (STICKY_LOSS_EN == 0) begin
                    sticky_loss_q <= 1'b0;
                end
            end
            else if (!filtered_lock_q) begin
                deassert_count_q <= {DEASSERT_COUNT_WIDTH{1'b0}};
                holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};
                stable_ready_q <= 1'b0;

                if (sample_good) begin
                    if (next_assert_reaches_lock) begin
                        assert_count_q <= {ASSERT_COUNT_WIDTH{1'b0}};
                        filtered_lock_q <= 1'b1;
                        lock_acquired_pulse <= 1'b1;

                        if (RELOCK_HOLDOFF == 0) begin
                            stable_ready_q <= 1'b1;
                        end
                    end
                    else begin
                        assert_count_q <= assert_count_q + ONE_ASSERT;
                    end
                end
                else begin
                    assert_count_q <= {ASSERT_COUNT_WIDTH{1'b0}};
                end
            end
            else begin
                assert_count_q <= {ASSERT_COUNT_WIDTH{1'b0}};

                if (!sample_good) begin
                    stable_ready_q <= 1'b0;
                    holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};

                    if (next_deassert_reaches_loss) begin
                        deassert_count_q <= {DEASSERT_COUNT_WIDTH{1'b0}};
                        filtered_lock_q <= 1'b0;
                        lock_lost_pulse <= 1'b1;

                        if (STICKY_LOSS_EN != 0) begin
                            sticky_loss_q <= 1'b1;
                        end
                    end
                    else begin
                        deassert_count_q <= deassert_count_q + ONE_DEASSERT;
                    end
                end
                else begin
                    deassert_count_q <= {DEASSERT_COUNT_WIDTH{1'b0}};

                    if (!stable_ready_q) begin
                        if (next_holdoff_reaches_ready) begin
                            holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};
                            stable_ready_q <= 1'b1;
                        end
                        else begin
                            holdoff_count_q <= holdoff_count_q + ONE_HOLDOFF;
                        end
                    end
                    else begin
                        holdoff_count_q <= {HOLDOFF_COUNT_WIDTH{1'b0}};
                    end

                    if (STICKY_LOSS_EN == 0) begin
                        sticky_loss_q <= 1'b0;
                    end
                end
            end
        end
    end
endmodule
