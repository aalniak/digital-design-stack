module clock_divider_formal;
    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg enable;
    (* anyseq *) reg bypass;
    (* anyseq *) reg load_divisor;
    (* anyseq *) reg [7:0] divisor_value;

    wire clk_out;
    wire tick_pulse;
    wire [7:0] active_divisor;
    wire pending_update;
    wire running;

    clock_divider #(
        .DEFAULT_DIVISOR(4),
        .DIVISOR_WIDTH(8),
        .PROGRAMMABLE_EN(1),
        .BYPASS_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .bypass(bypass),
        .load_divisor(load_divisor),
        .divisor_value(divisor_value),
        .clk_out(clk_out),
        .tick_pulse(tick_pulse),
        .active_divisor(active_divisor),
        .pending_update(pending_update),
        .running(running)
    );

    always @(*) begin
        assert(!tick_pulse);
        assert(!clk_out);
        assert(!pending_update);
        assert(!running);
    end
endmodule
