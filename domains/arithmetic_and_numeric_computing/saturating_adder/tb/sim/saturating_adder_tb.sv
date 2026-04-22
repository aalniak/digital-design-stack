module saturating_adder_tb;
    logic [3:0] signed_a;
    logic [3:0] signed_b;
    logic signed_carry_in;
    logic [3:0] signed_result;
    logic signed_saturated;
    logic signed_at_min;
    logic signed_at_max;

    logic [3:0] unsigned_a;
    logic [3:0] unsigned_b;
    logic [3:0] unsigned_result;
    logic unsigned_saturated;
    logic unsigned_at_min;
    logic unsigned_at_max;

    logic [5:0] custom_a;
    logic [5:0] custom_b;
    logic custom_carry_in;
    logic [5:0] custom_min;
    logic [5:0] custom_max;
    logic [5:0] custom_result;
    logic custom_saturated;
    logic custom_at_min;
    logic custom_at_max;

    logic [3:0] quiet_result;
    logic quiet_saturated;
    logic quiet_at_min;
    logic quiet_at_max;

    saturating_adder #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b1),
        .CARRY_IN_EN(1'b1),
        .CUSTOM_LIMITS_EN(1'b0),
        .FLAG_EN(1'b1)
    ) dut_signed (
        .operand_a(signed_a),
        .operand_b(signed_b),
        .carry_in(signed_carry_in),
        .custom_min_limit('0),
        .custom_max_limit('0),
        .result(signed_result),
        .saturated(signed_saturated),
        .at_min(signed_at_min),
        .at_max(signed_at_max)
    );

    saturating_adder #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .CARRY_IN_EN(1'b0),
        .CUSTOM_LIMITS_EN(1'b0),
        .FLAG_EN(1'b1)
    ) dut_unsigned (
        .operand_a(unsigned_a),
        .operand_b(unsigned_b),
        .carry_in(1'b0),
        .custom_min_limit('0),
        .custom_max_limit('0),
        .result(unsigned_result),
        .saturated(unsigned_saturated),
        .at_min(unsigned_at_min),
        .at_max(unsigned_at_max)
    );

    saturating_adder #(
        .DATA_WIDTH(6),
        .SIGNED_MODE(1'b1),
        .CARRY_IN_EN(1'b1),
        .CUSTOM_LIMITS_EN(1'b1),
        .FLAG_EN(1'b1)
    ) dut_custom (
        .operand_a(custom_a),
        .operand_b(custom_b),
        .carry_in(custom_carry_in),
        .custom_min_limit(custom_min),
        .custom_max_limit(custom_max),
        .result(custom_result),
        .saturated(custom_saturated),
        .at_min(custom_at_min),
        .at_max(custom_at_max)
    );

    saturating_adder #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b1),
        .CARRY_IN_EN(1'b0),
        .CUSTOM_LIMITS_EN(1'b0),
        .FLAG_EN(1'b0)
    ) dut_quiet (
        .operand_a(signed_a),
        .operand_b(signed_b),
        .carry_in(1'b0),
        .custom_min_limit('0),
        .custom_max_limit('0),
        .result(quiet_result),
        .saturated(quiet_saturated),
        .at_min(quiet_at_min),
        .at_max(quiet_at_max)
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

    task automatic expect6(
        input [5:0] actual,
        input [5:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0h expected=%0h", label, actual, expected);
            $fatal;
        end
    endtask

    initial begin
        signed_a = '0;
        signed_b = '0;
        signed_carry_in = 1'b0;
        unsigned_a = '0;
        unsigned_b = '0;
        custom_a = '0;
        custom_b = '0;
        custom_carry_in = 1'b0;
        custom_min = -6'sd10;
        custom_max = 6'sd10;
        #1;

        signed_a = 4'sd3;
        signed_b = 4'sd2;
        signed_carry_in = 1'b0;
        #1;
        expect4(signed_result, 4'sd5, "signed in-range result");
        expect1(signed_saturated, 1'b0, "signed in-range saturated");
        expect1(signed_at_min, 1'b0, "signed in-range at_min");
        expect1(signed_at_max, 1'b0, "signed in-range at_max");

        signed_a = 4'sd7;
        signed_b = 4'sd1;
        signed_carry_in = 1'b0;
        #1;
        expect4(signed_result, 4'sd7, "signed high clip result");
        expect1(signed_saturated, 1'b1, "signed high clip saturated");
        expect1(signed_at_min, 1'b0, "signed high clip at_min");
        expect1(signed_at_max, 1'b1, "signed high clip at_max");

        signed_a = -4'sd8;
        signed_b = -4'sd1;
        signed_carry_in = 1'b0;
        #1;
        expect4(signed_result, -4'sd8, "signed low clip result");
        expect1(signed_saturated, 1'b1, "signed low clip saturated");
        expect1(signed_at_min, 1'b1, "signed low clip at_min");
        expect1(signed_at_max, 1'b0, "signed low clip at_max");

        signed_a = 4'hf;
        signed_b = 4'h0;
        signed_carry_in = 1'b1;
        #1;
        expect4(signed_result, 4'h0, "carry-in increment result");
        expect1(signed_saturated, 1'b0, "carry-in increment saturated");

        unsigned_a = 4'd14;
        unsigned_b = 4'd3;
        #1;
        expect4(unsigned_result, 4'hf, "unsigned clip result");
        expect1(unsigned_saturated, 1'b1, "unsigned clip saturated");
        expect1(unsigned_at_min, 1'b0, "unsigned clip at_min");
        expect1(unsigned_at_max, 1'b1, "unsigned clip at_max");

        custom_a = 6'sd8;
        custom_b = 6'sd5;
        custom_carry_in = 1'b0;
        custom_min = -6'sd10;
        custom_max = 6'sd10;
        #1;
        expect6(custom_result, 6'sd10, "custom upper clip result");
        expect1(custom_saturated, 1'b1, "custom upper clip saturated");
        expect1(custom_at_min, 1'b0, "custom upper clip at_min");
        expect1(custom_at_max, 1'b1, "custom upper clip at_max");

        custom_a = -6'sd9;
        custom_b = -6'sd4;
        custom_carry_in = 1'b1;
        #1;
        expect6(custom_result, -6'sd10, "custom lower clip result");
        expect1(custom_saturated, 1'b1, "custom lower clip saturated");
        expect1(custom_at_min, 1'b1, "custom lower clip at_min");
        expect1(custom_at_max, 1'b0, "custom lower clip at_max");

        signed_a = 4'sd7;
        signed_b = 4'sd4;
        #1;
        expect4(quiet_result, 4'sd7, "flag-suppressed result still clips");
        expect1(quiet_saturated, 1'b0, "flag-suppressed saturated");
        expect1(quiet_at_min, 1'b0, "flag-suppressed at_min");
        expect1(quiet_at_max, 1'b0, "flag-suppressed at_max");

        $display("saturating_adder_tb passed");
        $finish;
    end
endmodule
