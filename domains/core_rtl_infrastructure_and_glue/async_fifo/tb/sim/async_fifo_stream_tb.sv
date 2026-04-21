`timescale 1ns/1ps

module async_fifo_stream_tb;
    localparam integer DATA_WIDTH = 24;
    localparam integer DEPTH = 16;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);
    localparam integer MODEL_CAPACITY = 512;
    localparam integer TOTAL_WORDS = 150;

    reg s_clk;
    reg m_clk;
    reg s_rst_n;
    reg m_rst_n;
    reg s_valid;
    reg [DATA_WIDTH-1:0] s_data;
    wire s_ready;
    wire s_almost_full;
    wire [COUNT_WIDTH-1:0] s_level;
    wire m_valid;
    wire [DATA_WIDTH-1:0] m_data;
    reg m_ready;
    wire m_almost_empty;
    wire [COUNT_WIDTH-1:0] m_level;

    reg [DATA_WIDTH-1:0] model_q [0:MODEL_CAPACITY-1];
    integer model_head;
    integer model_tail;
    integer model_count;
    integer sent_count;
    integer recv_count;
    integer failures;
    integer random_seed;
    integer src_rnd;
    integer sink_rnd;

    async_fifo_stream #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(2),
        .ALMOST_FULL_THRESHOLD(DEPTH - 2),
        .ALMOST_EMPTY_THRESHOLD(1),
        .EXPOSE_LEVELS(1'b1),
        .EXPOSE_WATERMARKS(1'b1)
    ) dut (
        .s_clk(s_clk),
        .s_rst_n(s_rst_n),
        .s_valid(s_valid),
        .s_data(s_data),
        .s_ready(s_ready),
        .s_almost_full(s_almost_full),
        .s_level(s_level),
        .m_clk(m_clk),
        .m_rst_n(m_rst_n),
        .m_valid(m_valid),
        .m_data(m_data),
        .m_ready(m_ready),
        .m_almost_empty(m_almost_empty),
        .m_level(m_level)
    );

    initial begin
        s_clk = 1'b0;
        forever #2.5 s_clk = ~s_clk;
    end

    initial begin
        m_clk = 1'b0;
        #1.25;
        forever #4 m_clk = ~m_clk;
    end

    initial begin
        s_rst_n = 1'b0;
        m_rst_n = 1'b0;
        s_valid = 1'b0;
        s_data = {DATA_WIDTH{1'b0}};
        m_ready = 1'b0;
        model_head = 0;
        model_tail = 0;
        model_count = 0;
        sent_count = 0;
        recv_count = 0;
        failures = 0;
        random_seed = 32'h76543210;

        repeat (3) @(posedge s_clk);
        s_rst_n = 1'b1;
        repeat (2) @(posedge m_clk);
        m_rst_n = 1'b1;

        fork
            begin : timeout_block
                repeat (2200) @(posedge s_clk);
                $display("STREAM_TB_FAIL timeout waiting for all words to drain");
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
            $display("STREAM_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "ASYNC_FIFO_STREAM_TB_PASS sent=%0d received=%0d",
            sent_count,
            recv_count
        );
        $finish;
    end

    always @(negedge s_clk) begin
        if (!s_rst_n) begin
            s_valid <= 1'b0;
            s_data <= {DATA_WIDTH{1'b0}};
        end
        else if (s_valid && !s_ready) begin
            s_valid <= s_valid;
            s_data <= s_data;
        end
        else if (sent_count < TOTAL_WORDS) begin
            src_rnd = $urandom(random_seed);
            if ((src_rnd % 100) < 75) begin
                s_valid <= 1'b1;
                s_data <= sent_count[DATA_WIDTH-1:0];
            end
            else begin
                s_valid <= 1'b0;
                s_data <= s_data;
            end
        end
        else begin
            s_valid <= 1'b0;
            s_data <= s_data;
        end
    end

    always @(negedge m_clk) begin
        if (!m_rst_n) begin
            m_ready <= 1'b0;
        end
        else if ((recv_count < TOTAL_WORDS) || (model_count != 0)) begin
            sink_rnd = $urandom(random_seed);
            m_ready <= ((sink_rnd % 100) < 70);
        end
        else begin
            m_ready <= 1'b0;
        end
    end

    always @(posedge s_clk) begin
        if (s_rst_n) begin
            if (s_valid && s_ready) begin
                model_q[model_tail] = s_data;
                model_tail = (model_tail + 1) % MODEL_CAPACITY;
                model_count = model_count + 1;
                sent_count = sent_count + 1;
            end

            #1;
            if (s_level > DEPTH) begin
                $display("STREAM_TB_FAIL s_level exceeded DEPTH at time %0t", $time);
                failures = failures + 1;
            end
        end
    end

    always @(posedge m_clk) begin
        reg [DATA_WIDTH-1:0] expected_word;
        if (m_rst_n) begin
            if (m_valid && m_ready) begin
                if (model_count <= 0) begin
                    $display("STREAM_TB_FAIL sink consumed from empty model at time %0t", $time);
                    failures = failures + 1;
                end
                else begin
                    expected_word = model_q[model_head];
                    if (m_data !== expected_word) begin
                        $display(
                            "STREAM_TB_FAIL data mismatch expected=0x%0h got=0x%0h at time %0t",
                            expected_word,
                            m_data,
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
                $display("STREAM_TB_FAIL m_level exceeded DEPTH at time %0t", $time);
                failures = failures + 1;
            end
        end
    end
endmodule
