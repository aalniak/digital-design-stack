module packetizer_tb;
    reg clk;
    reg rst_n;

    reg side_s_valid;
    wire side_s_ready;
    reg [15:0] side_s_data;
    reg side_s_first;
    reg side_s_last;
    reg [3:0] side_s_type;
    reg [7:0] side_s_length;
    reg side_s_error;
    wire side_m_valid;
    reg side_m_ready;
    wire [15:0] side_m_data;
    wire side_m_first;
    wire side_m_last;
    wire side_m_header;
    wire [3:0] side_m_type;
    wire [7:0] side_m_length;
    wire side_m_error;
    wire side_protocol_error;
    wire side_busy;

    reg hdr_s_valid;
    wire hdr_s_ready;
    reg [15:0] hdr_s_data;
    reg hdr_s_first;
    reg hdr_s_last;
    reg [3:0] hdr_s_type;
    reg [7:0] hdr_s_length;
    reg hdr_s_error;
    wire hdr_m_valid;
    reg hdr_m_ready;
    wire [15:0] hdr_m_data;
    wire hdr_m_first;
    wire hdr_m_last;
    wire hdr_m_header;
    wire [3:0] hdr_m_type;
    wire [7:0] hdr_m_length;
    wire hdr_m_error;
    wire hdr_protocol_error;
    wire hdr_busy;

    packetizer #(
        .DATA_WIDTH(16),
        .TYPE_WIDTH(4),
        .LENGTH_WIDTH(8),
        .HEADER_MODE(0),
        .AUTO_CLOSE_EN(1),
        .TRAILER_EN(0)
    ) sideband_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(side_s_valid),
        .s_ready(side_s_ready),
        .s_data(side_s_data),
        .s_first(side_s_first),
        .s_last(side_s_last),
        .s_type(side_s_type),
        .s_length(side_s_length),
        .s_error(side_s_error),
        .m_valid(side_m_valid),
        .m_ready(side_m_ready),
        .m_data(side_m_data),
        .m_first(side_m_first),
        .m_last(side_m_last),
        .m_header(side_m_header),
        .m_type(side_m_type),
        .m_length(side_m_length),
        .m_error(side_m_error),
        .protocol_error(side_protocol_error),
        .busy(side_busy)
    );

    packetizer #(
        .DATA_WIDTH(16),
        .TYPE_WIDTH(4),
        .LENGTH_WIDTH(8),
        .HEADER_MODE(1),
        .AUTO_CLOSE_EN(0),
        .TRAILER_EN(0)
    ) header_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(hdr_s_valid),
        .s_ready(hdr_s_ready),
        .s_data(hdr_s_data),
        .s_first(hdr_s_first),
        .s_last(hdr_s_last),
        .s_type(hdr_s_type),
        .s_length(hdr_s_length),
        .s_error(hdr_s_error),
        .m_valid(hdr_m_valid),
        .m_ready(hdr_m_ready),
        .m_data(hdr_m_data),
        .m_first(hdr_m_first),
        .m_last(hdr_m_last),
        .m_header(hdr_m_header),
        .m_type(hdr_m_type),
        .m_length(hdr_m_length),
        .m_error(hdr_m_error),
        .protocol_error(hdr_protocol_error),
        .busy(hdr_busy)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("PACKETIZER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic step_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        side_s_valid = 1'b0;
        side_s_data = 16'h0000;
        side_s_first = 1'b0;
        side_s_last = 1'b0;
        side_s_type = 4'h0;
        side_s_length = 8'h00;
        side_s_error = 1'b0;
        side_m_ready = 1'b0;

        hdr_s_valid = 1'b0;
        hdr_s_data = 16'h0000;
        hdr_s_first = 1'b0;
        hdr_s_last = 1'b0;
        hdr_s_type = 4'h0;
        hdr_s_length = 8'h00;
        hdr_s_error = 1'b0;
        hdr_m_ready = 1'b0;

        repeat (3) begin
            @(negedge clk);
            if (side_m_valid !== 1'b0 || hdr_m_valid !== 1'b0) begin
                fail("outputs must stay idle during reset");
            end
            if (side_busy !== 1'b0 || hdr_busy !== 1'b0) begin
                fail("busy must stay low during reset");
            end
            if (side_protocol_error !== 1'b0 || hdr_protocol_error !== 1'b0) begin
                fail("protocol_error must stay low during reset");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        side_s_valid = 1'b1;
        side_s_data = 16'h1111;
        side_s_first = 1'b0;
        side_s_last = 1'b0;
        side_s_type = 4'h2;
        side_s_length = 8'd2;
        side_s_error = 1'b0;
        side_m_ready = 1'b0;
        #1;
        if (side_s_ready !== 1'b1) begin
            fail("sideband mode should accept a first beat when idle");
        end
        step_clock();
        if (side_m_valid !== 1'b1 || side_m_header !== 1'b0 || side_m_first !== 1'b1 || side_m_last !== 1'b0) begin
            fail("sideband first output mismatch");
        end
        if (side_m_data !== 16'h1111 || side_m_type !== 4'h2 || side_m_length !== 8'd2 || side_m_error !== 1'b0) begin
            fail("sideband first metadata mismatch");
        end
        if (side_protocol_error !== 1'b1) begin
            fail("missing s_first should set sticky protocol_error");
        end

        @(negedge clk);
        side_s_valid = 1'b0;
        side_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        side_s_valid = 1'b1;
        side_s_data = 16'h2222;
        side_s_first = 1'b0;
        side_s_last = 1'b1;
        side_s_type = 4'hf;
        side_s_length = 8'hff;
        side_s_error = 1'b1;
        side_m_ready = 1'b0;
        #1;
        if (side_s_ready !== 1'b1) begin
            fail("sideband mode should accept a continuation beat");
        end
        step_clock();
        if (side_m_valid !== 1'b1 || side_m_header !== 1'b0 || side_m_first !== 1'b0 || side_m_last !== 1'b1) begin
            fail("sideband final output mismatch");
        end
        if (side_m_data !== 16'h2222 || side_m_type !== 4'h2 || side_m_length !== 8'd2 || side_m_error !== 1'b0) begin
            fail("sideband continuation must reuse packet metadata");
        end

        @(negedge clk);
        side_s_valid = 1'b0;
        side_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        side_s_valid = 1'b1;
        side_s_data = 16'h3333;
        side_s_first = 1'b1;
        side_s_last = 1'b1;
        side_s_type = 4'h4;
        side_s_length = 8'd1;
        side_s_error = 1'b1;
        side_m_ready = 1'b0;
        step_clock();
        if (side_m_valid !== 1'b1 || side_m_first !== 1'b1 || side_m_last !== 1'b1 || side_m_header !== 1'b0) begin
            fail("sideband single-beat packet mismatch");
        end
        if (side_m_data !== 16'h3333 || side_m_type !== 4'h4 || side_m_length !== 8'd1 || side_m_error !== 1'b1) begin
            fail("sideband single-beat metadata mismatch");
        end
        if (side_protocol_error !== 1'b1) begin
            fail("protocol_error should remain sticky after being set");
        end

        @(negedge clk);
        side_s_valid = 1'b0;
        side_m_ready = 1'b1;
        step_clock();

        @(negedge clk);
        hdr_s_valid = 1'b1;
        hdr_s_data = 16'h0a1a;
        hdr_s_first = 1'b1;
        hdr_s_last = 1'b0;
        hdr_s_type = 4'h3;
        hdr_s_length = 8'd2;
        hdr_s_error = 1'b1;
        hdr_m_ready = 1'b0;
        #1;
        if (hdr_s_ready !== 1'b1) begin
            fail("header mode should accept a first payload beat when idle");
        end
        step_clock();
        if (hdr_m_valid !== 1'b1 || hdr_m_header !== 1'b1 || hdr_m_first !== 1'b1 || hdr_m_last !== 1'b0) begin
            fail("header mode should emit a synthetic header first");
        end
        if (hdr_m_data !== 16'h1302 || hdr_m_type !== 4'h3 || hdr_m_length !== 8'd2 || hdr_m_error !== 1'b1) begin
            fail("header beat encoding mismatch");
        end

        @(negedge clk);
        #1;
        if (hdr_s_ready !== 1'b0) begin
            fail("header mode should stall input while the first payload beat is held");
        end
        if (hdr_m_data !== 16'h1302 || hdr_m_header !== 1'b1) begin
            fail("header beat should remain stable under stall");
        end
        step_clock();

        @(negedge clk);
        hdr_m_ready = 1'b1;
        hdr_s_valid = 1'b0;
        step_clock();
        if (hdr_m_valid !== 1'b1 || hdr_m_header !== 1'b0 || hdr_m_first !== 1'b0 || hdr_m_last !== 1'b0) begin
            fail("held first payload beat should follow the header");
        end
        if (hdr_m_data !== 16'h0a1a || hdr_m_type !== 4'h3 || hdr_m_length !== 8'd2 || hdr_m_error !== 1'b1) begin
            fail("held first payload metadata mismatch");
        end

        @(negedge clk);
        hdr_s_valid = 1'b1;
        hdr_s_data = 16'h0b2b;
        hdr_s_first = 1'b0;
        hdr_s_last = 1'b1;
        hdr_s_type = 4'hf;
        hdr_s_length = 8'hff;
        hdr_s_error = 1'b0;
        hdr_m_ready = 1'b1;
        #1;
        if (hdr_s_ready !== 1'b1) begin
            fail("header mode should resume accepting payload after the held beat is released");
        end
        step_clock();
        if (hdr_m_valid !== 1'b1 || hdr_m_header !== 1'b0 || hdr_m_first !== 1'b0 || hdr_m_last !== 1'b1) begin
            fail("header mode final payload beat mismatch");
        end
        if (hdr_m_data !== 16'h0b2b || hdr_m_type !== 4'h3 || hdr_m_length !== 8'd2 || hdr_m_error !== 1'b1) begin
            fail("header mode should reuse packet metadata on continuation beats");
        end

        @(negedge clk);
        hdr_s_valid = 1'b0;
        hdr_m_ready = 1'b1;
        step_clock();
        if (hdr_busy !== 1'b0) begin
            fail("header mode should return idle after payload completion");
        end
        if (hdr_protocol_error !== 1'b0) begin
            fail("header mode should not raise protocol_error in the clean-path test");
        end

        $display("PACKETIZER_TB_PASS");
        $finish;
    end
endmodule
