`timescale 1ns/1ps

module glitchless_clock_switch_tb;
    reg clk_a;
    reg clk_b;
    reg rst_n;
    reg select_req;
    wire switched_clk;
    wire active_select;
    wire active_select_valid;
    wire source_a_active;
    wire source_b_active;
    wire switch_busy;

    integer switched_edges;
    integer busy_cycles;
    integer idx;

    glitchless_clock_switch #(
        .DEFAULT_SOURCE(0),
        .STATUS_EN(1)
    ) dut (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .rst_n(rst_n),
        .select_req(select_req),
        .switched_clk(switched_clk),
        .active_select(active_select),
        .active_select_valid(active_select_valid),
        .source_a_active(source_a_active),
        .source_b_active(source_b_active),
        .switch_busy(switch_busy)
    );

    initial begin
        clk_a = 1'b0;
        forever #5 clk_a = ~clk_a;
    end

    initial begin
        clk_b = 1'b0;
        forever #7 clk_b = ~clk_b;
    end

    always @(posedge switched_clk) begin
        switched_edges = switched_edges + 1;

        if (!active_select_valid) begin
            $fatal(1, "switched clock toggled while no source ownership was valid");
        end

        if (!(source_a_active ^ source_b_active)) begin
            $fatal(1, "switched clock toggled without exactly one active source");
        end

        if (source_a_active && !clk_a) begin
            $fatal(1, "switched clock rose without clk_a being high");
        end

        if (source_b_active && !clk_b) begin
            $fatal(1, "switched clock rose without clk_b being high");
        end
    end

    task automatic wait_for_switch_complete;
        input expected_select;
        integer timeout_cycles;
        integer saw_busy;
        begin
            timeout_cycles = 0;
            saw_busy = 0;
            while (timeout_cycles < 200) begin
                @(posedge clk_a or posedge clk_b);
                timeout_cycles = timeout_cycles + 1;
                if (switch_busy) begin
                    saw_busy = 1;
                end
                if (active_select_valid && (active_select == expected_select) && !switch_busy) begin
                    if (!saw_busy) begin
                        $fatal(1, "switch to source %0d completed without busy being observed", expected_select);
                    end
                    disable wait_for_switch_complete;
                end
            end
            $fatal(1, "timeout waiting for source %0d ownership", expected_select);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        select_req = 1'b0;
        switched_edges = 0;
        busy_cycles = 0;

        #1;
        if (!source_a_active || source_b_active) begin
            $fatal(1, "reset should default to source A ownership");
        end

        repeat (4) @(posedge clk_a);
        rst_n = 1'b1;

        repeat (4) @(posedge clk_a);
        if (!active_select_valid || (active_select != 1'b0) || switch_busy) begin
            $fatal(1, "default source did not settle to source A after reset");
        end

        for (idx = 0; idx < 20; idx = idx + 1) begin
            @(posedge clk_a or posedge clk_b);
            if (switch_busy) begin
                busy_cycles = busy_cycles + 1;
            end
        end

        if (busy_cycles != 0) begin
            $fatal(1, "switch_busy should stay low while the selected source remains unchanged");
        end

        select_req = 1'b1;
        wait_for_switch_complete(1'b1);

        repeat (6) @(posedge clk_b);
        if (!source_b_active || source_a_active) begin
            $fatal(1, "source B should own the output after switching to source B");
        end

        select_req = 1'b0;
        wait_for_switch_complete(1'b0);

        repeat (6) @(posedge clk_a);
        if (!source_a_active || source_b_active) begin
            $fatal(1, "source A should own the output after switching back to source A");
        end

        if (switched_edges < 12) begin
            $fatal(1, "expected switched clock to toggle multiple times during the test");
        end

        $display("glitchless_clock_switch_tb passed");
        $finish;
    end
endmodule
