module register_slice_stage #(
    parameter integer PAYLOAD_WIDTH = 1
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     in_valid,
    output wire                     in_ready,
    input  wire [PAYLOAD_WIDTH-1:0] in_payload,
    output wire                     out_valid,
    input  wire                     out_ready,
    output wire [PAYLOAD_WIDTH-1:0] out_payload
);
    reg                     valid_q;
    reg [PAYLOAD_WIDTH-1:0] payload_q;

    assign in_ready = ~valid_q || out_ready;
    assign out_valid = valid_q;
    assign out_payload = payload_q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_q <= 1'b0;
        end
        else if (in_ready) begin
            valid_q <= in_valid;
            if (in_valid) begin
                payload_q <= in_payload;
            end
        end
    end
endmodule

module register_slice #(
    parameter integer DATA_WIDTH = 32,
    parameter integer SIDEBAND_WIDTH = 0,
    parameter integer STAGES = 1
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
            $fatal(1, "register_slice requires DATA_WIDTH >= 1");
        end
        if (SIDEBAND_WIDTH < 0) begin
            $fatal(1, "register_slice requires SIDEBAND_WIDTH >= 0");
        end
        if (STAGES < 0) begin
            $fatal(1, "register_slice requires STAGES >= 0");
        end
    end

    generate
        if (STAGES == 0) begin : gen_bypass
            assign s_ready = m_ready;
            assign m_valid = s_valid;
            assign m_data = s_data;
            assign m_sideband = s_sideband;
        end
        else begin : gen_pipeline
            wire [STAGES:0] valid_bus;
            wire [STAGES:0] ready_bus;
            wire [PAYLOAD_WIDTH-1:0] payload_bus [0:STAGES];

            genvar idx;

            assign valid_bus[0] = s_valid;
            assign ready_bus[STAGES] = m_ready;
            assign payload_bus[0] = {s_sideband, s_data};

            for (idx = 0; idx < STAGES; idx = idx + 1) begin : gen_stage
                register_slice_stage #(
                    .PAYLOAD_WIDTH(PAYLOAD_WIDTH)
                ) stage_i (
                    .clk(clk),
                    .rst_n(rst_n),
                    .in_valid(valid_bus[idx]),
                    .in_ready(ready_bus[idx]),
                    .in_payload(payload_bus[idx]),
                    .out_valid(valid_bus[idx+1]),
                    .out_ready(ready_bus[idx+1]),
                    .out_payload(payload_bus[idx+1])
                );
            end

            assign s_ready = ready_bus[0];
            assign m_valid = valid_bus[STAGES];
            assign {m_sideband, m_data} = payload_bus[STAGES];
        end
    endgenerate
endmodule
