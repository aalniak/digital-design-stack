module popcount_unit_formal;
    localparam int DATA_WIDTH = 5;
    localparam int COUNT_WIDTH = 3;

    (* anyconst *) logic [DATA_WIDTH-1:0] data_in;

    logic [COUNT_WIDTH-1:0] count_out;
    logic is_zero;
    logic is_full;

    logic [COUNT_WIDTH-1:0] expected_count;
    integer i;

    popcount_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .RETURN_FLAGS_EN(1'b1)
    ) dut (
        .data_in(data_in),
        .count_out(count_out),
        .is_zero(is_zero),
        .is_full(is_full)
    );

    always @* begin
        expected_count = '0;
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            if (data_in[i]) begin
                expected_count = expected_count + COUNT_WIDTH'(1);
            end
        end

        assert(count_out == expected_count);
        assert(is_zero == (expected_count == '0));
        assert(is_full == (expected_count == COUNT_WIDTH'(DATA_WIDTH)));
    end
endmodule
