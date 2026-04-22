module complex_multiplier #(
    parameter int DATA_WIDTH = 16,
    parameter bit SIGNED_MODE = 1'b1
) (
    input  logic [DATA_WIDTH-1:0] operand_a_re,
    input  logic [DATA_WIDTH-1:0] operand_a_im,
    input  logic [DATA_WIDTH-1:0] operand_b_re,
    input  logic [DATA_WIDTH-1:0] operand_b_im,
    input  logic                  conjugate_b,
    output logic [(2*DATA_WIDTH+1)-1:0] product_re,
    output logic [(2*DATA_WIDTH+1)-1:0] product_im
);

    localparam int PROD_WIDTH = 2 * DATA_WIDTH;
    localparam int OUT_WIDTH = 2 * DATA_WIDTH + 1;

    logic [DATA_WIDTH-1:0] effective_b_im;
    logic [PROD_WIDTH-1:0] mult_rr;
    logic [PROD_WIDTH-1:0] mult_ii;
    logic [PROD_WIDTH-1:0] mult_ri;
    logic [PROD_WIDTH-1:0] mult_ir;

    always @* begin
        if (conjugate_b) begin
            effective_b_im = (~operand_b_im) + {{(DATA_WIDTH-1){1'b0}}, 1'b1};
        end else begin
            effective_b_im = operand_b_im;
        end

        if (SIGNED_MODE) begin
            mult_rr = $signed(operand_a_re) * $signed(operand_b_re);
            mult_ii = $signed(operand_a_im) * $signed(effective_b_im);
            mult_ri = $signed(operand_a_re) * $signed(effective_b_im);
            mult_ir = $signed(operand_a_im) * $signed(operand_b_re);

            product_re = $signed({mult_rr[PROD_WIDTH-1], mult_rr}) - $signed({mult_ii[PROD_WIDTH-1], mult_ii});
            product_im = $signed({mult_ri[PROD_WIDTH-1], mult_ri}) + $signed({mult_ir[PROD_WIDTH-1], mult_ir});
        end else begin
            mult_rr = operand_a_re * operand_b_re;
            mult_ii = operand_a_im * effective_b_im;
            mult_ri = operand_a_re * effective_b_im;
            mult_ir = operand_a_im * operand_b_re;

            product_re = $signed({1'b0, mult_rr}) - $signed({1'b0, mult_ii});
            product_im = $signed({1'b0, mult_ri}) + $signed({1'b0, mult_ir});
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("complex_multiplier requires DATA_WIDTH >= 1");
            $finish;
        end
    end
endmodule
