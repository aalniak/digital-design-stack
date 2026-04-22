module barrel_shifter_formal;
    localparam int DATA_WIDTH = 5;
    localparam int AMOUNT_WIDTH = 3;

    (* anyconst *) logic [DATA_WIDTH-1:0] data_in;
    (* anyconst *) logic [AMOUNT_WIDTH-1:0] shift_amount;
    (* anyconst *) logic [1:0] shift_mode;

    logic [DATA_WIDTH-1:0] data_out;
    logic sticky;

    integer amount_int;
    integer amount_clamped;
    integer rotate_amount;
    integer bit_index;
    logic [DATA_WIDTH-1:0] expected_data_out;
    logic expected_sticky;

    barrel_shifter #(
        .DATA_WIDTH(DATA_WIDTH),
        .AMOUNT_WIDTH(AMOUNT_WIDTH),
        .STICKY_BIT_EN(1'b1)
    ) dut (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .shift_mode(shift_mode),
        .data_out(data_out),
        .sticky(sticky)
    );

    always @* begin
        amount_int = shift_amount;
        if (amount_int > DATA_WIDTH) begin
            amount_clamped = DATA_WIDTH;
        end else begin
            amount_clamped = amount_int;
        end
        rotate_amount = amount_int % DATA_WIDTH;

        expected_data_out = data_in;
        expected_sticky = 1'b0;

        case (shift_mode)
            2'b00: begin
                if (amount_clamped >= DATA_WIDTH) begin
                    expected_data_out = '0;
                end else begin
                    expected_data_out = data_in << amount_clamped;
                end
                for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
                    if ((amount_clamped > 0) && (bit_index >= (DATA_WIDTH - amount_clamped)) && data_in[bit_index]) begin
                        expected_sticky = 1'b1;
                    end
                end
            end

            2'b01: begin
                if (amount_clamped >= DATA_WIDTH) begin
                    expected_data_out = '0;
                end else begin
                    expected_data_out = data_in >> amount_clamped;
                end
                for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
                    if ((bit_index < amount_clamped) && data_in[bit_index]) begin
                        expected_sticky = 1'b1;
                    end
                end
            end

            2'b10: begin
                if (amount_clamped >= DATA_WIDTH) begin
                    expected_data_out = data_in[DATA_WIDTH-1] ? {DATA_WIDTH{1'b1}} : '0;
                end else begin
                    expected_data_out = $signed(data_in) >>> amount_clamped;
                end
                for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
                    if ((bit_index < amount_clamped) && data_in[bit_index]) begin
                        expected_sticky = 1'b1;
                    end
                end
            end

            default: begin
                if ((DATA_WIDTH <= 1) || (rotate_amount == 0)) begin
                    expected_data_out = data_in;
                end else begin
                    expected_data_out = (data_in << rotate_amount) | (data_in >> (DATA_WIDTH - rotate_amount));
                end
                expected_sticky = 1'b0;
            end
        endcase

        assert(data_out == expected_data_out);
        assert(sticky == expected_sticky);
    end
endmodule
