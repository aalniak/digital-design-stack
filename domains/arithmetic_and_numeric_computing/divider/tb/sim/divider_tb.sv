module divider_tb;
    logic [3:0] unsigned_dividend;
    logic [3:0] unsigned_divisor;
    logic [3:0] unsigned_quotient;
    logic [3:0] unsigned_remainder;
    logic unsigned_divide_by_zero;
    logic unsigned_overflow;

    logic [3:0] signed_dividend;
    logic [3:0] signed_divisor;
    logic [3:0] signed_quotient;
    logic [3:0] signed_remainder;
    logic signed_divide_by_zero;
    logic signed_overflow;

    logic [3:0] quiet_dividend;
    logic [3:0] quiet_divisor;
    logic [3:0] quiet_quotient;
    logic [3:0] quiet_remainder;
    logic quiet_divide_by_zero;
    logic quiet_overflow;

    divider #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .RETURN_REMAINDER_EN(1'b1),
        .SATURATE_ON_OVERFLOW(1'b1),
        .DIVIDE_BY_ZERO_QUOTIENT_ONES(1'b1)
    ) dut_unsigned (
        .dividend(unsigned_dividend),
        .divisor(unsigned_divisor),
        .quotient(unsigned_quotient),
        .remainder(unsigned_remainder),
        .divide_by_zero(unsigned_divide_by_zero),
        .overflow(unsigned_overflow)
    );

    divider #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b1),
        .RETURN_REMAINDER_EN(1'b1),
        .SATURATE_ON_OVERFLOW(1'b1),
        .DIVIDE_BY_ZERO_QUOTIENT_ONES(1'b1)
    ) dut_signed (
        .dividend(signed_dividend),
        .divisor(signed_divisor),
        .quotient(signed_quotient),
        .remainder(signed_remainder),
        .divide_by_zero(signed_divide_by_zero),
        .overflow(signed_overflow)
    );

    divider #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .RETURN_REMAINDER_EN(1'b0),
        .SATURATE_ON_OVERFLOW(1'b1),
        .DIVIDE_BY_ZERO_QUOTIENT_ONES(1'b1)
    ) dut_quiet (
        .dividend(quiet_dividend),
        .divisor(quiet_divisor),
        .quotient(quiet_quotient),
        .remainder(quiet_remainder),
        .divide_by_zero(quiet_divide_by_zero),
        .overflow(quiet_overflow)
    );

    task automatic expect4(
        input [3:0] actual,
        input [3:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0h expected=%0h", label, actual, expected);
            $fatal;
        end
    endtask

    task automatic expect1(
        input logic actual,
        input logic expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0b expected=%0b", label, actual, expected);
            $fatal;
        end
    endtask

    initial begin
        unsigned_dividend = 4'd13;
        unsigned_divisor = 4'd5;
        signed_dividend = -4'sd7;
        signed_divisor = 4'sd3;
        quiet_dividend = 4'd13;
        quiet_divisor = 4'd5;
        #1;

        expect4(unsigned_quotient, 4'd2, "unsigned quotient");
        expect4(unsigned_remainder, 4'd3, "unsigned remainder");
        expect1(unsigned_divide_by_zero, 1'b0, "unsigned divide_by_zero");
        expect1(unsigned_overflow, 1'b0, "unsigned overflow");

        expect4(signed_quotient, -4'sd2, "signed quotient");
        expect4(signed_remainder, -4'sd1, "signed remainder");
        expect1(signed_divide_by_zero, 1'b0, "signed divide_by_zero");
        expect1(signed_overflow, 1'b0, "signed overflow");

        quiet_dividend = 4'd13;
        quiet_divisor = 4'd5;
        #1;
        expect4(quiet_quotient, 4'd2, "quiet quotient");
        expect4(quiet_remainder, 4'd0, "quiet remainder suppressed");
        expect1(quiet_divide_by_zero, 1'b0, "quiet divide_by_zero");

        unsigned_dividend = 4'd9;
        unsigned_divisor = 4'd0;
        #1;
        expect4(unsigned_quotient, 4'hf, "divide-by-zero quotient");
        expect4(unsigned_remainder, 4'd9, "divide-by-zero remainder");
        expect1(unsigned_divide_by_zero, 1'b1, "divide-by-zero flag");
        expect1(unsigned_overflow, 1'b0, "divide-by-zero overflow");

        signed_dividend = -4'sd8;
        signed_divisor = -4'sd1;
        #1;
        expect4(signed_quotient, 4'sd7, "signed overflow quotient");
        expect4(signed_remainder, 4'd0, "signed overflow remainder");
        expect1(signed_divide_by_zero, 1'b0, "signed overflow divide_by_zero");
        expect1(signed_overflow, 1'b1, "signed overflow flag");

        $display("divider_tb passed");
        $finish;
    end
endmodule
