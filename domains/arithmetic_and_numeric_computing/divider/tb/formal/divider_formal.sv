module divider_formal;
    localparam int DATA_WIDTH = 4;

    (* anyconst *) logic [DATA_WIDTH-1:0] dividend;
    (* anyconst *) logic [DATA_WIDTH-1:0] divisor;

    logic [DATA_WIDTH-1:0] quotient;
    logic [DATA_WIDTH-1:0] remainder;
    logic divide_by_zero;
    logic overflow;

    localparam logic [DATA_WIDTH-1:0] SIGNED_MIN = {1'b1, {(DATA_WIDTH-1){1'b0}}};
    localparam logic [DATA_WIDTH-1:0] SIGNED_MAX = {1'b0, {(DATA_WIDTH-1){1'b1}}};

    logic [DATA_WIDTH-1:0] expected_quotient;
    logic [DATA_WIDTH-1:0] expected_remainder;
    logic expected_divide_by_zero;
    logic expected_overflow;

    divider #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1),
        .RETURN_REMAINDER_EN(1'b1),
        .SATURATE_ON_OVERFLOW(1'b1),
        .DIVIDE_BY_ZERO_QUOTIENT_ONES(1'b1)
    ) dut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .divide_by_zero(divide_by_zero),
        .overflow(overflow)
    );

    always @* begin
        expected_quotient = '0;
        expected_remainder = '0;
        expected_divide_by_zero = 1'b0;
        expected_overflow = 1'b0;

        if (divisor == '0) begin
            expected_divide_by_zero = 1'b1;
            expected_quotient = {DATA_WIDTH{1'b1}};
            expected_remainder = dividend;
        end else if ((dividend == SIGNED_MIN) && (divisor == {DATA_WIDTH{1'b1}})) begin
            expected_overflow = 1'b1;
            expected_quotient = SIGNED_MAX;
            expected_remainder = '0;
        end else begin
            expected_quotient = $signed(dividend) / $signed(divisor);
            expected_remainder = $signed(dividend) % $signed(divisor);
        end

        assert(quotient == expected_quotient);
        assert(remainder == expected_remainder);
        assert(divide_by_zero == expected_divide_by_zero);
        assert(overflow == expected_overflow);
    end
endmodule
