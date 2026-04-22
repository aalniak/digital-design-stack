module stream_mux #(
    parameter integer NUM_INPUTS = 4,
    parameter integer DATA_WIDTH = 32,
    parameter integer SIDEBAND_WIDTH = 0,
    parameter integer ARBITRATION_MODE = 0,
    parameter integer HOLD_UNTIL_LAST = 1,
    parameter integer SOURCE_ID_EN = 1
) (
    input  wire                                                       clk,
    input  wire                                                       rst_n,
    input  wire [NUM_INPUTS-1:0]                                      s_valid,
    output wire [NUM_INPUTS-1:0]                                      s_ready,
    input  wire [NUM_INPUTS*DATA_WIDTH-1:0]                           s_data,
    input  wire [NUM_INPUTS*SIDEBAND_WIDTH-1:0]                       s_sideband,
    input  wire [NUM_INPUTS-1:0]                                      s_last,
    output wire                                                       m_valid,
    input  wire                                                       m_ready,
    output wire [DATA_WIDTH-1:0]                                      m_data,
    output wire [SIDEBAND_WIDTH-1:0]                                  m_sideband,
    output wire                                                       m_last,
    output wire [((NUM_INPUTS <= 1) ? 1 : $clog2(NUM_INPUTS))-1:0]    m_source_id,
    output wire                                                       held_grant_active,
    output wire [((NUM_INPUTS <= 1) ? 1 : $clog2(NUM_INPUTS))-1:0]    held_grant_id
);
    localparam integer ID_WIDTH = (NUM_INPUTS <= 1) ? 1 : $clog2(NUM_INPUTS);

    reg [ID_WIDTH-1:0] rr_pointer_q;
    reg [ID_WIDTH-1:0] held_id_q;
    reg held_active_q;
    reg [NUM_INPUTS-1:0] arb_onehot;
    reg arb_valid;
    reg [ID_WIDTH-1:0] arb_index;

    wire use_held;
    wire selected_valid;
    wire [ID_WIDTH-1:0] selected_index;
    wire selected_last;
    wire accept_fire;

    integer idx;
    integer offset;
    reg [ID_WIDTH-1:0] candidate;

    function automatic [ID_WIDTH-1:0] next_index;
        input [ID_WIDTH-1:0] current;
        begin
            if (current == (NUM_INPUTS - 1)) begin
                next_index = {ID_WIDTH{1'b0}};
            end
            else begin
                next_index = current + {{(ID_WIDTH-1){1'b0}}, 1'b1};
            end
        end
    endfunction

    initial begin
        if (NUM_INPUTS < 1) begin
            $fatal(1, "stream_mux requires NUM_INPUTS >= 1");
        end
        if (DATA_WIDTH < 1) begin
            $fatal(1, "stream_mux requires DATA_WIDTH >= 1");
        end
        if (SIDEBAND_WIDTH < 0) begin
            $fatal(1, "stream_mux requires SIDEBAND_WIDTH >= 0");
        end
        if ((ARBITRATION_MODE != 0) && (ARBITRATION_MODE != 1)) begin
            $fatal(1, "stream_mux requires ARBITRATION_MODE to be 0 or 1");
        end
        if ((HOLD_UNTIL_LAST != 0) && (HOLD_UNTIL_LAST != 1)) begin
            $fatal(1, "stream_mux requires HOLD_UNTIL_LAST to be 0 or 1");
        end
        if ((SOURCE_ID_EN != 0) && (SOURCE_ID_EN != 1)) begin
            $fatal(1, "stream_mux requires SOURCE_ID_EN to be 0 or 1");
        end
    end

    always @(*) begin
        arb_onehot = {NUM_INPUTS{1'b0}};
        arb_valid = 1'b0;
        arb_index = {ID_WIDTH{1'b0}};

        if (ARBITRATION_MODE == 0) begin
            for (idx = 0; idx < NUM_INPUTS; idx = idx + 1) begin
                if (!arb_valid && s_valid[idx]) begin
                    arb_onehot[idx] = 1'b1;
                    arb_valid = 1'b1;
                    arb_index = idx[ID_WIDTH-1:0];
                end
            end
        end
        else begin
            for (offset = 0; offset < NUM_INPUTS; offset = offset + 1) begin
                candidate = rr_pointer_q + offset[ID_WIDTH-1:0];
                if (candidate >= NUM_INPUTS[ID_WIDTH-1:0]) begin
                    candidate = candidate - NUM_INPUTS[ID_WIDTH-1:0];
                end
                if (!arb_valid && s_valid[candidate]) begin
                    arb_onehot[candidate] = 1'b1;
                    arb_valid = 1'b1;
                    arb_index = candidate;
                end
            end
        end
    end

    assign use_held = (HOLD_UNTIL_LAST != 0) && held_active_q;
    assign selected_index = use_held ? held_id_q : arb_index;
    assign selected_valid = use_held ? s_valid[held_id_q] : arb_valid;
    assign selected_last = selected_valid ? s_last[selected_index] : 1'b0;
    assign m_valid = rst_n && selected_valid;
    assign m_data = s_data[(selected_index * DATA_WIDTH) +: DATA_WIDTH];
    assign m_sideband = s_sideband[(selected_index * SIDEBAND_WIDTH) +: SIDEBAND_WIDTH];
    assign m_last = selected_last;
    assign m_source_id = SOURCE_ID_EN ? selected_index : {ID_WIDTH{1'b0}};
    assign held_grant_active = held_active_q;
    assign held_grant_id = held_id_q;
    assign accept_fire = m_valid && m_ready;

    generate
        genvar in_idx;
        for (in_idx = 0; in_idx < NUM_INPUTS; in_idx = in_idx + 1) begin : gen_ready
            assign s_ready[in_idx] = (rst_n && selected_valid && (selected_index == in_idx[ID_WIDTH-1:0])) ? m_ready : 1'b0;
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rr_pointer_q <= {ID_WIDTH{1'b0}};
            held_id_q <= {ID_WIDTH{1'b0}};
            held_active_q <= 1'b0;
        end
        else begin
            if (accept_fire) begin
                if ((ARBITRATION_MODE == 1) && ((HOLD_UNTIL_LAST == 0) || selected_last)) begin
                    rr_pointer_q <= next_index(selected_index);
                end

                if (HOLD_UNTIL_LAST != 0) begin
                    if (held_active_q) begin
                        if (selected_last) begin
                            held_active_q <= 1'b0;
                        end
                    end
                    else if (!selected_last) begin
                        held_id_q <= selected_index;
                        held_active_q <= 1'b1;
                    end
                end
                else begin
                    held_id_q <= {ID_WIDTH{1'b0}};
                    held_active_q <= 1'b0;
                end
            end
        end
    end
endmodule
