module async_fifo_native #(
    parameter integer DATA_WIDTH = 32,
    parameter integer DEPTH = 16,
    parameter integer SYNC_STAGES = 2,
    parameter integer ALMOST_FULL_THRESHOLD = DEPTH - 2,
    parameter integer ALMOST_EMPTY_THRESHOLD = 1
) (
    input  wire                         wr_clk,
    input  wire                         wr_rst_n,
    input  wire                         wr_en,
    input  wire [DATA_WIDTH-1:0]        wr_data,
    output wire                         full,
    output wire                         almost_full,
    output wire [$clog2(DEPTH+1)-1:0]   wr_level,
    output wire                         overflow,

    input  wire                         rd_clk,
    input  wire                         rd_rst_n,
    input  wire                         rd_en,
    output wire [DATA_WIDTH-1:0]        rd_data,
    output wire                         empty,
    output wire                         almost_empty,
    output wire [$clog2(DEPTH+1)-1:0]   rd_level,
    output wire                         underflow
);
    async_fifo_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(SYNC_STAGES),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) core_i (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_push(wr_en),
        .wr_data(wr_data),
        .wr_full(full),
        .wr_almost_full(almost_full),
        .wr_level(wr_level),
        .wr_overflow(overflow),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_pop(rd_en),
        .rd_data(rd_data),
        .rd_empty(empty),
        .rd_almost_empty(almost_empty),
        .rd_level(rd_level),
        .rd_underflow(underflow)
    );
endmodule
