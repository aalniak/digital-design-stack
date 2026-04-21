module skid_buffer_stage #(
    parameter integer PAYLOAD_WIDTH = 1
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     s_valid,
    output wire                     s_ready,
    input  wire [PAYLOAD_WIDTH-1:0] s_payload,
    output wire                     m_valid,
    input  wire                     m_ready,
    output wire [PAYLOAD_WIDTH-1:0] m_payload
);
    reg                     hold_valid_q;
    reg [PAYLOAD_WIDTH-1:0] hold_payload_q;

    assign s_ready = ~hold_valid_q || m_ready;
    assign m_valid = hold_valid_q ? 1'b1 : s_valid;
    assign m_payload = hold_valid_q ? hold_payload_q : s_payload;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hold_valid_q <= 1'b0;
        end
        else if (hold_valid_q) begin
            if (m_ready) begin
                if (s_valid) begin
                    hold_valid_q <= 1'b1;
                    hold_payload_q <= s_payload;
                end
                else begin
                    hold_valid_q <= 1'b0;
                end
            end
        end
        else if (s_valid && !m_ready) begin
            hold_valid_q <= 1'b1;
            hold_payload_q <= s_payload;
        end
    end
endmodule

module skid_buffer #(
    parameter integer DATA_WIDTH = 32,
    parameter integer SIDEBAND_WIDTH = 0,
    parameter integer DEPTH = 1
) (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      s_valid,
    output wire                      s_ready,
    input  wire [DATA_WIDTH-1:0]     s_data,
    input  wire [SIDEBAND_WIDTH-1:0] s_sideband,
    output wire                      m_valid,
    input  wire                      m_ready,
    output wire [DATA_WIDTH-1:0]     m_data,
    output wire [SIDEBAND_WIDTH-1:0] m_sideband
);
    localparam integer PAYLOAD_WIDTH = DATA_WIDTH + SIDEBAND_WIDTH;

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "skid_buffer requires DATA_WIDTH >= 1");
        end
        if (SIDEBAND_WIDTH < 0) begin
            $fatal(1, "skid_buffer requires SIDEBAND_WIDTH >= 0");
        end
        if (DEPTH < 0) begin
            $fatal(1, "skid_buffer requires DEPTH >= 0");
        end
    end

    generate
        if (DEPTH == 0) begin : gen_bypass
            assign s_ready = m_ready;
            assign m_valid = s_valid;
            assign m_data = s_data;
            assign m_sideband = s_sideband;
        end
        else begin : gen_skid
            wire [DEPTH:0] valid_bus;
            wire [DEPTH:0] ready_bus;
            wire [PAYLOAD_WIDTH-1:0] payload_bus [0:DEPTH];

            genvar idx;

            assign valid_bus[0] = s_valid;
            assign ready_bus[DEPTH] = m_ready;
            assign payload_bus[0] = {s_sideband, s_data};

            for (idx = 0; idx < DEPTH; idx = idx + 1) begin : gen_stage
                skid_buffer_stage #(
                    .PAYLOAD_WIDTH(PAYLOAD_WIDTH)
                ) stage_i (
                    .clk(clk),
                    .rst_n(rst_n),
                    .s_valid(valid_bus[idx]),
                    .s_ready(ready_bus[idx]),
                    .s_payload(payload_bus[idx]),
                    .m_valid(valid_bus[idx+1]),
                    .m_ready(ready_bus[idx+1]),
                    .m_payload(payload_bus[idx+1])
                );
            end

            assign s_ready = ready_bus[0];
            assign m_valid = valid_bus[DEPTH];
            assign {m_sideband, m_data} = payload_bus[DEPTH];
        end
    endgenerate
endmodule
