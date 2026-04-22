module timestamp_counter #(
    parameter integer COUNTER_WIDTH = 48
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire                     clear,
    input  wire                     load,
    input  wire [COUNTER_WIDTH-1:0] load_value,
    input  wire                     capture_req,
    input  wire                     compare_enable,
    input  wire [COUNTER_WIDTH-1:0] compare_value,
    output reg  [COUNTER_WIDTH-1:0] timestamp,
    output reg  [COUNTER_WIDTH-1:0] capture_value,
    output reg                      tick_pulse,
    output reg                      capture_valid,
    output reg                      compare_hit,
    output reg                      overflow_pulse
);
    wire [COUNTER_WIDTH-1:0] incremented_value;
    wire increment_overflow;
    reg [COUNTER_WIDTH-1:0] next_timestamp;

    assign {increment_overflow, incremented_value} = timestamp + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};

    initial begin
        if (COUNTER_WIDTH < 1) begin
            $fatal(1, "timestamp_counter requires COUNTER_WIDTH >= 1");
        end
    end

    always @(*) begin
        next_timestamp = timestamp;
        if (clear) begin
            next_timestamp = {COUNTER_WIDTH{1'b0}};
        end
        else if (load) begin
            next_timestamp = load_value;
        end
        else if (enable) begin
            next_timestamp = incremented_value;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timestamp <= {COUNTER_WIDTH{1'b0}};
            capture_value <= {COUNTER_WIDTH{1'b0}};
            tick_pulse <= 1'b0;
            capture_valid <= 1'b0;
            compare_hit <= 1'b0;
            overflow_pulse <= 1'b0;
        end
        else begin
            timestamp <= next_timestamp;
            tick_pulse <= enable && !clear && !load;
            capture_valid <= capture_req;
            compare_hit <= compare_enable && (next_timestamp == compare_value);
            overflow_pulse <= enable && !clear && !load && increment_overflow;

            if (capture_req) begin
                capture_value <= timestamp;
            end
        end
    end
endmodule
