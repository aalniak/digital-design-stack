module round_robin_arbiter #(
    parameter integer NUM_REQUESTERS = 4
) (
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire [NUM_REQUESTERS-1:0]      request,
    input  wire [NUM_REQUESTERS-1:0]      mask,
    input  wire                           advance,
    output reg  [NUM_REQUESTERS-1:0]      grant_onehot,
    output reg                            grant_valid,
    output reg  [((NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS))-1:0] grant_index
);
    localparam integer INDEX_WIDTH = (NUM_REQUESTERS <= 1) ? 1 : $clog2(NUM_REQUESTERS);

    reg [INDEX_WIDTH-1:0] rr_pointer_q;
    wire [NUM_REQUESTERS-1:0] masked_request = request & mask;

    integer offset;
    integer candidate;

    initial begin
        if (NUM_REQUESTERS < 1) begin
            $fatal(1, "round_robin_arbiter requires NUM_REQUESTERS >= 1");
        end
    end

    always @(*) begin
        grant_onehot = {NUM_REQUESTERS{1'b0}};
        grant_valid = 1'b0;
        grant_index = {INDEX_WIDTH{1'b0}};

        for (offset = 0; offset < NUM_REQUESTERS; offset = offset + 1) begin
            candidate = rr_pointer_q + offset;
            if (candidate >= NUM_REQUESTERS) begin
                candidate = candidate - NUM_REQUESTERS;
            end

            if (!grant_valid && masked_request[candidate]) begin
                grant_onehot[candidate] = 1'b1;
                grant_valid = 1'b1;
                grant_index = candidate[INDEX_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rr_pointer_q <= {INDEX_WIDTH{1'b0}};
        end
        else if (advance && grant_valid) begin
            if (grant_index == NUM_REQUESTERS - 1) begin
                rr_pointer_q <= {INDEX_WIDTH{1'b0}};
            end
            else begin
                rr_pointer_q <= grant_index + {{(INDEX_WIDTH-1){1'b0}}, 1'b1};
            end
        end
    end
endmodule
