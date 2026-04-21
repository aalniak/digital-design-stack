module stream_fifo_tb;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 3;
    localparam integer DEPTH = 4;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);
    localparam integer TOTAL_BEATS = 80;
    localparam integer ALMOST_FULL_THRESHOLD = DEPTH - 1;
    localparam integer ALMOST_EMPTY_THRESHOLD = 1;
    localparam integer PAYLOAD_WIDTH = DATA_WIDTH + SIDEBAND_WIDTH;

    reg clk;
    reg rst_n;
    reg s_valid;
    wire s_ready;
    reg [DATA_WIDTH-1:0] s_data;
    reg [SIDEBAND_WIDTH-1:0] s_sideband;
    wire m_valid;
    reg m_ready;
    wire [DATA_WIDTH-1:0] m_data;
    wire [SIDEBAND_WIDTH-1:0] m_sideband;
    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    wire [COUNT_WIDTH-1:0] occupancy;
    wire overflow;

    reg [PAYLOAD_WIDTH-1:0] expected [0:255];
    integer expected_wr_ptr;
    integer expected_rd_ptr;
    integer expected_count;
    integer send_count;
    integer recv_count;
    integer idx;
    integer cycle;
    reg [PAYLOAD_WIDTH-1:0] observed_word;
    reg [PAYLOAD_WIDTH-1:0] expected_word;
    integer expected_after;

    stream_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
        .OUTPUT_REG(0),
        .COUNT_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_sideband(s_sideband),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_sideband(m_sideband),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .occupancy(occupancy),
        .overflow(overflow)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("STREAM_FIFO_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic check_state;
        input integer expected_level;
        begin
            if (occupancy !== expected_level[COUNT_WIDTH-1:0]) begin
                fail("occupancy mismatch");
            end
            if (full !== (expected_level == DEPTH)) begin
                fail("full flag mismatch");
            end
            if (empty !== (expected_level == 0)) begin
                fail("empty flag mismatch");
            end
            if (almost_full !== (expected_level >= ALMOST_FULL_THRESHOLD)) begin
                fail("almost_full mismatch");
            end
            if (almost_empty !== (expected_level <= ALMOST_EMPTY_THRESHOLD)) begin
                fail("almost_empty mismatch");
            end
            if (m_valid !== (expected_level != 0)) begin
                fail("m_valid mismatch");
            end
            if (expected_level != 0) begin
                expected_word = expected[expected_rd_ptr];
                observed_word = {m_sideband, m_data};
                if (observed_word !== expected_word) begin
                    fail("visible head beat mismatch");
                end
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        s_valid = 1'b0;
        s_data = {DATA_WIDTH{1'b0}};
        s_sideband = {SIDEBAND_WIDTH{1'b0}};
        m_ready = 1'b0;
        expected_wr_ptr = 0;
        expected_rd_ptr = 0;
        expected_count = 0;
        send_count = 0;
        recv_count = 0;

        repeat (3) @(negedge clk);
        if (m_valid !== 1'b0) begin
            fail("output valid should be low during reset");
        end
        if (empty !== 1'b1) begin
            fail("fifo should be empty during reset");
        end

        @(negedge clk);
        rst_n = 1'b1;

        for (idx = 0; idx < DEPTH; idx = idx + 1) begin
            @(negedge clk);
            s_valid = 1'b1;
            s_data = 8'h10 + idx[7:0];
            s_sideband = idx[SIDEBAND_WIDTH-1:0];
            m_ready = 1'b0;
        end

        @(negedge clk);
        s_valid = 1'b1;
        s_data = 8'hf0;
        s_sideband = 3'h7;
        m_ready = 1'b0;
        #1;
        if (s_ready !== 1'b0) begin
            fail("source should be stalled when full without a pop");
        end

        @(posedge clk);
        #1;
        if (overflow !== 1'b1) begin
            fail("overflow pulse missing on blocked full write");
        end

        @(negedge clk);
        s_valid = 1'b1;
        s_data = 8'ha0;
        s_sideband = 3'h5;
        m_ready = 1'b1;
        #1;
        if (s_ready !== 1'b1) begin
            fail("full fifo should allow replacement when the consumer is ready");
        end

        for (cycle = 0; cycle < 240; cycle = cycle + 1) begin
            @(negedge clk);
            m_ready = (($urandom % 100) < 65);
            if (send_count < TOTAL_BEATS) begin
                s_valid = (($urandom % 100) < 70);
                s_data = 8'h20 + send_count[7:0];
                s_sideband = (send_count + 3) & ((1 << SIDEBAND_WIDTH) - 1);
            end
            else begin
                s_valid = 1'b0;
                s_data = {DATA_WIDTH{1'b0}};
                s_sideband = {SIDEBAND_WIDTH{1'b0}};
            end
        end

        while (expected_count != 0) begin
            @(negedge clk);
            s_valid = 1'b0;
            s_data = {DATA_WIDTH{1'b0}};
            s_sideband = {SIDEBAND_WIDTH{1'b0}};
            m_ready = 1'b1;
        end

        @(negedge clk);
        s_valid = 1'b0;
        m_ready = 1'b0;

        if (send_count != recv_count) begin
            fail("all accepted beats should have been observed at the output");
        end

        $display("STREAM_FIFO_TB_PASS");
        $finish;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            expected_wr_ptr <= 0;
            expected_rd_ptr <= 0;
            expected_count <= 0;
            send_count <= 0;
            recv_count <= 0;
        end
        else begin
            if (m_valid && m_ready) begin
                expected_word = expected[expected_rd_ptr];
                observed_word = {m_sideband, m_data};
                if (observed_word !== expected_word) begin
                    fail("popped beat mismatch");
                end
                expected_rd_ptr <= (expected_rd_ptr == DEPTH - 1) ? 0 : (expected_rd_ptr + 1);
                recv_count <= recv_count + 1;
            end

            if (s_valid && s_ready) begin
                expected[expected_wr_ptr] = {s_sideband, s_data};
                expected_wr_ptr <= (expected_wr_ptr == DEPTH - 1) ? 0 : (expected_wr_ptr + 1);
                send_count <= send_count + 1;
            end

            expected_after = expected_count;
            if (s_valid && s_ready) begin
                expected_after = expected_after + 1;
            end
            if (m_valid && m_ready) begin
                expected_after = expected_after - 1;
            end
            expected_count <= expected_after;

            #1;
            check_state(expected_after);
        end
    end
endmodule
