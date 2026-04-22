module stream_mux_formal;
    localparam integer NUM_INPUTS = 3;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 2;
    localparam integer ID_WIDTH = $clog2(NUM_INPUTS);

    wire clk = 1'b0;
    wire rst_n = 1'b0;

    (* anyseq *) reg [NUM_INPUTS-1:0] s_valid;
    (* anyseq *) reg [NUM_INPUTS*DATA_WIDTH-1:0] s_data;
    (* anyseq *) reg [NUM_INPUTS*SIDEBAND_WIDTH-1:0] s_sideband;
    (* anyseq *) reg [NUM_INPUTS-1:0] s_last;
    (* anyseq *) reg m_ready;

    wire [NUM_INPUTS-1:0] s_ready;
    wire m_valid;
    wire [DATA_WIDTH-1:0] m_data;
    wire [SIDEBAND_WIDTH-1:0] m_sideband;
    wire m_last;
    wire [ID_WIDTH-1:0] m_source_id;
    wire held_grant_active;
    wire [ID_WIDTH-1:0] held_grant_id;

    stream_mux #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .ARBITRATION_MODE(1),
        .HOLD_UNTIL_LAST(1),
        .SOURCE_ID_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_sideband(s_sideband),
        .s_last(s_last),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_sideband(m_sideband),
        .m_last(m_last),
        .m_source_id(m_source_id),
        .held_grant_active(held_grant_active),
        .held_grant_id(held_grant_id)
    );

    always @(*) begin
        assert(!m_valid);
        assert(!held_grant_active);
        assert(s_ready == {NUM_INPUTS{1'b0}});
    end
endmodule
