module timer_block_formal;
    localparam integer COUNT_WIDTH = 8;
    localparam integer PRESCALE_WIDTH = 2;

    reg [4:0] formal_ticks;

    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 5'd3);

    (* anyseq *) reg start_pulse;
    (* anyseq *) reg stop_pulse;
    (* anyseq *) reg clear_pulse;
    (* anyseq *) reg load_pulse;
    (* anyseq *) reg periodic_en;
    (* anyseq *) reg irq_enable;
    (* anyseq *) reg irq_ack;
    (* anyseq *) reg [COUNT_WIDTH-1:0] load_value;
    (* anyseq *) reg [COUNT_WIDTH-1:0] reload_value;
    (* anyseq *) reg [PRESCALE_WIDTH-1:0] prescale_div;
    wire running;
    wire expire_pulse;
    wire irq;
    wire [COUNT_WIDTH-1:0] count_value;

    timer_block #(
        .COUNT_WIDTH(COUNT_WIDTH),
        .PRESCALE_WIDTH(PRESCALE_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_pulse(start_pulse),
        .stop_pulse(stop_pulse),
        .clear_pulse(clear_pulse),
        .load_pulse(load_pulse),
        .periodic_en(periodic_en),
        .irq_enable(irq_enable),
        .irq_ack(irq_ack),
        .load_value(load_value),
        .reload_value(reload_value),
        .prescale_div(prescale_div),
        .running(running),
        .expire_pulse(expire_pulse),
        .irq(irq),
        .count_value(count_value)
    );

    initial begin
        formal_ticks = 5'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (!rst_n) begin
            assert(!running);
            assert(!expire_pulse);
            assert(!irq);
            assert(count_value == {COUNT_WIDTH{1'b0}});
        end
    end
endmodule
