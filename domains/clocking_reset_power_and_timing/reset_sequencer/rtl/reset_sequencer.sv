module reset_sequencer #(
    parameter integer NUM_RESETS = 3,
    parameter integer RELEASE_DELAY_CYCLES = 2,
    parameter integer WAIT_FOR_PREREQ_EN = 1,
    parameter integer TIMEOUT_EN = 1,
    parameter integer TIMEOUT_CYCLES = 8,
    parameter integer AUTO_RESTART_EN = 0
) (
    input  wire                                                clk,
    input  wire                                                rst_n,
    input  wire                                                global_reset_req,
    input  wire                                                start_sequence,
    input  wire                                                prerequisites_ready,
    input  wire                                                clear_fault,
    output reg  [NUM_RESETS-1:0]                               reset_asserted,
    output reg  [((NUM_RESETS < 2) ? 1 : $clog2(NUM_RESETS))-1:0] release_index,
    output wire                                                sequencing_active,
    output reg                                                 step_release_pulse,
    output reg                                                 ready,
    output reg                                                 timeout_fault
);
    localparam integer INDEX_WIDTH = (NUM_RESETS < 2) ? 1 : $clog2(NUM_RESETS);
    localparam integer DELAY_COUNT_WIDTH = (RELEASE_DELAY_CYCLES < 1) ? 1 : $clog2(RELEASE_DELAY_CYCLES + 1);
    localparam integer TIMEOUT_COUNT_WIDTH = (TIMEOUT_CYCLES < 1) ? 1 : $clog2(TIMEOUT_CYCLES + 1);
    localparam [1:0] STATE_IDLE = 2'd0;
    localparam [1:0] STATE_WAIT = 2'd1;
    localparam [1:0] STATE_RELEASE = 2'd2;
    localparam [1:0] STATE_DONE = 2'd3;

    reg [1:0] state_q;
    reg [DELAY_COUNT_WIDTH-1:0] delay_count_q;
    reg [TIMEOUT_COUNT_WIDTH-1:0] timeout_count_q;

    wire prereq_met;
    wire timeout_hit;

    assign prereq_met = (WAIT_FOR_PREREQ_EN == 0) || prerequisites_ready;
    assign timeout_hit = (TIMEOUT_CYCLES == 0) ? 1'b1 : ((timeout_count_q + {{(TIMEOUT_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= TIMEOUT_CYCLES);
    assign sequencing_active = (state_q == STATE_WAIT) || (state_q == STATE_RELEASE);

    initial begin
        if (NUM_RESETS < 1) begin
            $fatal(1, "reset_sequencer requires NUM_RESETS >= 1");
        end
        if (RELEASE_DELAY_CYCLES < 0) begin
            $fatal(1, "reset_sequencer requires RELEASE_DELAY_CYCLES >= 0");
        end
        if ((WAIT_FOR_PREREQ_EN != 0) && (WAIT_FOR_PREREQ_EN != 1)) begin
            $fatal(1, "reset_sequencer requires WAIT_FOR_PREREQ_EN to be 0 or 1");
        end
        if ((TIMEOUT_EN != 0) && (TIMEOUT_EN != 1)) begin
            $fatal(1, "reset_sequencer requires TIMEOUT_EN to be 0 or 1");
        end
        if (TIMEOUT_CYCLES < 0) begin
            $fatal(1, "reset_sequencer requires TIMEOUT_CYCLES >= 0");
        end
        if ((AUTO_RESTART_EN != 0) && (AUTO_RESTART_EN != 1)) begin
            $fatal(1, "reset_sequencer requires AUTO_RESTART_EN to be 0 or 1");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
            reset_asserted <= {NUM_RESETS{1'b1}};
            release_index <= {INDEX_WIDTH{1'b0}};
            delay_count_q <= {DELAY_COUNT_WIDTH{1'b0}};
            timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};
            step_release_pulse <= 1'b0;
            ready <= 1'b0;
            timeout_fault <= 1'b0;
        end
        else begin
            step_release_pulse <= 1'b0;

            if (global_reset_req) begin
                state_q <= STATE_IDLE;
                reset_asserted <= {NUM_RESETS{1'b1}};
                release_index <= {INDEX_WIDTH{1'b0}};
                delay_count_q <= {DELAY_COUNT_WIDTH{1'b0}};
                timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};
                ready <= 1'b0;
                timeout_fault <= 1'b0;
            end
            else begin
                case (state_q)
                    STATE_IDLE: begin
                        reset_asserted <= {NUM_RESETS{1'b1}};
                        release_index <= {INDEX_WIDTH{1'b0}};
                        delay_count_q <= {DELAY_COUNT_WIDTH{1'b0}};
                        timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};
                        ready <= 1'b0;

                        if (clear_fault) begin
                            timeout_fault <= 1'b0;
                        end

                        if (start_sequence) begin
                            state_q <= STATE_WAIT;
                        end
                    end

                    STATE_WAIT: begin
                        reset_asserted <= {NUM_RESETS{1'b1}};
                        ready <= 1'b0;
                        delay_count_q <= RELEASE_DELAY_CYCLES;

                        if (clear_fault) begin
                            timeout_fault <= 1'b0;
                        end

                        if (prereq_met) begin
                            timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};
                            state_q <= STATE_RELEASE;
                        end
                        else if ((TIMEOUT_EN != 0) && timeout_hit) begin
                            timeout_fault <= 1'b1;
                            timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};
                            if (AUTO_RESTART_EN != 0) begin
                                state_q <= STATE_WAIT;
                            end
                            else begin
                                state_q <= STATE_IDLE;
                            end
                        end
                        else begin
                            timeout_count_q <= timeout_count_q + {{(TIMEOUT_COUNT_WIDTH-1){1'b0}}, 1'b1};
                        end
                    end

                    STATE_RELEASE: begin
                        ready <= 1'b0;
                        timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};

                        if (delay_count_q != {DELAY_COUNT_WIDTH{1'b0}}) begin
                            delay_count_q <= delay_count_q - {{(DELAY_COUNT_WIDTH-1){1'b0}}, 1'b1};
                        end
                        else begin
                            reset_asserted[release_index] <= 1'b0;
                            step_release_pulse <= 1'b1;
                            delay_count_q <= RELEASE_DELAY_CYCLES;

                            if (release_index == (NUM_RESETS - 1)) begin
                                state_q <= STATE_DONE;
                                ready <= 1'b1;
                            end
                            else begin
                                release_index <= release_index + {{(INDEX_WIDTH-1){1'b0}}, 1'b1};
                            end
                        end
                    end

                    default: begin
                        ready <= 1'b1;
                        timeout_count_q <= {TIMEOUT_COUNT_WIDTH{1'b0}};
                        delay_count_q <= {DELAY_COUNT_WIDTH{1'b0}};

                        if (start_sequence) begin
                            state_q <= STATE_WAIT;
                            reset_asserted <= {NUM_RESETS{1'b1}};
                            release_index <= {INDEX_WIDTH{1'b0}};
                            ready <= 1'b0;
                        end

                        if (clear_fault) begin
                            timeout_fault <= 1'b0;
                        end
                    end
                endcase
            end
        end
    end
endmodule
