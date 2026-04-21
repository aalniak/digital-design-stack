module timer_block_tb;
    localparam integer COUNT_WIDTH = 8;
    localparam integer PRESCALE_WIDTH = 4;

    reg clk;
    reg rst_n;
    reg start_pulse;
    reg stop_pulse;
    reg clear_pulse;
    reg load_pulse;
    reg periodic_en;
    reg irq_enable;
    reg irq_ack;
    reg [COUNT_WIDTH-1:0] load_value;
    reg [COUNT_WIDTH-1:0] reload_value;
    reg [PRESCALE_WIDTH-1:0] prescale_div;
    wire running;
    wire expire_pulse;
    wire irq;
    wire [COUNT_WIDTH-1:0] count_value;

    timer_block #(
        .COUNT_WIDTH(COUNT_WIDTH),
        .PRESCALE_WIDTH(PRESCALE_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_pulse(start_pulse),
        .stop_pulse(stop_pulse),
        .clear_pulse(clear_pulse),
        .load_pulse(load_pulse),
        .periodic_en(periodic_en),
        .irq_enable(irq_enable),
        .irq_ack(irq_ack),
        .load_value(load_value),
        .reload_value(reload_value),
        .prescale_div(prescale_div),
        .running(running),
        .expire_pulse(expire_pulse),
        .irq(irq),
        .count_value(count_value)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("TIMER_BLOCK_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic drive_cycle;
        input start_i;
        input stop_i;
        input clear_i;
        input load_i;
        input periodic_i;
        input irq_enable_i;
        input irq_ack_i;
        input [COUNT_WIDTH-1:0] load_i_value;
        input [COUNT_WIDTH-1:0] reload_i_value;
        input [PRESCALE_WIDTH-1:0] prescale_i_div;
        begin
            @(negedge clk);
            start_pulse = start_i;
            stop_pulse = stop_i;
            clear_pulse = clear_i;
            load_pulse = load_i;
            periodic_en = periodic_i;
            irq_enable = irq_enable_i;
            irq_ack = irq_ack_i;
            load_value = load_i_value;
            reload_value = reload_i_value;
            prescale_div = prescale_i_div;
            @(posedge clk);
            #1;
            start_pulse = 1'b0;
            stop_pulse = 1'b0;
            clear_pulse = 1'b0;
            load_pulse = 1'b0;
            irq_ack = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        start_pulse = 1'b0;
        stop_pulse = 1'b0;
        clear_pulse = 1'b0;
        load_pulse = 1'b0;
        periodic_en = 1'b0;
        irq_enable = 1'b0;
        irq_ack = 1'b0;
        load_value = {COUNT_WIDTH{1'b0}};
        reload_value = {COUNT_WIDTH{1'b0}};
        prescale_div = {PRESCALE_WIDTH{1'b0}};

        repeat (2) @(posedge clk);
        if (running !== 1'b0) begin
            fail("timer must reset to stopped");
        end
        if (expire_pulse !== 1'b0) begin
            fail("expire pulse must be low during reset");
        end
        if (irq !== 1'b0) begin
            fail("irq must be low during reset");
        end
        if (count_value !== {COUNT_WIDTH{1'b0}}) begin
            fail("count must reset to zero");
        end

        @(negedge clk);
        rst_n = 1'b1;

        drive_cycle(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd3, 8'd0, 4'd0);
        if (running !== 1'b1 || count_value !== 8'd3 || irq !== 1'b0) begin
            fail("start must load count and set running");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd0);
        if (count_value !== 8'd2 || expire_pulse !== 1'b0 || running !== 1'b1) begin
            fail("one-shot first decrement mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd0);
        if (count_value !== 8'd1 || expire_pulse !== 1'b0 || running !== 1'b1) begin
            fail("one-shot second decrement mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd0);
        if (count_value !== 8'd0 || expire_pulse !== 1'b1 || running !== 1'b0 || irq !== 1'b1) begin
            fail("one-shot expiration mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 8'd0, 8'd0, 4'd0);
        if (irq !== 1'b0 || expire_pulse !== 1'b0) begin
            fail("irq acknowledge must clear sticky interrupt");
        end

        drive_cycle(1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 8'd2, 8'd4, 4'd0);
        if (running !== 1'b1 || count_value !== 8'd2) begin
            fail("periodic start mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 8'd0, 8'd4, 4'd0);
        if (count_value !== 8'd1 || expire_pulse !== 1'b0 || running !== 1'b1) begin
            fail("periodic pre-expire decrement mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 8'd0, 8'd4, 4'd0);
        if (count_value !== 8'd4 || expire_pulse !== 1'b1 || running !== 1'b1) begin
            fail("periodic reload mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 8'd3, 8'd4, 4'd0);
        if (count_value !== 8'd3 || running !== 1'b1) begin
            fail("load pulse must reprogram active count");
        end

        drive_cycle(1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 8'd0, 8'd4, 4'd0);
        if (running !== 1'b0 || count_value !== 8'd3) begin
            fail("stop pulse must stop timer without clearing count");
        end

        drive_cycle(1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 8'd0, 8'd4, 4'd0);
        if (running !== 1'b0 || count_value !== 8'd0 || irq !== 1'b0) begin
            fail("clear pulse must clear timer state");
        end

        drive_cycle(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd2, 8'd0, 4'd1);
        if (count_value !== 8'd2 || running !== 1'b1) begin
            fail("prescaled start mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd1);
        if (count_value !== 8'd2 || expire_pulse !== 1'b0) begin
            fail("prescaler should delay first decrement");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd1);
        if (count_value !== 8'd1 || expire_pulse !== 1'b0) begin
            fail("prescaler decrement timing mismatch");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd1);
        if (count_value !== 8'd1 || expire_pulse !== 1'b0) begin
            fail("prescaler should delay second decrement");
        end

        drive_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'd0, 8'd0, 4'd1);
        if (count_value !== 8'd0 || expire_pulse !== 1'b1 || running !== 1'b0 || irq !== 1'b1) begin
            fail("prescaled expiration mismatch");
        end

        $display("TIMER_BLOCK_TB_PASS");
        $finish;
    end
endmodule
