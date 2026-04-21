module async_fifo_core #(
    parameter integer DATA_WIDTH = 32,
    parameter integer DEPTH = 16,
    parameter integer SYNC_STAGES = 2,
    parameter integer ALMOST_FULL_THRESHOLD = DEPTH - 2,
    parameter integer ALMOST_EMPTY_THRESHOLD = 1
) (
    input  wire                         wr_clk,
    input  wire                         wr_rst_n,
    input  wire                         wr_push,
    input  wire [DATA_WIDTH-1:0]        wr_data,
    output reg                          wr_full,
    output wire                         wr_almost_full,
    output wire [$clog2(DEPTH+1)-1:0]   wr_level,
    output reg                          wr_overflow,

    input  wire                         rd_clk,
    input  wire                         rd_rst_n,
    input  wire                         rd_pop,
    output wire [DATA_WIDTH-1:0]        rd_data,
    output reg                          rd_empty,
    output wire                         rd_almost_empty,
    output wire [$clog2(DEPTH+1)-1:0]   rd_level,
    output reg                          rd_underflow
);
    localparam integer ADDR_WIDTH = $clog2(DEPTH);
    localparam integer PTR_WIDTH = ADDR_WIDTH + 1;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);
    localparam [PTR_WIDTH-1:0] ALMOST_FULL_THRESHOLD_VALUE = ALMOST_FULL_THRESHOLD;
    localparam [PTR_WIDTH-1:0] ALMOST_EMPTY_THRESHOLD_VALUE = ALMOST_EMPTY_THRESHOLD;

    reg [DATA_WIDTH-1:0] storage [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] wr_ptr_bin_q;
    reg [PTR_WIDTH-1:0] wr_ptr_gray_q;
    reg [PTR_WIDTH-1:0] rd_ptr_bin_q;
    reg [PTR_WIDTH-1:0] rd_ptr_gray_q;
    reg [PTR_WIDTH-1:0] rd_ptr_gray_sync_q [0:SYNC_STAGES-1];
    reg [PTR_WIDTH-1:0] wr_ptr_gray_sync_q [0:SYNC_STAGES-1];

    integer wr_stage;
    integer rd_stage;

    function automatic [PTR_WIDTH-1:0] bin_to_gray;
        input [PTR_WIDTH-1:0] bin_value;
        begin
            bin_to_gray = (bin_value >> 1) ^ bin_value;
        end
    endfunction

    function automatic [PTR_WIDTH-1:0] gray_to_bin;
        input [PTR_WIDTH-1:0] gray_value;
        integer bit_idx;
        begin
            gray_to_bin[PTR_WIDTH-1] = gray_value[PTR_WIDTH-1];
            for (bit_idx = PTR_WIDTH - 2; bit_idx >= 0; bit_idx = bit_idx - 1) begin
                gray_to_bin[bit_idx] = gray_to_bin[bit_idx+1] ^ gray_value[bit_idx];
            end
        end
    endfunction

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "async_fifo_core requires DATA_WIDTH >= 1");
        end
        if (DEPTH < 4) begin
            $fatal(1, "async_fifo_core requires DEPTH >= 4");
        end
        if ((DEPTH & (DEPTH - 1)) != 0) begin
            $fatal(1, "async_fifo_core requires DEPTH to be a power of two");
        end
        if (SYNC_STAGES < 2) begin
            $fatal(1, "async_fifo_core requires SYNC_STAGES >= 2");
        end
        if ((ALMOST_FULL_THRESHOLD < 1) || (ALMOST_FULL_THRESHOLD > (DEPTH - 1))) begin
            $fatal(1, "async_fifo_core requires 1 <= ALMOST_FULL_THRESHOLD <= DEPTH-1");
        end
        if ((ALMOST_EMPTY_THRESHOLD < 0) || (ALMOST_EMPTY_THRESHOLD > (DEPTH - 1))) begin
            $fatal(1, "async_fifo_core requires 0 <= ALMOST_EMPTY_THRESHOLD <= DEPTH-1");
        end
    end

    wire [PTR_WIDTH-1:0] wr_ptr_bin_inc = wr_ptr_bin_q + 1'b1;
    wire [PTR_WIDTH-1:0] rd_ptr_bin_inc = rd_ptr_bin_q + 1'b1;
    wire [PTR_WIDTH-1:0] rd_ptr_gray_sync = rd_ptr_gray_sync_q[SYNC_STAGES-1];
    wire [PTR_WIDTH-1:0] wr_ptr_gray_sync = wr_ptr_gray_sync_q[SYNC_STAGES-1];
    wire [PTR_WIDTH-1:0] rd_ptr_bin_sync = gray_to_bin(rd_ptr_gray_sync);
    wire [PTR_WIDTH-1:0] wr_ptr_bin_sync = gray_to_bin(wr_ptr_gray_sync);
    wire [PTR_WIDTH-1:0] wr_full_compare_gray = {
        ~rd_ptr_gray_sync[PTR_WIDTH-1:PTR_WIDTH-2],
        rd_ptr_gray_sync[PTR_WIDTH-3:0]
    };
    wire [PTR_WIDTH-1:0] wr_level_next;
    wire [PTR_WIDTH-1:0] rd_level_next;
    wire wr_accept;
    wire rd_accept;
    wire [PTR_WIDTH-1:0] wr_ptr_bin_next;
    wire [PTR_WIDTH-1:0] rd_ptr_bin_next;
    wire [PTR_WIDTH-1:0] wr_ptr_gray_next;
    wire [PTR_WIDTH-1:0] rd_ptr_gray_next;
    wire wr_full_next;
    wire rd_empty_next;

    assign wr_accept = wr_push && !wr_full;
    assign rd_accept = rd_pop && !rd_empty;
    assign wr_ptr_bin_next = wr_accept ? wr_ptr_bin_inc : wr_ptr_bin_q;
    assign rd_ptr_bin_next = rd_accept ? rd_ptr_bin_inc : rd_ptr_bin_q;
    assign wr_ptr_gray_next = bin_to_gray(wr_ptr_bin_next);
    assign rd_ptr_gray_next = bin_to_gray(rd_ptr_bin_next);
    assign wr_full_next = (wr_ptr_gray_next == wr_full_compare_gray);
    assign rd_empty_next = (rd_ptr_gray_next == wr_ptr_gray_sync);
    assign wr_level_next = wr_ptr_bin_next - rd_ptr_bin_sync;
    assign rd_level_next = wr_ptr_bin_sync - rd_ptr_bin_next;
    assign wr_almost_full = (wr_level_next >= ALMOST_FULL_THRESHOLD_VALUE);
    assign rd_almost_empty = (rd_level_next <= ALMOST_EMPTY_THRESHOLD_VALUE);
    assign wr_level = wr_level_next[COUNT_WIDTH-1:0];
    assign rd_level = rd_level_next[COUNT_WIDTH-1:0];
    assign rd_data = storage[rd_ptr_bin_q[ADDR_WIDTH-1:0]];

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin_q <= {PTR_WIDTH{1'b0}};
            wr_ptr_gray_q <= {PTR_WIDTH{1'b0}};
            wr_full <= 1'b0;
            wr_overflow <= 1'b0;
            for (wr_stage = 0; wr_stage < SYNC_STAGES; wr_stage = wr_stage + 1) begin
                rd_ptr_gray_sync_q[wr_stage] <= {PTR_WIDTH{1'b0}};
            end
        end
        else begin
            rd_ptr_gray_sync_q[0] <= rd_ptr_gray_q;
            for (wr_stage = 1; wr_stage < SYNC_STAGES; wr_stage = wr_stage + 1) begin
                rd_ptr_gray_sync_q[wr_stage] <= rd_ptr_gray_sync_q[wr_stage-1];
            end

            wr_overflow <= wr_push && wr_full;
            wr_full <= wr_full_next;
            if (wr_accept) begin
                storage[wr_ptr_bin_q[ADDR_WIDTH-1:0]] <= wr_data;
                wr_ptr_bin_q <= wr_ptr_bin_next;
                wr_ptr_gray_q <= wr_ptr_gray_next;
            end
        end
    end

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin_q <= {PTR_WIDTH{1'b0}};
            rd_ptr_gray_q <= {PTR_WIDTH{1'b0}};
            rd_empty <= 1'b1;
            rd_underflow <= 1'b0;
            for (rd_stage = 0; rd_stage < SYNC_STAGES; rd_stage = rd_stage + 1) begin
                wr_ptr_gray_sync_q[rd_stage] <= {PTR_WIDTH{1'b0}};
            end
        end
        else begin
            wr_ptr_gray_sync_q[0] <= wr_ptr_gray_q;
            for (rd_stage = 1; rd_stage < SYNC_STAGES; rd_stage = rd_stage + 1) begin
                wr_ptr_gray_sync_q[rd_stage] <= wr_ptr_gray_sync_q[rd_stage-1];
            end

            rd_underflow <= rd_pop && rd_empty;
            rd_empty <= rd_empty_next;
            if (rd_accept) begin
                rd_ptr_bin_q <= rd_ptr_bin_next;
                rd_ptr_gray_q <= rd_ptr_gray_next;
            end
        end
    end
endmodule
