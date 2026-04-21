module stream_demux_formal;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 2;
    localparam integer NUM_OUTPUTS = 3;
    localparam integer SELECT_WIDTH = $clog2(NUM_OUTPUTS);

    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg s_valid;
    (* anyseq *) reg [DATA_WIDTH-1:0] s_data;
    (* anyseq *) reg [SIDEBAND_WIDTH-1:0] s_sideband;
    (* anyseq *) reg s_last;
    (* anyseq *) reg [SELECT_WIDTH-1:0] s_select;
    (* anyseq *) reg [NUM_OUTPUTS-1:0] m_ready;

    wire [NUM_OUTPUTS-1:0] m_valid;
    wire [NUM_OUTPUTS*DATA_WIDTH-1:0] m_data;
    wire [NUM_OUTPUTS*SIDEBAND_WIDTH-1:0] m_sideband;
    wire [NUM_OUTPUTS-1:0] m_last;
    wire s_ready;
    wire invalid_route;
    wire held_route_active;
    wire [SELECT_WIDTH-1:0] held_route_select;

    stream_demux #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .NUM_OUTPUTS(NUM_OUTPUTS),
        .HOLD_ROUTE_UNTIL_LAST(1),
        .DROP_ON_INVALID(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_sideband(s_sideband),
        .s_last(s_last),
        .s_select(s_select),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_sideband(m_sideband),
        .m_last(m_last),
        .invalid_route(invalid_route),
        .held_route_active(held_route_active),
        .held_route_select(held_route_select)
    );

    always @(*) begin
        assert(m_valid == {NUM_OUTPUTS{1'b0}});
        assert(!invalid_route);
        assert(!held_route_active);
    end
endmodule
