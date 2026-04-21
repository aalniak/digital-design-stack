module pulse_synchronizer #(
    parameter integer SYNC_STAGES = 2
) (
    input  wire src_clk,
    input  wire src_rst_n,
    input  wire src_pulse,
    output wire src_busy,

    input  wire dst_clk,
    input  wire dst_rst_n,
    output reg  dst_pulse
);
    reg src_toggle_q;
    reg dst_ack_toggle_q;
    reg dst_seen_toggle_q;
    reg ack_sync_q [0:SYNC_STAGES-1];
    reg req_sync_q [0:SYNC_STAGES-1];
    integer idx;

    initial begin
        if (SYNC_STAGES < 2) begin
            $fatal(1, "pulse_synchronizer requires SYNC_STAGES >= 2");
        end
    end

    assign src_busy = (src_toggle_q != ack_sync_q[SYNC_STAGES-1]);

    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            src_toggle_q <= 1'b0;
            for (idx = 0; idx < SYNC_STAGES; idx = idx + 1) begin
                ack_sync_q[idx] <= 1'b0;
            end
        end
        else begin
            ack_sync_q[0] <= dst_ack_toggle_q;
            for (idx = 1; idx < SYNC_STAGES; idx = idx + 1) begin
                ack_sync_q[idx] <= ack_sync_q[idx-1];
            end

            if (src_pulse && !src_busy) begin
                src_toggle_q <= ~src_toggle_q;
            end
        end
    end

    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            dst_ack_toggle_q <= 1'b0;
            dst_seen_toggle_q <= 1'b0;
            dst_pulse <= 1'b0;
            for (idx = 0; idx < SYNC_STAGES; idx = idx + 1) begin
                req_sync_q[idx] <= 1'b0;
            end
        end
        else begin
            req_sync_q[0] <= src_toggle_q;
            for (idx = 1; idx < SYNC_STAGES; idx = idx + 1) begin
                req_sync_q[idx] <= req_sync_q[idx-1];
            end

            dst_pulse <= 1'b0;
            if (req_sync_q[SYNC_STAGES-1] != dst_seen_toggle_q) begin
                dst_seen_toggle_q <= req_sync_q[SYNC_STAGES-1];
                dst_ack_toggle_q <= req_sync_q[SYNC_STAGES-1];
                dst_pulse <= 1'b1;
            end
        end
    end
endmodule
