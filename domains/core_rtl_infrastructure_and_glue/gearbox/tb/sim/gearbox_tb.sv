module gearbox_tb;
    reg clk;
    reg rst_n;

    reg bypass_s_valid;
    wire bypass_s_ready;
    reg [9:0] bypass_s_data;
    reg [1:0] bypass_s_keep;
    reg bypass_s_last;
    reg bypass_flush;
    wire bypass_m_valid;
    reg bypass_m_ready;
    wire [9:0] bypass_m_data;
    wire [1:0] bypass_m_keep;
    wire bypass_m_last;
    wire bypass_busy;

    reg widen_s_valid;
    wire widen_s_ready;
    reg [7:0] widen_s_data;
    reg [1:0] widen_s_keep;
    reg widen_s_last;
    reg widen_flush;
    wire widen_m_valid;
    reg widen_m_ready;
    wire [11:0] widen_m_data;
    wire [2:0] widen_m_keep;
    wire widen_m_last;
    wire widen_busy;

    reg narrow_s_valid;
    wire narrow_s_ready;
    reg [29:0] narrow_s_data;
    reg [4:0] narrow_s_keep;
    reg narrow_s_last;
    reg narrow_flush;
    wire narrow_m_valid;
    reg narrow_m_ready;
    wire [11:0] narrow_m_data;
    wire [1:0] narrow_m_keep;
    wire narrow_m_last;
    wire narrow_busy;

    gearbox #(
        .SYMBOL_WIDTH(5),
        .IN_SYMBOLS(2),
        .OUT_SYMBOLS(2),
        .LAST_EN(1),
        .FLUSH_EN(1)
    ) bypass_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(bypass_s_valid),
        .s_ready(bypass_s_ready),
        .s_data(bypass_s_data),
        .s_keep(bypass_s_keep),
        .s_last(bypass_s_last),
        .flush(bypass_flush),
        .m_valid(bypass_m_valid),
        .m_ready(bypass_m_ready),
        .m_data(bypass_m_data),
        .m_keep(bypass_m_keep),
        .m_last(bypass_m_last),
        .busy(bypass_busy)
    );

    gearbox #(
        .SYMBOL_WIDTH(4),
        .IN_SYMBOLS(2),
        .OUT_SYMBOLS(3),
        .LAST_EN(1),
        .FLUSH_EN(1)
    ) widen_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(widen_s_valid),
        .s_ready(widen_s_ready),
        .s_data(widen_s_data),
        .s_keep(widen_s_keep),
        .s_last(widen_s_last),
        .flush(widen_flush),
        .m_valid(widen_m_valid),
        .m_ready(widen_m_ready),
        .m_data(widen_m_data),
        .m_keep(widen_m_keep),
        .m_last(widen_m_last),
        .busy(widen_busy)
    );

    gearbox #(
        .SYMBOL_WIDTH(6),
        .IN_SYMBOLS(5),
        .OUT_SYMBOLS(2),
        .LAST_EN(1),
        .FLUSH_EN(1)
    ) narrow_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(narrow_s_valid),
        .s_ready(narrow_s_ready),
        .s_data(narrow_s_data),
        .s_keep(narrow_s_keep),
        .s_last(narrow_s_last),
        .flush(narrow_flush),
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
            $display("GEARBOX_TB_FAIL %0s", message);
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
        bypass_s_data = 10'd0;
        bypass_s_keep = 2'b00;
        bypass_s_last = 1'b0;
        bypass_flush = 1'b0;
        bypass_m_ready = 1'b0;

        widen_s_valid = 1'b0;
        widen_s_data = 8'h00;
        widen_s_keep = 2'b00;
        widen_s_last = 1'b0;
        widen_flush = 1'b0;
        widen_m_ready = 1'b0;

        narrow_s_valid = 1'b0;
        narrow_s_data = 30'd0;
        narrow_s_keep = 5'b00000;
        narrow_s_last = 1'b0;
        narrow_flush = 1'b0;
        narrow_m_ready = 1'b0;

        repeat (3) begin
            @(negedge clk);
            if (bypass_m_valid !== 1'b0 || widen_m_valid !== 1'b0 || narrow_m_valid !== 1'b0) begin
                fail("all outputs must stay idle during reset");
            end
            if (bypass_busy !== 1'b0 || widen_busy !== 1'b0 || narrow_busy !== 1'b0) begin
                fail("busy must stay low during reset");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        bypass_s_valid = 1'b1;
        bypass_s_data = {5'd9, 5'd7};
        bypass_s_keep = 2'b11;
        bypass_s_last = 1'b1;
        bypass_m_ready = 1'b1;
        #1;
        if (bypass_s_ready !== 1'b1) begin
            fail("bypass path should be ready when downstream is ready");
        end
        step_clock();
        if (bypass_m_valid !== 1'b1) begin
            fail("bypass path should produce output immediately");
        end
        if (bypass_m_data !== {5'd9, 5'd7} || bypass_m_keep !== 2'b11 || bypass_m_last !== 1'b1) begin
            fail("bypass output mismatch");
        end

        @(negedge clk);
        bypass_s_valid = 1'b0;
        bypass_m_ready = 1'b0;
        step_clock();

        @(negedge clk);
        widen_s_valid = 1'b1;
        widen_s_data = 8'h21;
        widen_s_keep = 2'b11;
        widen_s_last = 1'b0;
        widen_flush = 1'b0;
        widen_m_ready = 1'b0;
        #1;
        if (widen_s_ready !== 1'b1) begin
            fail("widen path should accept first beat");
        end
        step_clock();
        if (widen_busy !== 1'b1) begin
            fail("widen path should report buffered state after first beat");
        end

        @(negedge clk);
        widen_s_data = 8'h43;
        widen_s_keep = 2'b11;
        #1;
        if (widen_s_ready !== 1'b0) begin
            fail("widen path should preflush before accepting an overflowing beat");
        end
        step_clock();
        if (widen_m_valid !== 1'b1) begin
            fail("widen path should emit a preflush output");
        end
        if (widen_m_data !== 12'h021 || widen_m_keep !== 3'b011 || widen_m_last !== 1'b0) begin
            fail("widen preflush output mismatch");
        end

        @(negedge clk);
        widen_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        widen_m_ready = 1'b0;
        #1;
        if (widen_s_ready !== 1'b1) begin
            fail("widen path should accept the held overflowing beat after preflush");
        end
        step_clock();

        @(negedge clk);
        widen_s_data = 8'h05;
        widen_s_keep = 2'b01;
        widen_s_last = 1'b1;
        #1;
        if (widen_s_ready !== 1'b1) begin
            fail("widen path should accept a final partial beat");
        end
        step_clock();
        if (widen_m_valid !== 1'b1) begin
            fail("widen path should emit the completed packet");
        end
        if (widen_m_data !== 12'h543 || widen_m_keep !== 3'b111 || widen_m_last !== 1'b1) begin
            fail("widen final packet mismatch");
        end

        @(negedge clk);
        widen_s_valid = 1'b0;
        widen_s_last = 1'b0;
        widen_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        widen_s_valid = 1'b1;
        widen_s_data = 8'h0a;
        widen_s_keep = 2'b01;
        widen_s_last = 1'b0;
        widen_m_ready = 1'b0;
        step_clock();

        @(negedge clk);
        widen_s_valid = 1'b0;
        widen_flush = 1'b1;
        #1;
        if (widen_s_ready !== 1'b1) begin
            fail("flush should not block the already idle source side");
        end
        step_clock();
        if (widen_m_valid !== 1'b1) begin
            fail("standalone flush should emit buffered partial state");
        end
        if (widen_m_data !== 12'h00a || widen_m_keep !== 3'b001 || widen_m_last !== 1'b1) begin
            fail("standalone flush output mismatch");
        end

        @(negedge clk);
        widen_flush = 1'b0;
        widen_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        narrow_s_valid = 1'b1;
        narrow_s_data = {6'd5, 6'd4, 6'd3, 6'd2, 6'd1};
        narrow_s_keep = 5'b10101;
        narrow_s_last = 1'b1;
        narrow_flush = 1'b0;
        narrow_m_ready = 1'b0;
        #1;
        if (narrow_s_ready !== 1'b1) begin
            fail("narrow path should accept one wide beat when idle");
        end
        step_clock();
        if (narrow_m_valid !== 1'b1) begin
            fail("narrow path should present the first output slice");
        end
        if (narrow_m_data !== {6'd3, 6'd1} || narrow_m_keep !== 2'b11 || narrow_m_last !== 1'b0) begin
            fail("narrow first slice mismatch");
        end
        if (narrow_s_ready !== 1'b0) begin
            fail("narrow path should stall upstream while slices remain");
        end

        @(negedge clk);
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_m_valid !== 1'b1) begin
            fail("narrow path should advance to the second slice");
        end
        if (narrow_m_data !== {6'd0, 6'd5} || narrow_m_keep !== 2'b01 || narrow_m_last !== 1'b1) begin
            fail("narrow second slice mismatch");
        end

        @(negedge clk);
        narrow_s_valid = 1'b0;
        narrow_m_ready = 1'b1;
        step_clock();
        if (narrow_busy !== 1'b0) begin
            fail("narrow path should return idle after all slices drain");
        end

        $display("GEARBOX_TB_PASS");
        $finish;
    end
endmodule
