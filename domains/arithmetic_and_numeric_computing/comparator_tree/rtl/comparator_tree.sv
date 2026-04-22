module comparator_tree #(
    parameter int NUM_INPUTS = 4,
    parameter int DATA_WIDTH = 16,
    parameter bit SIGNED_MODE = 1'b0,
    parameter bit SELECT_MAX = 1'b1,
    parameter bit RETURN_INDEX_EN = 1'b1
) (
    input  logic [NUM_INPUTS*DATA_WIDTH-1:0] candidates_flat,
    input  logic [NUM_INPUTS-1:0]            candidate_valid,
    output logic                             any_valid,
    output logic [DATA_WIDTH-1:0]            winner_value,
    output logic [((NUM_INPUTS <= 1) ? 1 : $clog2(NUM_INPUTS))-1:0] winner_index
);

    localparam int INDEX_WIDTH = (NUM_INPUTS <= 1) ? 1 : $clog2(NUM_INPUTS);

    function automatic bit better_candidate(
        input logic [DATA_WIDTH-1:0] lhs,
        input logic [DATA_WIDTH-1:0] rhs
    );
        begin
            if (SIGNED_MODE) begin
                if (SELECT_MAX) begin
                    better_candidate = ($signed(lhs) > $signed(rhs));
                end else begin
                    better_candidate = ($signed(lhs) < $signed(rhs));
                end
            end else begin
                if (SELECT_MAX) begin
                    better_candidate = (lhs > rhs);
                end else begin
                    better_candidate = (lhs < rhs);
                end
            end
        end
    endfunction

    integer i;
    always @* begin
        any_valid = 1'b0;
        winner_value = '0;
        winner_index = '0;

        for (i = 0; i < NUM_INPUTS; i = i + 1) begin
            if (candidate_valid[i]) begin
                if (!any_valid) begin
                    any_valid = 1'b1;
                    winner_value = candidates_flat[i*DATA_WIDTH +: DATA_WIDTH];
                    winner_index = INDEX_WIDTH'(i);
                end else if (better_candidate(candidates_flat[i*DATA_WIDTH +: DATA_WIDTH], winner_value)) begin
                    winner_value = candidates_flat[i*DATA_WIDTH +: DATA_WIDTH];
                    winner_index = INDEX_WIDTH'(i);
                end
            end
        end

        if (!RETURN_INDEX_EN) begin
            winner_index = '0;
        end
    end

    initial begin
        if (NUM_INPUTS < 1) begin
            $error("comparator_tree requires NUM_INPUTS >= 1");
            $finish;
        end
        if (DATA_WIDTH < 1) begin
            $error("comparator_tree requires DATA_WIDTH >= 1");
            $finish;
        end
    end

endmodule
