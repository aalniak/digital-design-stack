`timescale 1ns/1ps

module reset_synchronizer_tb;
    localparam integer STAGES_ASYNC_LOW = 3;
    localparam integer STAGES_SYNC_HIGH = 2;

    reg clk;
    reg rst_in_low;
    reg rst_in_high;
    wire rst_out_low;
    wire release_done_low;
    wire rst_out_high;
    wire release_done_high;

    integer failures;
    integer release_count_low;
    integer release_count_high;
    reg track_release_low;
    reg track_release_high;
    reg saw_release_low;
    reg saw_release_high;

    reset_synchronizer #(
        .STAGES(STAGES_ASYNC_LOW),
        .ACTIVE_LOW(1'b1),
        .ASYNC_ASSERT(1'b1)
    ) dut_async_low (
        .clk(clk),
        .rst_in(rst_in_low),
        .rst_out(rst_out_low),
        .release_done(release_done_low)
    );

    reset_synchronizer #(
        .STAGES(STAGES_SYNC_HIGH),
        .ACTIVE_LOW(1'b0),
        .ASYNC_ASSERT(1'b0)
    ) dut_sync_high (
        .clk(clk),
        .rst_in(rst_in_high),
        .rst_out(rst_out_high),
        .release_done(release_done_high)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        failures = 0;
        release_count_low = 0;
        release_count_high = 0;
        track_release_low = 1'b0;
        track_release_high = 1'b0;
        saw_release_low = 1'b0;
        saw_release_high = 1'b0;
        rst_in_low = 1'b0;
        rst_in_high = 1'b1;

        #1;
        if (rst_out_low !== 1'b0 || release_done_low !== 1'b0) begin
            $display("RESET_SYNC_TB_FAIL active-low async instance not asserted immediately at time %0t", $time);
            failures = failures + 1;
        end

        repeat (3) @(posedge clk);
        #1;
        if (rst_out_high !== 1'b1 || release_done_high !== 1'b0) begin
            $display("RESET_SYNC_TB_FAIL active-high sync instance not asserted after startup clocks at time %0t", $time);
            failures = failures + 1;
        end

        #2;
        rst_in_low = 1'b1;
        rst_in_high = 1'b0;
        track_release_low = 1'b1;
        track_release_high = 1'b1;
        release_count_low = 0;
        release_count_high = 0;
        saw_release_low = 1'b0;
        saw_release_high = 1'b0;

        wait (saw_release_low && saw_release_high);
        #1;
        if (release_done_low !== 1'b1 || rst_out_low !== 1'b1) begin
            $display("RESET_SYNC_TB_FAIL active-low instance did not finish release cleanly at time %0t", $time);
            failures = failures + 1;
        end
        if (release_done_high !== 1'b1 || rst_out_high !== 1'b0) begin
            $display("RESET_SYNC_TB_FAIL active-high instance did not finish release cleanly at time %0t", $time);
            failures = failures + 1;
        end

        #2;
        rst_in_low = 1'b0;
        rst_in_high = 1'b1;
        #1;
        if (rst_out_low !== 1'b0 || release_done_low !== 1'b0) begin
            $display("RESET_SYNC_TB_FAIL active-low async assertion was not immediate at time %0t", $time);
            failures = failures + 1;
        end
        if (rst_out_high !== 1'b0 || release_done_high !== 1'b1) begin
            $display("RESET_SYNC_TB_FAIL active-high sync instance changed before a clock edge at time %0t", $time);
            failures = failures + 1;
        end

        @(posedge clk);
        #1;
        if (rst_out_high !== 1'b1 || release_done_high !== 1'b0) begin
            $display("RESET_SYNC_TB_FAIL active-high sync assertion did not occur on a clock edge at time %0t", $time);
            failures = failures + 1;
        end

        #2;
        rst_in_low = 1'b1;
        rst_in_high = 1'b0;
        track_release_low = 1'b1;
        track_release_high = 1'b1;
        release_count_low = 0;
        release_count_high = 0;
        saw_release_low = 1'b0;
        saw_release_high = 1'b0;

        wait (saw_release_low && saw_release_high);
        repeat (2) @(posedge clk);

        if (failures != 0) begin
            $display("RESET_SYNC_TB_FAIL failures=%0d", failures);
            $finish_and_return(1);
        end

        $display(
            "RESET_SYNCHRONIZER_TB_PASS low_release=%0d high_release=%0d",
            STAGES_ASYNC_LOW,
            STAGES_SYNC_HIGH
        );
        $finish;
    end

    initial begin
        #5000;
        $display("RESET_SYNC_TB_FAIL timeout failures=%0d", failures);
        $finish_and_return(1);
    end

    always @(posedge clk) begin
        #1;
        if (track_release_low && !saw_release_low) begin
            release_count_low = release_count_low + 1;
            if (rst_out_low === 1'b1) begin
                if (release_count_low != STAGES_ASYNC_LOW) begin
                    $display(
                        "RESET_SYNC_TB_FAIL active-low release latency expected=%0d got=%0d at time %0t",
                        STAGES_ASYNC_LOW,
                        release_count_low,
                        $time
                    );
                    failures = failures + 1;
                end
                saw_release_low = 1'b1;
                track_release_low = 1'b0;
            end
        end

        if (track_release_high && !saw_release_high) begin
            release_count_high = release_count_high + 1;
            if (rst_out_high === 1'b0) begin
                if (release_count_high != STAGES_SYNC_HIGH) begin
                    $display(
                        "RESET_SYNC_TB_FAIL active-high release latency expected=%0d got=%0d at time %0t",
                        STAGES_SYNC_HIGH,
                        release_count_high,
                        $time
                    );
                    failures = failures + 1;
                end
                saw_release_high = 1'b1;
                track_release_high = 1'b0;
            end
        end
    end
endmodule
