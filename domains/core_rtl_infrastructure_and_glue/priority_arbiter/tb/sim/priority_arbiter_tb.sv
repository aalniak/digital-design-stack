module priority_arbiter_tb;
    localparam integer NUM_REQUESTERS = 4;
    localparam integer INDEX_WIDTH = (NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS);

    reg [NUM_REQUESTERS-1:0] request;
    reg [NUM_REQUESTERS-1:0] mask;

    wire [NUM_REQUESTERS-1:0] low_grant_onehot;
    wire low_grant_valid;
    wire [INDEX_WIDTH-1:0] low_grant_index;

    wire [NUM_REQUESTERS-1:0] high_grant_onehot;
    wire high_grant_valid;
    wire [INDEX_WIDTH-1:0] high_grant_index;

    priority_arbiter #(
        .NUM_REQUESTERS(NUM_REQUESTERS),
        .LOW_INDEX_HIGH_PRIORITY(1)
    ) low_first_dut (
        .request(request),
        .mask(mask),
        .grant_onehot(low_grant_onehot),
        .grant_valid(low_grant_valid),
        .grant_index(low_grant_index)
    );

    priority_arbiter #(
        .NUM_REQUESTERS(NUM_REQUESTERS),
        .LOW_INDEX_HIGH_PRIORITY(0)
    ) high_first_dut (
        .request(request),
        .mask(mask),
        .grant_onehot(high_grant_onehot),
        .grant_valid(high_grant_valid),
        .grant_index(high_grant_index)
    );

    task automatic fail;
        input [1023:0] message;
        begin
            $display("PRIORITY_ARBITER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    initial begin
        request = 4'b0000;
        mask = 4'b1111;
        #1;
        if (low_grant_valid !== 1'b0 || low_grant_onehot !== 4'b0000) begin
            fail("low-priority instance should idle with no requests");
        end
        if (high_grant_valid !== 1'b0 || high_grant_onehot !== 4'b0000) begin
            fail("high-priority instance should idle with no requests");
        end

        request = 4'b1010;
        mask = 4'b1111;
        #1;
        if (low_grant_valid !== 1'b1 || low_grant_onehot !== 4'b0010 || low_grant_index !== 1) begin
            fail("low-index priority selection mismatch");
        end
        if (high_grant_valid !== 1'b1 || high_grant_onehot !== 4'b1000 || high_grant_index !== 3) begin
            fail("high-index priority selection mismatch");
        end

        request = 4'b1111;
        mask = 4'b0101;
        #1;
        if (low_grant_valid !== 1'b1 || low_grant_onehot !== 4'b0001 || low_grant_index !== 0) begin
            fail("low-index masking mismatch");
        end
        if (high_grant_valid !== 1'b1 || high_grant_onehot !== 4'b0100 || high_grant_index !== 2) begin
            fail("high-index masking mismatch");
        end

        request = 4'b1111;
        mask = 4'b0000;
        #1;
        if (low_grant_valid !== 1'b0 || low_grant_onehot !== 4'b0000) begin
            fail("masked-off requests should not produce a low-index grant");
        end
        if (high_grant_valid !== 1'b0 || high_grant_onehot !== 4'b0000) begin
            fail("masked-off requests should not produce a high-index grant");
        end

        $display("PRIORITY_ARBITER_TB_PASS");
        $finish;
    end
endmodule
