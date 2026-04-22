module saturating_adder #(
    parameter int DATA_WIDTH = 16,
    parameter bit SIGNED_MODE = 1'b0,
    parameter bit CARRY_IN_EN = 1'b0,
    parameter bit CUSTOM_LIMITS_EN = 1'b0,
    parameter bit FLAG_EN = 1'b1
) (
    input  logic [DATA_WIDTH-1:0] operand_a,
    input  logic [DATA_WIDTH-1:0] operand_b,
    input  logic                  carry_in,
    input  logic [DATA_WIDTH-1:0] custom_min_limit,
    input  logic [DATA_WIDTH-1:0] custom_max_limit,
    output logic [DATA_WIDTH-1:0] result,
    output logic                  saturated,
    output logic                  at_min,
    output logic                  at_max
);

    logic [DATA_WIDTH-1:0] default_min_limit;
    logic [DATA_WIDTH-1:0] default_max_limit;
    logic [DATA_WIDTH-1:0] selected_min_limit;
    logic [DATA_WIDTH-1:0] selected_max_limit;
    logic [DATA_WIDTH:0] unsigned_sum;
    logic signed [DATA_WIDTH:0] signed_sum;
    logic signed [DATA_WIDTH:0] signed_min_limit;
    logic signed [DATA_WIDTH:0] signed_max_limit;
    logic [DATA_WIDTH:0] carry_term;

    assign carry_term = CARRY_IN_EN ? {{DATA_WIDTH{1'b0}}, carry_in} : '0;

    always @* begin
        if (SIGNED_MODE) begin
            default_min_limit = {1'b1, {(DATA_WIDTH-1){1'b0}}};
            default_max_limit = {1'b0, {(DATA_WIDTH-1){1'b1}}};
        end else begin
            default_min_limit = '0;
            default_max_limit = {DATA_WIDTH{1'b1}};
        end

        if (CUSTOM_LIMITS_EN) begin
            selected_min_limit = custom_min_limit;
            selected_max_limit = custom_max_limit;
        end else begin
            selected_min_limit = default_min_limit;
            selected_max_limit = default_max_limit;
        end

        unsigned_sum = {1'b0, operand_a} + {1'b0, operand_b} + carry_term;
        signed_sum = $signed({operand_a[DATA_WIDTH-1], operand_a}) +
                     $signed({operand_b[DATA_WIDTH-1], operand_b}) +
                     $signed(carry_term);
        signed_min_limit = $signed({selected_min_limit[DATA_WIDTH-1], selected_min_limit});
        signed_max_limit = $signed({selected_max_limit[DATA_WIDTH-1], selected_max_limit});

        result = '0;
        saturated = 1'b0;
        at_min = 1'b0;
        at_max = 1'b0;

        if (SIGNED_MODE) begin
            if (signed_sum > signed_max_limit) begin
                result = selected_max_limit;
                saturated = 1'b1;
                at_max = 1'b1;
            end else if (signed_sum < signed_min_limit) begin
                result = selected_min_limit;
                saturated = 1'b1;
                at_min = 1'b1;
            end else begin
                result = signed_sum[DATA_WIDTH-1:0];
            end
        end else begin
            if (unsigned_sum > {1'b0, selected_max_limit}) begin
                result = selected_max_limit;
                saturated = 1'b1;
                at_max = 1'b1;
            end else if (unsigned_sum < {1'b0, selected_min_limit}) begin
                result = selected_min_limit;
                saturated = 1'b1;
                at_min = 1'b1;
            end else begin
                result = unsigned_sum[DATA_WIDTH-1:0];
            end
        end

        if (!FLAG_EN) begin
            saturated = 1'b0;
            at_min = 1'b0;
            at_max = 1'b0;
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("saturating_adder requires DATA_WIDTH >= 1");
            $finish;
        end
    end

endmodule
