module clock_enable_generator_formal;
    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg enable;
    (* anyseq *) reg bypass;
    (* anyseq *) reg load_period;
    (* anyseq *) reg [7:0] period_value;

    wire enable_pulse;
    wire [7:0] active_period;
    wire [7:0] phase_count;
    wire pending_update;
    wire running;

    clock_enable_generator #(
        .DEFAULT_PERIOD(4),
        .PERIOD_WIDTH(8),
        .PULSE_WIDTH(1),
        .PROGRAMMABLE_EN(1),
        .RESTART_ON_WRITE(0),
        .BYPASS_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .bypass(bypass),
        .load_period(load_period),
        .period_value(period_value),
        .enable_pulse(enable_pulse),
        .active_period(active_period),
        .phase_count(phase_count),
        .pending_update(pending_update),
        .running(running)
    );

    always @(*) begin
        assert(!enable_pulse);
        assert(!pending_update);
        assert(!running);
        assert(phase_count == 8'd0);
    end
endmodule
