module abs_min_max #(
    parameter int DATA_WIDTH = 16,
    parameter bit SIGNED_MODE = 1'b1,
    parameter bit SATURATE_ABS = 1'b1
) (
    input  logic [DATA_WIDTH-1:0] operand_a,
    input  logic [DATA_WIDTH-1:0] operand_b,
    output logic [DATA_WIDTH-1:0] abs_a,
    output logic [DATA_WIDTH-1:0] min_value,
    output logic [DATA_WIDTH-1:0] max_value,
    output logic                  a_eq_b,
    output logic                  a_lt_b,
    output logic                  abs_saturated
);

    logic operand_a_is_negative;
    logic a_lt_b_internal;
    logic [DATA_WIDTH-1:0] signed_abs_default;

    always @* begin
        operand_a_is_negative = SIGNED_MODE && operand_a[DATA_WIDTH-1];
        signed_abs_default = (~operand_a) + {{(DATA_WIDTH-1){1'b0}}, 1'b1};
        a_eq_b = (operand_a == operand_b);

        if (SIGNED_MODE) begin
            a_lt_b_internal = ($signed(operand_a) < $signed(operand_b));
        end else begin
            a_lt_b_internal = (operand_a < operand_b);
        end
        a_lt_b = a_lt_b_internal;

        if (a_lt_b_internal) begin
            min_value = operand_a;
            max_value = operand_b;
        end else begin
            min_value = operand_b;
            max_value = operand_a;
        end

        abs_a = operand_a;
        abs_saturated = 1'b0;

        if (SIGNED_MODE) begin
            if (operand_a == {1'b1, {(DATA_WIDTH-1){1'b0}}}) begin
                if (SATURATE_ABS) begin
                    abs_a = {1'b0, {(DATA_WIDTH-1){1'b1}}};
                    abs_saturated = 1'b1;
                end else begin
                    abs_a = operand_a;
                end
            end else if (operand_a_is_negative) begin
                abs_a = signed_abs_default;
            end
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("abs_min_max requires DATA_WIDTH >= 1");
            $finish;
        end
    end

endmodule
