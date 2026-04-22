module clock_enable_generator #(
    parameter integer DEFAULT_PERIOD = 4,
    parameter integer PERIOD_WIDTH = 16,
    parameter integer PULSE_WIDTH = 1,
    parameter integer PROGRAMMABLE_EN = 1,
    parameter integer RESTART_ON_WRITE = 0,
    parameter integer BYPASS_EN = 1
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire                     bypass,
    input  wire                     load_period,
    input  wire [PERIOD_WIDTH-1:0]  period_value,
    output reg                      enable_pulse,
    output wire [PERIOD_WIDTH-1:0]  active_period,
    output wire [PERIOD_WIDTH-1:0]  phase_count,
    output wire                     pending_update,
    output wire                     running
);
    localparam [PERIOD_WIDTH-1:0] DEFAULT_PERIOD_VALUE = DEFAULT_PERIOD;
    localparam [PERIOD_WIDTH-1:0] PULSE_WIDTH_VALUE = PULSE_WIDTH;
    localparam [PERIOD_WIDTH-1:0] ONE_VALUE = {{(PERIOD_WIDTH-1){1'b0}}, 1'b1};

    reg [PERIOD_WIDTH-1:0] period_q;
    reg [PERIOD_WIDTH-1:0] pending_period_q;
    reg [PERIOD_WIDTH-1:0] counter_q;
    reg pending_valid_q;

    reg [PERIOD_WIDTH-1:0] next_period;
    reg [PERIOD_WIDTH-1:0] next_pending_period;
    reg [PERIOD_WIDTH-1:0] next_counter;
    reg next_pending_valid;
    reg next_enable_pulse;

    wire [PERIOD_WIDTH-1:0] sanitized_period;
    wire terminal_count = (counter_q == (period_q - ONE_VALUE));
    wire pulse_window_active = (counter_q >= (period_q - PULSE_WIDTH_VALUE));

    function automatic [PERIOD_WIDTH-1:0] sanitize_period_value;
        input [PERIOD_WIDTH-1:0] requested_period;
        begin
            if (requested_period < PULSE_WIDTH_VALUE) begin
                sanitize_period_value = PULSE_WIDTH_VALUE;
            end
            else begin
                sanitize_period_value = requested_period;
            end
        end
    endfunction

    assign sanitized_period = sanitize_period_value(period_value);
    assign active_period = period_q;
    assign phase_count = counter_q;
    assign pending_update = pending_valid_q;
    assign running = rst_n && enable;

    initial begin
        if (DEFAULT_PERIOD < 1) begin
            $fatal(1, "clock_enable_generator requires DEFAULT_PERIOD >= 1");
        end
        if (PERIOD_WIDTH < 1) begin
            $fatal(1, "clock_enable_generator requires PERIOD_WIDTH >= 1");
        end
        if (PULSE_WIDTH < 1) begin
            $fatal(1, "clock_enable_generator requires PULSE_WIDTH >= 1");
        end
        if (DEFAULT_PERIOD < PULSE_WIDTH) begin
            $fatal(1, "clock_enable_generator requires DEFAULT_PERIOD >= PULSE_WIDTH");
        end
        if ((PROGRAMMABLE_EN != 0) && (PROGRAMMABLE_EN != 1)) begin
            $fatal(1, "clock_enable_generator requires PROGRAMMABLE_EN to be 0 or 1");
        end
        if ((RESTART_ON_WRITE != 0) && (RESTART_ON_WRITE != 1)) begin
            $fatal(1, "clock_enable_generator requires RESTART_ON_WRITE to be 0 or 1");
        end
        if ((BYPASS_EN != 0) && (BYPASS_EN != 1)) begin
            $fatal(1, "clock_enable_generator requires BYPASS_EN to be 0 or 1");
        end
    end

    always @* begin
        next_period = period_q;
        next_pending_period = pending_period_q;
        next_counter = counter_q;
        next_pending_valid = pending_valid_q;
        next_enable_pulse = 1'b0;

        if (!enable) begin
            next_counter = {PERIOD_WIDTH{1'b0}};

            if (PROGRAMMABLE_EN != 0) begin
                if (load_period) begin
                    next_period = sanitized_period;
                    next_pending_period = sanitized_period;
                    next_pending_valid = 1'b0;
                end
            end
            else begin
                next_pending_valid = 1'b0;
            end
        end
        else if ((BYPASS_EN != 0) && bypass) begin
            next_counter = {PERIOD_WIDTH{1'b0}};
            next_enable_pulse = 1'b1;

            if ((PROGRAMMABLE_EN != 0) && load_period) begin
                next_period = sanitized_period;
                next_pending_period = sanitized_period;
                next_pending_valid = 1'b0;
            end
        end
        else begin
            if ((PROGRAMMABLE_EN != 0) && load_period) begin
                if (RESTART_ON_WRITE != 0) begin
                    next_period = sanitized_period;
                    next_pending_period = sanitized_period;
                    next_pending_valid = 1'b0;
                    next_counter = {PERIOD_WIDTH{1'b0}};
                    next_enable_pulse = 1'b0;
                end
                else begin
                    next_pending_period = sanitized_period;
                    next_pending_valid = 1'b1;
                    next_enable_pulse = pulse_window_active;

                    if (terminal_count) begin
                        next_counter = {PERIOD_WIDTH{1'b0}};
                        next_period = next_pending_period;
                        next_pending_valid = 1'b0;
                    end
                    else begin
                        next_counter = counter_q + ONE_VALUE;
                    end
                end
            end
            else begin
                next_enable_pulse = pulse_window_active;

                if (terminal_count) begin
                    next_counter = {PERIOD_WIDTH{1'b0}};

                    if ((PROGRAMMABLE_EN != 0) && next_pending_valid) begin
                        next_period = next_pending_period;
                        next_pending_valid = 1'b0;
                    end
                end
                else begin
                    next_counter = counter_q + ONE_VALUE;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            period_q <= DEFAULT_PERIOD_VALUE;
            pending_period_q <= DEFAULT_PERIOD_VALUE;
            counter_q <= {PERIOD_WIDTH{1'b0}};
            pending_valid_q <= 1'b0;
            enable_pulse <= 1'b0;
        end
        else begin
            period_q <= next_period;
            pending_period_q <= next_pending_period;
            counter_q <= next_counter;
            pending_valid_q <= next_pending_valid;
            enable_pulse <= next_enable_pulse;
        end
    end
endmodule
