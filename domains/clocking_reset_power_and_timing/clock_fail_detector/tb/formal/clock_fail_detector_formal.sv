module clock_fail_detector_formal;
    wire ref_clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg enable;
    (* anyseq *) reg mon_clk;
    (* anyseq *) reg clear_fault;

    wire fault;
    wire healthy;
    wire timeout_event;
    wire window_event;
    wire monitored_edge_pulse;
    wire [3:0] window_edge_count;

    clock_fail_detector #(
        .WINDOW_CYCLES(12),
        .TIMEOUT_CYCLES(10),
        .MIN_EDGES(3),
        .MAX_EDGES(5),
        .FILTER_DEPTH(1),
        .STICKY_FAULT_EN(1),
        .AUTO_RECOVER_EN(0)
    ) dut (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .enable(enable),
        .mon_clk(mon_clk),
        .clear_fault(clear_fault),
        .fault(fault),
        .healthy(healthy),
        .timeout_event(timeout_event),
        .window_event(window_event),
        .monitored_edge_pulse(monitored_edge_pulse),
        .window_edge_count(window_edge_count)
    );

    always @(*) begin
        assert(!fault);
        assert(!healthy);
        assert(!timeout_event);
        assert(!window_event);
        assert(!monitored_edge_pulse);
        assert(window_edge_count == 4'd0);
    end
endmodule
