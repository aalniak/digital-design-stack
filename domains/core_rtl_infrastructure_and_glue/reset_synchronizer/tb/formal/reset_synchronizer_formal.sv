module reset_synchronizer_formal;
    reg [4:0] formal_ticks;
    (* anyseq *) reg rst_tail;

    wire clk = formal_ticks[0];
    wire rst_in = (formal_ticks < 5'd3) ? 1'b0 : rst_tail;
    wire rst_out;
    wire release_done;

    reset_synchronizer #(
        .STAGES(2),
        .ACTIVE_LOW(1'b1),
        .ASYNC_ASSERT(1'b1)
    ) dut (
        .clk(clk),
        .rst_in(rst_in),
        .rst_out(rst_out),
        .release_done(release_done)
    );

    initial begin
        formal_ticks = 5'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (!rst_in) begin
            assert(!rst_out);
            assert(!release_done);
        end

        if (release_done) begin
            assert(rst_out);
        end

        assert(release_done == rst_out);
    end
endmodule
