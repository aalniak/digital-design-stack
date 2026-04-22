module clock_mux_controller #(
    parameter integer NUM_SOURCES = 2,
    parameter integer DEFAULT_SOURCE = 0,
    parameter integer WAIT_FOR_STABLE_EN = 1,
    parameter integer STABLE_CYCLES = 2,
    parameter integer AUTO_FAILOVER_EN = 1,
    parameter integer HOLD_CYCLES = 2,
    parameter integer STATUS_STICKY_EN = 1
) (
    input  wire                                                            clk,
    input  wire                                                            rst_n,
    input  wire                                                            request_valid,
    input  wire [((NUM_SOURCES < 2) ? 1 : $clog2(NUM_SOURCES))-1:0]        requested_source,
    input  wire [NUM_SOURCES-1:0]                                          source_healthy,
    input  wire                                                            inhibit_switch,
    input  wire                                                            clear_sticky,
    output wire [((NUM_SOURCES < 2) ? 1 : $clog2(NUM_SOURCES))-1:0]        mux_select,
    output wire [((NUM_SOURCES < 2) ? 1 : $clog2(NUM_SOURCES))-1:0]        active_source,
    output reg  [((NUM_SOURCES < 2) ? 1 : $clog2(NUM_SOURCES))-1:0]        pending_source,
    output reg                                                             pending_source_valid,
    output wire                                                            switch_in_progress,
    output wire                                                            hold_request,
    output wire                                                            active_source_healthy,
    output reg                                                             request_reject_pulse,
    output reg                                                             switch_done_pulse,
    output reg                                                             auto_failover_pulse,
    output wire                                                            fault_status,
    output wire                                                            auto_failover_status
);
    localparam integer INDEX_WIDTH = (NUM_SOURCES < 2) ? 1 : $clog2(NUM_SOURCES);
    localparam integer STABLE_COUNT_WIDTH = (STABLE_CYCLES < 2) ? 1 : $clog2(STABLE_CYCLES + 1);
    localparam integer HOLD_COUNT_WIDTH = (HOLD_CYCLES < 2) ? 1 : $clog2(HOLD_CYCLES + 1);
    localparam [INDEX_WIDTH-1:0] DEFAULT_SOURCE_VALUE = DEFAULT_SOURCE;
    localparam [STABLE_COUNT_WIDTH-1:0] ONE_STABLE = {{(STABLE_COUNT_WIDTH-1){1'b0}}, 1'b1};
    localparam [HOLD_COUNT_WIDTH-1:0] ONE_HOLD = {{(HOLD_COUNT_WIDTH-1){1'b0}}, 1'b1};

    reg [INDEX_WIDTH-1:0] active_source_q;
    reg [STABLE_COUNT_WIDTH-1:0] stable_count_q;
    reg [HOLD_COUNT_WIDTH-1:0] hold_count_q;
    reg fault_sticky_q;
    reg auto_failover_sticky_q;

    reg manual_valid;
    reg request_in_range;
    reg active_healthy_live;
    reg auto_candidate_valid;
    reg [INDEX_WIDTH-1:0] auto_candidate_source;
    reg candidate_valid;
    reg candidate_is_auto;
    reg [INDEX_WIDTH-1:0] candidate_source;
    reg candidate_healthy;
    reg fault_live;

    integer idx;

    assign mux_select = active_source_q;
    assign active_source = active_source_q;
    assign switch_in_progress = (hold_count_q != {HOLD_COUNT_WIDTH{1'b0}});
    assign hold_request = switch_in_progress;
    assign active_source_healthy = rst_n && active_healthy_live;
    assign fault_status = rst_n && ((STATUS_STICKY_EN != 0) ? fault_sticky_q : fault_live);
    assign auto_failover_status = rst_n && ((STATUS_STICKY_EN != 0) ? auto_failover_sticky_q : auto_failover_pulse);

    initial begin
        if (NUM_SOURCES < 2) begin
            $fatal(1, "clock_mux_controller requires NUM_SOURCES >= 2");
        end
        if ((DEFAULT_SOURCE < 0) || (DEFAULT_SOURCE >= NUM_SOURCES)) begin
            $fatal(1, "clock_mux_controller requires DEFAULT_SOURCE inside NUM_SOURCES");
        end
        if ((WAIT_FOR_STABLE_EN != 0) && (WAIT_FOR_STABLE_EN != 1)) begin
            $fatal(1, "clock_mux_controller requires WAIT_FOR_STABLE_EN to be 0 or 1");
        end
        if (STABLE_CYCLES < 1) begin
            $fatal(1, "clock_mux_controller requires STABLE_CYCLES >= 1");
        end
        if ((AUTO_FAILOVER_EN != 0) && (AUTO_FAILOVER_EN != 1)) begin
            $fatal(1, "clock_mux_controller requires AUTO_FAILOVER_EN to be 0 or 1");
        end
        if (HOLD_CYCLES < 0) begin
            $fatal(1, "clock_mux_controller requires HOLD_CYCLES >= 0");
        end
        if ((STATUS_STICKY_EN != 0) && (STATUS_STICKY_EN != 1)) begin
            $fatal(1, "clock_mux_controller requires STATUS_STICKY_EN to be 0 or 1");
        end
    end

    always @* begin
        request_in_range = (requested_source < NUM_SOURCES);
        manual_valid = request_valid && request_in_range && (requested_source != active_source_q);

        active_healthy_live = source_healthy[active_source_q];

        auto_candidate_valid = 1'b0;
        auto_candidate_source = active_source_q;
        for (idx = 0; idx < NUM_SOURCES; idx = idx + 1) begin
            if (!auto_candidate_valid && (idx != active_source_q) && source_healthy[idx]) begin
                auto_candidate_valid = 1'b1;
                auto_candidate_source = idx[INDEX_WIDTH-1:0];
            end
        end

        candidate_valid = 1'b0;
        candidate_is_auto = 1'b0;
        candidate_source = active_source_q;
        candidate_healthy = 1'b0;

        if (manual_valid) begin
            candidate_valid = 1'b1;
            candidate_source = requested_source;
            candidate_healthy = source_healthy[requested_source];
        end
        else if ((AUTO_FAILOVER_EN != 0) && !active_healthy_live && auto_candidate_valid) begin
            candidate_valid = 1'b1;
            candidate_is_auto = 1'b1;
            candidate_source = auto_candidate_source;
            candidate_healthy = source_healthy[auto_candidate_source];
        end

        fault_live = !active_healthy_live && !auto_candidate_valid && !switch_in_progress;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_source_q <= DEFAULT_SOURCE_VALUE;
            pending_source <= DEFAULT_SOURCE_VALUE;
            pending_source_valid <= 1'b0;
            stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
            hold_count_q <= {HOLD_COUNT_WIDTH{1'b0}};
            request_reject_pulse <= 1'b0;
            switch_done_pulse <= 1'b0;
            auto_failover_pulse <= 1'b0;
            fault_sticky_q <= 1'b0;
            auto_failover_sticky_q <= 1'b0;
        end
        else begin
            request_reject_pulse <= 1'b0;
            switch_done_pulse <= 1'b0;
            auto_failover_pulse <= 1'b0;

            if (clear_sticky) begin
                fault_sticky_q <= 1'b0;
                auto_failover_sticky_q <= 1'b0;
            end
            else if ((STATUS_STICKY_EN != 0) && fault_live) begin
                fault_sticky_q <= 1'b1;
            end

            if (hold_count_q != {HOLD_COUNT_WIDTH{1'b0}}) begin
                hold_count_q <= hold_count_q - ONE_HOLD;
                pending_source_valid <= 1'b0;
                stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                pending_source <= active_source_q;
            end
            else begin
                if (request_valid && !request_in_range) begin
                    request_reject_pulse <= 1'b1;
                    pending_source_valid <= 1'b0;
                    stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                    pending_source <= active_source_q;
                end
                else if (manual_valid && inhibit_switch) begin
                    request_reject_pulse <= 1'b1;
                    pending_source_valid <= 1'b0;
                    stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                    pending_source <= active_source_q;
                end
                else if (candidate_valid) begin
                    if ((WAIT_FOR_STABLE_EN != 0) && !candidate_healthy) begin
                        pending_source <= candidate_source;
                        pending_source_valid <= 1'b1;
                        stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                    end
                    else if ((WAIT_FOR_STABLE_EN != 0) && candidate_healthy) begin
                        pending_source <= candidate_source;
                        pending_source_valid <= 1'b1;

                        if (pending_source_valid && (pending_source == candidate_source)) begin
                            if ((stable_count_q + ONE_STABLE) >= STABLE_CYCLES) begin
                                active_source_q <= candidate_source;
                                pending_source_valid <= 1'b0;
                                stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                                hold_count_q <= HOLD_CYCLES;
                                switch_done_pulse <= 1'b1;
                                if (candidate_is_auto) begin
                                    auto_failover_pulse <= 1'b1;
                                    if (STATUS_STICKY_EN != 0) begin
                                        auto_failover_sticky_q <= 1'b1;
                                    end
                                end
                            end
                            else begin
                                stable_count_q <= stable_count_q + ONE_STABLE;
                            end
                        end
                        else begin
                            stable_count_q <= ONE_STABLE;
                        end
                    end
                    else begin
                        active_source_q <= candidate_source;
                        pending_source <= candidate_source;
                        pending_source_valid <= 1'b0;
                        stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                        hold_count_q <= HOLD_CYCLES;
                        switch_done_pulse <= 1'b1;
                        if (candidate_is_auto) begin
                            auto_failover_pulse <= 1'b1;
                            if (STATUS_STICKY_EN != 0) begin
                                auto_failover_sticky_q <= 1'b1;
                            end
                        end
                    end
                end
                else begin
                    pending_source <= active_source_q;
                    pending_source_valid <= 1'b0;
                    stable_count_q <= {STABLE_COUNT_WIDTH{1'b0}};
                end
            end
        end
    end
endmodule
