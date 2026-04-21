module stream_demux_tb;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 2;
    localparam integer NUM_OUTPUTS = 3;
    localparam integer SELECT_WIDTH = $clog2(NUM_OUTPUTS);

    reg clk;
    reg rst_n;
    reg s_valid;
    wire s_ready;
    reg [DATA_WIDTH-1:0] s_data;
    reg [SIDEBAND_WIDTH-1:0] s_sideband;
    reg s_last;
    reg [SELECT_WIDTH-1:0] s_select;
    wire [NUM_OUTPUTS-1:0] m_valid;
    reg [NUM_OUTPUTS-1:0] m_ready;
    wire [NUM_OUTPUTS*DATA_WIDTH-1:0] m_data;
    wire [NUM_OUTPUTS*SIDEBAND_WIDTH-1:0] m_sideband;
    wire [NUM_OUTPUTS-1:0] m_last;
    wire invalid_route;
    wire held_route_active;
    wire [SELECT_WIDTH-1:0] held_route_select;

    function automatic [DATA_WIDTH-1:0] out_data;
        input integer idx;
        begin
            out_data = m_data[(idx*DATA_WIDTH) +: DATA_WIDTH];
        end
    endfunction

    function automatic [SIDEBAND_WIDTH-1:0] out_sideband;
        input integer idx;
        begin
            out_sideband = m_sideband[(idx*SIDEBAND_WIDTH) +: SIDEBAND_WIDTH];
        end
    endfunction

    stream_demux #(
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .NUM_OUTPUTS(NUM_OUTPUTS),
        .HOLD_ROUTE_UNTIL_LAST(1),
        .DROP_ON_INVALID(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_data(s_data),
        .s_sideband(s_sideband),
        .s_last(s_last),
        .s_select(s_select),
        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_data(m_data),
        .m_sideband(m_sideband),
        .m_last(m_last),
        .invalid_route(invalid_route),
        .held_route_active(held_route_active),
        .held_route_select(held_route_select)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("STREAM_DEMUX_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic drive;
        input drive_valid;
        input [DATA_WIDTH-1:0] drive_data;
        input [SIDEBAND_WIDTH-1:0] drive_sideband;
        input drive_last;
        input [SELECT_WIDTH-1:0] drive_select;
        input [NUM_OUTPUTS-1:0] drive_ready;
        begin
            @(negedge clk);
            s_valid = drive_valid;
            s_data = drive_data;
            s_sideband = drive_sideband;
            s_last = drive_last;
            s_select = drive_select;
            m_ready = drive_ready;
            #1;
        end
    endtask

    task automatic step;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task automatic expect_route;
        input [NUM_OUTPUTS-1:0] expected_valid;
        input expected_ready;
        input expected_invalid;
        input expected_hold;
        input [SELECT_WIDTH-1:0] expected_hold_select;
        input integer payload_idx;
        input [DATA_WIDTH-1:0] expected_data;
        input [SIDEBAND_WIDTH-1:0] expected_sideband;
        input expected_last;
        integer idx;
        begin
            if (m_valid !== expected_valid) begin
                fail("m_valid vector mismatch");
            end
            if (s_ready !== expected_ready) begin
                fail("s_ready mismatch");
            end
            if (invalid_route !== expected_invalid) begin
                fail("invalid_route mismatch");
            end
            if (held_route_active !== expected_hold) begin
                fail("held_route_active mismatch");
            end
            if (expected_hold && (held_route_select !== expected_hold_select)) begin
                fail("held_route_select mismatch");
            end
            for (idx = 0; idx < NUM_OUTPUTS; idx = idx + 1) begin
                if (expected_valid[idx]) begin
                    if (out_data(idx) !== expected_data) begin
                        fail("routed data mismatch");
                    end
                    if (out_sideband(idx) !== expected_sideband) begin
                        fail("routed sideband mismatch");
                    end
                    if (m_last[idx] !== expected_last) begin
                        fail("routed last mismatch");
                    end
                end
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        s_valid = 1'b0;
        s_data = {DATA_WIDTH{1'b0}};
        s_sideband = {SIDEBAND_WIDTH{1'b0}};
        s_last = 1'b0;
        s_select = {SELECT_WIDTH{1'b0}};
        m_ready = {NUM_OUTPUTS{1'b0}};

        repeat (3) begin
            @(negedge clk);
            if (m_valid !== {NUM_OUTPUTS{1'b0}}) begin
                fail("outputs must be idle during reset");
            end
            if (held_route_active !== 1'b0) begin
                fail("held route must be inactive during reset");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;

        drive(1'b1, 8'h55, 2'h1, 1'b1, 2'd2, 3'b111);
        expect_route(3'b100, 1'b1, 1'b0, 1'b0, 2'd0, 2, 8'h55, 2'h1, 1'b1);
        step();

        drive(1'b1, 8'h66, 2'h2, 1'b1, 2'd0, 3'b110);
        expect_route(3'b001, 1'b0, 1'b0, 1'b0, 2'd0, 0, 8'h66, 2'h2, 1'b1);
        step();

        drive(1'b1, 8'h66, 2'h2, 1'b1, 2'd0, 3'b111);
        expect_route(3'b001, 1'b1, 1'b0, 1'b0, 2'd0, 0, 8'h66, 2'h2, 1'b1);
        step();

        drive(1'b1, 8'ha1, 2'h0, 1'b0, 2'd1, 3'b111);
        expect_route(3'b010, 1'b1, 1'b0, 1'b0, 2'd0, 1, 8'ha1, 2'h0, 1'b0);
        step();
        if (held_route_active !== 1'b1 || held_route_select !== 2'd1) begin
            fail("held route should latch after the first non-last packet beat");
        end

        drive(1'b1, 8'ha2, 2'h1, 1'b0, 2'd2, 3'b111);
        expect_route(3'b010, 1'b1, 1'b0, 1'b1, 2'd1, 1, 8'ha2, 2'h1, 1'b0);
        step();

        drive(1'b1, 8'ha3, 2'h2, 1'b1, 2'd0, 3'b111);
        expect_route(3'b010, 1'b1, 1'b0, 1'b1, 2'd1, 1, 8'ha3, 2'h2, 1'b1);
        step();
        if (held_route_active !== 1'b0) begin
            fail("held route should clear after the last accepted packet beat");
        end

        drive(1'b1, 8'hf0, 2'h3, 1'b1, 2'd3, 3'b111);
        expect_route(3'b000, 1'b1, 1'b1, 1'b0, 2'd0, 0, 8'h00, 2'h0, 1'b0);
        step();
        if (held_route_active !== 1'b0) begin
            fail("invalid-route drop must not create held-route state");
        end

        drive(1'b0, 8'h00, 2'h0, 1'b0, 2'd0, 3'b111);
        expect_route(3'b000, 1'b1, 1'b0, 1'b0, 2'd0, 0, 8'h00, 2'h0, 1'b0);

        $display("STREAM_DEMUX_TB_PASS");
        $finish;
    end
endmodule
