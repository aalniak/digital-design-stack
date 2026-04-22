module abs_min_max_tb;
    logic [3:0] signed_a;
    logic [3:0] signed_b;
    logic [3:0] signed_abs;
    logic [3:0] signed_min;
    logic [3:0] signed_max;
    logic signed_eq;
    logic signed_lt;
    logic signed_abs_saturated;

    logic [3:0] unsigned_a;
    logic [3:0] unsigned_b;
    logic [3:0] unsigned_abs;
    logic [3:0] unsigned_min;
    logic [3:0] unsigned_max;
    logic unsigned_eq;
    logic unsigned_lt;
    logic unsigned_abs_saturated;

    logic [3:0] wrap_a;
    logic [3:0] wrap_b;
    logic [3:0] wrap_abs;
    logic [3:0] wrap_min;
    logic [3:0] wrap_max;
    logic wrap_eq;
    logic wrap_lt;
    logic wrap_abs_saturated;

    abs_min_max #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b1),
        .SATURATE_ABS(1'b1)
    ) dut_signed (
        .operand_a(signed_a),
        .operand_b(signed_b),
        .abs_a(signed_abs),
        .min_value(signed_min),
        .max_value(signed_max),
        .a_eq_b(signed_eq),
        .a_lt_b(signed_lt),
        .abs_saturated(signed_abs_saturated)
    );

    abs_min_max #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .SATURATE_ABS(1'b1)
    ) dut_unsigned (
        .operand_a(unsigned_a),
        .operand_b(unsigned_b),
        .abs_a(unsigned_abs),
        .min_value(unsigned_min),
        .max_value(unsigned_max),
        .a_eq_b(unsigned_eq),
        .a_lt_b(unsigned_lt),
        .abs_saturated(unsigned_abs_saturated)
    );

    abs_min_max #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b1),
        .SATURATE_ABS(1'b0)
    ) dut_wrap (
        .operand_a(wrap_a),
        .operand_b(wrap_b),
        .abs_a(wrap_abs),
        .min_value(wrap_min),
        .max_value(wrap_max),
        .a_eq_b(wrap_eq),
        .a_lt_b(wrap_lt),
        .abs_saturated(wrap_abs_saturated)
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
        signed_a = '0;
        signed_b = '0;
        unsigned_a = '0;
        unsigned_b = '0;
        wrap_a = '0;
        wrap_b = '0;
        #1;

        signed_a = -4'sd5;
        signed_b = 4'sd3;
        #1;
        expect4(signed_abs, 4'sd5, "signed abs value");
        expect4(signed_min, -4'sd5, "signed min value");
        expect4(signed_max, 4'sd3, "signed max value");
        expect1(signed_eq, 1'b0, "signed eq false");
        expect1(signed_lt, 1'b1, "signed lt true");
        expect1(signed_abs_saturated, 1'b0, "signed abs saturated false");

        signed_a = -4'sd2;
        signed_b = -4'sd2;
        #1;
        expect4(signed_min, -4'sd2, "signed equal min value");
        expect4(signed_max, -4'sd2, "signed equal max value");
        expect1(signed_eq, 1'b1, "signed eq true");
        expect1(signed_lt, 1'b0, "signed lt false on equal");

        signed_a = -4'sd8;
        signed_b = 4'sd7;
        #1;
        expect4(signed_abs, 4'sd7, "signed most-negative saturated abs");
        expect1(signed_abs_saturated, 1'b1, "signed most-negative abs_saturated");
        expect4(signed_min, -4'sd8, "signed saturating min");
        expect4(signed_max, 4'sd7, "signed saturating max");

        unsigned_a = 4'd15;
        unsigned_b = 4'd1;
        #1;
        expect4(unsigned_abs, 4'd15, "unsigned abs passthrough");
        expect4(unsigned_min, 4'd1, "unsigned min value");
        expect4(unsigned_max, 4'd15, "unsigned max value");
        expect1(unsigned_eq, 1'b0, "unsigned eq false");
        expect1(unsigned_lt, 1'b0, "unsigned lt false");
        expect1(unsigned_abs_saturated, 1'b0, "unsigned abs saturated false");

        wrap_a = -4'sd8;
        wrap_b = 4'sd0;
        #1;
        expect4(wrap_abs, -4'sd8, "wrap abs most-negative preserves value");
        expect1(wrap_abs_saturated, 1'b0, "wrap abs saturated false");
        expect4(wrap_min, -4'sd8, "wrap min value");
        expect4(wrap_max, 4'sd0, "wrap max value");

        $display("abs_min_max_tb passed");
        $finish;
    end
endmodule
