`timescale 1ns/1ps

module retention_controller_tb;
    localparam [1:0] STATE_IDLE = 2'd0;

    reg clk;
    reg rst_n;
    reg save_req;
    reg restore_req;
    reg domain_idle;
    reg domain_power_good;
    reg save_done;
    reg restore_done;
    reg clear_fault;
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
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task pulse_save_req;
        begin
            save_req = 1'b1;
            @(posedge clk);
            @(negedge clk);
            save_req = 1'b0;
        end
    endtask

    task pulse_restore_req;
        begin
            restore_req = 1'b1;
            @(posedge clk);
            @(negedge clk);
            restore_req = 1'b0;
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
        save_req = 1'b0;
        restore_req = 1'b0;
        domain_idle = 1'b0;
        domain_power_good = 1'b0;
        save_done = 1'b0;
        restore_done = 1'b0;
        clear_fault = 1'b0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        if (state_code !== STATE_IDLE || busy || retention_valid || fault_timeout) begin
            $fatal(1, "retention controller should reset to idle with no saved context");
        end

        domain_idle = 1'b1;
        pulse_save_req();
        @(posedge clk);
        if (!save_pulse || !busy) begin
            $fatal(1, "qualified save should start a save transaction");
        end
        save_done = 1'b1;
        @(posedge clk);
        save_done = 1'b0;
        @(negedge clk);
        if (busy || !retention_valid) begin
            $fatal(1, "successful save should clear busy and set retained-context validity");
        end

        domain_power_good = 1'b1;
        pulse_restore_req();
        @(posedge clk);
        if (!restore_pulse || !busy) begin
            $fatal(1, "qualified restore should start a restore transaction");
        end
        restore_done = 1'b1;
        @(posedge clk);
        restore_done = 1'b0;
        @(negedge clk);
        if (busy || retention_valid) begin
            $fatal(1, "successful restore should clear retained-context validity");
        end

        pulse_save_req();
        @(posedge clk);
        save_done = 1'b1;
        @(posedge clk);
        save_done = 1'b0;
        @(negedge clk);
        if (!retention_valid) begin
            $fatal(1, "save should recreate retained-context validity for timeout testing");
        end

        pulse_restore_req();
        repeat (4) @(posedge clk);
        @(negedge clk);
        if (!fault_timeout || busy || !retention_valid) begin
            $fatal(1, "restore timeout should set sticky fault and preserve retained context");
        end

        pulse_clear_fault();
        if (fault_timeout) begin
            $fatal(1, "clear_fault should clear the sticky timeout while idle");
        end

        restore_done = 1'b1;
        pulse_restore_req();
        @(posedge clk);
        @(posedge clk);
        restore_done = 1'b0;
        @(negedge clk);
        if (busy || retention_valid || fault_timeout) begin
            $fatal(1, "controller should retry successfully after fault clear");
        end

        $display("retention_controller_tb passed");
        $finish;
    end
endmodule
