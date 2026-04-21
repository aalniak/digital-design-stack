module stream_demux #(
    parameter integer DATA_WIDTH = 32,
    parameter integer SIDEBAND_WIDTH = 0,
    parameter integer NUM_OUTPUTS = 4,
    parameter integer HOLD_ROUTE_UNTIL_LAST = 1,
    parameter integer DROP_ON_INVALID = 0
) (
    input  wire                                                     clk,
    input  wire                                                     rst_n,
    input  wire                                                     s_valid,
    output wire                                                     s_ready,
    input  wire [DATA_WIDTH-1:0]                                    s_data,
    input  wire [SIDEBAND_WIDTH-1:0]                                s_sideband,
    input  wire                                                     s_last,
    input  wire [((NUM_OUTPUTS <= 1) ? 1 : $clog2(NUM_OUTPUTS))-1:0] s_select,
    output wire [NUM_OUTPUTS-1:0]                                   m_valid,
    input  wire [NUM_OUTPUTS-1:0]                                   m_ready,
    output wire [NUM_OUTPUTS*DATA_WIDTH-1:0]                        m_data,
    output wire [NUM_OUTPUTS*SIDEBAND_WIDTH-1:0]                    m_sideband,
    output wire [NUM_OUTPUTS-1:0]                                   m_last,
    output wire                                                     invalid_route,
    output wire                                                     held_route_active,
    output wire [((NUM_OUTPUTS <= 1) ? 1 : $clog2(NUM_OUTPUTS))-1:0] held_route_select
);
    localparam integer SELECT_WIDTH = (NUM_OUTPUTS <= 1) ? 1 : $clog2(NUM_OUTPUTS);

    reg [SELECT_WIDTH-1:0] held_route_q;
    reg held_route_active_q;
    reg [NUM_OUTPUTS-1:0] select_onehot;
    wire [SELECT_WIDTH-1:0] effective_select;
    wire select_valid;
    wire selected_ready;
    wire accept_fire;

    integer idx;

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "stream_demux requires DATA_WIDTH >= 1");
        end
        if (SIDEBAND_WIDTH < 0) begin
            $fatal(1, "stream_demux requires SIDEBAND_WIDTH >= 0");
        end
        if (NUM_OUTPUTS < 1) begin
            $fatal(1, "stream_demux requires NUM_OUTPUTS >= 1");
        end
        if ((HOLD_ROUTE_UNTIL_LAST != 0) && (HOLD_ROUTE_UNTIL_LAST != 1)) begin
            $fatal(1, "stream_demux requires HOLD_ROUTE_UNTIL_LAST to be 0 or 1");
        end
        if ((DROP_ON_INVALID != 0) && (DROP_ON_INVALID != 1)) begin
            $fatal(1, "stream_demux requires DROP_ON_INVALID to be 0 or 1");
        end
    end

    assign effective_select = (HOLD_ROUTE_UNTIL_LAST && held_route_active_q) ? held_route_q : s_select;
    assign select_valid = (effective_select < NUM_OUTPUTS[SELECT_WIDTH-1:0]);
    assign invalid_route = rst_n && s_valid && !select_valid;
    assign selected_ready = |(m_ready & select_onehot);
    assign s_ready = !rst_n ? 1'b0 : (select_valid ? selected_ready : (DROP_ON_INVALID ? 1'b1 : 1'b0));
    assign accept_fire = s_valid && s_ready;
    assign held_route_active = held_route_active_q;
    assign held_route_select = held_route_q;

    always @(*) begin
        select_onehot = {NUM_OUTPUTS{1'b0}};
        if (select_valid) begin
            select_onehot[effective_select] = 1'b1;
        end
    end

    generate
        genvar out_idx;
        for (out_idx = 0; out_idx < NUM_OUTPUTS; out_idx = out_idx + 1) begin : gen_output
            assign m_valid[out_idx] = rst_n && s_valid && select_valid && select_onehot[out_idx];
            assign m_last[out_idx] = s_last;
            assign m_data[(out_idx*DATA_WIDTH) +: DATA_WIDTH] = s_data;
            assign m_sideband[(out_idx*SIDEBAND_WIDTH) +: SIDEBAND_WIDTH] = s_sideband;
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            held_route_q <= {SELECT_WIDTH{1'b0}};
            held_route_active_q <= 1'b0;
        end
        else if (HOLD_ROUTE_UNTIL_LAST != 0) begin
            if (accept_fire && select_valid) begin
                if (!held_route_active_q && !s_last) begin
                    held_route_q <= effective_select;
                    held_route_active_q <= 1'b1;
                end
                else if (held_route_active_q && s_last) begin
                    held_route_active_q <= 1'b0;
                end
            end
        end
        else begin
            held_route_q <= {SELECT_WIDTH{1'b0}};
            held_route_active_q <= 1'b0;
        end
    end
endmodule
