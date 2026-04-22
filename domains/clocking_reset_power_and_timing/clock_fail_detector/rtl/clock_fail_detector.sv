module clock_fail_detector #(
    parameter integer WINDOW_CYCLES = 12,
    parameter integer TIMEOUT_CYCLES = 10,
    parameter integer MIN_EDGES = 3,
    parameter integer MAX_EDGES = 5,
    parameter integer FILTER_DEPTH = 1,
    parameter integer STICKY_FAULT_EN = 1,
    parameter integer AUTO_RECOVER_EN = 0
) (
    input  wire                                               ref_clk,
    input  wire                                               rst_n,
    input  wire                                               enable,
    input  wire                                               mon_clk,
    input  wire                                               clear_fault,
    output reg                                                fault,
    output wire                                               healthy,
    output reg                                                timeout_event,
    output reg                                                window_event,
    output reg                                                monitored_edge_pulse,
    output wire [((WINDOW_CYCLES < 1) ? 1 : $clog2(WINDOW_CYCLES + 1))-1:0] window_edge_count
);
    localparam integer WINDOW_COUNT_WIDTH = (WINDOW_CYCLES < 1) ? 1 : $clog2(WINDOW_CYCLES + 1);
    localparam integer FILTER_COUNT_WIDTH = (FILTER_DEPTH < 1) ? 1 : $clog2(FILTER_DEPTH + 1);
    localparam [WINDOW_COUNT_WIDTH-1:0] ONE_VALUE = {{(WINDOW_COUNT_WIDTH-1){1'b0}}, 1'b1};
    localparam [FILTER_COUNT_WIDTH-1:0] FILTER_DEPTH_VALUE = FILTER_DEPTH;

    reg mon_toggle_q;
    reg mon_meta_q;
    reg mon_sync_q;
    reg mon_prev_q;

    reg [WINDOW_COUNT_WIDTH-1:0] window_cycle_q;
    reg [WINDOW_COUNT_WIDTH-1:0] edge_count_q;
    reg [WINDOW_COUNT_WIDTH-1:0] gap_count_q;
    reg [FILTER_COUNT_WIDTH-1:0] bad_count_q;

    reg sync_edge;
    reg [WINDOW_COUNT_WIDTH-1:0] edge_count_next;
    reg [WINDOW_COUNT_WIDTH-1:0] gap_count_next;
    reg window_end;
    reg window_bad;
    reg window_good;
    reg timeout_violation;
    reg timeout_crossing;
    reg bad_sample;
    reg recovery_sample;

    assign healthy = rst_n && enable && !fault;
    assign window_edge_count = edge_count_q;

    initial begin
        if (WINDOW_CYCLES < 1) begin
            $fatal(1, "clock_fail_detector requires WINDOW_CYCLES >= 1");
        end
        if (TIMEOUT_CYCLES < 1) begin
            $fatal(1, "clock_fail_detector requires TIMEOUT_CYCLES >= 1");
        end
        if (MIN_EDGES < 0) begin
            $fatal(1, "clock_fail_detector requires MIN_EDGES >= 0");
        end
        if (MAX_EDGES < MIN_EDGES) begin
            $fatal(1, "clock_fail_detector requires MAX_EDGES >= MIN_EDGES");
        end
        if (FILTER_DEPTH < 1) begin
            $fatal(1, "clock_fail_detector requires FILTER_DEPTH >= 1");
        end
        if ((STICKY_FAULT_EN != 0) && (STICKY_FAULT_EN != 1)) begin
            $fatal(1, "clock_fail_detector requires STICKY_FAULT_EN to be 0 or 1");
        end
        if ((AUTO_RECOVER_EN != 0) && (AUTO_RECOVER_EN != 1)) begin
            $fatal(1, "clock_fail_detector requires AUTO_RECOVER_EN to be 0 or 1");
        end
    end

    always @(posedge mon_clk or negedge rst_n) begin
        if (!rst_n) begin
            mon_toggle_q <= 1'b0;
        end
        else if (enable) begin
            mon_toggle_q <= ~mon_toggle_q;
        end
    end

    always @* begin
        sync_edge = mon_sync_q ^ mon_prev_q;
        edge_count_next = edge_count_q + (sync_edge ? ONE_VALUE : {WINDOW_COUNT_WIDTH{1'b0}});

        if (sync_edge) begin
            gap_count_next = {WINDOW_COUNT_WIDTH{1'b0}};
        end
        else if (gap_count_q < TIMEOUT_CYCLES) begin
            gap_count_next = gap_count_q + ONE_VALUE;
        end
        else begin
            gap_count_next = gap_count_q;
        end

        window_end = (window_cycle_q == (WINDOW_CYCLES - 1));
        window_bad = window_end && ((edge_count_next < MIN_EDGES) || (edge_count_next > MAX_EDGES));
        window_good = window_end && !window_bad;
        timeout_violation = !sync_edge && (gap_count_next >= TIMEOUT_CYCLES);
        timeout_crossing = !sync_edge && (gap_count_q < TIMEOUT_CYCLES) && (gap_count_next >= TIMEOUT_CYCLES);
        bad_sample = timeout_violation || window_bad;
        recovery_sample = sync_edge || window_good;
    end

    always @(posedge ref_clk or negedge rst_n) begin
        if (!rst_n) begin
            mon_meta_q <= 1'b0;
            mon_sync_q <= 1'b0;
            mon_prev_q <= 1'b0;
            window_cycle_q <= {WINDOW_COUNT_WIDTH{1'b0}};
            edge_count_q <= {WINDOW_COUNT_WIDTH{1'b0}};
            gap_count_q <= {WINDOW_COUNT_WIDTH{1'b0}};
            bad_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
            fault <= 1'b0;
            timeout_event <= 1'b0;
            window_event <= 1'b0;
            monitored_edge_pulse <= 1'b0;
        end
        else begin
            mon_meta_q <= mon_toggle_q;
            mon_sync_q <= mon_meta_q;
            mon_prev_q <= mon_sync_q;

            timeout_event <= 1'b0;
            window_event <= 1'b0;
            monitored_edge_pulse <= 1'b0;

            if (clear_fault) begin
                fault <= 1'b0;
            end

            if (!enable) begin
                window_cycle_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                edge_count_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                gap_count_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                bad_count_q <= {FILTER_COUNT_WIDTH{1'b0}};
                monitored_edge_pulse <= 1'b0;

                if (STICKY_FAULT_EN == 0) begin
                    fault <= 1'b0;
                end
            end
            else begin
                monitored_edge_pulse <= sync_edge;

                if (timeout_crossing) begin
                    timeout_event <= 1'b1;
                end
                if (window_bad) begin
                    window_event <= 1'b1;
                end

                if (window_end) begin
                    window_cycle_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                    edge_count_q <= {WINDOW_COUNT_WIDTH{1'b0}};
                end
                else begin
                    window_cycle_q <= window_cycle_q + ONE_VALUE;
                    edge_count_q <= edge_count_next;
                end

                gap_count_q <= gap_count_next;

                if (bad_sample) begin
                    if (bad_count_q < FILTER_DEPTH_VALUE) begin
                        bad_count_q <= bad_count_q + {{(FILTER_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end

                    if ((bad_count_q + {{(FILTER_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= FILTER_DEPTH_VALUE) begin
                        fault <= 1'b1;
                    end
                end
                else if (recovery_sample) begin
                    bad_count_q <= {FILTER_COUNT_WIDTH{1'b0}};

                    if ((STICKY_FAULT_EN == 0) && (AUTO_RECOVER_EN != 0)) begin
                        fault <= 1'b0;
                    end
                end
            end
        end
    end
endmodule
