module leading_zero_counter #(
    parameter int DATA_WIDTH = 16,
    parameter bit RETURN_MSB_INDEX_EN = 1'b1
) (
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [((DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH + 1)) - 1:0] leading_zero_count,
    output logic                  all_zero,
    output logic [((DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH)) - 1:0] msb_index
);

    localparam int COUNT_WIDTH = (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH + 1);
    localparam int INDEX_WIDTH = (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);

    integer i;

    always @* begin
        leading_zero_count = COUNT_WIDTH'(DATA_WIDTH);
        all_zero = 1'b1;
        msb_index = '0;

        for (i = DATA_WIDTH - 1; i >= 0; i = i - 1) begin
            if (all_zero && data_in[i]) begin
                all_zero = 1'b0;
                leading_zero_count = COUNT_WIDTH'(DATA_WIDTH - 1 - i);
                msb_index = INDEX_WIDTH'(i);
            end
        end

        if (!RETURN_MSB_INDEX_EN) begin
            msb_index = '0;
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("leading_zero_counter requires DATA_WIDTH >= 1");
            $finish;
        end
    end
endmodule
