module packet_fifo_tb;
    localparam integer DATA_WIDTH = 8;
    localparam integer META_WIDTH = 2;
    localparam integer DEPTH = 6;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);
    localparam integer TOTAL_PACKETS = 20;
    localparam integer PAYLOAD_WIDTH = DATA_WIDTH + META_WIDTH + 2;

    reg clk;
    reg rst_n;
    reg s_valid;
    wire s_ready;
    reg [DATA_WIDTH-1:0] s_data;
    reg [META_WIDTH-1:0] s_meta;
    reg s_first;
    reg s_last;
    wire m_valid;
    reg m_ready;
    wire [DATA_WIDTH-1:0] m_data;
    wire [META_WIDTH-1:0] m_meta;
    wire m_first;
    wire m_last;
    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    wire [COUNT_WIDTH-1:0] beat_occupancy;
    wire [COUNT_WIDTH-1:0] packet_occupancy;
    wire overflow;

    reg [PAYLOAD_WIDTH-1:0] expected [0:255];
    integer expected_wr_ptr;
    integer expected_rd_ptr;
    integer expected_beats;
    integer expected_packets;
    integer sent_beats;
    integer recv_beats;
    integer sent_packets;
    integer current_packet_len;
    integer beat_in_packet;
    integer cycle;
    reg [PAYLOAD_WIDTH-1:0] observed_word;
    reg [PAYLOAD_WIDTH-1:0] expected_word;
    integer expected_beats_after;
    integer expected_packets_after;

    packet_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .META_WIDTH(META_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(DEPTH - 1),
        .ALMOST_EMPTY_THRESHOLD(1),
        .COUNT_EN(1),
        .PACKET_COUNT_EN(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_meta(s_meta),
        .s_first(s_first),
        .s_last(s_last),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_meta(m_meta),
        .m_first(m_first),
        .m_last(m_last),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .beat_occupancy(beat_occupancy),
        .packet_occupancy(packet_occupancy),
        .overflow(overflow)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("PACKET_FIFO_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic check_state;
        input integer expected_beat_level;
        input integer expected_packet_level;
        begin
            if (beat_occupancy !== expected_beat_level[COUNT_WIDTH-1:0]) begin
                fail("beat occupancy mismatch");
            end
            if (packet_occupancy !== expected_packet_level[COUNT_WIDTH-1:0]) begin
                fail("packet occupancy mismatch");
            end
            if (empty !== (expected_beat_level == 0)) begin
                fail("empty flag mismatch");
            end
            if (full !== (expected_beat_level == DEPTH)) begin
                fail("full flag mismatch");
            end
            if (m_valid !== (expected_beat_level != 0)) begin
                fail("m_valid mismatch");
            end
            if (expected_beat_level != 0) begin
                expected_word = expected[expected_rd_ptr];
                observed_word = {m_meta, m_first, m_last, m_data};
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
        s_meta = {META_WIDTH{1'b0}};
        s_first = 1'b0;
        s_last = 1'b0;
        m_ready = 1'b0;
        expected_wr_ptr = 0;
        expected_rd_ptr = 0;
        expected_beats = 0;
        expected_packets = 0;
        sent_beats = 0;
        recv_beats = 0;
        sent_packets = 0;
        current_packet_len = 1;
        beat_in_packet = 0;

        repeat (3) @(negedge clk);
        if (empty !== 1'b1) begin
            fail("packet_fifo should be empty during reset");
        end
        if (packet_occupancy !== {COUNT_WIDTH{1'b0}}) begin
            fail("packet occupancy should reset to zero");
        end

        @(negedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        s_valid = 1'b1;
        s_data = 8'h41;
        s_meta = 2'h1;
        s_first = 1'b1;
        s_last = 1'b0;
        m_ready = 1'b0;

        @(posedge clk);
        #1;
        if (packet_occupancy !== {COUNT_WIDTH{1'b0}}) begin
            fail("partial packet must not count as a complete packet");
        end

        @(negedge clk);
        s_valid = 1'b1;
        s_data = 8'h42;
        s_meta = 2'h1;
        s_first = 1'b0;
        s_last = 1'b1;
        m_ready = 1'b0;

        @(posedge clk);
        #1;
        if (packet_occupancy !== {{(COUNT_WIDTH-1){1'b0}}, 1'b1}) begin
            fail("packet occupancy should increment once the last beat arrives");
        end

        for (cycle = 0; cycle < 260; cycle = cycle + 1) begin
            @(negedge clk);
            m_ready = (($urandom % 100) < 65);
            if (sent_packets < TOTAL_PACKETS) begin
                s_valid = (($urandom % 100) < 75);
                s_data = 8'h20 + sent_beats[7:0];
                s_meta = sent_packets[META_WIDTH-1:0];
                s_first = (beat_in_packet == 0);
                s_last = (beat_in_packet == (current_packet_len - 1));
            end
            else begin
                s_valid = 1'b0;
                s_data = {DATA_WIDTH{1'b0}};
                s_meta = {META_WIDTH{1'b0}};
                s_first = 1'b0;
                s_last = 1'b0;
            end
        end

        while (expected_beats != 0) begin
            @(negedge clk);
            s_valid = 1'b0;
            s_data = {DATA_WIDTH{1'b0}};
            s_meta = {META_WIDTH{1'b0}};
            s_first = 1'b0;
            s_last = 1'b0;
            m_ready = 1'b1;
        end

        @(negedge clk);
        s_valid = 1'b0;
        m_ready = 1'b0;

        if (sent_beats != recv_beats) begin
            fail("all accepted beats should leave the fifo");
        end
        if (expected_packets != 0) begin
            fail("packet occupancy should be zero after final drain");
        end

        $display("PACKET_FIFO_TB_PASS");
        $finish;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            expected_wr_ptr <= 0;
            expected_rd_ptr <= 0;
            expected_beats <= 0;
            expected_packets <= 0;
            sent_beats <= 0;
            recv_beats <= 0;
            sent_packets <= 0;
            current_packet_len <= 1;
            beat_in_packet <= 0;
        end
        else begin
            if (m_valid && m_ready) begin
                expected_word = expected[expected_rd_ptr];
                observed_word = {m_meta, m_first, m_last, m_data};
                if (observed_word !== expected_word) begin
                    fail("popped beat mismatch");
                end
                expected_rd_ptr <= (expected_rd_ptr == DEPTH - 1) ? 0 : (expected_rd_ptr + 1);
                recv_beats <= recv_beats + 1;
            end

            if (s_valid && s_ready) begin
                expected[expected_wr_ptr] = {s_meta, s_first, s_last, s_data};
                expected_wr_ptr <= (expected_wr_ptr == DEPTH - 1) ? 0 : (expected_wr_ptr + 1);
                sent_beats <= sent_beats + 1;
                if (s_last) begin
                    sent_packets <= sent_packets + 1;
                    current_packet_len <= ((sent_packets + 1) % 4) + 1;
                    beat_in_packet <= 0;
                end
                else begin
                    beat_in_packet <= beat_in_packet + 1;
                end
            end

            expected_beats_after = expected_beats;
            if (s_valid && s_ready) begin
                expected_beats_after = expected_beats_after + 1;
            end
            if (m_valid && m_ready) begin
                expected_beats_after = expected_beats_after - 1;
            end
            expected_beats <= expected_beats_after;

            expected_packets_after = expected_packets;
            if (s_valid && s_ready && s_last) begin
                expected_packets_after = expected_packets_after + 1;
            end
            if (m_valid && m_ready && m_last) begin
                expected_packets_after = expected_packets_after - 1;
            end
            expected_packets <= expected_packets_after;

            #1;
            check_state(expected_beats_after, expected_packets_after);
        end
    end
endmodule
