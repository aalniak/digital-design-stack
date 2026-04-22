module popcount_unit_tb;
    logic [7:0] data_in;
    logic [3:0] count_out;
    logic is_zero;
    logic is_full;

    logic [3:0] quiet_count_out;
    logic quiet_is_zero;
    logic quiet_is_full;

    popcount_unit #(
        .DATA_WIDTH(8),
        .RETURN_FLAGS_EN(1'b1)
    ) dut (
        .data_in(data_in),
        .count_out(count_out),
        .is_zero(is_zero),
        .is_full(is_full)
    );

    popcount_unit #(
        .DATA_WIDTH(8),
        .RETURN_FLAGS_EN(1'b0)
    ) dut_quiet (
        .data_in(data_in),
        .count_out(quiet_count_out),
        .is_zero(quiet_is_zero),
        .is_full(quiet_is_full)
    );

    task automatic expect4(
        input [3:0] actual,
        input [3:0] expected,
        input [255:0] label
    );
        if (actual !== expected) begin
            $display("FAIL %0s actual=%0d expected=%0d", label, actual, expected);
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
        data_in = 8'h00;
        #1;
        expect4(count_out, 4'd0, "zero count");
        expect1(is_zero, 1'b1, "zero flag");
        expect1(is_full, 1'b0, "zero full flag");

        data_in = 8'hff;
        #1;
        expect4(count_out, 4'd8, "full count");
        expect1(is_zero, 1'b0, "full zero flag");
        expect1(is_full, 1'b1, "full flag");

        data_in = 8'h25;
        #1;
        expect4(count_out, 4'd3, "sparse count");
        expect1(is_zero, 1'b0, "sparse zero flag");
        expect1(is_full, 1'b0, "sparse full flag");

        data_in = 8'haa;
        #1;
        expect4(count_out, 4'd4, "alternating count");

        data_in = 8'h81;
        #1;
        expect4(quiet_count_out, 4'd2, "quiet count");
        expect1(quiet_is_zero, 1'b0, "quiet zero suppressed");
        expect1(quiet_is_full, 1'b0, "quiet full suppressed");

        $display("popcount_unit_tb passed");
        $finish;
    end
endmodule
