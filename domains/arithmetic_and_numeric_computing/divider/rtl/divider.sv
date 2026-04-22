module divider #(
    parameter int DATA_WIDTH = 16,
    parameter bit SIGNED_MODE = 1'b1,
    parameter bit RETURN_REMAINDER_EN = 1'b1,
    parameter bit SATURATE_ON_OVERFLOW = 1'b1,
    parameter bit DIVIDE_BY_ZERO_QUOTIENT_ONES = 1'b1
) (
    input  logic [DATA_WIDTH-1:0] dividend,
    input  logic [DATA_WIDTH-1:0] divisor,
    output logic [DATA_WIDTH-1:0] quotient,
    output logic [DATA_WIDTH-1:0] remainder,
    output logic                  divide_by_zero,
    output logic                  overflow
);

    localparam logic [DATA_WIDTH-1:0] SIGNED_MIN = {1'b1, {(DATA_WIDTH-1){1'b0}}};
    localparam logic [DATA_WIDTH-1:0] SIGNED_MAX = {1'b0, {(DATA_WIDTH-1){1'b1}}};

    always @* begin
        quotient = '0;
        remainder = '0;
        divide_by_zero = 1'b0;
        overflow = 1'b0;

        if (divisor == '0) begin
            divide_by_zero = 1'b1;
            quotient = DIVIDE_BY_ZERO_QUOTIENT_ONES ? {DATA_WIDTH{1'b1}} : '0;
            remainder = dividend;
        end else if (SIGNED_MODE && (dividend == SIGNED_MIN) && (divisor == {DATA_WIDTH{1'b1}})) begin
            overflow = 1'b1;
            if (SATURATE_ON_OVERFLOW) begin
                quotient = SIGNED_MAX;
            end else begin
                quotient = SIGNED_MIN;
            end
            remainder = '0;
        end else if (SIGNED_MODE) begin
            quotient = $signed(dividend) / $signed(divisor);
            remainder = $signed(dividend) % $signed(divisor);
        end else begin
            quotient = dividend / divisor;
            remainder = dividend % divisor;
        end

        if (!RETURN_REMAINDER_EN) begin
            remainder = '0;
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("divider requires DATA_WIDTH >= 1");
            $finish;
        end
    end
endmodule
