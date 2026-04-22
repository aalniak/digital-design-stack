`timescale 1ns/1ps

module adder_subtractor_tb;
    reg  [3:0] operand_a;
    reg  [3:0] operand_b;
    reg        add_sub;
    reg        carry_in;
    wire [3:0] result;
    wire       carry_out;
    wire       overflow;
    wire       zero;
    wire       negative;

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

    initial begin
        operand_a = 4'd5;
        operand_b = 4'd3;
        add_sub = 1'b0;
        carry_in = 1'b0;
        #1;
        if (result !== 4'd8 || carry_out !== 1'b0 || overflow !== 1'b1 || negative !== 1'b1) begin
            $fatal(1, "signed add overflow case should wrap and assert overflow");
        end

        operand_a = 4'hF;
        operand_b = 4'h1;
        add_sub = 1'b0;
        carry_in = 1'b1;
        #1;
        if (result !== 4'h1 || carry_out !== 1'b1 || zero !== 1'b0) begin
            $fatal(1, "carry-in addition should produce wrapped result with carry_out");
        end

        operand_a = 4'd7;
        operand_b = 4'd2;
        add_sub = 1'b1;
        carry_in = 1'b0;
        #1;
        if (result !== 4'd5 || carry_out !== 1'b1 || overflow !== 1'b0) begin
            $fatal(1, "subtraction without borrow should produce correct result");
        end

        operand_a = 4'd2;
        operand_b = 4'd7;
        add_sub = 1'b1;
        #1;
        if (result !== 4'hB || carry_out !== 1'b0 || negative !== 1'b1) begin
            $fatal(1, "subtraction with borrow should clear carry_out and set negative");
        end

        operand_a = 4'sh7;
        operand_b = 4'sh1;
        add_sub = 1'b0;
        #1;
        if (!overflow) begin
            $fatal(1, "signed positive overflow should assert overflow");
        end

        operand_a = 4'h8;
        operand_b = 4'h1;
        add_sub = 1'b1;
        #1;
        if (!overflow || result !== 4'h7) begin
            $fatal(1, "signed subtract overflow should assert overflow and wrap result");
        end

        $display("adder_subtractor_tb passed");
        $finish;
    end
endmodule
