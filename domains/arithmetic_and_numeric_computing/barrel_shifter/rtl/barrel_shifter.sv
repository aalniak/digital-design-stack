module barrel_shifter #(
    parameter int DATA_WIDTH = 16,
    parameter int AMOUNT_WIDTH = (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH + 1),
    parameter bit STICKY_BIT_EN = 1'b1
) (
    input  logic [DATA_WIDTH-1:0]   data_in,
    input  logic [AMOUNT_WIDTH-1:0] shift_amount,
    input  logic [1:0]              shift_mode,
    output logic [DATA_WIDTH-1:0]   data_out,
    output logic                    sticky
);

    localparam logic [1:0] MODE_LEFT = 2'b00;
    localparam logic [1:0] MODE_LOGICAL_RIGHT = 2'b01;
    localparam logic [1:0] MODE_ARITH_RIGHT = 2'b10;
    localparam logic [1:0] MODE_ROTATE_LEFT = 2'b11;

    integer amount_int;
    integer amount_clamped;
    integer rotate_amount;
    integer bit_index;
    logic sticky_internal;

    always @* begin
        amount_int = shift_amount;
        bit_index = 0;
        if (amount_int < 0) begin
            amount_int = 0;
        end
        if (amount_int > DATA_WIDTH) begin
            amount_clamped = DATA_WIDTH;
        end else begin
            amount_clamped = amount_int;
        end

        if (DATA_WIDTH > 0) begin
            rotate_amount = amount_int % DATA_WIDTH;
        end else begin
            rotate_amount = 0;
        end

        data_out = data_in;
        sticky_internal = 1'b0;

        case (shift_mode)
            MODE_LEFT: begin
                if (amount_clamped >= DATA_WIDTH) begin
                    data_out = '0;
                end else begin
                    data_out = data_in << amount_clamped;
                end
                for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
                    if ((amount_clamped > 0) && (bit_index >= (DATA_WIDTH - amount_clamped)) && data_in[bit_index]) begin
                        sticky_internal = 1'b1;
                    end
                end
            end

            MODE_LOGICAL_RIGHT: begin
                if (amount_clamped >= DATA_WIDTH) begin
                    data_out = '0;
                end else begin
                    data_out = data_in >> amount_clamped;
                end
                for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
                    if ((bit_index < amount_clamped) && data_in[bit_index]) begin
                        sticky_internal = 1'b1;
                    end
                end
            end

            MODE_ARITH_RIGHT: begin
                if (amount_clamped >= DATA_WIDTH) begin
                    data_out = data_in[DATA_WIDTH-1] ? {DATA_WIDTH{1'b1}} : '0;
                end else begin
                    data_out = $signed(data_in) >>> amount_clamped;
                end
                for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
                    if ((bit_index < amount_clamped) && data_in[bit_index]) begin
                        sticky_internal = 1'b1;
                    end
                end
            end

            default: begin
                if ((DATA_WIDTH <= 1) || (rotate_amount == 0)) begin
                    data_out = data_in;
                end else begin
                    data_out = (data_in << rotate_amount) | (data_in >> (DATA_WIDTH - rotate_amount));
                end
                sticky_internal = 1'b0;
            end
        endcase

        if (STICKY_BIT_EN) begin
            sticky = sticky_internal;
        end else begin
            sticky = 1'b0;
        end
    end

    initial begin
        if (DATA_WIDTH < 1) begin
            $error("barrel_shifter requires DATA_WIDTH >= 1");
            $finish;
        end
        if (AMOUNT_WIDTH < 1) begin
            $error("barrel_shifter requires AMOUNT_WIDTH >= 1");
            $finish;
        end
    end

endmodule
