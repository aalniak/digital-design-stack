module saturating_adder_formal;
    localparam int DATA_WIDTH = 4;

    (* anyconst *) logic [DATA_WIDTH-1:0] operand_a;
    (* anyconst *) logic [DATA_WIDTH-1:0] operand_b;
    (* anyconst *) logic carry_in;
    (* anyconst *) logic [DATA_WIDTH-1:0] custom_min_limit;
    (* anyconst *) logic [DATA_WIDTH-1:0] custom_max_limit;

    logic [DATA_WIDTH-1:0] result;
    logic saturated;
    logic at_min;
    logic at_max;

    logic signed [DATA_WIDTH:0] signed_sum;
    logic signed [DATA_WIDTH:0] signed_min_limit;
    logic signed [DATA_WIDTH:0] signed_max_limit;
    logic signed [DATA_WIDTH-1:0] expected_result;
    logic expected_saturated;
    logic expected_at_min;
    logic expected_at_max;

    saturating_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1),
        .CARRY_IN_EN(1'b1),
        .CUSTOM_LIMITS_EN(1'b1),
        .FLAG_EN(1'b1)
    ) dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .carry_in(carry_in),
        .custom_min_limit(custom_min_limit),
        .custom_max_limit(custom_max_limit),
        .result(result),
        .saturated(saturated),
        .at_min(at_min),
        .at_max(at_max)
    );

    always @* begin
        assume($signed(custom_min_limit) <= $signed(custom_max_limit));

        signed_sum = $signed({operand_a[DATA_WIDTH-1], operand_a}) +
                     $signed({operand_b[DATA_WIDTH-1], operand_b}) +
                     $signed({{DATA_WIDTH{1'b0}}, carry_in});
        signed_min_limit = $signed({custom_min_limit[DATA_WIDTH-1], custom_min_limit});
        signed_max_limit = $signed({custom_max_limit[DATA_WIDTH-1], custom_max_limit});

        expected_result = signed_sum[DATA_WIDTH-1:0];
        expected_saturated = 1'b0;
        expected_at_min = 1'b0;
        expected_at_max = 1'b0;

        if (signed_sum > signed_max_limit) begin
            expected_result = custom_max_limit;
            expected_saturated = 1'b1;
            expected_at_max = 1'b1;
        end else if (signed_sum < signed_min_limit) begin
            expected_result = custom_min_limit;
            expected_saturated = 1'b1;
            expected_at_min = 1'b1;
        end

        assert(result == expected_result);
        assert(saturated == expected_saturated);
        assert(at_min == expected_at_min);
        assert(at_max == expected_at_max);
    end
endmodule
