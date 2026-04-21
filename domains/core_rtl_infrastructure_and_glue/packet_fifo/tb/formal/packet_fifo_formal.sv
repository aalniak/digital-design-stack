module packet_fifo_formal;
    localparam integer DATA_WIDTH = 8;
    localparam integer META_WIDTH = 2;
    localparam integer DEPTH = 4;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);

    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg s_valid;
    (* anyseq *) reg [DATA_WIDTH-1:0] s_data;
    (* anyseq *) reg [META_WIDTH-1:0] s_meta;
    (* anyseq *) reg s_first;
    (* anyseq *) reg s_last;
    (* anyseq *) reg m_ready;

    wire s_ready;
    wire m_valid;
    wire [DATA_WIDTH-1:0] m_data;
    wire [META_WIDTH-1:0] m_meta;
    wire m_first;
    wire m_last;
    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    wire [COUNT_WIDTH-1:0] beat_occupancy;
    wire [COUNT_WIDTH-1:0] packet_occupancy;
    wire overflow;

    packet_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .META_WIDTH(META_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(DEPTH - 1),
        .ALMOST_EMPTY_THRESHOLD(1),
        .COUNT_EN(1),
        .PACKET_COUNT_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_meta(s_meta),
        .s_first(s_first),
        .s_last(s_last),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_meta(m_meta),
        .m_first(m_first),
        .m_last(m_last),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .beat_occupancy(beat_occupancy),
        .packet_occupancy(packet_occupancy),
        .overflow(overflow)
    );

    always @(*) begin
        assert(empty);
        assert(!full);
        assert(!m_valid);
        assert(beat_occupancy == {COUNT_WIDTH{1'b0}});
        assert(packet_occupancy == {COUNT_WIDTH{1'b0}});
        assert(!overflow);
    end
endmodule
