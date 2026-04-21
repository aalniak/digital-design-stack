`timescale 1ns/1ps

module bus_synchronizer_tb;
    localparam integer DATA_WIDTH = 20;
    localparam integer TOTAL_WORDS = 90;
    localparam integer MODEL_CAPACITY = 256;

    reg src_clk;
    reg dst_clk;
    reg src_rst_n;
    reg dst_rst_n;
    reg [DATA_WIDTH-1:0] src_data;
    reg src_valid;
    wire src_ready;
    wire [DATA_WIDTH-1:0] dst_data;
    wire dst_valid;
    wire dst_pulse;
    reg dst_ready;

    reg [DATA_WIDTH-1:0] model_q [0:MODEL_CAPACITY-1];
    integer model_head;
    integer model_tail;
    integer model_count;
    integer sent_count;
    integer recv_count;
    integer pulse_count;
    integer failures;
    integer random_seed;
    integer src_rnd;
    integer dst_rnd;
    reg prev_dst_valid;
    reg [DATA_WIDTH-1:0] prev_dst_data;

    bus_synchronizer #(
        .DATA_WIDTH(DATA_WIDTH),
        .SYNC_STAGES(2),
        .RESET_VALUE({DATA_WIDTH{1'b0}})
    ) dut (
        .src_clk(src_clk),
        .src_rst_n(src_rst_n),
        .src_data(src_data),
        .src_valid(src_valid),
        .src_ready(src_ready),
        .dst_clk(dst_clk),
        .dst_rst_n(dst_rst_n),
        .dst_data(dst_data),
        .dst_valid(dst_valid),
        .dst_pulse(dst_pulse),
        .dst_ready(dst_ready)
    );

    initial begin
        src_clk = 1'b0;
        forever #2.5 src_clk = ~src_clk;
    end

    initial begin
        dst_clk = 1'b0;
        #1.25;
        forever #4 dst_clk = ~dst_clk;
    end

    initial begin
        src_rst_n = 1'b0;
        dst_rst_n = 1'b0;
        src_data = {DATA_WIDTH{1'b0}};
        src_valid = 1'b0;
        dst_ready = 1'b0;
        model_head = 0;
        model_tail = 0;
        model_count = 0;
        sent_count = 0;
        recv_count = 0;
        pulse_count = 0;
        failures = 0;
        random_seed = 32'h00c0ffee;
        prev_dst_valid = 1'b0;
        prev_dst_data = {DATA_WIDTH{1'b0}};

        repeat (3) @(posedge src_clk);
        src_rst_n = 1'b1;
        repeat (2) @(posedge dst_clk);
        dst_rst_n = 1'b1;

        wait (recv_count == TOTAL_WORDS);
        wait (pulse_count == TOTAL_WORDS);
        repeat (8) @(posedge dst_clk);

        if (failures != 0) begin
            $display("BUS_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "BUS_SYNCHRONIZER_TB_PASS sent=%0d received=%0d pulses=%0d",
            sent_count,
            recv_count,
            pulse_count
        );
        $finish;
    end

    initial begin
        #160000;
        $display(
            "BUS_TB_FAIL timeout sent=%0d received=%0d pulses=%0d model_count=%0d src_ready=%0b dst_valid=%0b",
            sent_count,
            recv_count,
            pulse_count,
            model_count,
            src_ready,
            dst_valid
        );
        $finish_and_return(1);
    end

    always @(negedge src_clk) begin
        if (!src_rst_n) begin
            src_valid <= 1'b0;
            src_data <= {DATA_WIDTH{1'b0}};
        end
        else if (src_valid && !src_ready) begin
            src_valid <= src_valid;
            src_data <= src_data;
        end
        else if (sent_count < TOTAL_WORDS) begin
            src_rnd = $urandom(random_seed);
            if ((src_rnd % 100) < 75) begin
                src_valid <= 1'b1;
                src_data <= sent_count[DATA_WIDTH-1:0];
            end
            else begin
                src_valid <= 1'b0;
            end
        end
        else begin
            src_valid <= 1'b0;
        end
    end

    always @(negedge dst_clk) begin
        if (!dst_rst_n) begin
            dst_ready <= 1'b0;
        end
        else if ((recv_count < TOTAL_WORDS) || dst_valid) begin
            dst_rnd = $urandom(random_seed);
            dst_ready <= ((dst_rnd % 100) < 70);
        end
        else begin
            dst_ready <= 1'b0;
        end
    end

    always @(posedge src_clk) begin
        if (!src_rst_n) begin
            if (src_ready !== 1'b1) begin
                $display("BUS_TB_FAIL src_ready was not high during source reset at time %0t", $time);
                failures = failures + 1;
            end
        end
        else if (src_valid && src_ready) begin
            model_q[model_tail] = src_data;
            model_tail = (model_tail + 1) % MODEL_CAPACITY;
            model_count = model_count + 1;
            sent_count = sent_count + 1;
        end
    end

    always @(posedge dst_clk) begin
        reg [DATA_WIDTH-1:0] expected_word;
        if (!dst_rst_n) begin
            prev_dst_valid <= 1'b0;
            prev_dst_data <= {DATA_WIDTH{1'b0}};
            if (dst_valid !== 1'b0 || dst_pulse !== 1'b0) begin
                $display("BUS_TB_FAIL destination outputs active during reset at time %0t", $time);
                failures = failures + 1;
            end
        end
        else begin
            #1;
            if (prev_dst_valid && !dst_ready) begin
                if (!dst_valid) begin
                    $display("BUS_TB_FAIL dst_valid dropped before dst_ready at time %0t", $time);
                    failures = failures + 1;
                end
                if (dst_data !== prev_dst_data) begin
                    $display("BUS_TB_FAIL dst_data changed while stalled at time %0t", $time);
                    failures = failures + 1;
                end
            end

            if (dst_pulse) begin
                pulse_count = pulse_count + 1;
                if (!dst_valid) begin
                    $display("BUS_TB_FAIL dst_pulse asserted without dst_valid at time %0t", $time);
                    failures = failures + 1;
                end
            end

            if (prev_dst_valid && dst_ready) begin
                if (model_count <= 0) begin
                    $display("BUS_TB_FAIL destination consumed with empty model queue at time %0t", $time);
                    failures = failures + 1;
                end
                else begin
                    expected_word = model_q[model_head];
                    if (prev_dst_data !== expected_word) begin
                        $display(
                            "BUS_TB_FAIL data mismatch expected=0x%0h got=0x%0h at time %0t",
                            expected_word,
                            prev_dst_data,
                            $time
                        );
                        failures = failures + 1;
                    end
                    model_head = (model_head + 1) % MODEL_CAPACITY;
                    model_count = model_count - 1;
                    recv_count = recv_count + 1;
                end
            end

            if (pulse_count > sent_count) begin
                $display("BUS_TB_FAIL more destination pulses than launched source words at time %0t", $time);
                failures = failures + 1;
            end

            prev_dst_valid <= dst_valid;
            prev_dst_data <= dst_data;
        end
    end
endmodule
