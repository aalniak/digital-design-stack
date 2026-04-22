module comparator_tree_formal;
    localparam int NUM_INPUTS = 3;
    localparam int DATA_WIDTH = 4;
    localparam int INDEX_WIDTH = 2;

    (* anyconst *) logic [NUM_INPUTS*DATA_WIDTH-1:0] candidates_flat;
    (* anyconst *) logic [NUM_INPUTS-1:0] candidate_valid;

    logic any_valid;
    logic [DATA_WIDTH-1:0] winner_value;
    logic [INDEX_WIDTH-1:0] winner_index;

    logic expected_any_valid;
    logic [DATA_WIDTH-1:0] expected_winner_value;
    logic [INDEX_WIDTH-1:0] expected_winner_index;
    logic [DATA_WIDTH-1:0] candidate_value;
    integer i;

    comparator_tree #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1),
        .SELECT_MAX(1'b1),
        .RETURN_INDEX_EN(1'b1)
    ) dut (
        .candidates_flat(candidates_flat),
        .candidate_valid(candidate_valid),
        .any_valid(any_valid),
        .winner_value(winner_value),
        .winner_index(winner_index)
    );

    always @* begin
        expected_any_valid = 1'b0;
        expected_winner_value = '0;
        expected_winner_index = '0;

        for (i = 0; i < NUM_INPUTS; i = i + 1) begin
            candidate_value = candidates_flat[i*DATA_WIDTH +: DATA_WIDTH];
            if (candidate_valid[i]) begin
                if (!expected_any_valid) begin
                    expected_any_valid = 1'b1;
                    expected_winner_value = candidate_value;
                    expected_winner_index = INDEX_WIDTH'(i);
                end else if ($signed(candidate_value) > $signed(expected_winner_value)) begin
                    expected_winner_value = candidate_value;
                    expected_winner_index = INDEX_WIDTH'(i);
                end
            end
        end

        assert(any_valid == expected_any_valid);
        assert(winner_value == expected_winner_value);
        assert(winner_index == expected_winner_index);
    end
endmodule
