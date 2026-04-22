module width_converter_tb;
    reg clk;
    reg rst_n;

    reg bypass_s_valid;
    wire bypass_s_ready;
    reg [15:0] bypass_s_data;
    reg [1:0] bypass_s_keep;
    reg bypass_s_last;
    wire bypass_m_valid;
    reg bypass_m_ready;
    wire [15:0] bypass_m_data;
    wire [1:0] bypass_m_keep;
    wire bypass_m_last;
    wire bypass_busy;

    reg widen_s_valid;
    wire widen_s_ready;
    reg [7:0] widen_s_data;
    reg [0:0] widen_s_keep;
    reg widen_s_last;
    wire widen_m_valid;
    reg widen_m_ready;
    wire [31:0] widen_m_data;
    wire [3:0] widen_m_keep;
    wire widen_m_last;
    wire widen_busy;

    reg narrow_s_valid;
    wire narrow_s_ready;
    reg [31:0] narrow_s_data;
    reg [3:0] narrow_s_keep;
    reg narrow_s_last;
    wire narrow_m_valid;
    reg narrow_m_ready;
    wire [7:0] narrow_m_data;
    wire [0:0] narrow_m_keep;
    wire narrow_m_last;
    wire narrow_busy;

    width_converter #(
        .IN_BYTES(2),
        .OUT_BYTES(2)
    ) bypass_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(bypass_s_valid),
        .s_ready(bypass_s_ready),
        .s_data(bypass_s_data),
        .s_keep(bypass_s_keep),
        .s_last(bypass_s_last),
        .m_valid(bypass_m_valid),
        .m_ready(bypass_m_ready),
        .m_data(bypass_m_data),
        .m_keep(bypass_m_keep),
        .m_last(bypass_m_last),
        .busy(bypass_busy)
    );

    width_converter #(
        .IN_BYTES(1),
        .OUT_BYTES(4)
    ) widen_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(widen_s_valid),
        .s_ready(widen_s_ready),
        .s_data(widen_s_data),
        .s_keep(widen_s_keep),
        .s_last(widen_s_last),
        .m_valid(widen_m_valid),
        .m_ready(widen_m_ready),
        .m_data(widen_m_data),
        .m_keep(widen_m_keep),
        .m_last(widen_m_last),
        .busy(widen_busy)
    );

    width_converter #(
        .IN_BYTES(4),
        .OUT_BYTES(1)
    ) narrow_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(narrow_s_valid),
        .s_ready(narrow_s_ready),
        .s_data(narrow_s_data),
        .s_keep(narrow_s_keep),
        .s_last(narrow_s_last),
        .m_valid(narrow_m_valid),
        .m_ready(narrow_m_ready),
        .m_data(narrow_m_data),
        .m_keep(narrow_m_keep),
        .m_last(narrow_m_last),
        .busy(narrow_busy)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("WIDTH_CONVERTER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic step_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        bypass_s_valid = 1'b0;
        bypass_s_data = 16'h0000;
        bypass_s_keep = 2'b00;
        bypass_s_last = 1'b0;
        bypass_m_ready = 1'b0;

        widen_s_valid = 1'b0;
        widen_s_data = 8'h00;
        widen_s_keep = 1'b0;
        widen_s_last = 1'b0;
        widen_m_ready = 1'b0;

        narrow_s_valid = 1'b0;
        narrow_s_data = 32'h00000000;
        narrow_s_keep = 4'b0000;
        narrow_s_last = 1'b0;
        narrow_m_ready = 1'b0;

        repeat (3) begin
            @(negedge clk);
            if (bypass_m_valid !== 1'b0 || widen_m_valid !== 1'b0 || narrow_m_valid !== 1'b0) begin
                fail("outputs must remain idle during reset");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        bypass_s_valid = 1'b1;
        bypass_s_data = 16'hbbaa;
        bypass_s_keep = 2'b11;
        bypass_s_last = 1'b1;
        bypass_m_ready = 1'b1;
        #1;
        if (bypass_s_ready !== 1'b1) begin
            fail("bypass path should follow downstream ready");
        end
        if (bypass_m_valid !== 1'b1 || bypass_m_data !== 16'hbbaa || bypass_m_keep !== 2'b11 || bypass_m_last !== 1'b1) begin
            fail("bypass path mismatch");
        end
        step_clock();

        @(negedge clk);
        bypass_s_valid = 1'b0;
        bypass_m_ready = 1'b0;

        @(negedge clk);
        widen_s_valid = 1'b1;
        widen_s_data = 8'h11;
        widen_s_keep = 1'b1;
        widen_s_last = 1'b0;
        widen_m_ready = 1'b0;
        #1;
        if (widen_s_ready !== 1'b1) begin
            fail("widen path should accept first byte");
        end
        step_clock();

        @(negedge clk);
        widen_s_data = 8'h22;
        widen_s_last = 1'b0;
        step_clock();

        @(negedge clk);
        widen_s_data = 8'h33;
        widen_s_last = 1'b0;
        step_clock();

        @(negedge clk);
        widen_s_data = 8'h44;
        widen_s_last = 1'b1;
        step_clock();
        if (widen_m_valid !== 1'b1) begin
            fail("widen path should present a completed output word");
        end
        if (widen_m_data !== 32'h44332211 || widen_m_keep !== 4'b1111 || widen_m_last !== 1'b1) begin
            fail("widen full-group output mismatch");
        end
        if (widen_s_ready !== 1'b0) begin
            fail("widen path should stall the source while output is pending");
        end

        @(negedge clk);
        widen_s_valid = 1'b0;
        widen_m_ready = 1'b0;
        #1;
        if (widen_m_data !== 32'h44332211 || widen_m_keep !== 4'b1111 || widen_m_last !== 1'b1) begin
            fail("widen output should remain stable under stall");
        end
        step_clock();

        @(negedge clk);
        widen_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        widen_s_valid = 1'b1;
        widen_s_data = 8'haa;
        widen_s_keep = 1'b1;
        widen_s_last = 1'b0;
        widen_m_ready = 1'b0;
        step_clock();

        @(negedge clk);
        widen_s_data = 8'hbb;
        widen_s_last = 1'b1;
        step_clock();
        if (widen_m_valid !== 1'b1) begin
            fail("widen partial packet should emit on last");
        end
        if (widen_m_data !== 32'h0000bbaa || widen_m_keep !== 4'b0011 || widen_m_last !== 1'b1) begin
            fail("widen partial-group output mismatch");
        end

        @(negedge clk);
        widen_s_valid = 1'b0;
        widen_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        narrow_s_valid = 1'b1;
        narrow_s_data = 32'h44332211;
        narrow_s_keep = 4'b1111;
        narrow_s_last = 1'b1;
        narrow_m_ready = 1'b0;
        #1;
        if (narrow_s_ready !== 1'b1) begin
            fail("narrow path should accept a wide beat when idle");
        end
        step_clock();
        if (narrow_m_valid !== 1'b1 || narrow_m_data !== 8'h11 || narrow_m_keep !== 1'b1 || narrow_m_last !== 1'b0) begin
            fail("narrow first slice mismatch");
        end
        if (narrow_s_ready !== 1'b0) begin
            fail("narrow path should stall upstream while slices remain");
        end

        @(negedge clk);
        narrow_s_valid = 1'b0;
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_data !== 8'h22 || narrow_m_last !== 1'b0) begin
            fail("narrow second slice mismatch");
        end

        @(negedge clk);
        narrow_m_ready = 1'b0;
        #1;
        if (narrow_m_data !== 8'h22 || narrow_m_last !== 1'b0) begin
            fail("narrow slice should remain stable under stall");
        end
        step_clock();

        @(negedge clk);
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_data !== 8'h33 || narrow_m_last !== 1'b0) begin
            fail("narrow third slice mismatch");
        end

        @(negedge clk);
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_data !== 8'h44 || narrow_m_last !== 1'b1) begin
            fail("narrow final slice mismatch");
        end

        @(negedge clk);
        narrow_s_valid = 1'b0;
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_valid !== 1'b0 || narrow_busy !== 1'b0) begin
            fail("narrow path should return to idle after draining the full-width beat");
        end

        @(negedge clk);
        narrow_s_valid = 1'b1;
        narrow_s_data = 32'h0000bbaa;
        narrow_s_keep = 4'b0011;
        narrow_s_last = 1'b1;
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_data !== 8'haa || narrow_m_last !== 1'b0) begin
            fail("narrow partial first slice mismatch");
        end

        @(negedge clk);
        narrow_s_valid = 1'b0;
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_data !== 8'hbb || narrow_m_last !== 1'b1) begin
            fail("narrow partial final slice mismatch");
        end

        @(negedge clk);
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_valid !== 1'b0 || narrow_busy !== 1'b0) begin
            fail("narrow path should return to idle after draining");
        end

        $display("WIDTH_CONVERTER_TB_PASS");
        $finish;
    end
endmodule
