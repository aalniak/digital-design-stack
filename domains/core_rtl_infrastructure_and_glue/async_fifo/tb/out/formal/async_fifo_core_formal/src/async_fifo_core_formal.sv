module async_fifo_core_formal;
    localparam integer DATA_WIDTH = 8;
    localparam integer DEPTH = 4;
    localparam integer SYNC_STAGES = 2;
    localparam integer ADDR_WIDTH = $clog2(DEPTH);
    localparam integer PTR_WIDTH = ADDR_WIDTH + 1;
    localparam integer COUNT_WIDTH = $clog2(DEPTH + 1);

    reg [3:0] formal_ticks;
    wire wr_clk = formal_ticks[0];
    wire rd_clk = formal_ticks[1];
    wire wr_rst_n = (formal_ticks >= 4'd3);
    wire rd_rst_n = (formal_ticks >= 4'd5);

    (* anyseq *) reg wr_push;
    (* anyseq *) reg rd_pop;
    (* anyseq *) reg [DATA_WIDTH-1:0] wr_data;

    wire wr_full;
    wire wr_almost_full;
    wire [COUNT_WIDTH-1:0] wr_level;
    wire wr_overflow;
    wire [DATA_WIDTH-1:0] rd_data;
    wire rd_empty;
    wire rd_almost_empty;
    wire [COUNT_WIDTH-1:0] rd_level;
    wire rd_underflow;

    async_fifo_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .SYNC_STAGES(SYNC_STAGES),
        .ALMOST_FULL_THRESHOLD(DEPTH - 1),
        .ALMOST_EMPTY_THRESHOLD(1)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_push(wr_push),
        .wr_data(wr_data),
        .wr_full(wr_full),
        .wr_almost_full(wr_almost_full),
        .wr_level(wr_level),
        .wr_overflow(wr_overflow),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_pop(rd_pop),
        .rd_data(rd_data),
        .rd_empty(rd_empty),
        .rd_almost_empty(rd_almost_empty),
        .rd_level(rd_level),
        .rd_underflow(rd_underflow)
    );

    initial begin
        formal_ticks = 4'd0;
    end

    always @($global_clock) begin
        formal_ticks <= formal_ticks + 1'b1;

        if (wr_rst_n && rd_rst_n) begin
            assert(wr_level <= DEPTH);
            assert(rd_level <= DEPTH);
            assert(wr_almost_full == (wr_level >= (DEPTH - 1)));
            assert(rd_almost_empty == (rd_level <= 1));
        end
    end

    always @(posedge wr_clk) begin
        if (!wr_rst_n) begin
            assume(!wr_push);
            assert(wr_full == 1'b0);
        end
    end

    always @(posedge rd_clk) begin
        if (!rd_rst_n) begin
            assume(!rd_pop);
            assert(rd_empty == 1'b1);
        end
    end
endmodule
