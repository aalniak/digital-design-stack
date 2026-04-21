module round_robin_arbiter_tb;
    localparam integer NUM_REQUESTERS = 4;
    localparam integer INDEX_WIDTH = (NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS);

    reg clk;
    reg rst_n;
    reg [NUM_REQUESTERS-1:0] request;
    reg [NUM_REQUESTERS-1:0] mask;
    reg advance;
    wire [NUM_REQUESTERS-1:0] grant_onehot;
    wire grant_valid;
    wire [INDEX_WIDTH-1:0] grant_index;

    round_robin_arbiter #(
        .NUM_REQUESTERS(NUM_REQUESTERS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .request(request),
        .mask(mask),
        .advance(advance),
        .grant_onehot(grant_onehot),
        .grant_valid(grant_valid),
        .grant_index(grant_index)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("ROUND_ROBIN_ARBITER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic apply_inputs;
        input [NUM_REQUESTERS-1:0] request_i;
        input [NUM_REQUESTERS-1:0] mask_i;
        input advance_i;
        begin
            @(negedge clk);
            request = request_i;
            mask = mask_i;
            advance = advance_i;
            #1;
        end
    endtask

    task automatic advance_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        request = {NUM_REQUESTERS{1'b0}};
        mask = {NUM_REQUESTERS{1'b1}};
        advance = 1'b0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        apply_inputs(4'b0111, 4'b1111, 1'b1);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b0001 || grant_index !== 0) begin
            fail("first round-robin grant should start at requester 0");
        end
        advance_clock();

        apply_inputs(4'b0111, 4'b1111, 1'b1);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b0010 || grant_index !== 1) begin
            fail("second round-robin grant should rotate to requester 1");
        end
        advance_clock();

        apply_inputs(4'b0111, 4'b1111, 1'b1);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b0100 || grant_index !== 2) begin
            fail("third round-robin grant should rotate to requester 2");
        end
        advance_clock();

        apply_inputs(4'b0111, 4'b1111, 1'b0);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b0001 || grant_index !== 0) begin
            fail("pointer should hold when advance is low");
        end
        advance_clock();

        apply_inputs(4'b1010, 4'b1111, 1'b1);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b1000 || grant_index !== 3) begin
            fail("pointer-hold release should grant requester 3 first");
        end
        advance_clock();

        apply_inputs(4'b1010, 4'b1111, 1'b1);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b0010 || grant_index !== 1) begin
            fail("wraparound search should reach requester 1");
        end
        advance_clock();

        apply_inputs(4'b1111, 4'b0101, 1'b1);
        if (grant_valid !== 1'b1 || grant_onehot !== 4'b0100 || grant_index !== 2) begin
            fail("masking should skip disabled requesters");
        end
        advance_clock();

        apply_inputs(4'b0000, 4'b1111, 1'b1);
        if (grant_valid !== 1'b0 || grant_onehot !== 4'b0000) begin
            fail("no active requests should produce no grant");
        end
        advance_clock();

        $display("ROUND_ROBIN_ARBITER_TB_PASS");
        $finish;
    end
endmodule
