module stream_mux_tb;
    localparam integer NUM_INPUTS = 3;
    localparam integer DATA_WIDTH = 8;
    localparam integer SIDEBAND_WIDTH = 2;
    localparam integer ID_WIDTH = $clog2(NUM_INPUTS);

    reg clk;
    reg rst_n;

    reg [NUM_INPUTS-1:0] pri_s_valid;
    wire [NUM_INPUTS-1:0] pri_s_ready;
    reg [NUM_INPUTS*DATA_WIDTH-1:0] pri_s_data;
    reg [NUM_INPUTS*SIDEBAND_WIDTH-1:0] pri_s_sideband;
    reg [NUM_INPUTS-1:0] pri_s_last;
    wire pri_m_valid;
    reg pri_m_ready;
    wire [DATA_WIDTH-1:0] pri_m_data;
    wire [SIDEBAND_WIDTH-1:0] pri_m_sideband;
    wire pri_m_last;
    wire [ID_WIDTH-1:0] pri_m_source_id;
    wire pri_held_active;
    wire [ID_WIDTH-1:0] pri_held_id;

    reg [NUM_INPUTS-1:0] rr_s_valid;
    wire [NUM_INPUTS-1:0] rr_s_ready;
    reg [NUM_INPUTS*DATA_WIDTH-1:0] rr_s_data;
    reg [NUM_INPUTS*SIDEBAND_WIDTH-1:0] rr_s_sideband;
    reg [NUM_INPUTS-1:0] rr_s_last;
    wire rr_m_valid;
    reg rr_m_ready;
    wire [DATA_WIDTH-1:0] rr_m_data;
    wire [SIDEBAND_WIDTH-1:0] rr_m_sideband;
    wire rr_m_last;
    wire [ID_WIDTH-1:0] rr_m_source_id;
    wire rr_held_active;
    wire [ID_WIDTH-1:0] rr_held_id;

    function automatic [DATA_WIDTH-1:0] input_data;
        input [NUM_INPUTS*DATA_WIDTH-1:0] bus_value;
        input integer idx;
        begin
            input_data = bus_value[(idx*DATA_WIDTH) +: DATA_WIDTH];
        end
    endfunction

    function automatic [SIDEBAND_WIDTH-1:0] input_sideband;
        input [NUM_INPUTS*SIDEBAND_WIDTH-1:0] bus_value;
        input integer idx;
        begin
            input_sideband = bus_value[(idx*SIDEBAND_WIDTH) +: SIDEBAND_WIDTH];
        end
    endfunction

    stream_mux #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .ARBITRATION_MODE(0),
        .HOLD_UNTIL_LAST(1),
        .SOURCE_ID_EN(1)
    ) pri_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(pri_s_valid),
        .s_ready(pri_s_ready),
        .s_data(pri_s_data),
        .s_sideband(pri_s_sideband),
        .s_last(pri_s_last),
        .m_valid(pri_m_valid),
        .m_ready(pri_m_ready),
        .m_data(pri_m_data),
        .m_sideband(pri_m_sideband),
        .m_last(pri_m_last),
        .m_source_id(pri_m_source_id),
        .held_grant_active(pri_held_active),
        .held_grant_id(pri_held_id)
    );

    stream_mux #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH),
        .SIDEBAND_WIDTH(SIDEBAND_WIDTH),
        .ARBITRATION_MODE(1),
        .HOLD_UNTIL_LAST(1),
        .SOURCE_ID_EN(1)
    ) rr_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(rr_s_valid),
        .s_ready(rr_s_ready),
        .s_data(rr_s_data),
        .s_sideband(rr_s_sideband),
        .s_last(rr_s_last),
        .m_valid(rr_m_valid),
        .m_ready(rr_m_ready),
        .m_data(rr_m_data),
        .m_sideband(rr_m_sideband),
        .m_last(rr_m_last),
        .m_source_id(rr_m_source_id),
        .held_grant_active(rr_held_active),
        .held_grant_id(rr_held_id)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("STREAM_MUX_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic set_priority_input;
        input integer idx;
        input valid;
        input [DATA_WIDTH-1:0] data;
        input [SIDEBAND_WIDTH-1:0] sideband;
        input last;
        begin
            pri_s_valid[idx] = valid;
            pri_s_data[(idx*DATA_WIDTH) +: DATA_WIDTH] = data;
            pri_s_sideband[(idx*SIDEBAND_WIDTH) +: SIDEBAND_WIDTH] = sideband;
            pri_s_last[idx] = last;
        end
    endtask

    task automatic set_rr_input;
        input integer idx;
        input valid;
        input [DATA_WIDTH-1:0] data;
        input [SIDEBAND_WIDTH-1:0] sideband;
        input last;
        begin
            rr_s_valid[idx] = valid;
            rr_s_data[(idx*DATA_WIDTH) +: DATA_WIDTH] = data;
            rr_s_sideband[(idx*SIDEBAND_WIDTH) +: SIDEBAND_WIDTH] = sideband;
            rr_s_last[idx] = last;
        end
    endtask

    task automatic advance_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        integer idx;

        clk = 1'b0;
        rst_n = 1'b0;
        pri_s_valid = {NUM_INPUTS{1'b0}};
        pri_s_data = {(NUM_INPUTS*DATA_WIDTH){1'b0}};
        pri_s_sideband = {(NUM_INPUTS*SIDEBAND_WIDTH){1'b0}};
        pri_s_last = {NUM_INPUTS{1'b0}};
        pri_m_ready = 1'b0;
        rr_s_valid = {NUM_INPUTS{1'b0}};
        rr_s_data = {(NUM_INPUTS*DATA_WIDTH){1'b0}};
        rr_s_sideband = {(NUM_INPUTS*SIDEBAND_WIDTH){1'b0}};
        rr_s_last = {NUM_INPUTS{1'b0}};
        rr_m_ready = 1'b0;

        repeat (3) begin
            @(negedge clk);
            if (pri_m_valid !== 1'b0 || rr_m_valid !== 1'b0) begin
                fail("mux outputs must be idle during reset");
            end
            if (pri_held_active !== 1'b0 || rr_held_active !== 1'b0) begin
                fail("held state must clear during reset");
            end
        end

        @(negedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        set_priority_input(0, 1'b1, 8'h10, 2'h0, 1'b1);
        set_priority_input(2, 1'b1, 8'h22, 2'h2, 1'b1);
        pri_m_ready = 1'b1;
        #1;
        if (pri_m_valid !== 1'b1 || pri_m_source_id !== 0 || pri_m_data !== 8'h10 || pri_m_last !== 1'b1) begin
            fail("priority arbitration should pick input 0");
        end
        if (pri_s_ready !== 3'b001) begin
            fail("only the granted priority input should see ready");
        end
        advance_clock();

        @(negedge clk);
        pri_m_ready = 1'b0;
        #1;
        if (pri_s_ready !== 3'b000) begin
            fail("selected input should backpressure with downstream stall");
        end

        @(negedge clk);
        pri_s_valid = 3'b000;
        set_priority_input(1, 1'b1, 8'ha1, 2'h1, 1'b0);
        pri_m_ready = 1'b1;
        #1;
        if (pri_m_source_id !== 1 || pri_m_data !== 8'ha1 || pri_m_last !== 1'b0) begin
            fail("priority first packet beat mismatch");
        end
        advance_clock();
        if (pri_held_active !== 1'b1 || pri_held_id !== 1) begin
            fail("priority mux should hold the granted packet source");
        end

        @(negedge clk);
        set_priority_input(0, 1'b1, 8'h05, 2'h0, 1'b1);
        set_priority_input(1, 1'b1, 8'ha2, 2'h2, 1'b1);
        pri_m_ready = 1'b1;
        #1;
        if (pri_m_source_id !== 1 || pri_m_data !== 8'ha2 || pri_m_last !== 1'b1) begin
            fail("priority hold should keep source 1 through packet end");
        end
        advance_clock();
        if (pri_held_active !== 1'b0) begin
            fail("priority hold should clear after the last accepted beat");
        end

        @(negedge clk);
        pri_s_valid = 3'b000;
        rr_s_valid = 3'b111;
        rr_s_data = {8'h30, 8'h20, 8'h10};
        rr_s_sideband = {2'h2, 2'h1, 2'h0};
        rr_s_last = 3'b111;
        rr_m_ready = 1'b1;
        #1;
        if (rr_m_valid !== 1'b1 || rr_m_source_id !== 0 || rr_m_data !== 8'h10) begin
            fail("round-robin should start at input 0");
        end
        advance_clock();

        @(negedge clk);
        #1;
        if (rr_m_source_id !== 1 || rr_m_data !== 8'h20) begin
            fail("round-robin should advance to input 1");
        end
        advance_clock();

        @(negedge clk);
        rr_s_valid = 3'b100;
        set_rr_input(0, 1'b0, 8'h00, 2'h0, 1'b0);
        set_rr_input(1, 1'b0, 8'h00, 2'h0, 1'b0);
        set_rr_input(2, 1'b1, 8'hc1, 2'h2, 1'b0);
        rr_m_ready = 1'b1;
        #1;
        if (rr_m_source_id !== 2 || rr_m_data !== 8'hc1 || rr_m_last !== 1'b0) begin
            fail("round-robin should choose input 2 for the held packet start");
        end
        advance_clock();
        if (rr_held_active !== 1'b1 || rr_held_id !== 2) begin
            fail("round-robin hold should latch input 2");
        end

        @(negedge clk);
        set_rr_input(0, 1'b1, 8'h02, 2'h0, 1'b1);
        set_rr_input(2, 1'b1, 8'hc2, 2'h2, 1'b1);
        rr_m_ready = 1'b1;
        #1;
        if (rr_m_source_id !== 2 || rr_m_data !== 8'hc2 || rr_m_last !== 1'b1) begin
            fail("round-robin hold should keep input 2 through the packet end");
        end
        advance_clock();
        if (rr_held_active !== 1'b0) begin
            fail("round-robin hold should clear after final beat");
        end

        @(negedge clk);
        rr_s_valid = 3'b001;
        set_rr_input(0, 1'b1, 8'h77, 2'h0, 1'b1);
        rr_m_ready = 1'b1;
        #1;
        if (rr_m_source_id !== 0 || rr_m_data !== 8'h77) begin
            fail("round-robin should resume after the held source");
        end

        $display("STREAM_MUX_TB_PASS");
        $finish;
    end
endmodule
