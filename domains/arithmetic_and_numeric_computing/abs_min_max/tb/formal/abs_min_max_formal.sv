module abs_min_max_formal;
    localparam int DATA_WIDTH = 4;

    (* anyconst *) logic [DATA_WIDTH-1:0] operand_a;
    (* anyconst *) logic [DATA_WIDTH-1:0] operand_b;

    logic [DATA_WIDTH-1:0] abs_a;
    logic [DATA_WIDTH-1:0] min_value;
    logic [DATA_WIDTH-1:0] max_value;
    logic a_eq_b;
    logic a_lt_b;
    logic abs_saturated;

    logic [DATA_WIDTH-1:0] expected_abs_a;
    logic [DATA_WIDTH-1:0] expected_min_value;
    logic [DATA_WIDTH-1:0] expected_max_value;
    logic expected_eq;
    logic expected_lt;
    logic expected_abs_saturated;

    abs_min_max #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1),
        .SATURATE_ABS(1'b1)
    ) dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .abs_a(abs_a),
        .min_value(min_value),
        .max_value(max_value),
        .a_eq_b(a_eq_b),
        .a_lt_b(a_lt_b),
        .abs_saturated(abs_saturated)
    );

    always @* begin
        expected_eq = (operand_a == operand_b);
        expected_lt = ($signed(operand_a) < $signed(operand_b));
        expected_min_value = expected_lt ? operand_a : operand_b;
        expected_max_value = expected_lt ? operand_b : operand_a;
        expected_abs_saturated = 1'b0;
        expected_abs_a = operand_a;

        if (operand_a == {1'b1, {(DATA_WIDTH-1){1'b0}}}) begin
            expected_abs_a = {1'b0, {(DATA_WIDTH-1){1'b1}}};
            expected_abs_saturated = 1'b1;
        end else if (operand_a[DATA_WIDTH-1]) begin
            expected_abs_a = (~operand_a) + {{(DATA_WIDTH-1){1'b0}}, 1'b1};
        end

        assert(a_eq_b == expected_eq);
        assert(a_lt_b == expected_lt);
        assert(min_value == expected_min_value);
        assert(max_value == expected_max_value);
        assert(abs_a == expected_abs_a);
        assert(abs_saturated == expected_abs_saturated);
    end
endmodule
