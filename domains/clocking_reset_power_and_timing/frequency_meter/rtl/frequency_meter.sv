module frequency_meter #(
    parameter integer COUNTER_WIDTH = 16,
    parameter integer WINDOW_CYCLES = 16,
    parameter integer CONTINUOUS_MODE = 1,
    parameter integer RANGE_CHECK_EN = 0,
    parameter integer AVERAGING_EN = 0,
    parameter integer AVERAGE_SHIFT = 1
) (
    input  wire                          ref_clk,
    input  wire                          rst_n,
    input  wire                          enable,
    input  wire                          start,
    input  wire                          measured_clk,
    input  wire [COUNTER_WIDTH-1:0]      min_acceptable_count,
    input  wire [COUNTER_WIDTH-1:0]      max_acceptable_count,
    output reg  [COUNTER_WIDTH-1:0]      measured_count,
    output reg  [COUNTER_WIDTH-1:0]      average_count,
    output reg                           result_valid,
    output reg                           sample_valid,
    output reg                           busy,
    output reg                           below_range,
    output reg                           above_range,
    output wire                          out_of_range
);
    localparam integer WINDOW_COUNT_WIDTH = (WINDOW_CYCLES < 2) ? 1 : $clog2(WINDOW_CYCLES + 1);
    localparam [WINDOW_COUNT_WIDTH-1:0] ONE_WINDOW = {{(WINDOW_COUNT_WIDTH-1){1'b0}}, 1'b1};

    reg [COUNTER_WIDTH-1:0] measured_count_bin_q;
    reg [COUNTER_WIDTH-1:0] measured_count_gray_q;
    reg [COUNTER_WIDTH-1:0] measured_count_gray_meta_q;
    reg [COUNTER_WIDTH-1:0] measured_count_gray_sync_q;

    reg [COUNTER_WIDTH-1:0] start_snapshot_q;
    reg [WINDOW_COUNT_WIDTH-1:0] window_counter_q;

    wire [COUNTER_WIDTH-1:0] measured_count_gray_next;
    wire [COUNTER_WIDTH-1:0] measured_count_sync_bin;
    wire [COUNTER_WIDTH-1:0] completed_sample_count;
    wire                     auto_start_request;
    wire                     start_request;
    integer                  bit_idx;

    function [COUNTER_WIDTH-1:0] gray_to_binary;
        input [COUNTER_WIDTH-1:0] gray_value;
        integer idx;
        begin
            gray_to_binary[COUNTER_WIDTH-1] = gray_value[COUNTER_WIDTH-1];
            for (idx = COUNTER_WIDTH - 2; idx >= 0; idx = idx - 1) begin
                gray_to_binary[idx] = gray_to_binary[idx + 1] ^ gray_value[idx];
            end
        end
    endfunction

    assign measured_count_gray_next = ((measured_count_bin_q + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1}) >> 1) ^
                                      (measured_count_bin_q + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1});
    assign measured_count_sync_bin = gray_to_binary(measured_count_gray_sync_q);
    assign completed_sample_count = measured_count_sync_bin - start_snapshot_q;
    assign auto_start_request = (CONTINUOUS_MODE != 0) && enable;
    assign start_request = enable && !busy && (auto_start_request || start);
    assign out_of_range = below_range || above_range;

    initial begin
        if (COUNTER_WIDTH < 1) begin
            $fatal(1, "frequency_meter requires COUNTER_WIDTH >= 1");
        end
        if (WINDOW_CYCLES < 1) begin
            $fatal(1, "frequency_meter requires WINDOW_CYCLES >= 1");
        end
        if ((CONTINUOUS_MODE != 0) && (CONTINUOUS_MODE != 1)) begin
            $fatal(1, "frequency_meter requires CONTINUOUS_MODE to be 0 or 1");
        end
        if ((RANGE_CHECK_EN != 0) && (RANGE_CHECK_EN != 1)) begin
            $fatal(1, "frequency_meter requires RANGE_CHECK_EN to be 0 or 1");
        end
        if ((AVERAGING_EN != 0) && (AVERAGING_EN != 1)) begin
            $fatal(1, "frequency_meter requires AVERAGING_EN to be 0 or 1");
        end
        if (AVERAGE_SHIFT < 1) begin
            $fatal(1, "frequency_meter requires AVERAGE_SHIFT >= 1");
        end
    end

    always @(posedge measured_clk or negedge rst_n) begin
        if (!rst_n) begin
            measured_count_bin_q <= {COUNTER_WIDTH{1'b0}};
            measured_count_gray_q <= {COUNTER_WIDTH{1'b0}};
        end
        else begin
            measured_count_bin_q <= measured_count_bin_q + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
            measured_count_gray_q <= measured_count_gray_next;
        end
    end

    always @(posedge ref_clk or negedge rst_n) begin
        if (!rst_n) begin
            measured_count_gray_meta_q <= {COUNTER_WIDTH{1'b0}};
            measured_count_gray_sync_q <= {COUNTER_WIDTH{1'b0}};
            start_snapshot_q <= {COUNTER_WIDTH{1'b0}};
            window_counter_q <= {WINDOW_COUNT_WIDTH{1'b0}};
            measured_count <= {COUNTER_WIDTH{1'b0}};
            average_count <= {COUNTER_WIDTH{1'b0}};
            result_valid <= 1'b0;
            sample_valid <= 1'b0;
            busy <= 1'b0;
            below_range <= 1'b0;
            above_range <= 1'b0;
        end
        else begin
            measured_count_gray_meta_q <= measured_count_gray_q;
            measured_count_gray_sync_q <= measured_count_gray_meta_q;
            sample_valid <= 1'b0;

            if (!enable) begin
                start_snapshot_q <= measured_count_sync_bin;
                window_counter_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                result_valid <= 1'b0;
                busy <= 1'b0;
                below_range <= 1'b0;
                above_range <= 1'b0;
            end
            else if (!busy) begin
                if (start_request) begin
                    busy <= 1'b1;
                    window_counter_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                    start_snapshot_q <= measured_count_sync_bin;
                end
            end
            else begin
                if (window_counter_q == (WINDOW_CYCLES - 1)) begin
                    busy <= 1'b0;
                    measured_count <= completed_sample_count;
                    result_valid <= 1'b1;
                    sample_valid <= 1'b1;

                    if (AVERAGING_EN != 0) begin
                        if (!result_valid) begin
                            average_count <= completed_sample_count;
                        end
                        else if (completed_sample_count > average_count) begin
                            average_count <= average_count + ((completed_sample_count - average_count) >> AVERAGE_SHIFT);
                        end
                        else if (completed_sample_count < average_count) begin
                            average_count <= average_count - ((average_count - completed_sample_count) >> AVERAGE_SHIFT);
                        end
                    end
                    else begin
                        average_count <= completed_sample_count;
                    end

                    if (RANGE_CHECK_EN != 0) begin
                        below_range <= (completed_sample_count < min_acceptable_count);
                        above_range <= (completed_sample_count > max_acceptable_count);
                    end
                    else begin
                        below_range <= 1'b0;
                        above_range <= 1'b0;
                    end
                end
                else begin
                    window_counter_q <= window_counter_q + ONE_WINDOW;
                end
            end
        end
    end
endmodule
