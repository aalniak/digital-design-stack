module free_running_counter_formal;
    localparam integer COUNT_WIDTH = 4;
    localparam [COUNT_WIDTH-1:0] RESET_VALUE = {COUNT_WIDTH{1'b0}};

    reg [4:0] formal_ticks;
    wire clk = formal_ticks[0];

    (* anyseq *) reg rst_tail;
    (* anyseq *) reg enable;
    (* anyseq *) reg load;
    (* anyseq *) reg [COUNT_WIDTH-1:0] load_value;
    (* anyseq *) reg capture;

    wire rst_n = (formal_ticks < 5'd3) ? 1'b0 : rst_tail;
    wire [COUNT_WIDTH-1:0] count_value;
    wire [COUNT_WIDTH-1:0] capture_value;
    wire rollover_pulse;

    free_running_counter #(
        .COUNT_WIDTH(COUNT_WIDTH),
        .RESET_VALUE(RESET_VALUE),
        .ENABLE_EN(1'b1),
        .ROLLOVER_PULSE_EN(1'b1),
        .CAPTURE_EN(1'b1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .load(load),
        .load_value(load_value),
        .capture(capture),
        .count_value(count_value),
        .capture_value(capture_value),
        .rollover_pulse(rollover_pulse)
    );

    initial begin
        formal_ticks = 5'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (!rst_n) begin
            assert(count_value == RESET_VALUE);
            assert(capture_value == RESET_VALUE);
            assert(!rollover_pulse);
        end

        if (rollover_pulse) begin
            assert(count_value == {COUNT_WIDTH{1'b0}});
        end
    end
endmodule
