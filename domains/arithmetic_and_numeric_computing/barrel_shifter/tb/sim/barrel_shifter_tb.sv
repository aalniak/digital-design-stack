module barrel_shifter_tb;
    logic [7:0] data_in;
    logic [3:0] shift_amount;
    logic [1:0] shift_mode;
    logic [7:0] data_out;
    logic sticky;

    logic [7:0] quiet_data_out;
    logic quiet_sticky;

    barrel_shifter #(
        .DATA_WIDTH(8),
        .AMOUNT_WIDTH(4),
        .STICKY_BIT_EN(1'b1)
    ) dut (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .shift_mode(shift_mode),
        .data_out(data_out),
        .sticky(sticky)
    );

    barrel_shifter #(
        .DATA_WIDTH(8),
        .AMOUNT_WIDTH(4),
        .STICKY_BIT_EN(1'b0)
    ) dut_quiet (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .shift_mode(shift_mode),
        .data_out(quiet_data_out),
        .sticky(quiet_sticky)
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
        shift_amount = 4'd0;
        shift_mode = 2'b00;
        #1;

        data_in = 8'hb3;
        shift_amount = 4'd2;
        shift_mode = 2'b00;
        #1;
        expect8(data_out, 8'hcc, "left shift result");
        expect1(sticky, 1'b1, "left shift sticky");

        data_in = 8'hb3;
        shift_amount = 4'd3;
        shift_mode = 2'b01;
        #1;
        expect8(data_out, 8'h16, "logical right result");
        expect1(sticky, 1'b1, "logical right sticky");

        data_in = 8'h96;
        shift_amount = 4'd3;
        shift_mode = 2'b10;
        #1;
        expect8(data_out, 8'hf2, "arithmetic right result");
        expect1(sticky, 1'b1, "arithmetic right sticky");

        data_in = 8'h96;
        shift_amount = 4'd3;
        shift_mode = 2'b11;
        #1;
        expect8(data_out, 8'hb4, "rotate left result");
        expect1(sticky, 1'b0, "rotate left sticky");

        data_in = 8'h53;
        shift_amount = 4'd8;
        shift_mode = 2'b00;
        #1;
        expect8(data_out, 8'h00, "oversize left result");
        expect1(sticky, 1'b1, "oversize left sticky");

        data_in = 8'h96;
        shift_amount = 4'd8;
        shift_mode = 2'b10;
        #1;
        expect8(data_out, 8'hff, "oversize arithmetic right result");
        expect1(sticky, 1'b1, "oversize arithmetic right sticky");

        data_in = 8'hb3;
        shift_amount = 4'd2;
        shift_mode = 2'b00;
        #1;
        expect8(quiet_data_out, 8'hcc, "sticky disabled result");
        expect1(quiet_sticky, 1'b0, "sticky disabled output");

        $display("barrel_shifter_tb passed");
        $finish;
    end
endmodule
