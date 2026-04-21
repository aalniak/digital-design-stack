module skid_buffer_tb;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 3;
    localparam integer TOTAL_BEATS = 80;

    reg clk;
    reg rst_n;

    reg bypass_s_valid;
    wire bypass_s_ready;
    reg [DATA_WIDTH-1:0] bypass_s_data;
    reg [SIDEBAND_WIDTH-1:0] bypass_s_sideband;
    wire bypass_m_valid;
    reg bypass_m_ready;
    wire [DATA_WIDTH-1:0] bypass_m_data;
    wire [SIDEBAND_WIDTH-1:0] bypass_m_sideband;

    reg skid_s_valid;
    wire skid_s_ready;
    reg [DATA_WIDTH-1:0] skid_s_data;
    reg [SIDEBAND_WIDTH-1:0] skid_s_sideband;
    wire skid_m_valid;
    reg skid_m_ready;
    wire [DATA_WIDTH-1:0] skid_m_data;
    wire [SIDEBAND_WIDTH-1:0] skid_m_sideband;

    reg deep_s_valid;
    wire deep_s_ready;
    reg [DATA_WIDTH-1:0] deep_s_data;
    reg [SIDEBAND_WIDTH-1:0] deep_s_sideband;
    wire deep_m_valid;
    reg deep_m_ready;
    wire [DATA_WIDTH-1:0] deep_m_data;
    wire [SIDEBAND_WIDTH-1:0] deep_m_sideband;

    reg [DATA_WIDTH+SIDEBAND_WIDTH-1:0] bypass_expected [0:255];
    reg [DATA_WIDTH+SIDEBAND_WIDTH-1:0] skid_expected [0:255];
    reg [DATA_WIDTH+SIDEBAND_WIDTH-1:0] deep_expected [0:255];

    integer bypass_wr_ptr;
    integer bypass_rd_ptr;
    integer skid_wr_ptr;
    integer skid_rd_ptr;
    integer deep_wr_ptr;
    integer deep_rd_ptr;

    integer bypass_send_count;
    integer bypass_recv_count;
    integer skid_send_count;
    integer skid_recv_count;
    integer deep_send_count;
    integer deep_recv_count;

    reg prev_skid_valid;
    reg prev_skid_ready;
    reg [DATA_WIDTH-1:0] prev_skid_data;
    reg [SIDEBAND_WIDTH-1:0] prev_skid_sideband;

    skid_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .DEPTH(0)
    ) bypass_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(bypass_s_valid),
        .s_ready(bypass_s_ready),
        .s_data(bypass_s_data),
        .s_sideband(bypass_s_sideband),
        .m_valid(bypass_m_valid),
        .m_ready(bypass_m_ready),
        .m_data(bypass_m_data),
        .m_sideband(bypass_m_sideband)
    );

    skid_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .DEPTH(1)
    ) skid_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(skid_s_valid),
        .s_ready(skid_s_ready),
        .s_data(skid_s_data),
        .s_sideband(skid_s_sideband),
        .m_valid(skid_m_valid),
        .m_ready(skid_m_ready),
        .m_data(skid_m_data),
        .m_sideband(skid_m_sideband)
    );

    skid_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .DEPTH(2)
    ) deep_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(deep_s_valid),
        .s_ready(deep_s_ready),
        .s_data(deep_s_data),
        .s_sideband(deep_s_sideband),
        .m_valid(deep_m_valid),
        .m_ready(deep_m_ready),
        .m_data(deep_m_data),
        .m_sideband(deep_m_sideband)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("SKID_BUFFER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic check_reset_state;
        begin
            if (bypass_m_valid !== 1'b0) begin
                fail("bypass output valid should be low during reset");
            end
            if (skid_m_valid !== 1'b0) begin
                fail("skid output valid should be low during reset");
            end
            if (deep_m_valid !== 1'b0) begin
                fail("deep output valid should be low during reset");
            end
        end
    endtask

    task automatic run_directed_skid_sequence;
        begin
            @(negedge clk);
            skid_s_valid = 1'b1;
            skid_s_data = 8'h11;
            skid_s_sideband = 3'h1;
            skid_m_ready = 1'b1;
            @(posedge clk);

            @(negedge clk);
            skid_s_valid = 1'b1;
            skid_s_data = 8'h22;
            skid_s_sideband = 3'h2;
            skid_m_ready = 1'b0;
            if (skid_s_ready !== 1'b1) begin
                fail("first late-stall cycle must still accept the beat");
            end
            @(posedge clk);

            @(negedge clk);
            skid_s_valid = 1'b1;
            skid_s_data = 8'h33;
            skid_s_sideband = 3'h3;
            skid_m_ready = 1'b0;
            if (skid_m_valid !== 1'b1) begin
                fail("stored skid beat should remain visible while stalled");
            end
            if (skid_m_data !== 8'h22 || skid_m_sideband !== 3'h2) begin
                fail("stored skid beat contents changed while stalled");
            end
            if (skid_s_ready !== 1'b0) begin
                fail("source must be backpressured once skid storage is occupied");
            end
            @(posedge clk);

            @(negedge clk);
            skid_s_valid = 1'b1;
            skid_s_data = 8'h33;
            skid_s_sideband = 3'h3;
            skid_m_ready = 1'b1;
            @(posedge clk);

            @(negedge clk);
            skid_s_valid = 1'b0;
            skid_s_data = {DATA_WIDTH{1'b0}};
            skid_s_sideband = {SIDEBAND_WIDTH{1'b0}};
            skid_m_ready = 1'b1;
            if (skid_m_valid !== 1'b1) begin
                fail("replacement beat should remain available after drain-and-refill");
            end
            if (skid_m_data !== 8'h33 || skid_m_sideband !== 3'h3) begin
                fail("replacement beat mismatch after drain-and-refill");
            end
            @(posedge clk);

            @(negedge clk);
            skid_s_valid = 1'b0;
            skid_m_ready = 1'b1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        bypass_s_valid = 1'b0;
        bypass_s_data = {DATA_WIDTH{1'b0}};
        bypass_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        bypass_m_ready = 1'b0;

        skid_s_valid = 1'b0;
        skid_s_data = {DATA_WIDTH{1'b0}};
        skid_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        skid_m_ready = 1'b0;

        deep_s_valid = 1'b0;
        deep_s_data = {DATA_WIDTH{1'b0}};
        deep_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        deep_m_ready = 1'b0;

        bypass_wr_ptr = 0;
        bypass_rd_ptr = 0;
        skid_wr_ptr = 0;
        skid_rd_ptr = 0;
        deep_wr_ptr = 0;
        deep_rd_ptr = 0;

        bypass_send_count = 0;
        bypass_recv_count = 0;
        skid_send_count = 0;
        skid_recv_count = 0;
        deep_send_count = 0;
        deep_recv_count = 0;

        prev_skid_valid = 1'b0;
        prev_skid_ready = 1'b0;
        prev_skid_data = {DATA_WIDTH{1'b0}};
        prev_skid_sideband = {SIDEBAND_WIDTH{1'b0}};

        repeat (3) begin
            @(negedge clk);
            check_reset_state();
        end

        @(negedge clk);
        rst_n = 1'b1;

        run_directed_skid_sequence();

        bypass_s_valid = 1'b0;
        bypass_s_data = {DATA_WIDTH{1'b0}};
        bypass_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        bypass_m_ready = 1'b0;

        skid_s_valid = 1'b0;
        skid_s_data = {DATA_WIDTH{1'b0}};
        skid_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        skid_m_ready = 1'b0;

        deep_s_valid = 1'b0;
        deep_s_data = {DATA_WIDTH{1'b0}};
        deep_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        deep_m_ready = 1'b0;

        repeat (500) begin
            @(negedge clk);

            bypass_m_ready = ($random & 32'h1);
            skid_m_ready = ($random & 32'h1);
            deep_m_ready = ($random & 32'h1);

            if (bypass_send_count < TOTAL_BEATS) begin
                bypass_s_valid = ($random & 32'h3) != 0;
                bypass_s_data = bypass_send_count[DATA_WIDTH-1:0] ^ 8'h52;
                bypass_s_sideband = bypass_send_count[SIDEBAND_WIDTH-1:0];
            end
            else begin
                bypass_s_valid = 1'b0;
            end

            if (skid_send_count < TOTAL_BEATS) begin
                skid_s_valid = ($random & 32'h3) != 0;
                skid_s_data = skid_send_count[DATA_WIDTH-1:0] ^ 8'h35;
                skid_s_sideband = skid_send_count + 3;
            end
            else begin
                skid_s_valid = 1'b0;
            end

            if (deep_send_count < TOTAL_BEATS) begin
                deep_s_valid = ($random & 32'h3) != 0;
                deep_s_data = deep_send_count[DATA_WIDTH-1:0] ^ 8'h79;
                deep_s_sideband = deep_send_count + 5;
            end
            else begin
                deep_s_valid = 1'b0;
            end

            @(posedge clk);

            if (bypass_s_valid && bypass_s_ready) begin
                bypass_expected[bypass_wr_ptr] = {bypass_s_sideband, bypass_s_data};
                bypass_wr_ptr = bypass_wr_ptr + 1;
                bypass_send_count = bypass_send_count + 1;
            end

            if (skid_s_valid && skid_s_ready) begin
                skid_expected[skid_wr_ptr] = {skid_s_sideband, skid_s_data};
                skid_wr_ptr = skid_wr_ptr + 1;
                skid_send_count = skid_send_count + 1;
            end

            if (deep_s_valid && deep_s_ready) begin
                deep_expected[deep_wr_ptr] = {deep_s_sideband, deep_s_data};
                deep_wr_ptr = deep_wr_ptr + 1;
                deep_send_count = deep_send_count + 1;
            end

            if (prev_skid_valid && !prev_skid_ready) begin
                if (!skid_m_valid) begin
                    fail("skid output valid dropped while stalled");
                end
                if (skid_m_data !== prev_skid_data || skid_m_sideband !== prev_skid_sideband) begin
                    fail("skid output changed while stalled");
                end
            end

            if (bypass_m_valid && bypass_m_ready) begin
                if ({bypass_m_sideband, bypass_m_data} !== bypass_expected[bypass_rd_ptr]) begin
                    fail("bypass output ordering mismatch");
                end
                bypass_rd_ptr = bypass_rd_ptr + 1;
                bypass_recv_count = bypass_recv_count + 1;
            end

            if (skid_m_valid && skid_m_ready) begin
                if ({skid_m_sideband, skid_m_data} !== skid_expected[skid_rd_ptr]) begin
                    fail("skid output ordering mismatch");
                end
                skid_rd_ptr = skid_rd_ptr + 1;
                skid_recv_count = skid_recv_count + 1;
            end

            if (deep_m_valid && deep_m_ready) begin
                if ({deep_m_sideband, deep_m_data} !== deep_expected[deep_rd_ptr]) begin
                    fail("deep output ordering mismatch");
                end
                deep_rd_ptr = deep_rd_ptr + 1;
                deep_recv_count = deep_recv_count + 1;
            end

            prev_skid_valid = skid_m_valid;
            prev_skid_ready = skid_m_ready;
            prev_skid_data = skid_m_data;
            prev_skid_sideband = skid_m_sideband;

            if (bypass_recv_count == TOTAL_BEATS &&
                skid_recv_count == TOTAL_BEATS &&
                deep_recv_count == TOTAL_BEATS) begin
                $display(
                    "SKID_BUFFER_TB_PASS bypass_sent=%0d bypass_recv=%0d skid_sent=%0d skid_recv=%0d deep_sent=%0d deep_recv=%0d",
                    bypass_send_count,
                    bypass_recv_count,
                    skid_send_count,
                    skid_recv_count,
                    deep_send_count,
                    deep_recv_count
                );
                $finish;
            end
        end

        fail("simulation timed out before all beats drained");
    end
endmodule
