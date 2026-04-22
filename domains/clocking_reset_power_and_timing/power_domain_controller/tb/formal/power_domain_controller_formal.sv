module power_domain_controller_formal;
    reg [6:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 7'd4);

    (* anyseq *) reg power_on_req;
    (* anyseq *) reg power_off_req;
    (* anyseq *) reg power_good;
    (* anyseq *) reg save_done;
    (* anyseq *) reg restore_done;
    (* anyseq *) reg clear_fault;

    wire power_enable;
    wire isolation_enable;
    wire clock_gate_enable;
    wire domain_reset_asserted;
    wire retention_save_pulse;
    wire retention_restore_pulse;
    wire retention_context_valid;
    wire sequencing_active;
    wire domain_active;
    wire fault_timeout;
    wire [2:0] state_code;

    power_domain_controller #(
        .POWER_UP_DELAY_CYCLES(1),
        .POWER_DOWN_DELAY_CYCLES(1),
        .SAVE_TIMEOUT_CYCLES(2),
        .RESTORE_TIMEOUT_CYCLES(2),
        .RETENTION_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .power_on_req(power_on_req),
        .power_off_req(power_off_req),
        .power_good(power_good),
        .save_done(save_done),
        .restore_done(restore_done),
        .clear_fault(clear_fault),
        .power_enable(power_enable),
        .isolation_enable(isolation_enable),
        .clock_gate_enable(clock_gate_enable),
        .domain_reset_asserted(domain_reset_asserted),
        .retention_save_pulse(retention_save_pulse),
        .retention_restore_pulse(retention_restore_pulse),
        .retention_context_valid(retention_context_valid),
        .sequencing_active(sequencing_active),
        .domain_active(domain_active),
        .fault_timeout(fault_timeout),
        .state_code(state_code)
    );

    initial begin
        formal_ticks = 7'd0;
        past_valid = 1'b0;
        prev_clk = 1'b0;
    end

    always @($global_clock) begin
        prev_clk <= clk;
        formal_ticks <= formal_ticks + 1'b1;
        past_valid <= 1'b1;

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(state_code == 3'd0);
                assert(!power_enable);
                assert(isolation_enable);
                assert(clock_gate_enable);
                assert(domain_reset_asserted);
                assert(!domain_active);
            end
            else begin
                assert(domain_active ? (power_enable && !isolation_enable && !clock_gate_enable && !domain_reset_asserted) : 1'b1);
                assert(!power_enable ? (isolation_enable && clock_gate_enable && domain_reset_asserted) : 1'b1);
                assert(retention_restore_pulse ? retention_context_valid : 1'b1);
                assert(domain_active ? !sequencing_active : 1'b1);
            end
        end
    end
endmodule
