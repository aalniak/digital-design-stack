module interrupt_controller #(
    parameter integer NUM_SOURCES = 8
) (
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire [NUM_SOURCES-1:0]         src_event,
    input  wire [NUM_SOURCES-1:0]         src_level_mode,
    input  wire [NUM_SOURCES-1:0]         enable_mask,
    input  wire [NUM_SOURCES-1:0]         sw_set,
    input  wire [NUM_SOURCES-1:0]         ack_mask,
    output wire [NUM_SOURCES-1:0]         raw_status,
    output wire [NUM_SOURCES-1:0]         pending_status,
    output reg  [NUM_SOURCES-1:0]         active_onehot,
    output reg                            irq,
    output reg  [((NUM_SOURCES <= 1) ? 1 : $clog2(NUM_SOURCES))-1:0] irq_id
);
    localparam integer ID_WIDTH = (NUM_SOURCES <= 1) ? 1 : $clog2(NUM_SOURCES);

    reg [NUM_SOURCES-1:0] src_event_q;
    reg [NUM_SOURCES-1:0] edge_pending_q;

    wire [NUM_SOURCES-1:0] rise_event = src_event & ~src_event_q;
    wire [NUM_SOURCES-1:0] edge_set = (rise_event & ~src_level_mode) | sw_set;
    wire [NUM_SOURCES-1:0] edge_clear = ack_mask & ~edge_set;
    wire [NUM_SOURCES-1:0] level_pending = rst_n ? (src_level_mode & src_event) : {NUM_SOURCES{1'b0}};
    wire [NUM_SOURCES-1:0] enabled_pending = pending_status & enable_mask;

    integer idx;

    assign raw_status = src_event;
    assign pending_status = edge_pending_q | level_pending;

    initial begin
        if (NUM_SOURCES < 1) begin
            $fatal(1, "interrupt_controller requires NUM_SOURCES >= 1");
        end
    end

    always @(*) begin
        active_onehot = {NUM_SOURCES{1'b0}};
        irq = 1'b0;
        irq_id = {ID_WIDTH{1'b0}};

        for (idx = 0; idx < NUM_SOURCES; idx = idx + 1) begin
            if (!irq && enabled_pending[idx]) begin
                irq = 1'b1;
                active_onehot[idx] = 1'b1;
                irq_id = idx[ID_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            src_event_q <= {NUM_SOURCES{1'b0}};
            edge_pending_q <= {NUM_SOURCES{1'b0}};
        end
        else begin
            src_event_q <= src_event;
            edge_pending_q <= (edge_pending_q & ~edge_clear) | edge_set;
        end
    end
endmodule
