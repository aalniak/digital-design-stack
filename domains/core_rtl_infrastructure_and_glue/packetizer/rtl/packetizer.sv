module packetizer #(
    parameter integer DATA_WIDTH = 32,
    parameter integer TYPE_WIDTH = 4,
    parameter integer LENGTH_WIDTH = 16,
    parameter integer HEADER_MODE = 0,
    parameter integer AUTO_CLOSE_EN = 0,
    parameter integer TRAILER_EN = 0
) (
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          s_valid,
    output wire                          s_ready,
    input  wire [DATA_WIDTH-1:0]         s_data,
    input  wire                          s_first,
    input  wire                          s_last,
    input  wire [TYPE_WIDTH-1:0]         s_type,
    input  wire [LENGTH_WIDTH-1:0]       s_length,
    input  wire                          s_error,
    output wire                          m_valid,
    input  wire                          m_ready,
    output wire [DATA_WIDTH-1:0]         m_data,
    output wire                          m_first,
    output wire                          m_last,
    output wire                          m_header,
    output wire [TYPE_WIDTH-1:0]         m_type,
    output wire [LENGTH_WIDTH-1:0]       m_length,
    output wire                          m_error,
    output wire                          protocol_error,
    output wire                          busy
);
    localparam integer HEADER_BITS = TYPE_WIDTH + LENGTH_WIDTH + 1;

    reg [TYPE_WIDTH-1:0] active_type_q;
    reg [LENGTH_WIDTH-1:0] active_length_q;
    reg active_error_q;
    reg expect_first_q;
    reg protocol_error_q;

    reg [DATA_WIDTH-1:0] hold_data_q;
    reg hold_last_q;
    reg hold_valid_q;

    reg out_valid_q;
    reg [DATA_WIDTH-1:0] out_data_q;
    reg out_first_q;
    reg out_last_q;
    reg out_header_q;
    reg [TYPE_WIDTH-1:0] out_type_q;
    reg [LENGTH_WIDTH-1:0] out_length_q;
    reg out_error_q;

    wire can_load_output;
    wire accept_source;
    wire start_new_packet;
    wire missing_first_error;
    wire restart_error;

    function automatic [DATA_WIDTH-1:0] build_header_data;
        input [TYPE_WIDTH-1:0] packet_type;
        input [LENGTH_WIDTH-1:0] packet_length;
        input packet_error;
        begin
            build_header_data = {DATA_WIDTH{1'b0}};
            build_header_data[LENGTH_WIDTH-1:0] = packet_length;
            build_header_data[LENGTH_WIDTH + TYPE_WIDTH - 1:LENGTH_WIDTH] = packet_type;
            build_header_data[HEADER_BITS - 1] = packet_error;
        end
    endfunction

    initial begin
        if (DATA_WIDTH < 1) begin
            $fatal(1, "packetizer requires DATA_WIDTH >= 1");
        end
        if (TYPE_WIDTH < 1) begin
            $fatal(1, "packetizer requires TYPE_WIDTH >= 1");
        end
        if (LENGTH_WIDTH < 1) begin
            $fatal(1, "packetizer requires LENGTH_WIDTH >= 1");
        end
        if ((HEADER_MODE != 0) && (HEADER_MODE != 1)) begin
            $fatal(1, "packetizer requires HEADER_MODE to be 0 or 1");
        end
        if ((AUTO_CLOSE_EN != 0) && (AUTO_CLOSE_EN != 1)) begin
            $fatal(1, "packetizer requires AUTO_CLOSE_EN to be 0 or 1");
        end
        if (TRAILER_EN != 0) begin
            $fatal(1, "packetizer currently implements TRAILER_EN = 0 only");
        end
        if ((HEADER_MODE == 1) && (DATA_WIDTH < HEADER_BITS)) begin
            $fatal(1, "packetizer header mode requires DATA_WIDTH >= TYPE_WIDTH + LENGTH_WIDTH + 1");
        end
    end

    assign can_load_output = !out_valid_q || m_ready;
    assign s_ready = rst_n && can_load_output && !hold_valid_q;
    assign accept_source = s_valid && s_ready;
    assign start_new_packet = accept_source && (expect_first_q || s_first);
    assign missing_first_error = accept_source && expect_first_q && !s_first;
    assign restart_error = accept_source && !expect_first_q && s_first && (AUTO_CLOSE_EN == 0);

    assign m_valid = out_valid_q;
    assign m_data = out_data_q;
    assign m_first = out_first_q;
    assign m_last = out_last_q;
    assign m_header = out_header_q;
    assign m_type = out_type_q;
    assign m_length = out_length_q;
    assign m_error = out_error_q;
    assign protocol_error = protocol_error_q;
    assign busy = out_valid_q || hold_valid_q || !expect_first_q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_type_q <= {TYPE_WIDTH{1'b0}};
            active_length_q <= {LENGTH_WIDTH{1'b0}};
            active_error_q <= 1'b0;
            expect_first_q <= 1'b1;
            protocol_error_q <= 1'b0;
            hold_data_q <= {DATA_WIDTH{1'b0}};
            hold_last_q <= 1'b0;
            hold_valid_q <= 1'b0;
            out_valid_q <= 1'b0;
            out_data_q <= {DATA_WIDTH{1'b0}};
            out_first_q <= 1'b0;
            out_last_q <= 1'b0;
            out_header_q <= 1'b0;
            out_type_q <= {TYPE_WIDTH{1'b0}};
            out_length_q <= {LENGTH_WIDTH{1'b0}};
            out_error_q <= 1'b0;
        end
        else begin
            if (out_valid_q && m_ready) begin
                out_valid_q <= 1'b0;
            end

            if (missing_first_error || restart_error) begin
                protocol_error_q <= 1'b1;
            end

            if (can_load_output) begin
                if (hold_valid_q) begin
                    out_valid_q <= 1'b1;
                    out_data_q <= hold_data_q;
                    out_first_q <= 1'b0;
                    out_last_q <= hold_last_q;
                    out_header_q <= 1'b0;
                    out_type_q <= active_type_q;
                    out_length_q <= active_length_q;
                    out_error_q <= active_error_q;
                    hold_valid_q <= 1'b0;
                end
                else if (accept_source) begin
                    if (start_new_packet) begin
                        active_type_q <= s_type;
                        active_length_q <= s_length;
                        active_error_q <= s_error;
                    end

                    if ((HEADER_MODE != 0) && start_new_packet) begin
                        hold_data_q <= s_data;
                        hold_last_q <= s_last;
                        hold_valid_q <= 1'b1;

                        out_valid_q <= 1'b1;
                        out_data_q <= build_header_data(s_type, s_length, s_error);
                        out_first_q <= 1'b1;
                        out_last_q <= 1'b0;
                        out_header_q <= 1'b1;
                        out_type_q <= s_type;
                        out_length_q <= s_length;
                        out_error_q <= s_error;
                    end
                    else begin
                        out_valid_q <= 1'b1;
                        out_data_q <= s_data;
                        out_first_q <= start_new_packet;
                        out_last_q <= s_last;
                        out_header_q <= 1'b0;
                        out_type_q <= start_new_packet ? s_type : active_type_q;
                        out_length_q <= start_new_packet ? s_length : active_length_q;
                        out_error_q <= start_new_packet ? s_error : active_error_q;
                    end

                    expect_first_q <= s_last;
                end
            end
        end
    end
endmodule
