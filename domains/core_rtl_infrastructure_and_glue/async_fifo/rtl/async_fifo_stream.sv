module async_fifo_stream #(
    parameter integer DATA_WIDTH = 32,
    parameter integer DEPTH = 16,
    parameter integer SYNC_STAGES = 2,
    parameter integer ALMOST_FULL_THRESHOLD = DEPTH - 2,
    parameter integer ALMOST_EMPTY_THRESHOLD = 1,
    parameter bit EXPOSE_LEVELS = 1'b0,
    parameter bit EXPOSE_WATERMARKS = 1'b0
) (
    input  wire                         s_clk,
    input  wire                         s_rst_n,
    input  wire                         s_valid,
    input  wire [DATA_WIDTH-1:0]        s_data,
    output wire                         s_ready,
    output wire                         s_almost_full,
    output wire [$clog2(DEPTH+1)-1:0]   s_level,

    input  wire                         m_clk,
    input  wire                         m_rst_n,
    output wire                         m_valid,
    output wire [DATA_WIDTH-1:0]        m_data,
    input  wire                         m_ready,
    output wire                         m_almost_empty,
    output wire [$clog2(DEPTH+1)-1:0]   m_level
);
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);

    wire full_core;
    wire almost_full_core;
    wire [COUNT_WIDTH-1:0] wr_level_core;
    wire empty_core;
    wire almost_empty_core;
    wire [COUNT_WIDTH-1:0] rd_level_core;

    assign s_ready = !full_core;
    assign m_valid = !empty_core;
    assign s_almost_full = EXPOSE_WATERMARKS ? almost_full_core : 1'b0;
    assign m_almost_empty = EXPOSE_WATERMARKS ? almost_empty_core : 1'b0;
    assign s_level = EXPOSE_LEVELS ? wr_level_core : {COUNT_WIDTH{1'b0}};
    assign m_level = EXPOSE_LEVELS ? rd_level_core : {COUNT_WIDTH{1'b0}};

    async_fifo_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(SYNC_STAGES),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) core_i (
        .wr_clk(s_clk),
        .wr_rst_n(s_rst_n),
        .wr_push(s_valid && s_ready),
        .wr_data(s_data),
        .wr_full(full_core),
        .wr_almost_full(almost_full_core),
        .wr_level(wr_level_core),
        .wr_overflow(),
        .rd_clk(m_clk),
        .rd_rst_n(m_rst_n),
        .rd_pop(m_valid && m_ready),
        .rd_data(m_data),
        .rd_empty(empty_core),
        .rd_almost_empty(almost_empty_core),
        .rd_level(rd_level_core),
        .rd_underflow()
    );
endmodule
