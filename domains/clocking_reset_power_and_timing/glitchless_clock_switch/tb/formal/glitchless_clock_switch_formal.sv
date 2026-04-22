module glitchless_clock_switch_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_select_req;
    reg prev_switch_busy;
    wire clk_a = formal_ticks[0];
    wire clk_b = formal_ticks[1];
    wire rst_n = (formal_ticks >= 6'd4);
    (* anyseq *) reg select_req;

    wire switched_clk;
    wire active_select;
    wire active_select_valid;
    wire source_a_active;
    wire source_b_active;
    wire switch_busy;

    glitchless_clock_switch #(
        .DEFAULT_SOURCE(0),
        .STATUS_EN(1)
    ) dut (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .rst_n(rst_n),
        .select_req(select_req),
        .switched_clk(switched_clk),
        .active_select(active_select),
        .active_select_valid(active_select_valid),
        .source_a_active(source_a_active),
        .source_b_active(source_b_active),
        .switch_busy(switch_busy)
    );

    initial begin
        formal_ticks = 6'd0;
        past_valid = 1'b0;
        prev_select_req = 1'b0;
        prev_switch_busy = 1'b0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (past_valid && prev_switch_busy) begin
            assume(select_req == prev_select_req);
        end

        assert(!(source_a_active && source_b_active));
        assert(active_select_valid == (source_a_active || source_b_active));
        assert(switched_clk == ((source_a_active && clk_a) || (source_b_active && clk_b)));

        if (!rst_n) begin
            assert(source_a_active);
            assert(!source_b_active);
            assert(active_select_valid);
            assert(!active_select);
            assert(!switch_busy);
        end
        else begin
            if (source_a_active) begin
                assert(!active_select);
            end

            if (source_b_active) begin
                assert(active_select);
            end

            assert(switch_busy == ((!active_select_valid) || (select_req != active_select)));
        end

        past_valid <= 1'b1;
        prev_select_req <= select_req;
        prev_switch_busy <= switch_busy;
    end
endmodule
