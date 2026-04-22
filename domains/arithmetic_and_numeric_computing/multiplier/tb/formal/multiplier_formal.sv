module multiplier_formal;
    localparam int A_WIDTH = 4;
    localparam int B_WIDTH = 3;
    localparam int FULL_WIDTH = A_WIDTH + B_WIDTH;
    localparam int OUTPUT_WIDTH = 4;

    (* anyconst *) logic [A_WIDTH-1:0] operand_a;
    (* anyconst *) logic [B_WIDTH-1:0] operand_b;

    logic [OUTPUT_WIDTH-1:0] product_out;
    logic discarded_nonzero;

    logic [FULL_WIDTH-1:0] full_product;
    logic expected_discarded_nonzero;
    integer i;

    multiplier #(
        .A_WIDTH(A_WIDTH),
        .B_WIDTH(B_WIDTH),
        .SIGNED_MODE(1'b1),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .SELECT_HIGH_SLICE(1'b0)
    ) dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .product_out(product_out),
        .discarded_nonzero(discarded_nonzero)
    );

    always @* begin
        full_product = $signed(operand_a) * $signed(operand_b);
        expected_discarded_nonzero = 1'b0;
        for (i = OUTPUT_WIDTH; i < FULL_WIDTH; i = i + 1) begin
            if (full_product[i]) begin
                expected_discarded_nonzero = 1'b1;
            end
        end

        assert(product_out == full_product[OUTPUT_WIDTH-1:0]);
        assert(discarded_nonzero == expected_discarded_nonzero);
    end
endmodule
