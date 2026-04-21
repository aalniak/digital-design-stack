`timescale 1ns/1ps

module async_fifo_packet_tb;
    localparam integer DATA_WIDTH = 32;
    localparam integer DEPTH = 16;
    localparam integer KEEP_WIDTH = 4;
    localparam integer USER_WIDTH = 3;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);
    localparam integer MODEL_CAPACITY = 512;
    localparam integer TOTAL_WORDS = 96;
    localparam integer PACKED_WIDTH = DATA_WIDTH + 1 + KEEP_WIDTH + USER_WIDTH;

    reg s_clk;
    reg m_clk;
    reg s_rst_n;
    reg m_rst_n;
    reg s_valid;
    reg [DATA_WIDTH-1:0] s_data;
    reg s_last;
    reg [KEEP_WIDTH-1:0] s_keep;
    reg [USER_WIDTH-1:0] s_user;
    wire s_ready;
    wire s_almost_full;
    wire [COUNT_WIDTH-1:0] s_level;
    wire m_valid;
    wire [DATA_WIDTH-1:0] m_data;
    wire m_last;
    wire [KEEP_WIDTH-1:0] m_keep;
    wire [USER_WIDTH-1:0] m_user;
    reg m_ready;
    wire m_almost_empty;
    wire [COUNT_WIDTH-1:0] m_level;

    reg [PACKED_WIDTH-1:0] model_q [0:MODEL_CAPACITY-1];
    integer model_head;
    integer model_tail;
    integer model_count;
    integer sent_count;
    integer recv_count;
    integer failures;
    integer random_seed;
    integer src_rnd;
    integer sink_rnd;

    function automatic [PACKED_WIDTH-1:0] make_packet_word;
        input integer word_index;
        reg [KEEP_WIDTH-1:0] keep_value;
        reg [USER_WIDTH-1:0] user_value;
        reg last_value;
        begin
            keep_value = (~word_index) & ((1 << KEEP_WIDTH) - 1);
            if (keep_value == {KEEP_WIDTH{1'b0}}) begin
                keep_value = {{(KEEP_WIDTH-1){1'b0}}, 1'b1};
            end
            user_value = (word_index * 3) & ((1 << USER_WIDTH) - 1);
            last_value = ((word_index % 5) == 4) || (word_index == (TOTAL_WORDS - 1));
            make_packet_word = {user_value, keep_value, last_value, word_index[DATA_WIDTH-1:0]};
        end
    endfunction

    async_fifo_packet #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(2),
        .ALMOST_FULL_THRESHOLD(DEPTH - 2),
        .ALMOST_EMPTY_THRESHOLD(1),
        .EXPOSE_LEVELS(1'b1),
        .EXPOSE_WATERMARKS(1'b1),
        .KEEP_ENABLE(1'b1),
        .KEEP_WIDTH(KEEP_WIDTH),
        .USER_ENABLE(1'b1),
        .USER_WIDTH(USER_WIDTH)
    ) dut (
        .s_clk(s_clk),
        .s_rst_n(s_rst_n),
        .s_valid(s_valid),
        .s_data(s_data),
        .s_last(s_last),
        .s_keep(s_keep),
        .s_user(s_user),
        .s_ready(s_ready),
        .s_almost_full(s_almost_full),
        .s_level(s_level),
        .m_clk(m_clk),
        .m_rst_n(m_rst_n),
        .m_valid(m_valid),
        .m_data(m_data),
        .m_last(m_last),
        .m_keep(m_keep),
        .m_user(m_user),
        .m_ready(m_ready),
        .m_almost_empty(m_almost_empty),
        .m_level(m_level)
    );

    initial begin
        s_clk = 1'b0;
        forever #3 s_clk = ~s_clk;
    end

    initial begin
        m_clk = 1'b0;
        #1.5;
        forever #4.5 m_clk = ~m_clk;
    end

    initial begin
        s_rst_n = 1'b0;
        m_rst_n = 1'b0;
        s_valid = 1'b0;
        s_data = {DATA_WIDTH{1'b0}};
        s_last = 1'b0;
        s_keep = {KEEP_WIDTH{1'b0}};
        s_user = {USER_WIDTH{1'b0}};
        m_ready = 1'b0;
        model_head = 0;
        model_tail = 0;
        model_count = 0;
        sent_count = 0;
        recv_count = 0;
        failures = 0;
        random_seed = 32'h31415926;

        repeat (3) @(posedge s_clk);
        s_rst_n = 1'b1;
        repeat (2) @(posedge m_clk);
        m_rst_n = 1'b1;

        fork
            begin : timeout_block
                repeat (2200) @(posedge s_clk);
                $display("PACKET_TB_FAIL timeout waiting for packet stream to drain");
                failures = failures + 1;
                $finish_and_return(1);
            end
            begin : completion_block
                wait ((recv_count == TOTAL_WORDS) && (model_count == 0) && !s_valid);
                disable timeout_block;
            end
        join

        repeat (4) @(posedge m_clk);
        if (failures != 0) begin
            $display("PACKET_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "ASYNC_FIFO_PACKET_TB_PASS sent=%0d received=%0d",
            sent_count,
            recv_count
        );
        $finish;
    end

    always @(negedge s_clk) begin
        reg [PACKED_WIDTH-1:0] next_word;
        if (!s_rst_n) begin
            s_valid <= 1'b0;
            s_data <= {DATA_WIDTH{1'b0}};
            s_last <= 1'b0;
            s_keep <= {KEEP_WIDTH{1'b0}};
            s_user <= {USER_WIDTH{1'b0}};
        end
        else if (s_valid && !s_ready) begin
            s_valid <= s_valid;
            s_data <= s_data;
            s_last <= s_last;
            s_keep <= s_keep;
            s_user <= s_user;
        end
        else if (sent_count < TOTAL_WORDS) begin
            src_rnd = $urandom(random_seed);
            if ((src_rnd % 100) < 80) begin
                next_word = make_packet_word(sent_count);
                s_valid <= 1'b1;
                s_data <= next_word[DATA_WIDTH-1:0];
                s_last <= next_word[DATA_WIDTH];
                s_keep <= next_word[DATA_WIDTH+KEEP_WIDTH:DATA_WIDTH+1];
                s_user <= next_word[PACKED_WIDTH-1:DATA_WIDTH+KEEP_WIDTH+1];
            end
            else begin
                s_valid <= 1'b0;
            end
        end
        else begin
            s_valid <= 1'b0;
        end
    end

    always @(negedge m_clk) begin
        if (!m_rst_n) begin
            m_ready <= 1'b0;
        end
        else if ((recv_count < TOTAL_WORDS) || (model_count != 0)) begin
            sink_rnd = $urandom(random_seed);
            m_ready <= ((sink_rnd % 100) < 75);
        end
        else begin
            m_ready <= 1'b0;
        end
    end

    always @(posedge s_clk) begin
        reg [PACKED_WIDTH-1:0] packed_word;
        if (s_rst_n) begin
            if (s_valid && s_ready) begin
                packed_word = {s_user, s_keep, s_last, s_data};
                model_q[model_tail] = packed_word;
                model_tail = (model_tail + 1) % MODEL_CAPACITY;
                model_count = model_count + 1;
                sent_count = sent_count + 1;
            end

            #1;
            if (s_level > DEPTH) begin
                $display("PACKET_TB_FAIL s_level exceeded DEPTH at time %0t", $time);
                failures = failures + 1;
            end
        end
    end

    always @(posedge m_clk) begin
        reg [PACKED_WIDTH-1:0] expected_word;
        reg [PACKED_WIDTH-1:0] observed_word;
        if (m_rst_n) begin
            if (m_valid && m_ready) begin
                if (model_count <= 0) begin
                    $display("PACKET_TB_FAIL sink consumed from empty model at time %0t", $time);
                    failures = failures + 1;
                end
                else begin
                    expected_word = model_q[model_head];
                    observed_word = {m_user, m_keep, m_last, m_data};
                    if (observed_word !== expected_word) begin
                        $display(
                            "PACKET_TB_FAIL packet mismatch expected=0x%0h got=0x%0h at time %0t",
                            expected_word,
                            observed_word,
                            $time
                        );
                        failures = failures + 1;
                    end
                    model_head = (model_head + 1) % MODEL_CAPACITY;
                    model_count = model_count - 1;
                    recv_count = recv_count + 1;
                end
            end

            #1;
            if (m_level > DEPTH) begin
                $display("PACKET_TB_FAIL m_level exceeded DEPTH at time %0t", $time);
                failures = failures + 1;
            end
        end
    end
endmodule
