`timescale 1ns/1ps

module reset_sequencer_tb;
    reg clk;
    reg rst_n;
    reg global_reset_req;
    reg start_sequence;
    reg prerequisites_ready;
    reg clear_fault;
    wire [2:0] reset_asserted;
    wire [1:0] release_index;
    wire sequencing_active;
    wire step_release_pulse;
    wire ready;
    wire timeout_fault;

    integer release_pulses;

    reset_sequencer #(
        .NUM_RESETS(3),
        .RELEASE_DELAY_CYCLES(2),
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
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (step_release_pulse) begin
            release_pulses = release_pulses + 1;
        end
    end

    initial begin
        rst_n = 1'b0;
        global_reset_req = 1'b1;
        start_sequence = 1'b0;
        prerequisites_ready = 1'b0;
        clear_fault = 1'b0;
        release_pulses = 0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        if (reset_asserted !== 3'b111 || ready || sequencing_active) begin
            $fatal(1, "reset sequencer should start fully asserted and idle");
        end

        global_reset_req = 1'b0;
        start_sequence = 1'b1;
        @(posedge clk);
        start_sequence = 1'b0;

        repeat (4) @(posedge clk);
        if (!timeout_fault || ready || (reset_asserted !== 3'b111)) begin
            $fatal(1, "missing prerequisites should trigger timeout while holding all resets asserted");
        end

        clear_fault = 1'b1;
        @(posedge clk);
        clear_fault = 1'b0;

        prerequisites_ready = 1'b1;
        start_sequence = 1'b1;
        @(posedge clk);
        start_sequence = 1'b0;

        wait (release_pulses == 1);
        @(negedge clk);
        if (reset_asserted !== 3'b110) begin
            $fatal(1, "first release should deassert reset 0");
        end

        wait (release_pulses == 2);
        @(negedge clk);
        if (reset_asserted !== 3'b100) begin
            $fatal(1, "second release should deassert reset 1");
        end

        wait (release_pulses == 3);
        @(negedge clk);
        if (reset_asserted !== 3'b000 || !ready) begin
            $fatal(1, "final release should deassert every reset and assert ready");
        end

        global_reset_req = 1'b1;
        @(posedge clk);
        @(negedge clk);
        global_reset_req = 1'b0;
        if (reset_asserted !== 3'b111 || ready) begin
            $fatal(1, "global reset request should return the sequencer to idle asserted state");
        end

        $display("reset_sequencer_tb passed");
        $finish;
    end
endmodule
