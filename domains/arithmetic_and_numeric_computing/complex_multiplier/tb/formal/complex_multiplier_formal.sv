module complex_multiplier_formal;
    localparam int DATA_WIDTH = 4;
    localparam int PROD_WIDTH = 2 * DATA_WIDTH;
    localparam int OUT_WIDTH = 2 * DATA_WIDTH + 1;

    (* anyconst *) logic [DATA_WIDTH-1:0] operand_a_re;
    (* anyconst *) logic [DATA_WIDTH-1:0] operand_a_im;
    (* anyconst *) logic [DATA_WIDTH-1:0] operand_b_re;
    (* anyconst *) logic [DATA_WIDTH-1:0] operand_b_im;
    (* anyconst *) logic                  conjugate_b;

    logic [OUT_WIDTH-1:0] product_re;
    logic [OUT_WIDTH-1:0] product_im;

    logic [DATA_WIDTH-1:0] effective_b_im;
    logic [PROD_WIDTH-1:0] mult_rr;
    logic [PROD_WIDTH-1:0] mult_ii;
    logic [PROD_WIDTH-1:0] mult_ri;
    logic [PROD_WIDTH-1:0] mult_ir;

    complex_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1)
    ) dut (
        .operand_a_re(operand_a_re),
        .operand_a_im(operand_a_im),
        .operand_b_re(operand_b_re),
        .operand_b_im(operand_b_im),
        .conjugate_b(conjugate_b),
        .product_re(product_re),
        .product_im(product_im)
    );

    always @* begin
        if (conjugate_b) begin
            effective_b_im = (~operand_b_im) + {{(DATA_WIDTH-1){1'b0}}, 1'b1};
        end else begin
            effective_b_im = operand_b_im;
        end

        mult_rr = $signed(operand_a_re) * $signed(operand_b_re);
        mult_ii = $signed(operand_a_im) * $signed(effective_b_im);
        mult_ri = $signed(operand_a_re) * $signed(effective_b_im);
        mult_ir = $signed(operand_a_im) * $signed(operand_b_re);

        assert(product_re == ($signed({mult_rr[PROD_WIDTH-1], mult_rr}) - $signed({mult_ii[PROD_WIDTH-1], mult_ii})));
        assert(product_im == ($signed({mult_ri[PROD_WIDTH-1], mult_ri}) + $signed({mult_ir[PROD_WIDTH-1], mult_ir})));
    end
endmodule
