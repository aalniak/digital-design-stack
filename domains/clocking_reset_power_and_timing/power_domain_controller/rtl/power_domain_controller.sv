module power_domain_controller #(
    parameter integer POWER_UP_DELAY_CYCLES = 2,
    parameter integer POWER_DOWN_DELAY_CYCLES = 2,
    parameter integer SAVE_TIMEOUT_CYCLES = 8,
    parameter integer RESTORE_TIMEOUT_CYCLES = 8,
    parameter integer RETENTION_EN = 1
) (
    input  wire clk,
    input  wire rst_n,
    input  wire power_on_req,
    input  wire power_off_req,
    input  wire power_good,
    input  wire save_done,
    input  wire restore_done,
    input  wire clear_fault,
    output wire power_enable,
    output wire isolation_enable,
    output wire clock_gate_enable,
    output wire domain_reset_asserted,
    output reg  retention_save_pulse,
    output reg  retention_restore_pulse,
    output reg  retention_context_valid,
    output wire sequencing_active,
    output wire domain_active,
    output reg  fault_timeout,
    output wire [2:0] state_code
);
    localparam integer POWER_UP_COUNT_WIDTH = (POWER_UP_DELAY_CYCLES < 1) ? 1 : $clog2(POWER_UP_DELAY_CYCLES + 1);
    localparam integer POWER_DOWN_COUNT_WIDTH = (POWER_DOWN_DELAY_CYCLES < 1) ? 1 : $clog2(POWER_DOWN_DELAY_CYCLES + 1);
    localparam integer SAVE_TIMEOUT_COUNT_WIDTH = (SAVE_TIMEOUT_CYCLES < 1) ? 1 : $clog2(SAVE_TIMEOUT_CYCLES + 1);
    localparam integer RESTORE_TIMEOUT_COUNT_WIDTH = (RESTORE_TIMEOUT_CYCLES < 1) ? 1 : $clog2(RESTORE_TIMEOUT_CYCLES + 1);

    localparam [2:0] STATE_OFF        = 3'd0;
    localparam [2:0] STATE_POWER_UP   = 3'd1;
    localparam [2:0] STATE_RESTORE    = 3'd2;
    localparam [2:0] STATE_ACTIVE     = 3'd3;
    localparam [2:0] STATE_SAVE       = 3'd4;
    localparam [2:0] STATE_POWER_DOWN = 3'd5;

    reg [2:0] state_q;
    reg [POWER_UP_COUNT_WIDTH-1:0] power_up_count_q;
    reg [POWER_DOWN_COUNT_WIDTH-1:0] power_down_count_q;
    reg [SAVE_TIMEOUT_COUNT_WIDTH-1:0] save_timeout_count_q;
    reg [RESTORE_TIMEOUT_COUNT_WIDTH-1:0] restore_timeout_count_q;

    wire save_timeout_hit;
    wire restore_timeout_hit;

    assign save_timeout_hit = (SAVE_TIMEOUT_CYCLES == 0) ? 1'b1 :
        ((save_timeout_count_q + {{(SAVE_TIMEOUT_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= SAVE_TIMEOUT_CYCLES);
    assign restore_timeout_hit = (RESTORE_TIMEOUT_CYCLES == 0) ? 1'b1 :
        ((restore_timeout_count_q + {{(RESTORE_TIMEOUT_COUNT_WIDTH-1){1'b0}}, 1'b1}) >= RESTORE_TIMEOUT_CYCLES);

    assign power_enable = (state_q != STATE_OFF);
    assign isolation_enable = (state_q != STATE_ACTIVE);
    assign clock_gate_enable = (state_q != STATE_ACTIVE);
    assign domain_reset_asserted = (state_q != STATE_ACTIVE);
    assign sequencing_active = (state_q != STATE_OFF) && (state_q != STATE_ACTIVE);
    assign domain_active = (state_q == STATE_ACTIVE);
    assign state_code = state_q;

    initial begin
        if (POWER_UP_DELAY_CYCLES < 0) begin
            $fatal(1, "power_domain_controller requires POWER_UP_DELAY_CYCLES >= 0");
        end
        if (POWER_DOWN_DELAY_CYCLES < 0) begin
            $fatal(1, "power_domain_controller requires POWER_DOWN_DELAY_CYCLES >= 0");
        end
        if (SAVE_TIMEOUT_CYCLES < 0) begin
            $fatal(1, "power_domain_controller requires SAVE_TIMEOUT_CYCLES >= 0");
        end
        if (RESTORE_TIMEOUT_CYCLES < 0) begin
            $fatal(1, "power_domain_controller requires RESTORE_TIMEOUT_CYCLES >= 0");
        end
        if ((RETENTION_EN != 0) && (RETENTION_EN != 1)) begin
            $fatal(1, "power_domain_controller requires RETENTION_EN to be 0 or 1");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_OFF;
            power_up_count_q <= {POWER_UP_COUNT_WIDTH{1'b0}};
            power_down_count_q <= {POWER_DOWN_COUNT_WIDTH{1'b0}};
            save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
            restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};
            retention_save_pulse <= 1'b0;
            retention_restore_pulse <= 1'b0;
            retention_context_valid <= 1'b0;
            fault_timeout <= 1'b0;
        end
        else begin
            retention_save_pulse <= 1'b0;
            retention_restore_pulse <= 1'b0;

            case (state_q)
                STATE_OFF: begin
                    power_up_count_q <= {POWER_UP_COUNT_WIDTH{1'b0}};
                    power_down_count_q <= {POWER_DOWN_COUNT_WIDTH{1'b0}};
                    save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                    restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};

                    if (clear_fault) begin
                        fault_timeout <= 1'b0;
                    end

                    if (power_on_req && !fault_timeout) begin
                        state_q <= STATE_POWER_UP;
                        power_up_count_q <= POWER_UP_DELAY_CYCLES;
                    end
                end

                STATE_POWER_UP: begin
                    save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                    restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};

                    if (power_good) begin
                        if (power_up_count_q != {POWER_UP_COUNT_WIDTH{1'b0}}) begin
                            power_up_count_q <= power_up_count_q - {{(POWER_UP_COUNT_WIDTH-1){1'b0}}, 1'b1};
                        end
                        else if ((RETENTION_EN != 0) && retention_context_valid) begin
                            state_q <= STATE_RESTORE;
                            restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};
                            retention_restore_pulse <= 1'b1;
                        end
                        else begin
                            state_q <= STATE_ACTIVE;
                        end
                    end
                    else begin
                        power_up_count_q <= POWER_UP_DELAY_CYCLES;
                    end
                end

                STATE_RESTORE: begin
                    if (restore_done || (RESTORE_TIMEOUT_CYCLES == 0)) begin
                        state_q <= STATE_ACTIVE;
                        restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};
                        retention_context_valid <= 1'b0;
                    end
                    else if (restore_timeout_hit) begin
                        state_q <= STATE_POWER_DOWN;
                        power_down_count_q <= POWER_DOWN_DELAY_CYCLES;
                        restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};
                        fault_timeout <= 1'b1;
                    end
                    else begin
                        restore_timeout_count_q <= restore_timeout_count_q + {{(RESTORE_TIMEOUT_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                STATE_ACTIVE: begin
                    power_up_count_q <= {POWER_UP_COUNT_WIDTH{1'b0}};
                    power_down_count_q <= {POWER_DOWN_COUNT_WIDTH{1'b0}};
                    save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                    restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};

                    if (power_off_req) begin
                        if (RETENTION_EN != 0) begin
                            state_q <= STATE_SAVE;
                            save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                            retention_save_pulse <= 1'b1;
                        end
                        else begin
                            state_q <= STATE_POWER_DOWN;
                            power_down_count_q <= POWER_DOWN_DELAY_CYCLES;
                        end
                    end
                end

                STATE_SAVE: begin
                    if (save_done || (SAVE_TIMEOUT_CYCLES == 0)) begin
                        state_q <= STATE_POWER_DOWN;
                        power_down_count_q <= POWER_DOWN_DELAY_CYCLES;
                        save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                        retention_context_valid <= (RETENTION_EN != 0);
                    end
                    else if (save_timeout_hit) begin
                        state_q <= STATE_POWER_DOWN;
                        power_down_count_q <= POWER_DOWN_DELAY_CYCLES;
                        save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                        fault_timeout <= 1'b1;
                    end
                    else begin
                        save_timeout_count_q <= save_timeout_count_q + {{(SAVE_TIMEOUT_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                default: begin
                    power_up_count_q <= {POWER_UP_COUNT_WIDTH{1'b0}};
                    save_timeout_count_q <= {SAVE_TIMEOUT_COUNT_WIDTH{1'b0}};
                    restore_timeout_count_q <= {RESTORE_TIMEOUT_COUNT_WIDTH{1'b0}};

                    if (power_down_count_q != {POWER_DOWN_COUNT_WIDTH{1'b0}}) begin
                        power_down_count_q <= power_down_count_q - {{(POWER_DOWN_COUNT_WIDTH-1){1'b0}}, 1'b1};
                    end
                    else begin
                        state_q <= STATE_OFF;
                    end
                end
            endcase
        end
    end
endmodule
