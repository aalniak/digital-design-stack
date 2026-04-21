module timer_block #(
    parameter integer COUNT_WIDTH = 32,
    parameter integer PRESCALE_WIDTH = 0
) (
    input  wire                             clk,
    input  wire                             rst_n,
    input  wire                             start_pulse,
    input  wire                             stop_pulse,
    input  wire                             clear_pulse,
    input  wire                             load_pulse,
    input  wire                             periodic_en,
    input  wire                             irq_enable,
    input  wire                             irq_ack,
    input  wire [COUNT_WIDTH-1:0]           load_value,
    input  wire [COUNT_WIDTH-1:0]           reload_value,
    input  wire [((PRESCALE_WIDTH < 1) ? 1 : PRESCALE_WIDTH)-1:0] prescale_div,
    output reg                              running,
    output reg                              expire_pulse,
    output reg                              irq,
    output reg [COUNT_WIDTH-1:0]            count_value
);
    localparam integer PRESCALE_BITS = (PRESCALE_WIDTH < 1) ? 1 : PRESCALE_WIDTH;

    reg [PRESCALE_BITS-1:0] prescale_count_q;

    wire prescale_tick = (PRESCALE_WIDTH == 0) ? 1'b1 : (prescale_count_q == prescale_div);
    wire [PRESCALE_BITS-1:0] next_prescale_count =
        prescale_tick ? {PRESCALE_BITS{1'b0}} : (prescale_count_q + {{(PRESCALE_BITS-1){1'b0}}, 1'b1});

    initial begin
        if (COUNT_WIDTH < 1) begin
            $fatal(1, "timer_block requires COUNT_WIDTH >= 1");
        end
        if (PRESCALE_WIDTH < 0) begin
            $fatal(1, "timer_block requires PRESCALE_WIDTH >= 0");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running <= 1'b0;
            expire_pulse <= 1'b0;
            irq <= 1'b0;
            count_value <= {COUNT_WIDTH{1'b0}};
            prescale_count_q <= {PRESCALE_BITS{1'b0}};
        end
        else begin
            expire_pulse <= 1'b0;

            if (clear_pulse) begin
                running <= 1'b0;
                irq <= 1'b0;
                count_value <= {COUNT_WIDTH{1'b0}};
                prescale_count_q <= {PRESCALE_BITS{1'b0}};
            end
            else if (load_pulse) begin
                count_value <= load_value;
                prescale_count_q <= {PRESCALE_BITS{1'b0}};
                if (irq_ack) begin
                    irq <= 1'b0;
                end
            end
            else if (stop_pulse) begin
                running <= 1'b0;
                prescale_count_q <= {PRESCALE_BITS{1'b0}};
                if (irq_ack) begin
                    irq <= 1'b0;
                end
            end
            else if (start_pulse) begin
                running <= (load_value != {COUNT_WIDTH{1'b0}});
                irq <= 1'b0;
                count_value <= load_value;
                prescale_count_q <= {PRESCALE_BITS{1'b0}};
            end
            else begin
                if (irq_ack) begin
                    irq <= 1'b0;
                end

                if (running) begin
                    if (count_value != {COUNT_WIDTH{1'b0}}) begin
                        prescale_count_q <= next_prescale_count;

                        if (prescale_tick) begin
                            if (count_value > {{(COUNT_WIDTH-1){1'b0}}, 1'b1}) begin
                                count_value <= count_value - {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                            end
                            else begin
                                expire_pulse <= 1'b1;
                                if (irq_enable) begin
                                    irq <= 1'b1;
                                end

                                if (periodic_en && (reload_value != {COUNT_WIDTH{1'b0}})) begin
                                    count_value <= reload_value;
                                    running <= 1'b1;
                                end
                                else begin
                                    count_value <= {COUNT_WIDTH{1'b0}};
                                    running <= 1'b0;
                                end
                            end
                        end
                    end
                    else begin
                        running <= 1'b0;
                        prescale_count_q <= {PRESCALE_BITS{1'b0}};
                    end
                end
                else begin
                    prescale_count_q <= {PRESCALE_BITS{1'b0}};
                end
            end
        end
    end
endmodule
