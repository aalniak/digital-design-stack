module multiplier #(
    parameter int A_WIDTH = 16,
    parameter int B_WIDTH = 16,
    parameter bit SIGNED_MODE = 1'b0,
    parameter int OUTPUT_WIDTH = A_WIDTH + B_WIDTH,
    parameter bit SELECT_HIGH_SLICE = 1'b0
) (
    input  logic [A_WIDTH-1:0] operand_a,
    input  logic [B_WIDTH-1:0] operand_b,
    output logic [OUTPUT_WIDTH-1:0] product_out,
    output logic                    discarded_nonzero
);

    localparam int FULL_WIDTH = A_WIDTH + B_WIDTH;

    integer i;
    logic [FULL_WIDTH-1:0] full_product;

    always @* begin
        if (SIGNED_MODE) begin
            full_product = $signed(operand_a) * $signed(operand_b);
        end else begin
            full_product = operand_a * operand_b;
        end

        if (SELECT_HIGH_SLICE) begin
            product_out = full_product[FULL_WIDTH-1 -: OUTPUT_WIDTH];
        end else begin
            product_out = full_product[OUTPUT_WIDTH-1:0];
        end

        discarded_nonzero = 1'b0;
        if (SELECT_HIGH_SLICE) begin
            for (i = 0; i < (FULL_WIDTH - OUTPUT_WIDTH); i = i + 1) begin
                if (full_product[i]) begin
                    discarded_nonzero = 1'b1;
                end
            end
        end else begin
            for (i = OUTPUT_WIDTH; i < FULL_WIDTH; i = i + 1) begin
                if (full_product[i]) begin
                    discarded_nonzero = 1'b1;
                end
            end
        end
    end

    initial begin
        if (A_WIDTH < 1) begin
            $error("multiplier requires A_WIDTH >= 1");
            $finish;
        end
        if (B_WIDTH < 1) begin
            $error("multiplier requires B_WIDTH >= 1");
            $finish;
        end
        if ((OUTPUT_WIDTH < 1) || (OUTPUT_WIDTH > FULL_WIDTH)) begin
            $error("multiplier requires 1 <= OUTPUT_WIDTH <= A_WIDTH + B_WIDTH");
            $finish;
        end
    end
endmodule
