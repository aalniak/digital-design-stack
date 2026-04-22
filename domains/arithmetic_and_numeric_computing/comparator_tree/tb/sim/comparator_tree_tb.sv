module comparator_tree_tb;
    localparam int NUM_INPUTS = 4;
    localparam int DATA_WIDTH = 4;
    localparam int INDEX_WIDTH = 2;

    logic [NUM_INPUTS*DATA_WIDTH-1:0] signed_candidates;
    logic [NUM_INPUTS-1:0] signed_valid;
    logic signed_any_valid;
    logic [DATA_WIDTH-1:0] signed_winner_value;
    logic [INDEX_WIDTH-1:0] signed_winner_index;

    logic [NUM_INPUTS*DATA_WIDTH-1:0] unsigned_candidates;
    logic [NUM_INPUTS-1:0] unsigned_valid;
    logic unsigned_any_valid;
    logic [DATA_WIDTH-1:0] unsigned_winner_value;
    logic [INDEX_WIDTH-1:0] unsigned_winner_index;

    logic [NUM_INPUTS*DATA_WIDTH-1:0] quiet_candidates;
    logic [NUM_INPUTS-1:0] quiet_valid;
    logic quiet_any_valid;
    logic [DATA_WIDTH-1:0] quiet_winner_value;
    logic [INDEX_WIDTH-1:0] quiet_winner_index;

    comparator_tree #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1),
        .SELECT_MAX(1'b1),
        .RETURN_INDEX_EN(1'b1)
    ) dut_signed_max (
        .candidates_flat(signed_candidates),
        .candidate_valid(signed_valid),
        .any_valid(signed_any_valid),
        .winner_value(signed_winner_value),
        .winner_index(signed_winner_index)
    );

    comparator_tree #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b0),
        .SELECT_MAX(1'b0),
        .RETURN_INDEX_EN(1'b1)
    ) dut_unsigned_min (
        .candidates_flat(unsigned_candidates),
        .candidate_valid(unsigned_valid),
        .any_valid(unsigned_any_valid),
        .winner_value(unsigned_winner_value),
        .winner_index(unsigned_winner_index)
    );

    comparator_tree #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIGNED_MODE(1'b1),
        .SELECT_MAX(1'b1),
        .RETURN_INDEX_EN(1'b0)
    ) dut_quiet_index (
        .candidates_flat(quiet_candidates),
        .candidate_valid(quiet_valid),
        .any_valid(quiet_any_valid),
        .winner_value(quiet_winner_value),
        .winner_index(quiet_winner_index)
    );

    task automatic expect_logic(
        input logic actual,
        input logic expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0b expected=%0b", label, actual, expected);
            $fatal;
        end
    endtask

    task automatic expect_value(
        input [DATA_WIDTH-1:0] actual,
        input [DATA_WIDTH-1:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0h expected=%0h", label, actual, expected);
            $fatal;
        end
    endtask

    task automatic expect_index(
        input [INDEX_WIDTH-1:0] actual,
        input [INDEX_WIDTH-1:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0d expected=%0d", label, actual, expected);
            $fatal;
        end
    endtask

    initial begin
        signed_candidates = '0;
        signed_valid = '0;
        unsigned_candidates = '0;
        unsigned_valid = '0;
        quiet_candidates = '0;
        quiet_valid = '0;

        signed_candidates[0*DATA_WIDTH +: DATA_WIDTH] = 4'sd3;
        signed_candidates[1*DATA_WIDTH +: DATA_WIDTH] = -4'sd2;
        signed_candidates[2*DATA_WIDTH +: DATA_WIDTH] = 4'sd5;
        signed_candidates[3*DATA_WIDTH +: DATA_WIDTH] = 4'sd1;
        signed_valid = 4'b1111;
        #1;
        expect_logic(signed_any_valid, 1'b1, "signed max any_valid");
        expect_value(signed_winner_value, 4'sd5, "signed max winner value");
        expect_index(signed_winner_index, 2, "signed max winner index");

        signed_candidates[0*DATA_WIDTH +: DATA_WIDTH] = 4'sd4;
        signed_candidates[1*DATA_WIDTH +: DATA_WIDTH] = 4'sd4;
        signed_candidates[2*DATA_WIDTH +: DATA_WIDTH] = 4'sd2;
        signed_candidates[3*DATA_WIDTH +: DATA_WIDTH] = 4'sd4;
        signed_valid = 4'b1111;
        #1;
        expect_value(signed_winner_value, 4'sd4, "tie winner value");
        expect_index(signed_winner_index, 0, "tie winner index");

        signed_candidates[0*DATA_WIDTH +: DATA_WIDTH] = 4'sd7;
        signed_candidates[1*DATA_WIDTH +: DATA_WIDTH] = 4'sd6;
        signed_candidates[2*DATA_WIDTH +: DATA_WIDTH] = 4'sd5;
        signed_candidates[3*DATA_WIDTH +: DATA_WIDTH] = 4'sd4;
        signed_valid = 4'b0110;
        #1;
        expect_value(signed_winner_value, 4'sd6, "masked winner value");
        expect_index(signed_winner_index, 1, "masked winner index");

        signed_valid = 4'b0000;
        signed_candidates = '1;
        #1;
        expect_logic(signed_any_valid, 1'b0, "all invalid any_valid");
        expect_value(signed_winner_value, '0, "all invalid winner value");
        expect_index(signed_winner_index, '0, "all invalid winner index");

        unsigned_candidates[0*DATA_WIDTH +: DATA_WIDTH] = 4'd14;
        unsigned_candidates[1*DATA_WIDTH +: DATA_WIDTH] = 4'd1;
        unsigned_candidates[2*DATA_WIDTH +: DATA_WIDTH] = 4'd7;
        unsigned_candidates[3*DATA_WIDTH +: DATA_WIDTH] = 4'd1;
        unsigned_valid = 4'b1111;
        #1;
        expect_logic(unsigned_any_valid, 1'b1, "unsigned min any_valid");
        expect_value(unsigned_winner_value, 4'd1, "unsigned min winner value");
        expect_index(unsigned_winner_index, 1, "unsigned min winner index");

        quiet_candidates[0*DATA_WIDTH +: DATA_WIDTH] = -4'sd1;
        quiet_candidates[1*DATA_WIDTH +: DATA_WIDTH] = 4'sd6;
        quiet_candidates[2*DATA_WIDTH +: DATA_WIDTH] = 4'sd5;
        quiet_candidates[3*DATA_WIDTH +: DATA_WIDTH] = 4'sd2;
        quiet_valid = 4'b1111;
        #1;
        expect_logic(quiet_any_valid, 1'b1, "quiet any_valid");
        expect_value(quiet_winner_value, 4'sd6, "quiet winner value");
        expect_index(quiet_winner_index, '0, "quiet winner index suppressed");

        $display("comparator_tree_tb passed");
        $finish;
    end
endmodule
