module leading_zero_counter_tb;
    logic [7:0] data_in;
    logic [3:0] leading_zero_count;
    logic all_zero;
    logic [2:0] msb_index;

    logic [3:0] quiet_count;
    logic quiet_all_zero;
    logic [2:0] quiet_msb_index;

    leading_zero_counter #(
        .DATA_WIDTH(8),
        .RETURN_MSB_INDEX_EN(1'b1)
    ) dut (
        .data_in(data_in),
        .leading_zero_count(leading_zero_count),
        .all_zero(all_zero),
        .msb_index(msb_index)
    );

    leading_zero_counter #(
        .DATA_WIDTH(8),
        .RETURN_MSB_INDEX_EN(1'b0)
    ) dut_quiet (
        .data_in(data_in),
        .leading_zero_count(quiet_count),
        .all_zero(quiet_all_zero),
        .msb_index(quiet_msb_index)
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

    task automatic expect3(
        input [2:0] actual,
        input [2:0] expected,
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
        expect4(leading_zero_count, 4'd8, "all-zero count");
        expect1(all_zero, 1'b1, "all-zero flag");
        expect3(msb_index, 3'd0, "all-zero index");

        data_in = 8'h80;
        #1;
        expect4(leading_zero_count, 4'd0, "msb count");
        expect1(all_zero, 1'b0, "msb flag");
        expect3(msb_index, 3'd7, "msb index");

        data_in = 8'h12;
        #1;
        expect4(leading_zero_count, 4'd3, "middle count");
        expect1(all_zero, 1'b0, "middle flag");
        expect3(msb_index, 3'd4, "middle index");

        data_in = 8'h01;
        #1;
        expect4(leading_zero_count, 4'd7, "lsb count");
        expect1(all_zero, 1'b0, "lsb flag");
        expect3(msb_index, 3'd0, "lsb index");

        data_in = 8'h24;
        #1;
        expect4(quiet_count, 4'd2, "quiet count");
        expect1(quiet_all_zero, 1'b0, "quiet flag");
        expect3(quiet_msb_index, 3'd0, "quiet index suppressed");

        $display("leading_zero_counter_tb passed");
        $finish;
    end
endmodule
