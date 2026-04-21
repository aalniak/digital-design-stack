module async_fifo_packet #(
    parameter integer DATA_WIDTH = 32,
    parameter integer DEPTH = 16,
    parameter integer SYNC_STAGES = 2,
    parameter integer ALMOST_FULL_THRESHOLD = DEPTH - 2,
    parameter integer ALMOST_EMPTY_THRESHOLD = 1,
    parameter bit EXPOSE_LEVELS = 1'b0,
    parameter bit EXPOSE_WATERMARKS = 1'b0,
    parameter bit KEEP_ENABLE = 1'b0,
    parameter integer KEEP_WIDTH = 1,
    parameter bit USER_ENABLE = 1'b0,
    parameter integer USER_WIDTH = 1
) (
    input  wire                                 s_clk,
    input  wire                                 s_rst_n,
    input  wire                                 s_valid,
    input  wire [DATA_WIDTH-1:0]                s_data,
    input  wire                                 s_last,
    input  wire [((KEEP_WIDTH < 1) ? 1 : KEEP_WIDTH)-1:0] s_keep,
    input  wire [((USER_WIDTH < 1) ? 1 : USER_WIDTH)-1:0] s_user,
    output wire                                 s_ready,
    output wire                                 s_almost_full,
    output wire [$clog2(DEPTH+1)-1:0]           s_level,

    input  wire                                 m_clk,
    input  wire                                 m_rst_n,
    output wire                                 m_valid,
    output wire [DATA_WIDTH-1:0]                m_data,
    output wire                                 m_last,
    output wire [((KEEP_WIDTH < 1) ? 1 : KEEP_WIDTH)-1:0] m_keep,
    output wire [((USER_WIDTH < 1) ? 1 : USER_WIDTH)-1:0] m_user,
    input  wire                                 m_ready,
    output wire                                 m_almost_empty,
    output wire [$clog2(DEPTH+1)-1:0]           m_level
);
    localparam integer KEEP_PORT_WIDTH = (KEEP_WIDTH < 1) ? 1 : KEEP_WIDTH;
    localparam integer USER_PORT_WIDTH = (USER_WIDTH < 1) ? 1 : USER_WIDTH;
    localparam integer PACKED_WIDTH = DATA_WIDTH + 1 + KEEP_PORT_WIDTH + USER_PORT_WIDTH;

    wire [PACKED_WIDTH-1:0] packed_s_data;
    wire [PACKED_WIDTH-1:0] packed_m_data;
    wire [KEEP_PORT_WIDTH-1:0] s_keep_masked = KEEP_ENABLE ? s_keep : {KEEP_PORT_WIDTH{1'b0}};
    wire [USER_PORT_WIDTH-1:0] s_user_masked = USER_ENABLE ? s_user : {USER_PORT_WIDTH{1'b0}};
    wire [KEEP_PORT_WIDTH-1:0] keep_unpacked;
    wire [USER_PORT_WIDTH-1:0] user_unpacked;

    assign packed_s_data = {s_user_masked, s_keep_masked, s_last, s_data};
    assign {user_unpacked, keep_unpacked, m_last, m_data} = packed_m_data;
    assign m_keep = KEEP_ENABLE ? keep_unpacked : {KEEP_PORT_WIDTH{1'b0}};
    assign m_user = USER_ENABLE ? user_unpacked : {USER_PORT_WIDTH{1'b0}};

    async_fifo_stream #(
        .DATA_WIDTH(PACKED_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(SYNC_STAGES),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
        .EXPOSE_LEVELS(EXPOSE_LEVELS),
        .EXPOSE_WATERMARKS(EXPOSE_WATERMARKS)
    ) stream_i (
        .s_clk(s_clk),
        .s_rst_n(s_rst_n),
        .s_valid(s_valid),
        .s_data(packed_s_data),
        .s_ready(s_ready),
        .s_almost_full(s_almost_full),
        .s_level(s_level),
        .m_clk(m_clk),
        .m_rst_n(m_rst_n),
        .m_valid(m_valid),
        .m_data(packed_m_data),
        .m_ready(m_ready),
        .m_almost_empty(m_almost_empty),
        .m_level(m_level)
    );
endmodule
