module priority_arbiter_formal;
    localparam integer NUM_REQUESTERS = 4;
    localparam integer INDEX_WIDTH = (NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS);

    (* anyseq *) reg [NUM_REQUESTERS-1:0] request;
    (* anyseq *) reg [NUM_REQUESTERS-1:0] mask;
    wire [NUM_REQUESTERS-1:0] grant_onehot;
    wire grant_valid;
    wire [INDEX_WIDTH-1:0] grant_index;

    priority_arbiter #(
        .NUM_REQUESTERS(NUM_REQUESTERS),
        .LOW_INDEX_HIGH_PRIORITY(1)
    ) dut (
        .request(request),
        .mask(mask),
        .grant_onehot(grant_onehot),
        .grant_valid(grant_valid),
        .grant_index(grant_index)
    );

    always @(*) begin
        assert((grant_onehot & ~(request & mask)) == {NUM_REQUESTERS{1'b0}});
        assert(grant_valid == (grant_onehot != {NUM_REQUESTERS{1'b0}}));
        assert((grant_onehot == {NUM_REQUESTERS{1'b0}}) || ((grant_onehot & (grant_onehot - {{(NUM_REQUESTERS-1){1'b0}}, 1'b1})) == {NUM_REQUESTERS{1'b0}}));
    end
endmodule
