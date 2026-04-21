module stream_fifo_formal;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 2;
    localparam integer DEPTH = 4;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);

    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg s_valid;
    (* anyseq *) reg [DATA_WIDTH-1:0] s_data;
    (* anyseq *) reg [SIDEBAND_WIDTH-1:0] s_sideband;
    (* anyseq *) reg m_ready;

    wire s_ready;
    wire m_valid;
    wire [DATA_WIDTH-1:0] m_data;
    wire [SIDEBAND_WIDTH-1:0] m_sideband;
    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    wire [COUNT_WIDTH-1:0] occupancy;
    wire overflow;

    stream_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(DEPTH - 1),
        .ALMOST_EMPTY_THRESHOLD(1),
        .OUTPUT_REG(0),
        .COUNT_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_sideband(s_sideband),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_sideband(m_sideband),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .occupancy(occupancy),
        .overflow(overflow)
    );

    always @(*) begin
        assert(empty);
        assert(!full);
        assert(!m_valid);
        assert(occupancy == {COUNT_WIDTH{1'b0}});
        assert(!overflow);
    end
endmodule
