module width_converter #(
    parameter integer IN_BYTES = 4,
    parameter integer OUT_BYTES = 4
) (
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          s_valid,
    output wire                          s_ready,
    input  wire [(IN_BYTES*8)-1:0]       s_data,
    input  wire [IN_BYTES-1:0]           s_keep,
    input  wire                          s_last,
    output wire                          m_valid,
    input  wire                          m_ready,
    output wire [(OUT_BYTES*8)-1:0]      m_data,
    output wire [OUT_BYTES-1:0]          m_keep,
    output wire                          m_last,
    output wire                          busy
);
    localparam integer RATIO = (IN_BYTES >= OUT_BYTES) ? (IN_BYTES / OUT_BYTES) : (OUT_BYTES / IN_BYTES);
    localparam integer COUNT_WIDTH = (RATIO <= 1) ? 1 : $clog2(RATIO + 1);
    localparam integer NARROW_INDEX_WIDTH = (RATIO <= 1) ? 1 : $clog2(RATIO);

    function automatic integer count_ones;
        input [IN_BYTES-1:0] keep_value;
        integer keep_idx;
        begin
            count_ones = 0;
            for (keep_idx = 0; keep_idx < IN_BYTES; keep_idx = keep_idx + 1) begin
                if (keep_value[keep_idx]) begin
                    count_ones = count_ones + 1;
                end
            end
        end
    endfunction

    initial begin
        if (IN_BYTES < 1) begin
            $fatal(1, "width_converter requires IN_BYTES >= 1");
        end
        if (OUT_BYTES < 1) begin
            $fatal(1, "width_converter requires OUT_BYTES >= 1");
        end
        if ((IN_BYTES >= OUT_BYTES) && ((IN_BYTES % OUT_BYTES) != 0)) begin
            $fatal(1, "width_converter requires IN_BYTES to be an integer multiple of OUT_BYTES when narrowing");
        end
        if ((OUT_BYTES > IN_BYTES) && ((OUT_BYTES % IN_BYTES) != 0)) begin
            $fatal(1, "width_converter requires OUT_BYTES to be an integer multiple of IN_BYTES when widening");
        end
    end

    generate
        if (IN_BYTES == OUT_BYTES) begin : gen_bypass
            assign s_ready = rst_n ? m_ready : 1'b0;
            assign m_valid = rst_n ? s_valid : 1'b0;
            assign m_data = s_data;
            assign m_keep = s_keep;
            assign m_last = s_last;
            assign busy = 1'b0;
        end
        else if (OUT_BYTES > IN_BYTES) begin : gen_widen
            localparam integer SEGMENT_COUNT = OUT_BYTES / IN_BYTES;

            reg [(OUT_BYTES*8)-1:0] accum_data_q;
            reg [OUT_BYTES-1:0] accum_keep_q;
            reg [COUNT_WIDTH-1:0] accum_count_q;
            reg [(OUT_BYTES*8)-1:0] out_data_q;
            reg [OUT_BYTES-1:0] out_keep_q;
            reg out_last_q;
            reg out_valid_q;
            reg [(OUT_BYTES*8)-1:0] next_data;
            reg [OUT_BYTES-1:0] next_keep;
            reg [COUNT_WIDTH-1:0] next_count;

            integer lane_idx;

            assign s_ready = rst_n && !out_valid_q;
            assign m_valid = out_valid_q;
            assign m_data = out_data_q;
            assign m_keep = out_keep_q;
            assign m_last = out_last_q;
            assign busy = out_valid_q || (accum_count_q != {COUNT_WIDTH{1'b0}});

            always @(*) begin
                next_data = accum_data_q;
                next_keep = accum_keep_q;
                next_count = accum_count_q;

                for (lane_idx = 0; lane_idx < IN_BYTES; lane_idx = lane_idx + 1) begin
                    next_data[((accum_count_q * IN_BYTES * 8) + (lane_idx * 8)) +: 8] = s_data[(lane_idx * 8) +: 8];
                    next_keep[(accum_count_q * IN_BYTES) + lane_idx] = s_keep[lane_idx];
                end
                next_count = accum_count_q + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
            end

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    accum_data_q <= {(OUT_BYTES*8){1'b0}};
                    accum_keep_q <= {OUT_BYTES{1'b0}};
                    accum_count_q <= {COUNT_WIDTH{1'b0}};
                    out_data_q <= {(OUT_BYTES*8){1'b0}};
                    out_keep_q <= {OUT_BYTES{1'b0}};
                    out_last_q <= 1'b0;
                    out_valid_q <= 1'b0;
                end
                else begin
                    if (out_valid_q && m_ready) begin
                        out_valid_q <= 1'b0;
                    end

                    if (s_valid && s_ready) begin
                        if (s_last || (accum_count_q == (SEGMENT_COUNT - 1))) begin
                            out_data_q <= next_data;
                            out_keep_q <= next_keep;
                            out_last_q <= s_last;
                            out_valid_q <= 1'b1;
                            accum_data_q <= {(OUT_BYTES*8){1'b0}};
                            accum_keep_q <= {OUT_BYTES{1'b0}};
                            accum_count_q <= {COUNT_WIDTH{1'b0}};
                        end
                        else begin
                            accum_data_q <= next_data;
                            accum_keep_q <= next_keep;
                            accum_count_q <= next_count;
                        end
                    end
                end
            end
        end
        else begin : gen_narrow
            localparam integer SEGMENT_COUNT = IN_BYTES / OUT_BYTES;

            reg [(IN_BYTES*8)-1:0] hold_data_q;
            reg [IN_BYTES-1:0] hold_keep_q;
            reg hold_last_q;
            reg [NARROW_INDEX_WIDTH-1:0] slice_index_q;
            reg [COUNT_WIDTH-1:0] slice_count_q;
            reg active_q;
            reg [COUNT_WIDTH-1:0] valid_byte_count;
            reg [COUNT_WIDTH-1:0] slice_count_calc;

            assign s_ready = rst_n && !active_q;
            assign m_valid = active_q;
            assign m_data = hold_data_q[(slice_index_q * OUT_BYTES * 8) +: (OUT_BYTES*8)];
            assign m_keep = hold_keep_q[(slice_index_q * OUT_BYTES) +: OUT_BYTES];
            assign m_last = hold_last_q && (slice_index_q == (slice_count_q - 1));
            assign busy = active_q;

            always @(*) begin
                valid_byte_count = count_ones(s_keep);
                if (valid_byte_count == 0) begin
                    slice_count_calc = {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                end
                else begin
                    slice_count_calc = (valid_byte_count + OUT_BYTES - 1) / OUT_BYTES;
                end
            end

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    hold_data_q <= {(IN_BYTES*8){1'b0}};
                    hold_keep_q <= {IN_BYTES{1'b0}};
                    hold_last_q <= 1'b0;
                    slice_index_q <= {NARROW_INDEX_WIDTH{1'b0}};
                    slice_count_q <= {COUNT_WIDTH{1'b0}};
                    active_q <= 1'b0;
                end
                else begin
                    if (active_q && m_ready) begin
                        if (slice_index_q == (slice_count_q - 1)) begin
                            active_q <= 1'b0;
                            slice_index_q <= {NARROW_INDEX_WIDTH{1'b0}};
                        end
                        else begin
                            slice_index_q <= slice_index_q + {{(NARROW_INDEX_WIDTH-1){1'b0}}, 1'b1};
                        end
                    end

                    if (s_valid && s_ready) begin
                        hold_data_q <= s_data;
                        hold_keep_q <= s_keep;
                        hold_last_q <= s_last;
                        slice_index_q <= {NARROW_INDEX_WIDTH{1'b0}};
                        slice_count_q <= slice_count_calc;
                        active_q <= 1'b1;
                    end
                end
            end
        end
    endgenerate
endmodule
