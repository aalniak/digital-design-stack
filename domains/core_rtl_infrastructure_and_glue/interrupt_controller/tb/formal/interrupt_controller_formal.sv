module interrupt_controller_formal;
    localparam integer NUM_SOURCES = 4;
    localparam integer ID_WIDTH = (NUM_SOURCES <= 1) ? 1 : $clog2(NUM_SOURCES);

    reg [4:0] formal_ticks;

    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 5'd3);

    (* anyseq *) reg [NUM_SOURCES-1:0] src_event;
    (* anyseq *) reg [NUM_SOURCES-1:0] src_level_mode;
    (* anyseq *) reg [NUM_SOURCES-1:0] enable_mask;
    (* anyseq *) reg [NUM_SOURCES-1:0] sw_set;
    (* anyseq *) reg [NUM_SOURCES-1:0] ack_mask;
    wire [NUM_SOURCES-1:0] raw_status;
    wire [NUM_SOURCES-1:0] pending_status;
    wire [NUM_SOURCES-1:0] active_onehot;
    wire irq;
    wire [ID_WIDTH-1:0] irq_id;

    interrupt_controller #(
        .NUM_SOURCES(NUM_SOURCES)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .src_event(src_event),
        .src_level_mode(src_level_mode),
        .enable_mask(enable_mask),
        .sw_set(sw_set),
        .ack_mask(ack_mask),
        .raw_status(raw_status),
        .pending_status(pending_status),
        .active_onehot(active_onehot),
        .irq(irq),
        .irq_id(irq_id)
    );

    initial begin
        formal_ticks = 5'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (!rst_n) begin
            assert(pending_status == {NUM_SOURCES{1'b0}});
            assert(!irq);
        end

        assert((active_onehot & ~(pending_status & enable_mask)) == {NUM_SOURCES{1'b0}});
        assert(irq == (active_onehot != {NUM_SOURCES{1'b0}}));
    end
endmodule
