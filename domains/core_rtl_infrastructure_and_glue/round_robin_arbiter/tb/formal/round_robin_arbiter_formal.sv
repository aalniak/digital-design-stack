module round_robin_arbiter_formal;
    localparam integer NUM_REQUESTERS = 4;
    localparam integer INDEX_WIDTH = (NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS);

    wire clk = 1'b0;
    wire rst_n = 1'b1;

    (* anyseq *) reg [NUM_REQUESTERS-1:0] request;
    (* anyseq *) reg [NUM_REQUESTERS-1:0] mask;
    (* anyseq *) reg advance;
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

    always @(*) begin
        assert((grant_onehot & ~(request & mask)) == {NUM_REQUESTERS{1'b0}});
        assert(grant_valid == (grant_onehot != {NUM_REQUESTERS{1'b0}}));
        assert((grant_onehot == {NUM_REQUESTERS{1'b0}}) || ((grant_onehot & (grant_onehot - {{(NUM_REQUESTERS-1){1'b0}}, 1'b1})) == {NUM_REQUESTERS{1'b0}}));
    end
endmodule
