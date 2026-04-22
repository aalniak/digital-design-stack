module clock_gating_wrapper_tb;
    reg clk_in;
    reg rst_n;

    reg asic_enable_req;
    reg asic_test_bypass;
    reg asic_bypass;

    reg fpga_enable_req;
    reg fpga_test_bypass;
    reg fpga_bypass;

    reg active_low_enable_req;

    integer guard;
    integer asic_edge_count;
    integer active_low_edge_count;

    wire asic_gated_clk;
    wire asic_domain_ce;
    wire asic_gate_open;
    wire asic_override_active;

    wire fpga_gated_clk;
    wire fpga_domain_ce;
    wire fpga_gate_open;
    wire fpga_override_active;

    wire active_low_gated_clk;
    wire active_low_domain_ce;
    wire active_low_gate_open;
    wire active_low_override_active;

    clock_gating_wrapper #(
        .DEFAULT_ENABLE(0),
        .ACTIVE_HIGH_ENABLE(1),
        .TEST_BYPASS_EN(1),
        .BYPASS_EN(1),
        .FPGA_SAFE_MODE(0),
        .ENABLE_SYNC_STAGES(2)
    ) asic_dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .enable_req(asic_enable_req),
        .test_bypass(asic_test_bypass),
        .bypass(asic_bypass),
        .gated_clk(asic_gated_clk),
        .domain_ce(asic_domain_ce),
        .gate_open(asic_gate_open),
        .override_active(asic_override_active)
    );

    clock_gating_wrapper #(
        .DEFAULT_ENABLE(0),
        .ACTIVE_HIGH_ENABLE(1),
        .TEST_BYPASS_EN(1),
        .BYPASS_EN(1),
        .FPGA_SAFE_MODE(1),
        .ENABLE_SYNC_STAGES(2)
    ) fpga_dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .enable_req(fpga_enable_req),
        .test_bypass(fpga_test_bypass),
        .bypass(fpga_bypass),
        .gated_clk(fpga_gated_clk),
        .domain_ce(fpga_domain_ce),
        .gate_open(fpga_gate_open),
        .override_active(fpga_override_active)
    );

    clock_gating_wrapper #(
        .DEFAULT_ENABLE(0),
        .ACTIVE_HIGH_ENABLE(0),
        .TEST_BYPASS_EN(0),
        .BYPASS_EN(0),
        .FPGA_SAFE_MODE(0),
        .ENABLE_SYNC_STAGES(0)
    ) active_low_dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .enable_req(active_low_enable_req),
        .test_bypass(1'b0),
        .bypass(1'b0),
        .gated_clk(active_low_gated_clk),
        .domain_ce(active_low_domain_ce),
        .gate_open(active_low_gate_open),
        .override_active(active_low_override_active)
    );

    always #5 clk_in = ~clk_in;

    always @(posedge asic_gated_clk) begin
        if (rst_n) begin
            asic_edge_count = asic_edge_count + 1;
        end
    end

    always @(posedge active_low_gated_clk) begin
        if (rst_n) begin
            active_low_edge_count = active_low_edge_count + 1;
        end
    end

    always @(asic_gate_open) begin
        if (rst_n && (clk_in !== 1'b0)) begin
            fail("ASIC gate_open changed while source clock was high");
        end
    end

    always @(fpga_gate_open) begin
        if (rst_n && (clk_in !== 1'b0)) begin
            fail("FPGA-safe gate_open changed while source clock was high");
        end
    end

    always @(active_low_gate_open) begin
        if (rst_n && (clk_in !== 1'b0)) begin
            fail("active-low gate_open changed while source clock was high");
        end
    end

    always @(clk_in or fpga_gated_clk) begin
        if (fpga_gated_clk !== clk_in) begin
            fail("FPGA safe mode must leave gated_clk equal to clk_in");
        end
    end

    task automatic fail;
        input [1023:0] message;
        begin
            $display("CLOCK_GATING_WRAPPER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic step_clk;
        begin
            @(posedge clk_in);
            #1;
        end
    endtask

    task automatic wait_clk_cycles;
        input integer count;
        integer idx;
        begin
            for (idx = 0; idx < count; idx = idx + 1) begin
                step_clk();
            end
        end
    endtask

`define WAIT_FOR_HIGH(signal_name, max_cycles, message_text) \
    begin \
        guard = 0; \
        while (((signal_name) !== 1'b1) && (guard < (max_cycles))) begin \
            step_clk(); \
            guard = guard + 1; \
        end \
        if ((signal_name) !== 1'b1) begin \
            fail(message_text); \
        end \
    end

`define WAIT_FOR_LOW(signal_name, max_cycles, message_text) \
    begin \
        guard = 0; \
        while (((signal_name) !== 1'b0) && (guard < (max_cycles))) begin \
            step_clk(); \
            guard = guard + 1; \
        end \
        if ((signal_name) !== 1'b0) begin \
            fail(message_text); \
        end \
    end

    initial begin
        clk_in = 1'b0;
        rst_n = 1'b0;
        asic_enable_req = 1'b0;
        asic_test_bypass = 1'b0;
        asic_bypass = 1'b0;
        fpga_enable_req = 1'b0;
        fpga_test_bypass = 1'b0;
        fpga_bypass = 1'b0;
        active_low_enable_req = 1'b1;
        asic_edge_count = 0;
        active_low_edge_count = 0;

        wait_clk_cycles(3);
        if (asic_gate_open !== 1'b0 || asic_domain_ce !== 1'b0 || asic_override_active !== 1'b0) begin
            fail("ASIC-style wrapper must reset closed without override");
        end
        if (active_low_gate_open !== 1'b0 || active_low_domain_ce !== 1'b0 || active_low_override_active !== 1'b0) begin
            fail("active-low wrapper must reset closed without override");
        end

        @(negedge clk_in);
        #1;
        rst_n = 1'b1;

        wait_clk_cycles(2);
        if (asic_gate_open !== 1'b0 || asic_domain_ce !== 1'b0) begin
            fail("ASIC-style wrapper should remain closed before enable request");
        end
        if (asic_gated_clk !== 1'b0) begin
            fail("ASIC-style gated clock must stay low while closed");
        end
        if (fpga_gate_open !== 1'b0 || fpga_domain_ce !== 1'b0) begin
            fail("FPGA-safe wrapper should remain closed before enable request");
        end

        @(negedge clk_in);
        #1;
        asic_enable_req = 1'b1;
        fpga_enable_req = 1'b1;

        `WAIT_FOR_HIGH(asic_gate_open, 6, "ASIC-style wrapper did not open after enable request");
        `WAIT_FOR_HIGH(fpga_gate_open, 6, "FPGA-safe wrapper did not open after enable request");
        if (asic_domain_ce !== 1'b1 || fpga_domain_ce !== 1'b1) begin
            fail("domain_ce should follow accepted gate-open state");
        end

        guard = asic_edge_count;
        wait_clk_cycles(3);
        if (asic_edge_count <= guard) begin
            fail("ASIC-style gated clock must toggle while gate is open");
        end

        @(negedge clk_in);
        #1;
        asic_enable_req = 1'b0;
        fpga_enable_req = 1'b0;

        `WAIT_FOR_LOW(asic_gate_open, 6, "ASIC-style wrapper did not close after enable removal");
        `WAIT_FOR_LOW(fpga_gate_open, 6, "FPGA-safe wrapper did not close after enable removal");
        guard = asic_edge_count;
        wait_clk_cycles(3);
        if (asic_edge_count != guard) begin
            fail("ASIC-style gated clock must stop toggling while gate is closed");
        end
        if (fpga_domain_ce !== 1'b0) begin
            fail("FPGA-safe domain_ce must deassert when gate is closed");
        end

        @(negedge clk_in);
        #1;
        asic_test_bypass = 1'b1;
        fpga_test_bypass = 1'b1;

        `WAIT_FOR_HIGH(asic_gate_open, 3, "test bypass did not reopen ASIC-style wrapper");
        `WAIT_FOR_HIGH(fpga_gate_open, 3, "test bypass did not reopen FPGA-safe wrapper");
        if (asic_override_active !== 1'b1 || fpga_override_active !== 1'b1) begin
            fail("override_active must assert during test bypass request");
        end

        @(negedge clk_in);
        #1;
        asic_test_bypass = 1'b0;
        fpga_test_bypass = 1'b0;

        `WAIT_FOR_LOW(asic_gate_open, 3, "ASIC-style wrapper did not close after test bypass cleared");
        `WAIT_FOR_LOW(fpga_gate_open, 3, "FPGA-safe wrapper did not close after test bypass cleared");

        @(negedge clk_in);
        #1;
        asic_bypass = 1'b1;
        fpga_bypass = 1'b1;

        `WAIT_FOR_HIGH(asic_gate_open, 3, "functional bypass did not reopen ASIC-style wrapper");
        `WAIT_FOR_HIGH(fpga_gate_open, 3, "functional bypass did not reopen FPGA-safe wrapper");
        if (asic_override_active !== 1'b1 || fpga_override_active !== 1'b1) begin
            fail("override_active must assert during functional bypass request");
        end

        @(negedge clk_in);
        #1;
        asic_bypass = 1'b0;
        fpga_bypass = 1'b0;

        `WAIT_FOR_LOW(asic_gate_open, 3, "ASIC-style wrapper did not close after functional bypass cleared");
        `WAIT_FOR_LOW(fpga_gate_open, 3, "FPGA-safe wrapper did not close after functional bypass cleared");

        @(negedge clk_in);
        #1;
        active_low_enable_req = 1'b0;
        `WAIT_FOR_HIGH(active_low_gate_open, 3, "active-low enable request did not open gate");
        guard = active_low_edge_count;
        wait_clk_cycles(2);
        if (active_low_edge_count <= guard) begin
            fail("active-low instance should toggle while open");
        end

        @(negedge clk_in);
        #1;
        active_low_enable_req = 1'b1;
        `WAIT_FOR_LOW(active_low_gate_open, 3, "active-low enable request did not close gate");

        $display("CLOCK_GATING_WRAPPER_TB_PASS");
        $finish;
    end
endmodule
