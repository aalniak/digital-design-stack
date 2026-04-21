`timescale 1ns/1ps

module free_running_counter_tb;
    localparam integer GATED_WIDTH = 4;
    localparam integer ALWAYS_WIDTH = 3;

    reg clk;
    reg rst_n;

    reg gated_enable;
    reg gated_load;
    reg [GATED_WIDTH-1:0] gated_load_value;
    reg gated_capture;
    wire [GATED_WIDTH-1:0] gated_count_value;
    wire [GATED_WIDTH-1:0] gated_capture_value;
    wire gated_rollover_pulse;

    reg always_enable;
    reg always_load;
    reg [ALWAYS_WIDTH-1:0] always_load_value;
    reg always_capture;
    wire [ALWAYS_WIDTH-1:0] always_count_value;
    wire [ALWAYS_WIDTH-1:0] always_capture_value;
    wire always_rollover_pulse;

    reg [GATED_WIDTH-1:0] gated_model_count;
    reg [GATED_WIDTH-1:0] gated_model_capture;
    reg gated_model_rollover;

    reg [ALWAYS_WIDTH-1:0] always_model_count;
    reg [ALWAYS_WIDTH-1:0] always_model_capture;
    reg always_model_rollover;

    integer failures;
    integer idx;

    free_running_counter #(
        .COUNT_WIDTH(GATED_WIDTH),
        .RESET_VALUE(4'h3),
        .ENABLE_EN(1'b1),
        .ROLLOVER_PULSE_EN(1'b1),
        .CAPTURE_EN(1'b1)
    ) dut_gated (
        .clk(clk),
        .rst_n(rst_n),
        .enable(gated_enable),
        .load(gated_load),
        .load_value(gated_load_value),
        .capture(gated_capture),
        .count_value(gated_count_value),
        .capture_value(gated_capture_value),
        .rollover_pulse(gated_rollover_pulse)
    );

    free_running_counter #(
        .COUNT_WIDTH(ALWAYS_WIDTH),
        .RESET_VALUE({ALWAYS_WIDTH{1'b0}}),
        .ENABLE_EN(1'b0),
        .ROLLOVER_PULSE_EN(1'b1),
        .CAPTURE_EN(1'b0)
    ) dut_always (
        .clk(clk),
        .rst_n(rst_n),
        .enable(always_enable),
        .load(always_load),
        .load_value(always_load_value),
        .capture(always_capture),
        .count_value(always_count_value),
        .capture_value(always_capture_value),
        .rollover_pulse(always_rollover_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic step_both(
        input reg next_gated_enable,
        input reg next_gated_load,
        input reg [GATED_WIDTH-1:0] next_gated_load_value,
        input reg next_gated_capture,
        input reg next_always_enable,
        input reg next_always_load,
        input reg [ALWAYS_WIDTH-1:0] next_always_load_value,
        input reg next_always_capture
    );
        reg [GATED_WIDTH-1:0] gated_next_count;
        reg [GATED_WIDTH-1:0] gated_next_capture;
        reg gated_next_rollover;
        reg gated_count_now;

        reg [ALWAYS_WIDTH-1:0] always_next_count;
        reg [ALWAYS_WIDTH-1:0] always_next_capture;
        reg always_next_rollover;
        reg always_count_now;
        begin
            @(negedge clk);
            gated_enable = next_gated_enable;
            gated_load = next_gated_load;
            gated_load_value = next_gated_load_value;
            gated_capture = next_gated_capture;
            always_enable = next_always_enable;
            always_load = next_always_load;
            always_load_value = next_always_load_value;
            always_capture = next_always_capture;

            gated_count_now = next_gated_enable;
            gated_next_rollover = 1'b0;
            gated_next_count = gated_model_count;
            if (next_gated_load) begin
                gated_next_count = next_gated_load_value;
            end
            else if (gated_count_now) begin
                gated_next_count = gated_model_count + 1'b1;
                gated_next_rollover = (gated_model_count == {GATED_WIDTH{1'b1}});
            end
            if (next_gated_capture) begin
                gated_next_capture = gated_next_count;
            end
            else if (next_gated_load) begin
                gated_next_capture = next_gated_load_value;
            end
            else begin
                gated_next_capture = gated_model_capture;
            end

            always_count_now = 1'b1;
            always_next_rollover = 1'b0;
            always_next_count = always_model_count;
            if (next_always_load) begin
                always_next_count = next_always_load_value;
            end
            else if (always_count_now) begin
                always_next_count = always_model_count + 1'b1;
                always_next_rollover = (always_model_count == {ALWAYS_WIDTH{1'b1}});
            end
            always_next_capture = always_next_count;

            @(posedge clk);
            #1;

            if (gated_count_value !== gated_next_count) begin
                $display("FREE_RUNNING_COUNTER_TB_FAIL gated count expected=0x%0h got=0x%0h at time %0t", gated_next_count, gated_count_value, $time);
                failures = failures + 1;
            end
            if (gated_capture_value !== gated_next_capture) begin
                $display("FREE_RUNNING_COUNTER_TB_FAIL gated capture expected=0x%0h got=0x%0h at time %0t", gated_next_capture, gated_capture_value, $time);
                failures = failures + 1;
            end
            if (gated_rollover_pulse !== gated_next_rollover) begin
                $display("FREE_RUNNING_COUNTER_TB_FAIL gated rollover expected=%0b got=%0b at time %0t", gated_next_rollover, gated_rollover_pulse, $time);
                failures = failures + 1;
            end

            if (always_count_value !== always_next_count) begin
                $display("FREE_RUNNING_COUNTER_TB_FAIL always count expected=0x%0h got=0x%0h at time %0t", always_next_count, always_count_value, $time);
                failures = failures + 1;
            end
            if (always_capture_value !== always_next_capture) begin
                $display("FREE_RUNNING_COUNTER_TB_FAIL always capture expected=0x%0h got=0x%0h at time %0t", always_next_capture, always_capture_value, $time);
                failures = failures + 1;
            end
            if (always_rollover_pulse !== always_next_rollover) begin
                $display("FREE_RUNNING_COUNTER_TB_FAIL always rollover expected=%0b got=%0b at time %0t", always_next_rollover, always_rollover_pulse, $time);
                failures = failures + 1;
            end

            gated_model_count = gated_next_count;
            gated_model_capture = gated_next_capture;
            gated_model_rollover = gated_next_rollover;
            always_model_count = always_next_count;
            always_model_capture = always_next_capture;
            always_model_rollover = always_next_rollover;
        end
    endtask

    initial begin
        rst_n = 1'b0;
        gated_enable = 1'b0;
        gated_load = 1'b0;
        gated_load_value = {GATED_WIDTH{1'b0}};
        gated_capture = 1'b0;
        always_enable = 1'b0;
        always_load = 1'b0;
        always_load_value = {ALWAYS_WIDTH{1'b0}};
        always_capture = 1'b0;
        gated_model_count = 4'h3;
        gated_model_capture = 4'h3;
        gated_model_rollover = 1'b0;
        always_model_count = {ALWAYS_WIDTH{1'b0}};
        always_model_capture = {ALWAYS_WIDTH{1'b0}};
        always_model_rollover = 1'b0;
        failures = 0;

        repeat (2) @(posedge clk);
        #1;
        if (gated_count_value !== 4'h3 || gated_capture_value !== 4'h3 || gated_rollover_pulse !== 0) begin
            $display("FREE_RUNNING_COUNTER_TB_FAIL gated instance not reset cleanly at time %0t", $time);
            failures = failures + 1;
        end
        if (always_count_value !== 0 || always_capture_value !== 0 || always_rollover_pulse !== 0) begin
            $display("FREE_RUNNING_COUNTER_TB_FAIL always instance not reset cleanly at time %0t", $time);
            failures = failures + 1;
        end

        rst_n = 1'b1;

        step_both(0, 0, 4'h0, 0, 0, 0, 3'h0, 0);
        step_both(1, 0, 4'h0, 0, 0, 0, 3'h0, 0);
        step_both(1, 0, 4'h0, 1, 0, 0, 3'h0, 0);
        step_both(0, 1, 4'hE, 0, 0, 1, 3'h6, 0);
        step_both(1, 0, 4'h0, 0, 0, 0, 3'h0, 0);
        step_both(1, 0, 4'h0, 0, 0, 0, 3'h0, 0);

        for (idx = 0; idx < 10; idx = idx + 1) begin
            step_both(1, 0, 4'h0, 0, 0, 0, 3'h0, 0);
        end

        if (failures != 0) begin
            $display("FREE_RUNNING_COUNTER_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "FREE_RUNNING_COUNTER_TB_PASS gated_count=0x%0h always_count=0x%0h gated_roll=%0b always_roll=%0b",
            gated_count_value,
            always_count_value,
            gated_rollover_pulse,
            always_rollover_pulse
        );
        $finish;
    end

    initial begin
        #10000;
        $display("FREE_RUNNING_COUNTER_TB_FAIL timeout failures=%0d", failures);
        $finish_and_return(1);
    end
endmodule
