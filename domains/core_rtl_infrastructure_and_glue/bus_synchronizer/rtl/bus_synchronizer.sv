module bus_synchronizer #(
    parameter integer DATA_WIDTH = 32,
    parameter integer SYNC_STAGES = 2,
    parameter [DATA_WIDTH-1:0] RESET_VALUE = {DATA_WIDTH{1'b0}}
) (
    input  wire                  src_clk,
    input  wire                  src_rst_n,
    input  wire [DATA_WIDTH-1:0] src_data,
    input  wire                  src_valid,
    output wire                  src_ready,

    input  wire                  dst_clk,
    input  wire                  dst_rst_n,
    output reg  [DATA_WIDTH-1:0] dst_data,
    output reg                   dst_valid,
    output reg                   dst_pulse,
    input  wire                  dst_ready
);
    reg [DATA_WIDTH-1:0] src_buffer_q;
    reg src_req_toggle_q;
    reg dst_seen_req_toggle_q;
    reg dst_ack_toggle_q;
    reg ack_sync_q [0:SYNC_STAGES-1];
    reg req_sync_q [0:SYNC_STAGES-1];
    integer idx;

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "bus_synchronizer requires DATA_WIDTH >= 1");
        end
        if (SYNC_STAGES < 2) begin
            $fatal(1, "bus_synchronizer requires SYNC_STAGES >= 2");
        end
    end

    assign src_ready = (src_req_toggle_q == ack_sync_q[SYNC_STAGES-1]);

    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            src_buffer_q <= RESET_VALUE;
            src_req_toggle_q <= 1'b0;
            for (idx = 0; idx < SYNC_STAGES; idx = idx + 1) begin
                ack_sync_q[idx] <= 1'b0;
            end
        end
        else begin
            ack_sync_q[0] <= dst_ack_toggle_q;
            for (idx = 1; idx < SYNC_STAGES; idx = idx + 1) begin
                ack_sync_q[idx] <= ack_sync_q[idx-1];
            end

            if (src_valid && src_ready) begin
                src_buffer_q <= src_data;
                src_req_toggle_q <= ~src_req_toggle_q;
            end
        end
    end

    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            dst_data <= RESET_VALUE;
            dst_valid <= 1'b0;
            dst_pulse <= 1'b0;
            dst_seen_req_toggle_q <= 1'b0;
            dst_ack_toggle_q <= 1'b0;
            for (idx = 0; idx < SYNC_STAGES; idx = idx + 1) begin
                req_sync_q[idx] <= 1'b0;
            end
        end
        else begin
            req_sync_q[0] <= src_req_toggle_q;
            for (idx = 1; idx < SYNC_STAGES; idx = idx + 1) begin
                req_sync_q[idx] <= req_sync_q[idx-1];
            end

            dst_pulse <= 1'b0;

            if (!dst_valid && (req_sync_q[SYNC_STAGES-1] != dst_seen_req_toggle_q)) begin
                dst_data <= src_buffer_q;
                dst_valid <= 1'b1;
                dst_pulse <= 1'b1;
                dst_seen_req_toggle_q <= req_sync_q[SYNC_STAGES-1];
            end
            else if (dst_valid && dst_ready) begin
                dst_valid <= 1'b0;
                dst_ack_toggle_q <= dst_seen_req_toggle_q;
            end
        end
    end
endmodule
