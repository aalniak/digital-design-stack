module packetizer_formal;
    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg s_valid;
    (* anyseq *) reg [15:0] s_data;
    (* anyseq *) reg s_first;
    (* anyseq *) reg s_last;
    (* anyseq *) reg [3:0] s_type;
    (* anyseq *) reg [7:0] s_length;
    (* anyseq *) reg s_error;
    (* anyseq *) reg m_ready;

    wire s_ready;
    wire m_valid;
    wire [15:0] m_data;
    wire m_first;
    wire m_last;
    wire m_header;
    wire [3:0] m_type;
    wire [7:0] m_length;
    wire m_error;
    wire protocol_error;
    wire busy;

    packetizer #(
        .DATA_WIDTH(16),
        .TYPE_WIDTH(4),
        .LENGTH_WIDTH(8),
        .HEADER_MODE(1),
        .AUTO_CLOSE_EN(0),
        .TRAILER_EN(0)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_first(s_first),
        .s_last(s_last),
        .s_type(s_type),
        .s_length(s_length),
        .s_error(s_error),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_first(m_first),
        .m_last(m_last),
        .m_header(m_header),
        .m_type(m_type),
        .m_length(m_length),
        .m_error(m_error),
        .protocol_error(protocol_error),
        .busy(busy)
    );

    always @(*) begin
        assert(!m_valid);
        assert(!busy);
        assert(!s_ready);
        assert(!protocol_error);
    end
endmodule
