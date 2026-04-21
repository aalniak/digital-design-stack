module register_slice_formal;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 3;

    reg [4:0] formal_ticks;

    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 5'd3);

    (* anyseq *) reg s_valid;
    (* anyseq *) reg [DATA_WIDTH-1:0] s_data;
    (* anyseq *) reg [SIDEBAND_WIDTH-1:0] s_sideband;
    wire s_ready;
    wire m_valid;
    (* anyseq *) reg m_ready;
    wire [DATA_WIDTH-1:0] m_data;
    wire [SIDEBAND_WIDTH-1:0] m_sideband;

    register_slice #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .STAGES(1)
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
        .m_sideband(m_sideband)
    );

    initial begin
        formal_ticks = 5'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (!rst_n) begin
            assert(!m_valid);
        end
    end
endmodule
