module depacketizer #(
    parameter integer DATA_WIDTH = 32,
    parameter integer TYPE_WIDTH = 4,
    parameter integer LENGTH_WIDTH = 16,
    parameter integer HEADER_MODE = 0,
    parameter integer DROP_BAD_PACKET = 0
) (
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          s_valid,
    output wire                          s_ready,
    input  wire [DATA_WIDTH-1:0]         s_data,
    input  wire                          s_first,
    input  wire                          s_last,
    input  wire                          s_header,
    input  wire [TYPE_WIDTH-1:0]         s_type,
    input  wire [LENGTH_WIDTH-1:0]       s_length,
    input  wire                          s_error,
    output wire                          m_valid,
    input  wire                          m_ready,
    output wire [DATA_WIDTH-1:0]         m_data,
    output wire                          m_first,
    output wire                          m_last,
    output wire [TYPE_WIDTH-1:0]         m_type,
    output wire [LENGTH_WIDTH-1:0]       m_length,
    output wire                          m_error,
    output wire                          protocol_error,
    output wire                          dropping_packet,
    output wire                          busy
);
    localparam integer HEADER_BITS = TYPE_WIDTH + LENGTH_WIDTH + 1;

    reg [TYPE_WIDTH-1:0] active_type_q;
    reg [LENGTH_WIDTH-1:0] active_length_q;
    reg active_error_q;
    reg packet_active_q;
    reg first_payload_q;
    reg drop_active_q;
    reg protocol_error_q;

    reg out_valid_q;
    reg [DATA_WIDTH-1:0] out_data_q;
    reg out_first_q;
    reg out_last_q;
    reg [TYPE_WIDTH-1:0] out_type_q;
    reg [LENGTH_WIDTH-1:0] out_length_q;
    reg out_error_q;

    wire can_load_output;
    wire accept_source;
    wire expecting_header;
    wire [LENGTH_WIDTH-1:0] decoded_length;
    wire [TYPE_WIDTH-1:0] decoded_type;
    wire decoded_error;

    reg start_error;
    reg header_format_error;
    reg header_mismatch_error;
    reg unexpected_header_error;
    reg unexpected_first_error;
    reg payload_meta_mismatch_error;
    reg beat_error;
    reg drop_this_beat;
    reg emit_payload;
    reg emit_first;

    assign can_load_output = !out_valid_q || m_ready;
    assign s_ready = rst_n && can_load_output;
    assign accept_source = s_valid && s_ready;
    assign expecting_header = (HEADER_MODE != 0) && !packet_active_q;

    assign decoded_length = s_data[LENGTH_WIDTH-1:0];
    assign decoded_type = s_data[LENGTH_WIDTH + TYPE_WIDTH - 1:LENGTH_WIDTH];
    assign decoded_error = s_data[HEADER_BITS - 1];

    assign m_valid = out_valid_q;
    assign m_data = out_data_q;
    assign m_first = out_first_q;
    assign m_last = out_last_q;
    assign m_type = out_type_q;
    assign m_length = out_length_q;
    assign m_error = out_error_q;
    assign protocol_error = protocol_error_q;
    assign dropping_packet = drop_active_q;
    assign busy = out_valid_q || packet_active_q;

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "depacketizer requires DATA_WIDTH >= 1");
        end
        if (TYPE_WIDTH < 1) begin
            $fatal(1, "depacketizer requires TYPE_WIDTH >= 1");
        end
        if (LENGTH_WIDTH < 1) begin
            $fatal(1, "depacketizer requires LENGTH_WIDTH >= 1");
        end
        if ((HEADER_MODE != 0) && (HEADER_MODE != 1)) begin
            $fatal(1, "depacketizer requires HEADER_MODE to be 0 or 1");
        end
        if ((DROP_BAD_PACKET != 0) && (DROP_BAD_PACKET != 1)) begin
            $fatal(1, "depacketizer requires DROP_BAD_PACKET to be 0 or 1");
        end
        if ((HEADER_MODE == 1) && (DATA_WIDTH < HEADER_BITS)) begin
            $fatal(1, "depacketizer header mode requires DATA_WIDTH >= TYPE_WIDTH + LENGTH_WIDTH + 1");
        end
    end

    always @(*) begin
        start_error = 1'b0;
        header_format_error = 1'b0;
        header_mismatch_error = 1'b0;
        unexpected_header_error = 1'b0;
        unexpected_first_error = 1'b0;
        payload_meta_mismatch_error = 1'b0;
        beat_error = 1'b0;
        drop_this_beat = 1'b0;
        emit_payload = 1'b0;
        emit_first = 1'b0;

        if (accept_source) begin
            if (HEADER_MODE != 0) begin
                if (!packet_active_q) begin
                    header_format_error = !s_header || !s_first || s_last;
                    header_mismatch_error = (s_type != decoded_type) || (s_length != decoded_length) || (s_error != decoded_error);
                    beat_error = header_format_error || header_mismatch_error;
                end
                else begin
                    unexpected_header_error = s_header;
                    unexpected_first_error = s_first;
                    payload_meta_mismatch_error = (s_type != active_type_q) || (s_length != active_length_q) || (s_error != active_error_q);
                    beat_error = unexpected_header_error || unexpected_first_error || payload_meta_mismatch_error;
                    drop_this_beat = drop_active_q || ((DROP_BAD_PACKET != 0) && beat_error);
                    emit_payload = !drop_this_beat;
                    emit_first = first_payload_q;
                end
            end
            else begin
                if (!packet_active_q) begin
                    start_error = !s_first;
                    unexpected_header_error = s_header;
                    beat_error = start_error || unexpected_header_error;
                    drop_this_beat = (DROP_BAD_PACKET != 0) && (s_error || beat_error);
                    emit_payload = !drop_this_beat;
                    emit_first = 1'b1;
                end
                else begin
                    unexpected_header_error = s_header;
                    unexpected_first_error = s_first;
                    payload_meta_mismatch_error = (s_type != active_type_q) || (s_length != active_length_q) || (s_error != active_error_q);
                    beat_error = unexpected_header_error || unexpected_first_error || payload_meta_mismatch_error;
                    drop_this_beat = drop_active_q || ((DROP_BAD_PACKET != 0) && beat_error);
                    emit_payload = !drop_this_beat;
                    emit_first = 1'b0;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_type_q <= {TYPE_WIDTH{1'b0}};
            active_length_q <= {LENGTH_WIDTH{1'b0}};
            active_error_q <= 1'b0;
            packet_active_q <= 1'b0;
            first_payload_q <= 1'b0;
            drop_active_q <= 1'b0;
            protocol_error_q <= 1'b0;
            out_valid_q <= 1'b0;
            out_data_q <= {DATA_WIDTH{1'b0}};
            out_first_q <= 1'b0;
            out_last_q <= 1'b0;
            out_type_q <= {TYPE_WIDTH{1'b0}};
            out_length_q <= {LENGTH_WIDTH{1'b0}};
            out_error_q <= 1'b0;
        end
        else begin
            if (out_valid_q && m_ready) begin
                out_valid_q <= 1'b0;
            end

            if (accept_source && beat_error) begin
                protocol_error_q <= 1'b1;
            end

            if (can_load_output && accept_source) begin
                if ((HEADER_MODE != 0) && !packet_active_q) begin
                    active_type_q <= decoded_type;
                    active_length_q <= decoded_length;
                    active_error_q <= decoded_error;

                    if (s_last) begin
                        packet_active_q <= 1'b0;
                        first_payload_q <= 1'b0;
                        drop_active_q <= 1'b0;
                    end
                    else begin
                        packet_active_q <= 1'b1;
                        first_payload_q <= 1'b1;
                        drop_active_q <= (DROP_BAD_PACKET != 0) && (decoded_error || beat_error);
                    end
                end
                else begin
                    if ((HEADER_MODE == 0) && !packet_active_q) begin
                        active_type_q <= s_type;
                        active_length_q <= s_length;
                        active_error_q <= s_error;
                    end

                    if (emit_payload) begin
                        out_valid_q <= 1'b1;
                        out_data_q <= s_data;
                        out_first_q <= emit_first;
                        out_last_q <= s_last;
                        out_type_q <= packet_active_q ? active_type_q : s_type;
                        out_length_q <= packet_active_q ? active_length_q : s_length;
                        out_error_q <= packet_active_q ? active_error_q : s_error;
                    end

                    if (s_last) begin
                        packet_active_q <= 1'b0;
                        first_payload_q <= 1'b0;
                        drop_active_q <= 1'b0;
                    end
                    else begin
                        packet_active_q <= 1'b1;
                        first_payload_q <= 1'b0;
                        if ((HEADER_MODE == 0) && !packet_active_q) begin
                            drop_active_q <= (DROP_BAD_PACKET != 0) && (s_error || beat_error);
                        end
                        else begin
                            drop_active_q <= drop_this_beat;
                        end
                    end
                end
            end
        end
    end
endmodule
