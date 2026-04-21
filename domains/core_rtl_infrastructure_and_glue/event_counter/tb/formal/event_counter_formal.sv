module event_counter_formal;
    localparam integer COUNT_WIDTH = 4;
    localparam [COUNT_WIDTH-1:0] RESET_VALUE = {COUNT_WIDTH{1'b0}};
    localparam [COUNT_WIDTH-1:0] THRESHOLD_VALUE = 4;

    reg [4:0] formal_ticks;
    wire clk = formal_ticks[0];

    (* anyseq *) reg rst_tail;
    (* anyseq *) reg event_pulse;
    (* anyseq *) reg count_enable;
    (* anyseq *) reg clear;
    (* anyseq *) reg snapshot;

    wire rst_n = (formal_ticks < 5'd3) ? 1'b0 : rst_tail;
    wire [COUNT_WIDTH-1:0] count_value;
    wire [COUNT_WIDTH-1:0] snapshot_value;
    wire overflow_sticky;
    wire threshold_reached;

    event_counter #(
        .COUNT_WIDTH(COUNT_WIDTH),
        .SATURATE(1'b1),
        .THRESHOLD_EN(1'b1),
        .THRESHOLD_VALUE(THRESHOLD_VALUE),
        .SNAPSHOT_EN(1'b1),
        .CLEAR_PRIORITY(1'b1),
        .RESET_VALUE(RESET_VALUE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .event_pulse(event_pulse),
        .count_enable(count_enable),
        .clear(clear),
        .snapshot(snapshot),
        .count_value(count_value),
        .snapshot_value(snapshot_value),
        .overflow_sticky(overflow_sticky),
        .threshold_reached(threshold_reached)
    );

    initial begin
        formal_ticks = 5'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (!rst_n) begin
            assert(count_value == RESET_VALUE);
            assert(snapshot_value == RESET_VALUE);
            assert(!overflow_sticky);
        end

        assert(threshold_reached == (count_value >= THRESHOLD_VALUE));
    end
endmodule
