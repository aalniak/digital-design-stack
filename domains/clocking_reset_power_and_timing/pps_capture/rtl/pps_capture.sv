module pps_capture #(
    parameter integer TIMESTAMP_WIDTH = 32,
    parameter integer EDGE_MODE = 0,
    parameter integer FILTER_EN = 1,
    parameter integer FILTER_CYCLES = 2,
    parameter integer INTERVAL_MEASURE_EN = 1,
    parameter integer CDC_MODE = 1
) (
    input  wire [TIMESTAMP_WIDTH-1:0]                                  timestamp_in,
    input  wire                                                        clk,
    input  wire                                                        rst_n,
    input  wire                                                        enable,
    input  wire                                                        pps_in,
    input  wire                                                        clear_flags,
    output reg                                                         capture_valid,
    output reg  [TIMESTAMP_WIDTH-1:0]                                  captured_timestamp,
    output reg                                                         interval_valid,
    output reg  [TIMESTAMP_WIDTH-1:0]                                  interval_delta,
    output reg                                                         first_capture_seen,
    output reg                                                         selected_edge_pulse,
    output reg                                                         glitch_reject_pulse,
    output reg                                                         glitch_reject_sticky,
    output wire                                                        qualified_level
);
    localparam integer FILTER_COUNT_WIDTH = (FILTER_CYCLES < 1) ? 1 : $clog2(FILTER_CYCLES + 1);

    reg pps_meta_q;
    reg pps_sync_q;
    reg sampled_level_q;
    reg qualified_level_q;
    reg qualified_level_prev_q;
    reg [FILTER_COUNT_WIDTH-1:0] transition_count_q;
    reg [TIMESTAMP_WIDTH-1:0] previous_capture_q;

    wire sampled_level;
    wire level_changed;
    wire edge_rise;
    wire edge_fall;
    wire selected_edge;
    wire next_transition_reaches_commit;

    assign sampled_level = (CDC_MODE == 0) ? pps_in : pps_sync_q;
    assign level_changed = (sampled_level != qualified_level_q);
    assign edge_rise = !qualified_level_prev_q && qualified_level_q;
    assign edge_fall = qualified_level_prev_q && !qualified_level_q;
    assign selected_edge = (EDGE_MODE == 0) ? edge_rise : edge_fall;
    assign next_transition_reaches_commit = ((transition_count_q + {{(FILTER_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= FILTER_CYCLES);
    assign qualified_level = qualified_level_q;

    initial begin
        if (TIMESTAMP_WIDTH < 1) begin
            $fatal(1, "pps_capture requires TIMESTAMP_WIDTH >= 1");
        end
        if ((EDGE_MODE != 0) && (EDGE_MODE != 1)) begin
            $fatal(1, "pps_capture requires EDGE_MODE to be 0 (rising) or 1 (falling)");
        end
        if ((FILTER_EN != 0) && (FILTER_EN != 1)) begin
            $fatal(1, "pps_capture requires FILTER_EN to be 0 or 1");
        end
        if (FILTER_CYCLES < 1) begin
            $fatal(1, "pps_capture requires FILTER_CYCLES >= 1");
        end
        if ((INTERVAL_MEASURE_EN != 0) && (INTERVAL_MEASURE_EN != 1)) begin
            $fatal(1, "pps_capture requires INTERVAL_MEASURE_EN to be 0 or 1");
        end
        if ((CDC_MODE != 0) && (CDC_MODE != 1)) begin
            $fatal(1, "pps_capture requires CDC_MODE to be 0 or 1");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pps_meta_q <= 1'b0;
            pps_sync_q <= 1'b0;
        end
        else begin
            pps_meta_q <= pps_in;
            pps_sync_q <= pps_meta_q;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sampled_level_q <= 1'b0;
            qualified_level_q <= 1'b0;
            qualified_level_prev_q <= 1'b0;
            transition_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
            captured_timestamp <= {TIMESTAMP_WIDTH{1'b0}};
            previous_capture_q <= {TIMESTAMP_WIDTH{1'b0}};
            interval_delta <= {TIMESTAMP_WIDTH{1'b0}};
            capture_valid <= 1'b0;
            interval_valid <= 1'b0;
            first_capture_seen <= 1'b0;
            selected_edge_pulse <= 1'b0;
            glitch_reject_pulse <= 1'b0;
            glitch_reject_sticky <= 1'b0;
        end
        else begin
            sampled_level_q <= sampled_level;
            qualified_level_prev_q <= qualified_level_q;
            capture_valid <= 1'b0;
            interval_valid <= 1'b0;
            selected_edge_pulse <= 1'b0;
            glitch_reject_pulse <= 1'b0;

            if (clear_flags) begin
                glitch_reject_sticky <= 1'b0;
            end

            if (!enable) begin
                transition_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
                qualified_level_q <= 1'b0;
                qualified_level_prev_q <= 1'b0;
                first_capture_seen <= 1'b0;
                previous_capture_q <= {TIMESTAMP_WIDTH{1'b0}};
            end
            else if (FILTER_EN == 0) begin
                qualified_level_q <= sampled_level;
                transition_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
            end
            else begin
                if (level_changed) begin
                    if (next_transition_reaches_commit) begin
                        qualified_level_q <= sampled_level;
                        transition_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
                    end
                    else begin
                        transition_count_q <= transition_count_q + {{(FILTER_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                end
                else begin
                    if (transition_count_q != {FILTER_COUNT_WIDTH{1'b0}}) begin
                        glitch_reject_pulse <= 1'b1;
                        glitch_reject_sticky <= 1'b1;
                    end
                    transition_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
                end
            end

            if (selected_edge) begin
                selected_edge_pulse <= 1'b1;
                capture_valid <= 1'b1;
                captured_timestamp <= timestamp_in;

                if (first_capture_seen && (INTERVAL_MEASURE_EN != 0)) begin
                    interval_valid <= 1'b1;
                    interval_delta <= timestamp_in - previous_capture_q;
                end

                previous_capture_q <= timestamp_in;
                first_capture_seen <= 1'b1;
            end
        end
    end
endmodule
