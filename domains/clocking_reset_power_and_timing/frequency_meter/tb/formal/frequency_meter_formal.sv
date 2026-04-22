module frequency_meter_formal;
    wire ref_clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg enable;
    (* anyseq *) reg start;
    (* anyseq *) reg measured_clk;
    (* anyseq *) reg [7:0] min_acceptable_count;
    (* anyseq *) reg [7:0] max_acceptable_count;

    wire [7:0] measured_count;
    wire [7:0] average_count;
    wire result_valid;
    wire sample_valid;
    wire busy;
    wire below_range;
    wire above_range;
    wire out_of_range;

    frequency_meter #(
        .COUNTER_WIDTH(8),
        .WINDOW_CYCLES(16),
        .CONTINUOUS_MODE(1),
        .RANGE_CHECK_EN(1),
        .AVERAGING_EN(1),
        .AVERAGE_SHIFT(1)
    ) dut (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .enable(enable),
        .start(start),
        .measured_clk(measured_clk),
        .min_acceptable_count(min_acceptable_count),
        .max_acceptable_count(max_acceptable_count),
        .measured_count(measured_count),
        .average_count(average_count),
        .result_valid(result_valid),
        .sample_valid(sample_valid),
        .busy(busy),
        .below_range(below_range),
        .above_range(above_range),
        .out_of_range(out_of_range)
    );

    always @(*) begin
        assert(measured_count == 8'd0);
        assert(average_count == 8'd0);
        assert(result_valid == 1'b0);
        assert(sample_valid == 1'b0);
        assert(busy == 1'b0);
        assert(below_range == 1'b0);
        assert(above_range == 1'b0);
        assert(out_of_range == 1'b0);
    end
endmodule
