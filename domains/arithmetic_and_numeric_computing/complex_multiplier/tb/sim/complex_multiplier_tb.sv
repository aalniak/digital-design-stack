module complex_multiplier_tb;
    logic [3:0] signed_a_re;
    logic [3:0] signed_a_im;
    logic [3:0] signed_b_re;
    logic [3:0] signed_b_im;
    logic signed_conjugate_b;
    logic [8:0] signed_product_re;
    logic [8:0] signed_product_im;

    logic [3:0] unsigned_a_re;
    logic [3:0] unsigned_a_im;
    logic [3:0] unsigned_b_re;
    logic [3:0] unsigned_b_im;
    logic unsigned_conjugate_b;
    logic [8:0] unsigned_product_re;
    logic [8:0] unsigned_product_im;

    complex_multiplier #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b1)
    ) dut_signed (
        .operand_a_re(signed_a_re),
        .operand_a_im(signed_a_im),
        .operand_b_re(signed_b_re),
        .operand_b_im(signed_b_im),
        .conjugate_b(signed_conjugate_b),
        .product_re(signed_product_re),
        .product_im(signed_product_im)
    );

    complex_multiplier #(
        .DATA_WIDTH(4),
        .SIGNED_MODE(1'b0)
    ) dut_unsigned (
        .operand_a_re(unsigned_a_re),
        .operand_a_im(unsigned_a_im),
        .operand_b_re(unsigned_b_re),
        .operand_b_im(unsigned_b_im),
        .conjugate_b(unsigned_conjugate_b),
        .product_re(unsigned_product_re),
        .product_im(unsigned_product_im)
    );

    task automatic expect9(
        input [8:0] actual,
        input [8:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0h expected=%0h", label, actual, expected);
            $fatal;
        end
    endtask

    initial begin
        signed_a_re = 4'sd2;
        signed_a_im = 4'sd3;
        signed_b_re = 4'sd4;
        signed_b_im = -4'sd1;
        signed_conjugate_b = 1'b0;
        unsigned_a_re = 4'd1;
        unsigned_a_im = 4'd1;
        unsigned_b_re = 4'd1;
        unsigned_b_im = 4'd1;
        unsigned_conjugate_b = 1'b0;
        #1;

        expect9(signed_product_re, 9'sd11, "signed real");
        expect9(signed_product_im, 9'sd10, "signed imag");

        signed_conjugate_b = 1'b1;
        #1;
        expect9(signed_product_re, 9'sd5, "signed conjugated real");
        expect9(signed_product_im, 9'sd14, "signed conjugated imag");

        expect9(unsigned_product_re, 9'sd0, "unsigned real");
        expect9(unsigned_product_im, 9'sd2, "unsigned imag");

        $display("complex_multiplier_tb passed");
        $finish;
    end
endmodule
