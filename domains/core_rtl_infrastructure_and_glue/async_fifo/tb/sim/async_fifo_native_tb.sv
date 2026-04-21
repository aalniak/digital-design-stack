`timescale 1ns/1ps

module async_fifo_native_tb;
    localparam integer DATA_WIDTH = 16;
    localparam integer DEPTH = 16;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);
    localparam integer MODEL_CAPACITY = 512;
    localparam integer RANDOM_WRITES_TARGET = 180;
    localparam integer PHASE_IDLE = 0;
    localparam integer PHASE_UNDERFLOW_A = 1;
    localparam integer PHASE_FILL = 2;
    localparam integer PHASE_OVERFLOW = 3;
    localparam integer PHASE_DRAIN = 4;
    localparam integer PHASE_UNDERFLOW_B = 5;
    localparam integer PHASE_RANDOM = 6;
    localparam integer PHASE_FLUSH = 7;
    localparam integer PHASE_DONE = 8;

    reg wr_clk;
    reg rd_clk;
    reg wr_rst_n;
    reg rd_rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    reg rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire almost_full;
    wire [COUNT_WIDTH-1:0] wr_level;
    wire overflow;
    wire empty;
    wire almost_empty;
    wire [COUNT_WIDTH-1:0] rd_level;
    wire underflow;

    reg [DATA_WIDTH-1:0] model_q [0:MODEL_CAPACITY-1];
    integer model_head;
    integer model_tail;
    integer model_count;
    integer next_write_value;
    integer fill_value;
    integer random_writes_issued;
    integer checked_reads;
    integer overflow_hits;
    integer underflow_hits;
    integer failures;
    integer phase;
    integer wr_rnd;
    integer rd_rnd;
    integer random_seed;

    reg wr_accept_expected;
    reg wr_overflow_expected;
    reg rd_accept_expected;
    reg rd_underflow_expected;

    async_fifo_native #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(2),
        .ALMOST_FULL_THRESHOLD(DEPTH - 2),
        .ALMOST_EMPTY_THRESHOLD(1)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .almost_full(almost_full),
        .wr_level(wr_level),
        .overflow(overflow),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .almost_empty(almost_empty),
        .rd_level(rd_level),
        .underflow(underflow)
    );

    initial begin
        wr_clk = 1'b0;
        forever #2 wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 1'b0;
        #1;
        forever #3.5 rd_clk = ~rd_clk;
    end

    initial begin
        wr_rst_n = 1'b0;
        rd_rst_n = 1'b0;
        wr_en = 1'b0;
        wr_data = {DATA_WIDTH{1'b0}};
        rd_en = 1'b0;
        model_head = 0;
        model_tail = 0;
        model_count = 0;
        next_write_value = 0;
        fill_value = 0;
        random_writes_issued = 0;
        checked_reads = 0;
        overflow_hits = 0;
        underflow_hits = 0;
        failures = 0;
        phase = PHASE_IDLE;
        random_seed = 32'h1badf00d;
        wr_accept_expected = 1'b0;
        wr_overflow_expected = 1'b0;
        rd_accept_expected = 1'b0;
        rd_underflow_expected = 1'b0;

        repeat (3) @(posedge wr_clk);
        wr_rst_n = 1'b1;
        repeat (2) @(posedge rd_clk);
        rd_rst_n = 1'b1;

        repeat (4) @(posedge rd_clk);
        if (!empty) begin
            $display("NATIVE_TB_FAIL empty was not asserted after reset release at time %0t", $time);
            failures = failures + 1;
        end

        phase = PHASE_UNDERFLOW_A;
        repeat (2) @(posedge rd_clk);

        phase = PHASE_FILL;
        wait (model_count == DEPTH);
        wait (full === 1'b1);

        phase = PHASE_OVERFLOW;
        repeat (2) @(posedge wr_clk);

        phase = PHASE_DRAIN;
        wait (model_count == 0);
        wait (empty === 1'b1);

        phase = PHASE_UNDERFLOW_B;
        repeat (2) @(posedge rd_clk);

        phase = PHASE_RANDOM;
        repeat (320) @(posedge wr_clk);

        phase = PHASE_FLUSH;
        wait (model_count == 0);
        repeat (6) @(posedge rd_clk);

        phase = PHASE_DONE;
        repeat (2) @(posedge wr_clk);

        if (overflow_hits < 1) begin
            $display("NATIVE_TB_FAIL expected at least one overflow pulse");
            failures = failures + 1;
        end
        if (underflow_hits < 2) begin
            $display("NATIVE_TB_FAIL expected at least two underflow pulses");
            failures = failures + 1;
        end
        if (failures != 0) begin
            $display("NATIVE_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "ASYNC_FIFO_NATIVE_TB_PASS reads=%0d overflows=%0d underflows=%0d",
            checked_reads,
            overflow_hits,
            underflow_hits
        );
        $finish;
    end

    initial begin
        #200000;
        $display(
            "NATIVE_TB_FAIL timeout phase=%0d model_count=%0d fill_value=%0d full=%0b empty=%0b wr_level=%0d rd_level=%0d",
            phase,
            model_count,
            fill_value,
            full,
            empty,
            wr_level,
            rd_level
        );
        $finish_and_return(1);
    end

    always @(negedge wr_clk) begin
        if (!wr_rst_n) begin
            wr_en <= 1'b0;
            wr_data <= {DATA_WIDTH{1'b0}};
            wr_accept_expected <= 1'b0;
            wr_overflow_expected <= 1'b0;
        end
        else begin
            case (phase)
                PHASE_FILL: begin
                    if (fill_value < DEPTH && !full) begin
                        wr_en <= 1'b1;
                        wr_data <= fill_value[DATA_WIDTH-1:0];
                        wr_accept_expected <= 1'b1;
                        wr_overflow_expected <= 1'b0;
                        fill_value = fill_value + 1;
                    end
                    else begin
                        wr_en <= 1'b0;
                        wr_data <= wr_data;
                        wr_accept_expected <= 1'b0;
                        wr_overflow_expected <= 1'b0;
                    end
                end
                PHASE_OVERFLOW: begin
                    wr_en <= 1'b1;
                    wr_data <= 16'hcafe;
                    wr_accept_expected <= 1'b0;
                    wr_overflow_expected <= full;
                end
                PHASE_RANDOM: begin
                    wr_rnd = $urandom(random_seed);
                    if ((random_writes_issued < RANDOM_WRITES_TARGET) && ((wr_rnd % 100) < 65)) begin
                        wr_en <= 1'b1;
                        wr_data <= next_write_value[DATA_WIDTH-1:0];
                        wr_accept_expected <= !full;
                        wr_overflow_expected <= full;
                        if (!full) begin
                            next_write_value = next_write_value + 1;
                            random_writes_issued = random_writes_issued + 1;
                        end
                    end
                    else begin
                        wr_en <= 1'b0;
                        wr_data <= wr_data;
                        wr_accept_expected <= 1'b0;
                        wr_overflow_expected <= 1'b0;
                    end
                end
                default: begin
                    wr_en <= 1'b0;
                    wr_data <= wr_data;
                    wr_accept_expected <= 1'b0;
                    wr_overflow_expected <= 1'b0;
                end
            endcase
        end
    end

    always @(negedge rd_clk) begin
        if (!rd_rst_n) begin
            rd_en <= 1'b0;
            rd_accept_expected <= 1'b0;
            rd_underflow_expected <= 1'b0;
        end
        else begin
            case (phase)
                PHASE_UNDERFLOW_A,
                PHASE_UNDERFLOW_B: begin
                    rd_en <= 1'b1;
                    rd_accept_expected <= !empty;
                    rd_underflow_expected <= empty;
                end
                PHASE_DRAIN,
                PHASE_FLUSH: begin
                    rd_en <= !empty;
                    rd_accept_expected <= !empty;
                    rd_underflow_expected <= 1'b0;
                end
                PHASE_RANDOM: begin
                    rd_rnd = $urandom(random_seed);
                    if ((rd_rnd % 100) < 60) begin
                        rd_en <= 1'b1;
                        rd_accept_expected <= !empty;
                        rd_underflow_expected <= empty;
                    end
                    else begin
                        rd_en <= 1'b0;
                        rd_accept_expected <= 1'b0;
                        rd_underflow_expected <= 1'b0;
                    end
                end
                default: begin
                    rd_en <= 1'b0;
                    rd_accept_expected <= 1'b0;
                    rd_underflow_expected <= 1'b0;
                end
            endcase
        end
    end

    always @(posedge wr_clk) begin
        if (wr_rst_n) begin
            if (wr_accept_expected) begin
                model_q[model_tail] = wr_data;
                model_tail = (model_tail + 1) % MODEL_CAPACITY;
                model_count = model_count + 1;
                if (model_count > MODEL_CAPACITY) begin
                    $display("NATIVE_TB_FAIL model queue overflow at time %0t", $time);
                    failures = failures + 1;
                end
            end

            if (wr_overflow_expected) begin
                overflow_hits = overflow_hits + 1;
            end

            #1;
            if (overflow !== wr_overflow_expected) begin
                $display(
                    "NATIVE_TB_FAIL overflow mismatch expected=%0b got=%0b at time %0t",
                    wr_overflow_expected,
                    overflow,
                    $time
                );
                failures = failures + 1;
            end

            if (wr_level > DEPTH) begin
                $display("NATIVE_TB_FAIL wr_level exceeded DEPTH at time %0t", $time);
                failures = failures + 1;
            end
        end
    end

    always @(posedge rd_clk) begin
        reg [DATA_WIDTH-1:0] expected_word;
        if (rd_rst_n) begin
            if (rd_accept_expected) begin
                if (model_count <= 0) begin
                    $display("NATIVE_TB_FAIL read accepted with empty model queue at time %0t", $time);
                    failures = failures + 1;
                end
                else begin
                    expected_word = model_q[model_head];
                    if (rd_data !== expected_word) begin
                        $display(
                            "NATIVE_TB_FAIL data mismatch expected=0x%0h got=0x%0h at time %0t",
                            expected_word,
                            rd_data,
                            $time
                        );
                        failures = failures + 1;
                    end
                    model_head = (model_head + 1) % MODEL_CAPACITY;
                    model_count = model_count - 1;
                    checked_reads = checked_reads + 1;
                end
            end

            if (rd_underflow_expected) begin
                underflow_hits = underflow_hits + 1;
            end

            #1;
            if (underflow !== rd_underflow_expected) begin
                $display(
                    "NATIVE_TB_FAIL underflow mismatch expected=%0b got=%0b at time %0t",
                    rd_underflow_expected,
                    underflow,
                    $time
                );
                failures = failures + 1;
            end

            if (rd_level > DEPTH) begin
                $display("NATIVE_TB_FAIL rd_level exceeded DEPTH at time %0t", $time);
                failures = failures + 1;
            end
        end
    end
endmodule
