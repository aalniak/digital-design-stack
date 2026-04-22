module wakeup_controller #(
    parameter integer NUM_SOURCES = 4
) (
    input  wire clk,
    input  wire rst_n,
    input  wire sleep_armed,
    input  wire [NUM_SOURCES-1:0] source_level,
    input  wire [NUM_SOURCES-1:0] enable_mask,
    input  wire [NUM_SOURCES-1:0] edge_mask,
    input  wire [NUM_SOURCES-1:0] clear_pending_mask,
    output reg  [NUM_SOURCES-1:0] pending_mask,
    output wire [NUM_SOURCES-1:0] active_wake_mask,
    output wire wake_request,
    output reg  wake_pulse
);
    reg [NUM_SOURCES-1:0] source_prev_q;
    wire [NUM_SOURCES-1:0] rise_detect;
    wire [NUM_SOURCES-1:0] level_detect;
    wire [NUM_SOURCES-1:0] event_detect;
    wire [NUM_SOURCES-1:0] qualified_event;
    wire [NUM_SOURCES-1:0] next_pending;

    assign rise_detect = source_level & ~source_prev_q;
    assign level_detect = source_level & ~edge_mask;
    assign event_detect = (rise_detect & edge_mask) | level_detect;
    assign qualified_event = event_detect & enable_mask;
    assign next_pending = (pending_mask | qualified_event) & ~clear_pending_mask;
    assign active_wake_mask = pending_mask & enable_mask;
    assign wake_request = sleep_armed && (|active_wake_mask);

    initial begin
        if (NUM_SOURCES < 1) begin
            $fatal(1, "wakeup_controller requires NUM_SOURCES >= 1");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            source_prev_q <= {NUM_SOURCES{1'b0}};
            pending_mask <= {NUM_SOURCES{1'b0}};
            wake_pulse <= 1'b0;
        end
        else begin
            source_prev_q <= source_level;
            pending_mask <= next_pending;
            wake_pulse <= sleep_armed && (|qualified_event);
        end
    end
endmodule
