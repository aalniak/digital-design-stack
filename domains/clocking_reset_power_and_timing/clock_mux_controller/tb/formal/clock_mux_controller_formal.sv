module clock_mux_controller_formal;
    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg request_valid;
    (* anyseq *) reg [1:0] requested_source;
    (* anyseq *) reg [2:0] source_healthy;
    (* anyseq *) reg inhibit_switch;
    (* anyseq *) reg clear_sticky;

    wire [1:0] mux_select;
    wire [1:0] active_source;
    wire [1:0] pending_source;
    wire pending_source_valid;
    wire switch_in_progress;
    wire hold_request;
    wire active_source_healthy;
    wire request_reject_pulse;
    wire switch_done_pulse;
    wire auto_failover_pulse;
    wire fault_status;
    wire auto_failover_status;

    clock_mux_controller #(
        .NUM_SOURCES(3),
        .DEFAULT_SOURCE(0),
        .WAIT_FOR_STABLE_EN(1),
        .STABLE_CYCLES(2),
        .AUTO_FAILOVER_EN(1),
        .HOLD_CYCLES(2),
        .STATUS_STICKY_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .request_valid(request_valid),
        .requested_source(requested_source),
        .source_healthy(source_healthy),
        .inhibit_switch(inhibit_switch),
        .clear_sticky(clear_sticky),
        .mux_select(mux_select),
        .active_source(active_source),
        .pending_source(pending_source),
        .pending_source_valid(pending_source_valid),
        .switch_in_progress(switch_in_progress),
        .hold_request(hold_request),
        .active_source_healthy(active_source_healthy),
        .request_reject_pulse(request_reject_pulse),
        .switch_done_pulse(switch_done_pulse),
        .auto_failover_pulse(auto_failover_pulse),
        .fault_status(fault_status),
        .auto_failover_status(auto_failover_status)
    );

    always @(*) begin
        assert(mux_select == 2'd0);
        assert(active_source == 2'd0);
        assert(pending_source_valid == 1'b0);
        assert(switch_in_progress == 1'b0);
        assert(hold_request == 1'b0);
        assert(active_source_healthy == 1'b0);
        assert(request_reject_pulse == 1'b0);
        assert(switch_done_pulse == 1'b0);
        assert(auto_failover_pulse == 1'b0);
        assert(fault_status == 1'b0);
        assert(auto_failover_status == 1'b0);
    end
endmodule
