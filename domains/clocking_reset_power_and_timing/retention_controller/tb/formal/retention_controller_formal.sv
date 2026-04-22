module retention_controller_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg save_req;
    (* anyseq *) reg restore_req;
    (* anyseq *) reg domain_idle;
    (* anyseq *) reg domain_power_good;
    (* anyseq *) reg save_done;
    (* anyseq *) reg restore_done;
    (* anyseq *) reg clear_fault;

    wire save_pulse;
    wire restore_pulse;
    wire retention_valid;
    wire busy;
    wire fault_timeout;
    wire [1:0] state_code;

    retention_controller #(
        .SAVE_TIMEOUT_CYCLES(2),
        .RESTORE_TIMEOUT_CYCLES(2)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .save_req(save_req),
        .restore_req(restore_req),
        .domain_idle(domain_idle),
        .domain_power_good(domain_power_good),
        .save_done(save_done),
        .restore_done(restore_done),
        .clear_fault(clear_fault),
        .save_pulse(save_pulse),
        .restore_pulse(restore_pulse),
        .retention_valid(retention_valid),
        .busy(busy),
        .fault_timeout(fault_timeout),
        .state_code(state_code)
    );

    initial begin
        formal_ticks = 6'd0;
        past_valid = 1'b0;
        prev_clk = 1'b0;
    end

    always @($global_clock) begin
        prev_clk <= clk;
        formal_ticks <= formal_ticks + 1'b1;
        past_valid <= 1'b1;

        if (past_valid && !prev_clk && clk) begin
            if (!rst_n) begin
                assert(state_code == 2'd0);
                assert(!busy);
                assert(!save_pulse);
                assert(!restore_pulse);
                assert(!retention_valid);
            end
            else begin
                assert(busy ? (state_code != 2'd0) : 1'b1);
                assert(restore_pulse ? retention_valid : 1'b1);
            end
        end
    end
endmodule
