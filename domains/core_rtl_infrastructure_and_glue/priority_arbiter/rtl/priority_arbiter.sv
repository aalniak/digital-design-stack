module priority_arbiter #(
    parameter integer NUM_REQUESTERS = 4,
    parameter integer LOW_INDEX_HIGH_PRIORITY = 1
) (
    input  wire [NUM_REQUESTERS-1:0] request,
    input  wire [NUM_REQUESTERS-1:0] mask,
    output reg  [NUM_REQUESTERS-1:0] grant_onehot,
    output reg                       grant_valid,
    output reg  [((NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS))-1:0] grant_index
);
    localparam integer INDEX_WIDTH = (NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS);

    integer idx;

    initial begin
        if (NUM_REQUESTERS < 1) begin
            $fatal(1, "priority_arbiter requires NUM_REQUESTERS >= 1");
        end
    end

    always @(*) begin
        grant_onehot = {NUM_REQUESTERS{1'b0}};
        grant_valid = 1'b0;
        grant_index = {INDEX_WIDTH{1'b0}};

        if (LOW_INDEX_HIGH_PRIORITY != 0) begin
            for (idx = 0; idx < NUM_REQUESTERS; idx = idx + 1) begin
                if (!grant_valid && request[idx] && mask[idx]) begin
                    grant_onehot[idx] = 1'b1;
                    grant_valid = 1'b1;
                    grant_index = idx[INDEX_WIDTH-1:0];
                end
            end
        end
        else begin
            for (idx = NUM_REQUESTERS - 1; idx >= 0; idx = idx - 1) begin
                if (!grant_valid && request[idx] && mask[idx]) begin
                    grant_onehot[idx] = 1'b1;
                    grant_valid = 1'b1;
                    grant_index = idx[INDEX_WIDTH-1:0];
                end
            end
        end
    end
endmodule
