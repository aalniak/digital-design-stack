module gearbox #(
    parameter integer SYMBOL_WIDTH = 8,
    parameter integer IN_SYMBOLS = 1,
    parameter integer OUT_SYMBOLS = 4,
    parameter integer LAST_EN = 1,
    parameter integer FLUSH_EN = 1
) (
    input  wire                                   clk,
    input  wire                                   rst_n,
    input  wire                                   s_valid,
    output wire                                   s_ready,
    input  wire [(IN_SYMBOLS*SYMBOL_WIDTH)-1:0]   s_data,
    input  wire [IN_SYMBOLS-1:0]                  s_keep,
    input  wire                                   s_last,
    input  wire                                   flush,
    output wire                                   m_valid,
    input  wire                                   m_ready,
    output wire [(OUT_SYMBOLS*SYMBOL_WIDTH)-1:0]  m_data,
    output wire [OUT_SYMBOLS-1:0]                 m_keep,
    output wire                                   m_last,
    output wire                                   busy
);
    localparam integer IN_COUNT_WIDTH = (IN_SYMBOLS <= 1) ? 1 : $clog2(IN_SYMBOLS + 1);
    localparam integer OUT_COUNT_WIDTH = (OUT_SYMBOLS <= 1) ? 1 : $clog2(OUT_SYMBOLS + 1);
    localparam integer SLICE_COUNT_MAX = (IN_SYMBOLS + OUT_SYMBOLS - 1) / OUT_SYMBOLS;
    localparam integer SLICE_COUNT_WIDTH = (SLICE_COUNT_MAX <= 1) ? 1 : $clog2(SLICE_COUNT_MAX + 1);
    localparam integer SLICE_INDEX_WIDTH = (SLICE_COUNT_MAX <= 1) ? 1 : $clog2(SLICE_COUNT_MAX);
    localparam integer REMAIN_WIDTH = (IN_SYMBOLS <= OUT_SYMBOLS) ? OUT_COUNT_WIDTH : IN_COUNT_WIDTH;

    function automatic [OUT_SYMBOLS-1:0] make_keep_mask;
        input integer valid_count;
        integer keep_idx;
        begin
            make_keep_mask = {OUT_SYMBOLS{1'b0}};
            for (keep_idx = 0; keep_idx < OUT_SYMBOLS; keep_idx = keep_idx + 1) begin
                if (keep_idx < valid_count) begin
                    make_keep_mask[keep_idx] = 1'b1;
                end
            end
        end
    endfunction

    initial begin
        if (SYMBOL_WIDTH < 1) begin
            $fatal(1, "gearbox requires SYMBOL_WIDTH >= 1");
        end
        if (IN_SYMBOLS < 1) begin
            $fatal(1, "gearbox requires IN_SYMBOLS >= 1");
        end
        if (OUT_SYMBOLS < 1) begin
            $fatal(1, "gearbox requires OUT_SYMBOLS >= 1");
        end
        if ((LAST_EN != 0) && (LAST_EN != 1)) begin
            $fatal(1, "gearbox requires LAST_EN to be 0 or 1");
        end
        if ((FLUSH_EN != 0) && (FLUSH_EN != 1)) begin
            $fatal(1, "gearbox requires FLUSH_EN to be 0 or 1");
        end
    end

    generate
        if (OUT_SYMBOLS >= IN_SYMBOLS) begin : gen_accumulate
            reg [(OUT_SYMBOLS*SYMBOL_WIDTH)-1:0] accum_data_q;
            reg [OUT_SYMBOLS-1:0] accum_keep_q;
            reg [OUT_COUNT_WIDTH-1:0] accum_symbols_q;

            reg [(OUT_SYMBOLS*SYMBOL_WIDTH)-1:0] out_data_q;
            reg [OUT_SYMBOLS-1:0] out_keep_q;
            reg out_last_q;
            reg out_valid_q;

            reg [(OUT_SYMBOLS*SYMBOL_WIDTH)-1:0] next_accum_data;
            reg [OUT_SYMBOLS-1:0] next_accum_keep;
            reg [OUT_COUNT_WIDTH-1:0] next_accum_symbols;
            reg [IN_COUNT_WIDTH-1:0] incoming_symbol_count;
            reg boundary_on_input;
            reg need_preflush;
            integer append_index;
            integer lane_idx;

            assign s_ready = rst_n && !out_valid_q && !need_preflush;
            assign m_valid = out_valid_q;
            assign m_data = out_data_q;
            assign m_keep = out_keep_q;
            assign m_last = out_last_q;
            assign busy = out_valid_q || (accum_symbols_q != {OUT_COUNT_WIDTH{1'b0}});

            always @(*) begin
                incoming_symbol_count = {IN_COUNT_WIDTH{1'b0}};
                for (lane_idx = 0; lane_idx < IN_SYMBOLS; lane_idx = lane_idx + 1) begin
                    if (s_keep[lane_idx]) begin
                        incoming_symbol_count = incoming_symbol_count + {{(IN_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                next_accum_data = accum_data_q;
                next_accum_keep = accum_keep_q;
                next_accum_symbols = accum_symbols_q;
                append_index = accum_symbols_q;

                for (lane_idx = 0; lane_idx < IN_SYMBOLS; lane_idx = lane_idx + 1) begin
                    if (s_keep[lane_idx]) begin
                        next_accum_data[(append_index * SYMBOL_WIDTH) +: SYMBOL_WIDTH] = s_data[(lane_idx * SYMBOL_WIDTH) +: SYMBOL_WIDTH];
                        next_accum_keep[append_index] = 1'b1;
                        append_index = append_index + 1;
                    end
                end

                next_accum_symbols = append_index[OUT_COUNT_WIDTH-1:0];
                boundary_on_input = ((LAST_EN != 0) && s_last) || ((FLUSH_EN != 0) && flush);
                need_preflush = (accum_symbols_q != {OUT_COUNT_WIDTH{1'b0}}) &&
                                s_valid &&
                                ((accum_symbols_q + incoming_symbol_count) > OUT_SYMBOLS);
            end

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    accum_data_q <= {(OUT_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                    accum_keep_q <= {OUT_SYMBOLS{1'b0}};
                    accum_symbols_q <= {OUT_COUNT_WIDTH{1'b0}};
                    out_data_q <= {(OUT_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                    out_keep_q <= {OUT_SYMBOLS{1'b0}};
                    out_last_q <= 1'b0;
                    out_valid_q <= 1'b0;
                end
                else begin
                    if (out_valid_q && m_ready) begin
                        out_valid_q <= 1'b0;
                    end

                    if (!out_valid_q) begin
                        if (need_preflush) begin
                            out_data_q <= accum_data_q;
                            out_keep_q <= accum_keep_q;
                            out_last_q <= 1'b0;
                            out_valid_q <= 1'b1;
                            accum_data_q <= {(OUT_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                            accum_keep_q <= {OUT_SYMBOLS{1'b0}};
                            accum_symbols_q <= {OUT_COUNT_WIDTH{1'b0}};
                        end
                        else if (s_valid && s_ready) begin
                            if ((next_accum_symbols != {OUT_COUNT_WIDTH{1'b0}}) &&
                                ((next_accum_symbols >= OUT_SYMBOLS) || boundary_on_input)) begin
                                out_data_q <= next_accum_data;
                                out_keep_q <= next_accum_keep;
                                out_last_q <= boundary_on_input;
                                out_valid_q <= 1'b1;
                                accum_data_q <= {(OUT_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                                accum_keep_q <= {OUT_SYMBOLS{1'b0}};
                                accum_symbols_q <= {OUT_COUNT_WIDTH{1'b0}};
                            end
                            else begin
                                accum_data_q <= next_accum_data;
                                accum_keep_q <= next_accum_keep;
                                accum_symbols_q <= next_accum_symbols;
                            end
                        end
                        else if ((FLUSH_EN != 0) && flush && (accum_symbols_q != {OUT_COUNT_WIDTH{1'b0}})) begin
                            out_data_q <= accum_data_q;
                            out_keep_q <= accum_keep_q;
                            out_last_q <= 1'b1;
                            out_valid_q <= 1'b1;
                            accum_data_q <= {(OUT_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                            accum_keep_q <= {OUT_SYMBOLS{1'b0}};
                            accum_symbols_q <= {OUT_COUNT_WIDTH{1'b0}};
                        end
                    end
                end
            end
        end
        else begin : gen_slice
            reg [(IN_SYMBOLS*SYMBOL_WIDTH)-1:0] hold_data_q;
            reg [IN_COUNT_WIDTH-1:0] valid_symbols_q;
            reg [SLICE_COUNT_WIDTH-1:0] slice_count_q;
            reg [SLICE_INDEX_WIDTH-1:0] slice_index_q;
            reg boundary_q;
            reg active_q;

            reg [(IN_SYMBOLS*SYMBOL_WIDTH)-1:0] packed_input_data;
            reg [IN_COUNT_WIDTH-1:0] incoming_symbol_count;
            reg [SLICE_COUNT_WIDTH-1:0] slice_count_calc;
            reg boundary_on_input;
            reg [REMAIN_WIDTH-1:0] current_remaining_symbols;
            reg [REMAIN_WIDTH-1:0] current_keep_count;
            integer pack_index;
            integer in_lane;

            assign s_ready = rst_n && !active_q;
            assign m_valid = active_q;
            assign m_data = hold_data_q[(slice_index_q * OUT_SYMBOLS * SYMBOL_WIDTH) +: (OUT_SYMBOLS*SYMBOL_WIDTH)];
            assign m_keep = make_keep_mask(current_keep_count);
            assign m_last = boundary_q && (slice_index_q == (slice_count_q - 1));
            assign busy = active_q;

            always @(*) begin
                packed_input_data = {(IN_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                incoming_symbol_count = {IN_COUNT_WIDTH{1'b0}};
                pack_index = 0;

                for (in_lane = 0; in_lane < IN_SYMBOLS; in_lane = in_lane + 1) begin
                    if (s_keep[in_lane]) begin
                        packed_input_data[(pack_index * SYMBOL_WIDTH) +: SYMBOL_WIDTH] = s_data[(in_lane * SYMBOL_WIDTH) +: SYMBOL_WIDTH];
                        incoming_symbol_count = incoming_symbol_count + {{(IN_COUNT_WIDTH-1){1'b0}}, 1'b1};
                        pack_index = pack_index + 1;
                    end
                end

                if (incoming_symbol_count == {IN_COUNT_WIDTH{1'b0}}) begin
                    slice_count_calc = {SLICE_COUNT_WIDTH{1'b0}};
                end
                else begin
                    slice_count_calc = (incoming_symbol_count + OUT_SYMBOLS - 1) / OUT_SYMBOLS;
                end

                current_remaining_symbols = valid_symbols_q - (slice_index_q * OUT_SYMBOLS);
                if (current_remaining_symbols >= OUT_SYMBOLS) begin
                    current_keep_count = OUT_SYMBOLS[REMAIN_WIDTH-1:0];
                end
                else begin
                    current_keep_count = current_remaining_symbols;
                end

                boundary_on_input = ((LAST_EN != 0) && s_last) || ((FLUSH_EN != 0) && flush);
            end

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    hold_data_q <= {(IN_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                    valid_symbols_q <= {IN_COUNT_WIDTH{1'b0}};
                    slice_count_q <= {SLICE_COUNT_WIDTH{1'b0}};
                    slice_index_q <= {SLICE_INDEX_WIDTH{1'b0}};
                    boundary_q <= 1'b0;
                    active_q <= 1'b0;
                end
                else begin
                    if (active_q && m_ready) begin
                        if (slice_index_q == (slice_count_q - 1)) begin
                            hold_data_q <= {(IN_SYMBOLS*SYMBOL_WIDTH){1'b0}};
                            valid_symbols_q <= {IN_COUNT_WIDTH{1'b0}};
                            slice_count_q <= {SLICE_COUNT_WIDTH{1'b0}};
                            slice_index_q <= {SLICE_INDEX_WIDTH{1'b0}};
                            boundary_q <= 1'b0;
                            active_q <= 1'b0;
                        end
                        else begin
                            slice_index_q <= slice_index_q + {{(SLICE_INDEX_WIDTH-1){1'b0}}, 1'b1};
                        end
                    end

                    if (s_valid && s_ready) begin
                        hold_data_q <= packed_input_data;
                        valid_symbols_q <= incoming_symbol_count;
                        slice_count_q <= slice_count_calc;
                        slice_index_q <= {SLICE_INDEX_WIDTH{1'b0}};
                        boundary_q <= boundary_on_input;
                        active_q <= (incoming_symbol_count != {IN_COUNT_WIDTH{1'b0}});
                    end
                end
            end
        end
    endgenerate
endmodule
