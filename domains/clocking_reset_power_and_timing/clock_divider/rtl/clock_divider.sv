module clock_divider #(
    parameter integer DEFAULT_DIVISOR = 4,
    parameter integer DIVISOR_WIDTH = 16,
    parameter integer PROGRAMMABLE_EN = 1,
    parameter integer BYPASS_EN = 1
) (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      enable,
    input  wire                      bypass,
    input  wire                      load_divisor,
    input  wire [DIVISOR_WIDTH-1:0]  divisor_value,
    output wire                      clk_out,
    output reg                       tick_pulse,
    output wire [DIVISOR_WIDTH-1:0]  active_divisor,
    output wire                      pending_update,
    output wire                      running
);
    localparam [DIVISOR_WIDTH-1:0] DEFAULT_DIVISOR_VALUE = DEFAULT_DIVISOR;
    localparam [DIVISOR_WIDTH-1:0] ONE_VALUE = {{(DIVISOR_WIDTH-1){1'b0}}, 1'b1};

    reg [DIVISOR_WIDTH-1:0] divisor_q;
    reg [DIVISOR_WIDTH-1:0] pending_divisor_q;
    reg [DIVISOR_WIDTH-1:0] counter_q;
    reg pending_valid_q;

    reg [DIVISOR_WIDTH-1:0] next_divisor;
    reg [DIVISOR_WIDTH-1:0] next_pending_divisor;
    reg [DIVISOR_WIDTH-1:0] next_counter;
    reg next_pending_valid;
    reg next_tick_pulse;

    wire [DIVISOR_WIDTH-1:0] sanitized_divisor = (divisor_value == {DIVISOR_WIDTH{1'b0}}) ? ONE_VALUE : divisor_value;
    wire [DIVISOR_WIDTH-1:0] high_cycles = (divisor_q >> 1) + divisor_q[0];
    wire terminal_count = (counter_q == (divisor_q - ONE_VALUE));

    assign clk_out = (!rst_n || !enable) ? 1'b0 :
                     (((BYPASS_EN != 0) && bypass) ? clk : (counter_q < high_cycles));
    assign active_divisor = divisor_q;
    assign pending_update = pending_valid_q;
    assign running = rst_n && enable;

    initial begin
        if (DEFAULT_DIVISOR < 1) begin
            $fatal(1, "clock_divider requires DEFAULT_DIVISOR >= 1");
        end
        if (DIVISOR_WIDTH < 1) begin
            $fatal(1, "clock_divider requires DIVISOR_WIDTH >= 1");
        end
        if ((PROGRAMMABLE_EN != 0) && (PROGRAMMABLE_EN != 1)) begin
            $fatal(1, "clock_divider requires PROGRAMMABLE_EN to be 0 or 1");
        end
        if ((BYPASS_EN != 0) && (BYPASS_EN != 1)) begin
            $fatal(1, "clock_divider requires BYPASS_EN to be 0 or 1");
        end
    end

    always @* begin
        next_divisor = divisor_q;
        next_pending_divisor = pending_divisor_q;
        next_counter = counter_q;
        next_pending_valid = pending_valid_q;
        next_tick_pulse = 1'b0;

        if (!enable) begin
            next_counter = {DIVISOR_WIDTH{1'b0}};
            if (PROGRAMMABLE_EN != 0) begin
                if (load_divisor) begin
                    next_divisor = sanitized_divisor;
                    next_pending_divisor = sanitized_divisor;
                    next_pending_valid = 1'b0;
                end
            end
            else begin
                next_pending_valid = 1'b0;
            end
        end
        else if ((BYPASS_EN != 0) && bypass) begin
            next_counter = {DIVISOR_WIDTH{1'b0}};
            next_tick_pulse = 1'b1;
            if (PROGRAMMABLE_EN != 0) begin
                if (load_divisor) begin
                    next_divisor = sanitized_divisor;
                    next_pending_divisor = sanitized_divisor;
                    next_pending_valid = 1'b0;
                end
            end
        end
        else begin
            if (PROGRAMMABLE_EN != 0) begin
                if (load_divisor) begin
                    next_pending_divisor = sanitized_divisor;
                    next_pending_valid = 1'b1;
                end
            end

            if (terminal_count) begin
                next_tick_pulse = 1'b1;
                next_counter = {DIVISOR_WIDTH{1'b0}};

                if ((PROGRAMMABLE_EN != 0) && next_pending_valid) begin
                    next_divisor = next_pending_divisor;
                    next_pending_valid = 1'b0;
                end
            end
            else begin
                next_counter = counter_q + ONE_VALUE;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divisor_q <= DEFAULT_DIVISOR_VALUE;
            pending_divisor_q <= DEFAULT_DIVISOR_VALUE;
            counter_q <= {DIVISOR_WIDTH{1'b0}};
            pending_valid_q <= 1'b0;
            tick_pulse <= 1'b0;
        end
        else begin
            divisor_q <= next_divisor;
            pending_divisor_q <= next_pending_divisor;
            counter_q <= next_counter;
            pending_valid_q <= next_pending_valid;
            tick_pulse <= next_tick_pulse;
        end
    end
endmodule
