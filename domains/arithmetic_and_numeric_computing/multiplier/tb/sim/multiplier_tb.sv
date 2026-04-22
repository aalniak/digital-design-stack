module multiplier_tb;
    logic [3:0] full_a;
    logic [3:0] full_b;
    logic [7:0] full_product;
    logic full_discarded;

    logic [3:0] low_a;
    logic [3:0] low_b;
    logic [3:0] low_product;
    logic low_discarded;

    logic [3:0] high_a;
    logic [3:0] high_b;
    logic [3:0] high_product;
    logic high_discarded;

    logic [3:0] signed_a;
    logic [3:0] signed_b;
    logic [7:0] signed_product;
    logic signed_discarded;

    multiplier #(
        .A_WIDTH(4),
        .B_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .OUTPUT_WIDTH(8),
        .SELECT_HIGH_SLICE(1'b0)
    ) dut_full (
        .operand_a(full_a),
        .operand_b(full_b),
        .product_out(full_product),
        .discarded_nonzero(full_discarded)
    );

    multiplier #(
        .A_WIDTH(4),
        .B_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .OUTPUT_WIDTH(4),
        .SELECT_HIGH_SLICE(1'b0)
    ) dut_low (
        .operand_a(low_a),
        .operand_b(low_b),
        .product_out(low_product),
        .discarded_nonzero(low_discarded)
    );

    multiplier #(
        .A_WIDTH(4),
        .B_WIDTH(4),
        .SIGNED_MODE(1'b0),
        .OUTPUT_WIDTH(4),
        .SELECT_HIGH_SLICE(1'b1)
    ) dut_high (
        .operand_a(high_a),
        .operand_b(high_b),
        .product_out(high_product),
        .discarded_nonzero(high_discarded)
    );

    multiplier #(
        .A_WIDTH(4),
        .B_WIDTH(4),
        .SIGNED_MODE(1'b1),
        .OUTPUT_WIDTH(8),
        .SELECT_HIGH_SLICE(1'b0)
    ) dut_signed (
        .operand_a(signed_a),
        .operand_b(signed_b),
        .product_out(signed_product),
        .discarded_nonzero(signed_discarded)
    );

    task automatic expect8(
        input [7:0] actual,
        input [7:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0h expected=%0h", label, actual, expected);
            $fatal;
        end
    endtask

    task automatic expect4(
        input [3:0] actual,
        input [3:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0h expected=%0h", label, actual, expected);
            $fatal;
        end
    endtask

    task automatic expect1(
        input logic actual,
        input logic expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0b expected=%0b", label, actual, expected);
            $fatal;
        end
    endtask

    initial begin
        full_a = 4'hd;
        full_b = 4'h7;
        low_a = 4'hd;
        low_b = 4'h7;
        high_a = 4'hd;
        high_b = 4'h7;
        signed_a = -4'sd3;
        signed_b = 4'sd5;
        #1;

        expect8(full_product, 8'h5b, "unsigned full product");
        expect1(full_discarded, 1'b0, "unsigned full discarded");

        expect4(low_product, 4'hb, "low slice product");
        expect1(low_discarded, 1'b1, "low slice discarded");

        expect4(high_product, 4'h5, "high slice product");
        expect1(high_discarded, 1'b1, "high slice discarded");

        expect8(signed_product, 8'hf1, "signed full product");
        expect1(signed_discarded, 1'b0, "signed full discarded");

        $display("multiplier_tb passed");
        $finish;
    end
endmodule
