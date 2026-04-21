`timescale 1ns/1ps

module pulse_synchronizer_tb;
    localparam integer TARGET_ACCEPTED = 120;

    reg src_clk;
    reg dst_clk;
    reg src_rst_n;
    reg dst_rst_n;
    reg src_pulse;
    wire src_busy;
    wire dst_pulse;

    integer accepted_count;
    integer delivered_count;
    integer ignored_busy_count;
    integer failures;
    integer random_seed;
    integer rnd_value;
    reg prev_dst_pulse;

    pulse_synchronizer #(
        .SYNC_STAGES(2)
    ) dut (
        .src_clk(src_clk),
        .src_rst_n(src_rst_n),
        .src_pulse(src_pulse),
        .src_busy(src_busy),
        .dst_clk(dst_clk),
        .dst_rst_n(dst_rst_n),
        .dst_pulse(dst_pulse)
    );

    initial begin
        src_clk = 1'b0;
        forever #2 src_clk = ~src_clk;
    end

    initial begin
        dst_clk = 1'b0;
        #1;
        forever #5 dst_clk = ~dst_clk;
    end

    initial begin
        src_rst_n = 1'b0;
        dst_rst_n = 1'b0;
        src_pulse = 1'b0;
        accepted_count = 0;
        delivered_count = 0;
        ignored_busy_count = 0;
        failures = 0;
        random_seed = 32'h02468ace;
        prev_dst_pulse = 1'b0;

        repeat (3) @(posedge src_clk);
        src_rst_n = 1'b1;
        repeat (2) @(posedge dst_clk);
        dst_rst_n = 1'b1;

        wait (accepted_count >= TARGET_ACCEPTED);
        wait (delivered_count == accepted_count);
        repeat (8) @(posedge dst_clk);

        if (ignored_busy_count == 0) begin
            $display("PULSE_TB_FAIL expected at least one source pulse while busy");
            failures = failures + 1;
        end
        if (failures != 0) begin
            $display("PULSE_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "PULSE_SYNCHRONIZER_TB_PASS accepted=%0d delivered=%0d ignored_busy=%0d",
            accepted_count,
            delivered_count,
            ignored_busy_count
        );
        $finish;
    end

    initial begin
        #120000;
        $display(
            "PULSE_TB_FAIL timeout accepted=%0d delivered=%0d busy=%0b",
            accepted_count,
            delivered_count,
            src_busy
        );
        $finish_and_return(1);
    end

    always @(negedge src_clk) begin
        if (!src_rst_n) begin
            src_pulse <= 1'b0;
        end
        else begin
            rnd_value = $urandom(random_seed);
            if ((rnd_value % 100) < 35) begin
                src_pulse <= 1'b1;
            end
            else begin
                src_pulse <= 1'b0;
            end
        end
    end

    always @(posedge src_clk) begin
        if (!src_rst_n) begin
            if (src_busy !== 1'b0) begin
                $display("PULSE_TB_FAIL src_busy asserted during source reset at time %0t", $time);
                failures = failures + 1;
            end
        end
        else begin
            if (src_pulse && !src_busy) begin
                accepted_count = accepted_count + 1;
            end
            if (src_pulse && src_busy) begin
                ignored_busy_count = ignored_busy_count + 1;
            end
        end
    end

    always @(posedge dst_clk) begin
        if (!dst_rst_n) begin
            if (dst_pulse !== 1'b0) begin
                $display("PULSE_TB_FAIL dst_pulse asserted during destination reset at time %0t", $time);
                failures = failures + 1;
            end
            prev_dst_pulse <= 1'b0;
        end
        else begin
            if (dst_pulse) begin
                delivered_count = delivered_count + 1;
            end
            if (prev_dst_pulse && dst_pulse) begin
                $display("PULSE_TB_FAIL dst_pulse wider than one cycle at time %0t", $time);
                failures = failures + 1;
            end
            if (delivered_count > accepted_count) begin
                $display("PULSE_TB_FAIL delivered more pulses than accepted at time %0t", $time);
                failures = failures + 1;
            end
            prev_dst_pulse <= dst_pulse;
        end
    end
endmodule
