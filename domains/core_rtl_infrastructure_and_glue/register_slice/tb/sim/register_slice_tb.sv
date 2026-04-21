`timescale 1ns/1ps

module register_slice_tb;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 3;
    localparam integer TOTAL_BEATS = 80;
    localparam integer MODEL_CAPACITY = 256;

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

    reg pipe_s_valid;
    wire pipe_s_ready;
    reg [DATA_WIDTH-1:0] pipe_s_data;
    reg [SIDEBAND_WIDTH-1:0] pipe_s_sideband;
    wire pipe_m_valid;
    reg pipe_m_ready;
    wire [DATA_WIDTH-1:0] pipe_m_data;
    wire [SIDEBAND_WIDTH-1:0] pipe_m_sideband;

    reg [DATA_WIDTH-1:0] bypass_model_data [0:MODEL_CAPACITY-1];
    reg [SIDEBAND_WIDTH-1:0] bypass_model_side [0:MODEL_CAPACITY-1];
    integer bypass_head;
    integer bypass_tail;
    integer bypass_count;
    integer bypass_sent;
    integer bypass_recv;

    reg [DATA_WIDTH-1:0] pipe_model_data [0:MODEL_CAPACITY-1];
    reg [SIDEBAND_WIDTH-1:0] pipe_model_side [0:MODEL_CAPACITY-1];
    integer pipe_head;
    integer pipe_tail;
    integer pipe_count;
    integer pipe_sent;
    integer pipe_recv;

    reg prev_bypass_valid;
    reg prev_bypass_ready;
    reg [DATA_WIDTH-1:0] prev_bypass_data;
    reg [SIDEBAND_WIDTH-1:0] prev_bypass_side;
    reg prev_pipe_valid;
    reg prev_pipe_ready;
    reg [DATA_WIDTH-1:0] prev_pipe_data;
    reg [SIDEBAND_WIDTH-1:0] prev_pipe_side;
    reg bypass_s_ready_sampled;
    reg pipe_s_ready_sampled;

    integer failures;
    integer random_seed;
    integer rnd;
    register_slice #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .STAGES(0)
    ) dut_bypass (
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

    register_slice #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .STAGES(2)
    ) dut_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(pipe_s_valid),
        .s_ready(pipe_s_ready),
        .s_data(pipe_s_data),
        .s_sideband(pipe_s_sideband),
        .m_valid(pipe_m_valid),
        .m_ready(pipe_m_ready),
        .m_data(pipe_m_data),
        .m_sideband(pipe_m_sideband)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        bypass_s_valid = 1'b0;
        bypass_s_data = {DATA_WIDTH{1'b0}};
        bypass_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        bypass_m_ready = 1'b0;
        pipe_s_valid = 1'b0;
        pipe_s_data = {DATA_WIDTH{1'b0}};
        pipe_s_sideband = {SIDEBAND_WIDTH{1'b0}};
        pipe_m_ready = 1'b0;
        bypass_head = 0;
        bypass_tail = 0;
        bypass_count = 0;
        bypass_sent = 0;
        bypass_recv = 0;
        pipe_head = 0;
        pipe_tail = 0;
        pipe_count = 0;
        pipe_sent = 0;
        pipe_recv = 0;
        prev_bypass_valid = 1'b0;
        prev_bypass_ready = 1'b0;
        prev_bypass_data = {DATA_WIDTH{1'b0}};
        prev_bypass_side = {SIDEBAND_WIDTH{1'b0}};
        prev_pipe_valid = 1'b0;
        prev_pipe_ready = 1'b0;
        prev_pipe_data = {DATA_WIDTH{1'b0}};
        prev_pipe_side = {SIDEBAND_WIDTH{1'b0}};
        bypass_s_ready_sampled = 1'b0;
        pipe_s_ready_sampled = 1'b0;
        failures = 0;
        random_seed = 32'h13572468;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        wait ((bypass_recv == TOTAL_BEATS) && (pipe_recv == TOTAL_BEATS));
        repeat (5) @(posedge clk);

        if (failures != 0) begin
            $display("REGISTER_SLICE_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "REGISTER_SLICE_TB_PASS bypass_sent=%0d bypass_recv=%0d pipe_sent=%0d pipe_recv=%0d",
            bypass_sent,
            bypass_recv,
            pipe_sent,
            pipe_recv
        );
        $finish;
    end

    initial begin
        #30000;
        $display(
            "REGISTER_SLICE_TB_FAIL timeout bypass_sent=%0d bypass_recv=%0d pipe_sent=%0d pipe_recv=%0d",
            bypass_sent,
            bypass_recv,
            pipe_sent,
            pipe_recv
        );
        $finish_and_return(1);
    end

    always @(negedge clk) begin
        if (!rst_n) begin
            bypass_s_valid <= 1'b0;
            bypass_s_data <= {DATA_WIDTH{1'b0}};
            bypass_s_sideband <= {SIDEBAND_WIDTH{1'b0}};
            pipe_s_valid <= 1'b0;
            pipe_s_data <= {DATA_WIDTH{1'b0}};
            pipe_s_sideband <= {SIDEBAND_WIDTH{1'b0}};
        end
        else begin
            if (bypass_s_valid && !bypass_s_ready_sampled) begin
                bypass_s_valid <= bypass_s_valid;
                bypass_s_data <= bypass_s_data;
                bypass_s_sideband <= bypass_s_sideband;
            end
            else if (bypass_sent < TOTAL_BEATS) begin
                rnd = $urandom(random_seed);
                if ((rnd % 100) < 75) begin
                    bypass_s_valid <= 1'b1;
                    bypass_s_data <= bypass_sent[DATA_WIDTH-1:0];
                    bypass_s_sideband <= (bypass_sent ^ 3'h5);
                end
                else begin
                    bypass_s_valid <= 1'b0;
                end
            end
            else begin
                bypass_s_valid <= 1'b0;
            end

            if (pipe_s_valid && !pipe_s_ready_sampled) begin
                pipe_s_valid <= pipe_s_valid;
                pipe_s_data <= pipe_s_data;
                pipe_s_sideband <= pipe_s_sideband;
            end
            else if (pipe_sent < TOTAL_BEATS) begin
                rnd = $urandom(random_seed);
                if ((rnd % 100) < 78) begin
                    pipe_s_valid <= 1'b1;
                    pipe_s_data <= pipe_sent[DATA_WIDTH-1:0];
                    pipe_s_sideband <= (pipe_sent ^ 3'h2);
                end
                else begin
                    pipe_s_valid <= 1'b0;
                end
            end
            else begin
                pipe_s_valid <= 1'b0;
            end
        end
    end

    always @(negedge clk) begin
        if (!rst_n) begin
            bypass_m_ready <= 1'b0;
            pipe_m_ready <= 1'b0;
        end
        else begin
            rnd = $urandom(random_seed);
            bypass_m_ready <= ((rnd % 100) < 70);
            rnd = $urandom(random_seed);
            pipe_m_ready <= ((rnd % 100) < 65);
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            if (bypass_m_valid !== 1'b0 || pipe_m_valid !== 1'b0) begin
                $display("REGISTER_SLICE_TB_FAIL output valid active during reset at time %0t", $time);
                failures = failures + 1;
            end
            prev_bypass_valid <= 1'b0;
            prev_bypass_ready <= 1'b0;
            prev_bypass_data <= {DATA_WIDTH{1'b0}};
            prev_bypass_side <= {SIDEBAND_WIDTH{1'b0}};
            prev_pipe_valid <= 1'b0;
            prev_pipe_ready <= 1'b0;
            prev_pipe_data <= {DATA_WIDTH{1'b0}};
            prev_pipe_side <= {SIDEBAND_WIDTH{1'b0}};
        end
        else begin
            if (bypass_s_valid && bypass_s_ready) begin
                bypass_model_data[bypass_tail] = bypass_s_data;
                bypass_model_side[bypass_tail] = bypass_s_sideband;
                bypass_tail = (bypass_tail + 1) % MODEL_CAPACITY;
                bypass_count = bypass_count + 1;
                bypass_sent = bypass_sent + 1;
            end
            if (pipe_s_valid && pipe_s_ready) begin
                pipe_model_data[pipe_tail] = pipe_s_data;
                pipe_model_side[pipe_tail] = pipe_s_sideband;
                pipe_tail = (pipe_tail + 1) % MODEL_CAPACITY;
                pipe_count = pipe_count + 1;
                pipe_sent = pipe_sent + 1;
            end

            bypass_s_ready_sampled <= bypass_s_ready;
            pipe_s_ready_sampled <= pipe_s_ready;

            if (prev_bypass_valid && !prev_bypass_ready) begin
                if (!bypass_m_valid || bypass_m_data !== prev_bypass_data || bypass_m_sideband !== prev_bypass_side) begin
                    $display("REGISTER_SLICE_TB_FAIL bypass output changed while stalled at time %0t", $time);
                    failures = failures + 1;
                end
            end
            if (prev_pipe_valid && !prev_pipe_ready) begin
                if (!pipe_m_valid || pipe_m_data !== prev_pipe_data || pipe_m_sideband !== prev_pipe_side) begin
                    $display("REGISTER_SLICE_TB_FAIL pipe output changed while stalled at time %0t", $time);
                    failures = failures + 1;
                end
            end

            if (bypass_m_valid && bypass_m_ready) begin
                if (bypass_count <= 0) begin
                    $display("REGISTER_SLICE_TB_FAIL bypass consumed with empty model queue at time %0t", $time);
                    failures = failures + 1;
                end
                else begin
                    if (bypass_m_data !== bypass_model_data[bypass_head] || bypass_m_sideband !== bypass_model_side[bypass_head]) begin
                        $display("REGISTER_SLICE_TB_FAIL bypass ordering mismatch at time %0t", $time);
                        failures = failures + 1;
                    end
                    bypass_head = (bypass_head + 1) % MODEL_CAPACITY;
                    bypass_count = bypass_count - 1;
                    bypass_recv = bypass_recv + 1;
                end
            end
            if (pipe_m_valid && pipe_m_ready) begin
                if (pipe_count <= 0) begin
                    $display("REGISTER_SLICE_TB_FAIL pipe consumed with empty model queue at time %0t", $time);
                    failures = failures + 1;
                end
                else begin
                    if (pipe_m_data !== pipe_model_data[pipe_head] || pipe_m_sideband !== pipe_model_side[pipe_head]) begin
                        $display("REGISTER_SLICE_TB_FAIL pipe ordering mismatch at time %0t", $time);
                        failures = failures + 1;
                    end
                    pipe_head = (pipe_head + 1) % MODEL_CAPACITY;
                    pipe_count = pipe_count - 1;
                    pipe_recv = pipe_recv + 1;
                end
            end

            prev_bypass_valid <= bypass_m_valid;
            prev_bypass_ready <= bypass_m_ready;
            prev_bypass_data <= bypass_m_data;
            prev_bypass_side <= bypass_m_sideband;
            prev_pipe_valid <= pipe_m_valid;
            prev_pipe_ready <= pipe_m_ready;
            prev_pipe_data <= pipe_m_data;
            prev_pipe_side <= pipe_m_sideband;
        end
    end
endmodule
