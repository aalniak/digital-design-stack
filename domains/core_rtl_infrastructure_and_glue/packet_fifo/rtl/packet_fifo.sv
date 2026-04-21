module packet_fifo #(
    parameter integer DATA_WIDTH = 32,
    parameter integer META_WIDTH = 0,
    parameter integer DEPTH = 8,
    parameter integer ALMOST_FULL_THRESHOLD = DEPTH - 1,
    parameter integer ALMOST_EMPTY_THRESHOLD = 1,
    parameter integer COUNT_EN = 1,
    parameter integer PACKET_COUNT_EN = 1
) (
    input  wire                                     clk,
    input  wire                                     rst_n,
    input  wire                                     s_valid,
    output wire                                     s_ready,
    input  wire [DATA_WIDTH-1:0]                    s_data,
    input  wire [META_WIDTH-1:0]                    s_meta,
    input  wire                                     s_first,
    input  wire                                     s_last,
    output wire                                     m_valid,
    input  wire                                     m_ready,
    output wire [DATA_WIDTH-1:0]                    m_data,
    output wire [META_WIDTH-1:0]                    m_meta,
    output wire                                     m_first,
    output wire                                     m_last,
    output wire                                     full,
    output wire                                     empty,
    output wire                                     almost_full,
    output wire                                     almost_empty,
    output wire [((DEPTH < 1) ? 1 : $clog2(DEPTH + 1))-1:0] beat_occupancy,
    output wire [((DEPTH < 1) ? 1 : $clog2(DEPTH + 1))-1:0] packet_occupancy,
    output wire                                     overflow
);
    localparam integer COUNT_WIDTH = (DEPTH < 1) ? 1 : $clog2(DEPTH + 1);
    localparam integer SIDEBAND_WIDTH = META_WIDTH + 2;

    wire [SIDEBAND_WIDTH-1:0] fifo_s_sideband;
    wire [SIDEBAND_WIDTH-1:0] fifo_m_sideband;
    wire push_fire;
    wire pop_fire;
    reg [COUNT_WIDTH-1:0] packet_count_q;

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "packet_fifo requires DATA_WIDTH >= 1");
        end
        if (META_WIDTH < 0) begin
            $fatal(1, "packet_fifo requires META_WIDTH >= 0");
        end
        if (DEPTH < 1) begin
            $fatal(1, "packet_fifo requires DEPTH >= 1");
        end
        if ((COUNT_EN != 0) && (COUNT_EN != 1)) begin
            $fatal(1, "packet_fifo requires COUNT_EN to be 0 or 1");
        end
        if ((PACKET_COUNT_EN != 0) && (PACKET_COUNT_EN != 1)) begin
            $fatal(1, "packet_fifo requires PACKET_COUNT_EN to be 0 or 1");
        end
    end

    assign fifo_s_sideband = {s_meta, s_first, s_last};
    assign {m_meta, m_first, m_last} = fifo_m_sideband;
    assign push_fire = s_valid && s_ready;
    assign pop_fire = m_valid && m_ready;
    assign packet_occupancy = PACKET_COUNT_EN ? packet_count_q : {COUNT_WIDTH{1'b0}};

    stream_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
        .OUTPUT_REG(0),
        .COUNT_EN(COUNT_EN)
    ) fifo_i (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_sideband(fifo_s_sideband),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_sideband(fifo_m_sideband),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .occupancy(beat_occupancy),
        .overflow(overflow)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            packet_count_q <= {COUNT_WIDTH{1'b0}};
        end
        else begin
            case ({push_fire && s_last, pop_fire && m_last})
                2'b10: packet_count_q <= packet_count_q + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                2'b01: packet_count_q <= packet_count_q - {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                default: begin
                end
            endcase
        end
    end
endmodule
