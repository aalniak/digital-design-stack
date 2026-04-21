module event_counter #(
    parameter integer COUNT_WIDTH = 32,
    parameter bit SATURATE = 1'b0,
    parameter bit THRESHOLD_EN = 1'b1,
    parameter [COUNT_WIDTH-1:0] THRESHOLD_VALUE = {COUNT_WIDTH{1'b1}},
    parameter bit SNAPSHOT_EN = 1'b1,
    parameter bit CLEAR_PRIORITY = 1'b1,
    parameter [COUNT_WIDTH-1:0] RESET_VALUE = {COUNT_WIDTH{1'b0}}
) (
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   event_pulse,
    input  wire                   count_enable,
    input  wire                   clear,
    input  wire                   snapshot,
    output reg  [COUNT_WIDTH-1:0] count_value,
    output reg  [COUNT_WIDTH-1:0] snapshot_value,
    output reg                    overflow_sticky,
    output wire                   threshold_reached
);
    localparam [COUNT_WIDTH-1:0] MAX_COUNT = {COUNT_WIDTH{1'b1}};
    localparam [COUNT_WIDTH-1:0] ONE_VALUE = {{(COUNT_WIDTH-1){1'b0}}, 1'b1};

    reg [COUNT_WIDTH-1:0] base_count;
    reg [COUNT_WIDTH-1:0] next_count;
    reg                   event_overflow;
    reg                   count_now;

    initial begin
        if (COUNT_WIDTH < 1) begin
            $fatal(1, "event_counter requires COUNT_WIDTH >= 1");
        end
    end

    always @* begin
        count_now = count_enable && event_pulse && (!clear || !CLEAR_PRIORITY);
        base_count = clear ? RESET_VALUE : count_value;
        next_count = base_count;
        event_overflow = 1'b0;

        if (count_now) begin
            if (SATURATE) begin
                if (base_count == MAX_COUNT) begin
                    next_count = MAX_COUNT;
                    event_overflow = 1'b1;
                end
                else begin
                    next_count = base_count + ONE_VALUE;
                end
            end
            else begin
                next_count = base_count + ONE_VALUE;
                event_overflow = (base_count == MAX_COUNT);
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_value <= RESET_VALUE;
            snapshot_value <= RESET_VALUE;
            overflow_sticky <= 1'b0;
        end
        else begin
            count_value <= next_count;
            overflow_sticky <= (clear ? 1'b0 : overflow_sticky) | event_overflow;

            if (SNAPSHOT_EN) begin
                if (snapshot) begin
                    snapshot_value <= next_count;
                end
                else if (clear) begin
                    snapshot_value <= RESET_VALUE;
                end
            end
            else begin
                snapshot_value <= next_count;
            end
        end
    end

    assign threshold_reached = THRESHOLD_EN ? (count_value >= THRESHOLD_VALUE) : 1'b0;
endmodule
