module timestamp_counter_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg enable;
    (* anyseq *) reg clear;
    (* anyseq *) reg load;
    (* anyseq *) reg [7:0] load_value;
    (* anyseq *) reg capture_req;
    (* anyseq *) reg compare_enable;
    (* anyseq *) reg [7:0] compare_value;

    wire [7:0] timestamp;
    wire [7:0] capture_value;
    wire tick_pulse;
    wire capture_valid;
    wire compare_hit;
    wire overflow_pulse;

    timestamp_counter #(
        .COUNTER_WIDTH(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear(clear),
        .load(load),
        .load_value(load_value),
        .capture_req(capture_req),
        .compare_enable(compare_enable),
        .compare_value(compare_value),
        .timestamp(timestamp),
        .capture_value(capture_value),
        .tick_pulse(tick_pulse),
        .capture_valid(capture_valid),
        .compare_hit(compare_hit),
        .overflow_pulse(overflow_pulse)
    );

    initial begin
        formal_ticks = 6'd0;
        past_valid = 1'b0;
        prev_clk = 1'b0;
    end

    always @($global_clock) begin
        prev_clk <= clk;
        formal_ticks <= formal_ticks + 1'b1;
        past_valid <= 1'b1;

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(timestamp == 8'h00);
                assert(!tick_pulse);
                assert(!capture_valid);
                assert(!compare_hit);
                assert(!overflow_pulse);
            end
        end
    end
endmodule
