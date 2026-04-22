module popcount_unit #(
    parameter int DATA_WIDTH = 32,
    parameter bit RETURN_FLAGS_EN = 1'b1
) (
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [((DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH + 1)) - 1:0] count_out,
    output logic                  is_zero,
    output logic                  is_full
);

    localparam int COUNT_WIDTH = (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH + 1);

    integer i;

    always @* begin
        count_out = '0;
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            if (data_in[i]) begin
                count_out = count_out + COUNT_WIDTH'(1);
            end
        end

        is_zero = (count_out == '0);
        is_full = (count_out == COUNT_WIDTH'(DATA_WIDTH));

        if (!RETURN_FLAGS_EN) begin
            is_zero = 1'b0;
            is_full = 1'b0;
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("popcount_unit requires DATA_WIDTH >= 1");
            $finish;
        end
    end
endmodule
