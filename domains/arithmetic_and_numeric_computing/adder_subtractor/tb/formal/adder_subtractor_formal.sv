module adder_subtractor_formal;
    (* anyconst *) reg [3:0] operand_a;
    (* anyconst *) reg [3:0] operand_b;
    (* anyconst *) reg       add_sub;
    (* anyconst *) reg       carry_in;

    wire [3:0] result;
    wire       carry_out;
    wire       overflow;
    wire       zero;
    wire       negative;
    wire       effective_carry_in;
    wire [4:0] expected_sum;

    adder_subtractor #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1),
        .CARRY_IN_EN(1)
    ) dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .add_sub(add_sub),
        .carry_in(carry_in),
        .result(result),
        .carry_out(carry_out),
        .overflow(overflow),
        .zero(zero),
        .negative(negative)
    );

    assign effective_carry_in = add_sub ? 1'b1 : carry_in;
    assign expected_sum = {1'b0, operand_a} + {1'b0, (add_sub ? ~operand_b : operand_b)} + effective_carry_in;

    always @* begin
        assert(result == expected_sum[3:0]);
        assert(carry_out == expected_sum[4]);
        assert(zero == (result == 4'h0));
        assert(negative == result[3]);
    end
endmodule
