module retention_controller #(
    parameter integer SAVE_TIMEOUT_CYCLES = 8,
    parameter integer RESTORE_TIMEOUT_CYCLES = 8
) (
    input  wire clk,
    input  wire rst_n,
    input  wire save_req,
    input  wire restore_req,
    input  wire domain_idle,
    input  wire domain_power_good,
    input  wire save_done,
    input  wire restore_done,
    input  wire clear_fault,
    output reg  save_pulse,
    output reg  restore_pulse,
    output reg  retention_valid,
    output wire busy,
    output reg  fault_timeout,
    output wire [1:0] state_code
);
    localparam integer SAVE_COUNT_WIDTH = (SAVE_TIMEOUT_CYCLES < 1) ? 1 : $clog2(SAVE_TIMEOUT_CYCLES + 1);
    localparam integer RESTORE_COUNT_WIDTH = (RESTORE_TIMEOUT_CYCLES < 1) ? 1 : $clog2(RESTORE_TIMEOUT_CYCLES + 1);

    localparam [1:0] STATE_IDLE    = 2'd0;
    localparam [1:0] STATE_SAVE    = 2'd1;
    localparam [1:0] STATE_RESTORE = 2'd2;

    reg [1:0] state_q;
    reg [SAVE_COUNT_WIDTH-1:0] save_count_q;
    reg [RESTORE_COUNT_WIDTH-1:0] restore_count_q;

    wire save_timeout_hit;
    wire restore_timeout_hit;

    assign save_timeout_hit = (SAVE_TIMEOUT_CYCLES == 0) ? 1'b1 :
        ((save_count_q + {{(SAVE_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= SAVE_TIMEOUT_CYCLES);
    assign restore_timeout_hit = (RESTORE_TIMEOUT_CYCLES == 0) ? 1'b1 :
        ((restore_count_q + {{(RESTORE_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= RESTORE_TIMEOUT_CYCLES);

    assign busy = (state_q != STATE_IDLE);
    assign state_code = state_q;

    initial begin
        if (SAVE_TIMEOUT_CYCLES < 0) begin
            $fatal(1, "retention_controller requires SAVE_TIMEOUT_CYCLES >= 0");
        end
        if (RESTORE_TIMEOUT_CYCLES < 0) begin
            $fatal(1, "retention_controller requires RESTORE_TIMEOUT_CYCLES >= 0");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
            save_count_q <= {SAVE_COUNT_WIDTH{1'b0}};
            restore_count_q <= {RESTORE_COUNT_WIDTH{1'b0}};
            save_pulse <= 1'b0;
            restore_pulse <= 1'b0;
            retention_valid <= 1'b0;
            fault_timeout <= 1'b0;
        end
        else begin
            save_pulse <= 1'b0;
            restore_pulse <= 1'b0;

            case (state_q)
                STATE_IDLE: begin
                    save_count_q <= {SAVE_COUNT_WIDTH{1'b0}};
                    restore_count_q <= {RESTORE_COUNT_WIDTH{1'b0}};

                    if (clear_fault) begin
                        fault_timeout <= 1'b0;
                    end

                    if (save_req && domain_idle && !fault_timeout) begin
                        state_q <= STATE_SAVE;
                        save_count_q <= {SAVE_COUNT_WIDTH{1'b0}};
                        save_pulse <= 1'b1;
                    end
                    else if (restore_req && domain_power_good && retention_valid && !fault_timeout) begin
                        state_q <= STATE_RESTORE;
                        restore_count_q <= {RESTORE_COUNT_WIDTH{1'b0}};
                        restore_pulse <= 1'b1;
                    end
                end

                STATE_SAVE: begin
                    if (save_done || (SAVE_TIMEOUT_CYCLES == 0)) begin
                        state_q <= STATE_IDLE;
                        save_count_q <= {SAVE_COUNT_WIDTH{1'b0}};
                        retention_valid <= 1'b1;
                    end
                    else if (save_timeout_hit) begin
                        state_q <= STATE_IDLE;
                        save_count_q <= {SAVE_COUNT_WIDTH{1'b0}};
                        fault_timeout <= 1'b1;
                    end
                    else begin
                        save_count_q <= save_count_q + {{(SAVE_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                default: begin
                    if (restore_done || (RESTORE_TIMEOUT_CYCLES == 0)) begin
                        state_q <= STATE_IDLE;
                        restore_count_q <= {RESTORE_COUNT_WIDTH{1'b0}};
                        retention_valid <= 1'b0;
                    end
                    else if (restore_timeout_hit) begin
                        state_q <= STATE_IDLE;
                        restore_count_q <= {RESTORE_COUNT_WIDTH{1'b0}};
                        fault_timeout <= 1'b1;
                    end
                    else begin
                        restore_count_q <= restore_count_q + {{(RESTORE_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                end
            endcase
        end
    end
endmodule
