module clock_gating_wrapper_formal;
    wire clk_in = 1'b1;
    wire rst_n = 1'b0;

    (* anyseq *) reg enable_req;
    (* anyseq *) reg test_bypass;
    (* anyseq *) reg bypass;

    wire gated_clk;
    wire domain_ce;
    wire gate_open;
    wire override_active;

    clock_gating_wrapper #(
        .DEFAULT_ENABLE(0),
        .ACTIVE_HIGH_ENABLE(1),
        .TEST_BYPASS_EN(1),
        .BYPASS_EN(1),
        .FPGA_SAFE_MODE(0),
        .ENABLE_SYNC_STAGES(0)
    ) dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .enable_req(enable_req),
        .test_bypass(test_bypass),
        .bypass(bypass),
        .gated_clk(gated_clk),
        .domain_ce(domain_ce),
        .gate_open(gate_open),
        .override_active(override_active)
    );

    always @(*) begin
        assert(!gate_open);
        assert(!domain_ce);
        assert(!override_active);
        assert(!gated_clk);
    end
endmodule
