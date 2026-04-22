module adder_subtractor #(
    parameter integer DATA_WIDTH = 16,
    parameter integer SIGNED_MODE = 0,
    parameter integer CARRY_IN_EN = 1
) (
    input  wire [DATA_WIDTH-1:0] operand_a,
    input  wire [DATA_WIDTH-1:0] operand_b,
    input  wire                  add_sub,
    input  wire                  carry_in,
    output wire [DATA_WIDTH-1:0] result,
    output wire                  carry_out,
    output wire                  overflow,
    output wire                  zero,
    output wire                  negative
);
    wire effective_carry_in;
    wire [DATA_WIDTH:0] extended_sum;
    wire operand_a_sign;
    wire operand_b_sign;
    wire result_sign;

    assign effective_carry_in = add_sub ? 1'b1 : (((CARRY_IN_EN != 0) && carry_in) ? 1'b1 : 1'b0);
    assign extended_sum = {1'b0, operand_a} + {1'b0, (add_sub ? ~operand_b : operand_b)} + {{DATA_WIDTH{1'b0}}, effective_carry_in};
    assign result = extended_sum[DATA_WIDTH-1:0];
    assign carry_out = extended_sum[DATA_WIDTH];

    assign operand_a_sign = operand_a[DATA_WIDTH-1];
    assign operand_b_sign = operand_b[DATA_WIDTH-1];
    assign result_sign = result[DATA_WIDTH-1];

    assign overflow = (SIGNED_MODE != 0) ?
        (add_sub ? ((operand_a_sign != operand_b_sign) && (result_sign != operand_a_sign))
                 : ((operand_a_sign == operand_b_sign) && (result_sign != operand_a_sign)))
        : 1'b0;
    assign zero = (result == {DATA_WIDTH{1'b0}});
    assign negative = (SIGNED_MODE != 0) ? result_sign : 1'b0;

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "adder_subtractor requires DATA_WIDTH >= 1");
        end
        if ((SIGNED_MODE != 0) && (SIGNED_MODE != 1)) begin
            $fatal(1, "adder_subtractor requires SIGNED_MODE to be 0 or 1");
        end
        if ((CARRY_IN_EN != 0) && (CARRY_IN_EN != 1)) begin
            $fatal(1, "adder_subtractor requires CARRY_IN_EN to be 0 or 1");
        end
    end
endmodule
