module stream_fifo #(
    parameter integer DATA_WIDTH = 32,
    parameter integer SIDEBAND_WIDTH = 0,
    parameter integer DEPTH = 8,
    parameter integer ALMOST_FULL_THRESHOLD = DEPTH - 1,
    parameter integer ALMOST_EMPTY_THRESHOLD = 1,
    parameter integer OUTPUT_REG = 0,
    parameter integer COUNT_EN = 1
) (
    input  wire                                     clk,
    input  wire                                     rst_n,
    input  wire                                     s_valid,
    output wire                                     s_ready,
    input  wire [DATA_WIDTH-1:0]                    s_data,
    input  wire [SIDEBAND_WIDTH-1:0]                s_sideband,
    output wire                                     m_valid,
    input  wire                                     m_ready,
    output wire [DATA_WIDTH-1:0]                    m_data,
    output wire [SIDEBAND_WIDTH-1:0]                m_sideband,
    output wire                                     full,
    output wire                                     empty,
    output wire                                     almost_full,
    output wire                                     almost_empty,
    output wire [((DEPTH < 1) ? 1 : $clog2(DEPTH + 1))-1:0] occupancy,
    output reg                                      overflow
);
    localparam integer PTR_WIDTH = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    localparam integer COUNT_WIDTH = (DEPTH < 1) ? 1 : $clog2(DEPTH + 1);
    localparam integer PAYLOAD_WIDTH = DATA_WIDTH + SIDEBAND_WIDTH;
    localparam [COUNT_WIDTH-1:0] DEPTH_VALUE = DEPTH;
    localparam [COUNT_WIDTH-1:0] ALMOST_FULL_THRESHOLD_VALUE = ALMOST_FULL_THRESHOLD;
    localparam [COUNT_WIDTH-1:0] ALMOST_EMPTY_THRESHOLD_VALUE = ALMOST_EMPTY_THRESHOLD;

    reg [PAYLOAD_WIDTH-1:0] storage [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] wr_ptr_q;
    reg [PTR_WIDTH-1:0] rd_ptr_q;
    reg [COUNT_WIDTH-1:0] count_q;

    wire [PAYLOAD_WIDTH-1:0] head_payload;
    wire push_fire;
    wire pop_fire;
    wire [PTR_WIDTH-1:0] wr_ptr_next;
    wire [PTR_WIDTH-1:0] rd_ptr_next;

    function automatic [PTR_WIDTH-1:0] ptr_increment;
        input [PTR_WIDTH-1:0] value;
        begin
            if (value == (DEPTH - 1)) begin
                ptr_increment = {PTR_WIDTH{1'b0}};
            end
            else begin
                ptr_increment = value + {{(PTR_WIDTH-1){1'b0}}, 1'b1};
            end
        end
    endfunction

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "stream_fifo requires DATA_WIDTH >= 1");
        end
        if (SIDEBAND_WIDTH < 0) begin
            $fatal(1, "stream_fifo requires SIDEBAND_WIDTH >= 0");
        end
        if (DEPTH < 1) begin
            $fatal(1, "stream_fifo requires DEPTH >= 1");
        end
        if ((ALMOST_FULL_THRESHOLD < 0) || (ALMOST_FULL_THRESHOLD > DEPTH)) begin
            $fatal(1, "stream_fifo requires 0 <= ALMOST_FULL_THRESHOLD <= DEPTH");
        end
        if ((ALMOST_EMPTY_THRESHOLD < 0) || (ALMOST_EMPTY_THRESHOLD > DEPTH)) begin
            $fatal(1, "stream_fifo requires 0 <= ALMOST_EMPTY_THRESHOLD <= DEPTH");
        end
        if (OUTPUT_REG != 0) begin
            $fatal(1, "stream_fifo currently implements OUTPUT_REG = 0 only");
        end
        if ((COUNT_EN != 0) && (COUNT_EN != 1)) begin
            $fatal(1, "stream_fifo requires COUNT_EN to be 0 or 1");
        end
    end

    assign head_payload = storage[rd_ptr_q];
    assign full = (count_q == DEPTH_VALUE);
    assign empty = (count_q == {COUNT_WIDTH{1'b0}});
    assign s_ready = !full || (m_ready && !empty);
    assign m_valid = !empty;
    assign {m_sideband, m_data} = head_payload;
    assign almost_full = (count_q >= ALMOST_FULL_THRESHOLD_VALUE);
    assign almost_empty = (count_q <= ALMOST_EMPTY_THRESHOLD_VALUE);
    assign occupancy = COUNT_EN ? count_q : {COUNT_WIDTH{1'b0}};

    assign push_fire = s_valid && s_ready;
    assign pop_fire = m_valid && m_ready;
    assign wr_ptr_next = ptr_increment(wr_ptr_q);
    assign rd_ptr_next = ptr_increment(rd_ptr_q);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_q <= {PTR_WIDTH{1'b0}};
            rd_ptr_q <= {PTR_WIDTH{1'b0}};
            count_q <= {COUNT_WIDTH{1'b0}};
            overflow <= 1'b0;
        end
        else begin
            overflow <= s_valid && !s_ready;

            if (push_fire) begin
                storage[wr_ptr_q] <= {s_sideband, s_data};
            end

            case ({push_fire, pop_fire})
                2'b10: begin
                    wr_ptr_q <= wr_ptr_next;
                    count_q <= count_q + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                end
                2'b01: begin
                    rd_ptr_q <= rd_ptr_next;
                    count_q <= count_q - {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                end
                2'b11: begin
                    wr_ptr_q <= wr_ptr_next;
                    rd_ptr_q <= rd_ptr_next;
                end
                default: begin
                end
            endcase
        end
    end
endmodule
