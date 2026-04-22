`timescale 1ns/1ps

module power_domain_controller_tb;
    localparam [2:0] STATE_OFF        = 3'd0;
    localparam [2:0] STATE_RESTORE    = 3'd2;
    localparam [2:0] STATE_ACTIVE     = 3'd3;

    reg clk;
    reg rst_n;
    reg power_on_req;
    reg power_off_req;
    reg power_good;
    reg save_done;
    reg restore_done;
    reg clear_fault;
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
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        repeat (200) @(posedge clk);
        $fatal(1, "power_domain_controller_tb timed out");
    end

    task pulse_power_on;
        begin
            power_on_req = 1'b1;
            @(posedge clk);
            @(negedge clk);
            power_on_req = 1'b0;
        end
    endtask

    task pulse_power_off;
        begin
            power_off_req = 1'b1;
            @(posedge clk);
            @(negedge clk);
            power_off_req = 1'b0;
        end
    endtask

    task pulse_clear_fault;
        begin
            clear_fault = 1'b1;
            @(posedge clk);
            @(negedge clk);
            clear_fault = 1'b0;
        end
    endtask

    initial begin
        rst_n = 1'b0;
        power_on_req = 1'b0;
        power_off_req = 1'b0;
        power_good = 1'b0;
        save_done = 1'b0;
        restore_done = 1'b0;
        clear_fault = 1'b0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        if (state_code !== STATE_OFF || power_enable || !isolation_enable || !clock_gate_enable || !domain_reset_asserted) begin
            $fatal(1, "controller should reset to safe powered-off state");
        end

        pulse_power_on();
        repeat (2) @(posedge clk);
        power_good = 1'b1;
        wait (state_code == STATE_ACTIVE);
        @(negedge clk);
        if (state_code !== STATE_ACTIVE || !domain_active || !power_enable || isolation_enable || clock_gate_enable || domain_reset_asserted) begin
            $fatal(1, "controller should enter active state after qualified power_good");
        end

        pulse_power_off();
        @(posedge clk);
        if (!retention_save_pulse) begin
            $fatal(1, "shutdown should request retention save when enabled");
        end
        save_done = 1'b1;
        @(posedge clk);
        save_done = 1'b0;
        power_good = 1'b0;
        repeat (3) @(posedge clk);
        @(negedge clk);
        if (state_code !== STATE_OFF || !retention_context_valid || power_enable || !isolation_enable) begin
            $fatal(1, "saved shutdown should end in powered-off state with retained context");
        end

        pulse_power_on();
        repeat (2) @(posedge clk);
        power_good = 1'b1;
        wait (state_code == STATE_RESTORE);
        @(posedge clk);
        if (!retention_restore_pulse) begin
            $fatal(1, "retained power-up should request restore before activation");
        end
        restore_done = 1'b1;
        wait (state_code == STATE_ACTIVE);
        restore_done = 1'b0;
        @(negedge clk);
        if (state_code !== STATE_ACTIVE || retention_context_valid) begin
            $fatal(1, "successful restore should clear retained context and return active");
        end

        pulse_power_off();
        @(posedge clk);
        save_done = 1'b1;
        @(posedge clk);
        save_done = 1'b0;
        power_good = 1'b0;
        repeat (3) @(posedge clk);

        pulse_power_on();
        repeat (2) @(posedge clk);
        power_good = 1'b1;
        wait (state_code == STATE_RESTORE);
        repeat (4) @(posedge clk);
        power_good = 1'b0;
        @(negedge clk);
        if (!fault_timeout || state_code !== STATE_OFF || power_enable) begin
            $fatal(1, "restore timeout should latch a fault and return to safe power-off");
        end

        pulse_clear_fault();
        if (fault_timeout) begin
            $fatal(1, "clear_fault should clear sticky timeout while powered off");
        end

        restore_done = 1'b1;
        pulse_power_on();
        repeat (2) @(posedge clk);
        power_good = 1'b1;
        wait (state_code == STATE_RESTORE);
        wait (state_code == STATE_ACTIVE);
        restore_done = 1'b0;
        @(negedge clk);
        if (state_code !== STATE_ACTIVE || !domain_active) begin
            $fatal(1, "controller should retry successfully after fault clear");
        end

        $display("power_domain_controller_tb passed");
        $finish;
    end
endmodule
