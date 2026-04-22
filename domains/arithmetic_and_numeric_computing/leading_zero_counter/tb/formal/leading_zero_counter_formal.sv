module leading_zero_counter_formal;
    localparam int DATA_WIDTH = 5;
    localparam int COUNT_WIDTH = 3;
    localparam int INDEX_WIDTH = 3;

    (* anyconst *) logic [DATA_WIDTH-1:0] data_in;

    logic [COUNT_WIDTH-1:0] leading_zero_count;
    logic all_zero;
    logic [INDEX_WIDTH-1:0] msb_index;

    logic [COUNT_WIDTH-1:0] expected_count;
    logic expected_all_zero;
    logic [INDEX_WIDTH-1:0] expected_index;
    integer i;

    leading_zero_counter #(
        .DATA_WIDTH(DATA_WIDTH),
        .RETURN_MSB_INDEX_EN(1'b1)
    ) dut (
        .data_in(data_in),
        .leading_zero_count(leading_zero_count),
        .all_zero(all_zero),
        .msb_index(msb_index)
    );

    always @* begin
        expected_count = COUNT_WIDTH'(DATA_WIDTH);
        expected_all_zero = 1'b1;
        expected_index = '0;

        for (i = DATA_WIDTH - 1; i >= 0; i = i - 1) begin
            if (expected_all_zero && data_in[i]) begin
                expected_all_zero = 1'b0;
                expected_count = COUNT_WIDTH'(DATA_WIDTH - 1 - i);
                expected_index = INDEX_WIDTH'(i);
            end
        end

        assert(all_zero == expected_all_zero);
        assert(leading_zero_count == expected_count);
        assert(msb_index == expected_index);
    end
endmodule
