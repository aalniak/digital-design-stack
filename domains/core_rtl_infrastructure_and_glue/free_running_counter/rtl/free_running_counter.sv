module free_running_counter #(
    parameter integer COUNT_WIDTH = 32,
    parameter [COUNT_WIDTH-1:0] RESET_VALUE = {COUNT_WIDTH{1'b0}},
    parameter bit ENABLE_EN = 1'b1,
    parameter bit ROLLOVER_PULSE_EN = 1'b1,
    parameter bit CAPTURE_EN = 1'b1
) (
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   enable,
    input  wire                   load,
    input  wire [COUNT_WIDTH-1:0] load_value,
    input  wire                   capture,
    output reg  [COUNT_WIDTH-1:0] count_value,
    output reg  [COUNT_WIDTH-1:0] capture_value,
    output reg                    rollover_pulse
);
    localparam [COUNT_WIDTH-1:0] MAX_COUNT = {COUNT_WIDTH{1'b1}};
    localparam [COUNT_WIDTH-1:0] ONE_VALUE = {{(COUNT_WIDTH-1){1'b0}}, 1'b1};

    reg count_now;
    reg counted_wrap;
    reg [COUNT_WIDTH-1:0] next_count;

    initial begin
        if (COUNT_WIDTH < 1) begin
            $fatal(1, "free_running_counter requires COUNT_WIDTH >= 1");
        end
    end

    always @* begin
        count_now = ENABLE_EN ? enable : 1'b1;
        counted_wrap = 1'b0;
        next_count = count_value;

        if (load) begin
            next_count = load_value;
        end
        else if (count_now) begin
            next_count = count_value + ONE_VALUE;
            counted_wrap = (count_value == MAX_COUNT);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_value <= RESET_VALUE;
            capture_value <= RESET_VALUE;
            rollover_pulse <= 1'b0;
        end
        else begin
            count_value <= next_count;
            rollover_pulse <= ROLLOVER_PULSE_EN ? counted_wrap : 1'b0;

            if (CAPTURE_EN) begin
                if (capture) begin
                    capture_value <= next_count;
                end
                else if (load) begin
                    capture_value <= load_value;
                end
            end
            else begin
                capture_value <= next_count;
            end
        end
    end
endmodule
