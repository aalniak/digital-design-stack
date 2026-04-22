module reset_sequencer_formal;
    reg [5:0] formal_ticks;
    reg past_valid;
    reg prev_clk;
    wire clk = formal_ticks[0];
    wire rst_n = (formal_ticks >= 6'd4);

    (* anyseq *) reg global_reset_req;
    (* anyseq *) reg start_sequence;
    (* anyseq *) reg prerequisites_ready;
    (* anyseq *) reg clear_fault;

    wire [1:0] reset_asserted;
    wire release_index;
    wire sequencing_active;
    wire step_release_pulse;
    wire ready;
    wire timeout_fault;

    reset_sequencer #(
        .NUM_RESETS(2),
        .RELEASE_DELAY_CYCLES(1),
        .WAIT_FOR_PREREQ_EN(1),
        .TIMEOUT_EN(1),
        .TIMEOUT_CYCLES(3),
        .AUTO_RESTART_EN(0)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .global_reset_req(global_reset_req),
        .start_sequence(start_sequence),
        .prerequisites_ready(prerequisites_ready),
        .clear_fault(clear_fault),
        .reset_asserted(reset_asserted),
        .release_index(release_index),
        .sequencing_active(sequencing_active),
        .step_release_pulse(step_release_pulse),
        .ready(ready),
        .timeout_fault(timeout_fault)
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
                assert(reset_asserted == 2'b11);
                assert(!ready);
                assert(!step_release_pulse);
                assert(!timeout_fault);
            end
            else begin
                assert(ready ? (reset_asserted == 2'b00) : 1'b1);
            end
        end
    end
endmodule
