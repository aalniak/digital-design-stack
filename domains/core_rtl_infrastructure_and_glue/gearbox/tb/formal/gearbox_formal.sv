module gearbox_formal;
    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg s_valid;
    (* anyseq *) reg [7:0] s_data;
    (* anyseq *) reg [1:0] s_keep;
    (* anyseq *) reg s_last;
    (* anyseq *) reg flush;
    (* anyseq *) reg m_ready;

    wire s_ready;
    wire m_valid;
    wire [11:0] m_data;
    wire [2:0] m_keep;
    wire m_last;
    wire busy;

    gearbox #(
        .SYMBOL_WIDTH(4),
        .IN_SYMBOLS(2),
        .OUT_SYMBOLS(3),
        .LAST_EN(1),
        .FLUSH_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_keep(s_keep),
        .s_last(s_last),
        .flush(flush),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_keep(m_keep),
        .m_last(m_last),
        .busy(busy)
    );

    always @(*) begin
        assert(!m_valid);
        assert(!busy);
        assert(!s_ready);
    end
endmodule
