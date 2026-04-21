module interrupt_controller_tb;
    localparam integer NUM_SOURCES = 4;
    localparam integer ID_WIDTH = (NUM_SOURCES <= 1) ? 1 : $clog2(NUM_SOURCES);

    reg clk;
    reg rst_n;
    reg [NUM_SOURCES-1:0] src_event;
    reg [NUM_SOURCES-1:0] src_level_mode;
    reg [NUM_SOURCES-1:0] enable_mask;
    reg [NUM_SOURCES-1:0] sw_set;
    reg [NUM_SOURCES-1:0] ack_mask;
    wire [NUM_SOURCES-1:0] raw_status;
    wire [NUM_SOURCES-1:0] pending_status;
    wire [NUM_SOURCES-1:0] active_onehot;
    wire irq;
    wire [ID_WIDTH-1:0] irq_id;

    interrupt_controller #(
        .NUM_SOURCES(NUM_SOURCES)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .src_event(src_event),
        .src_level_mode(src_level_mode),
        .enable_mask(enable_mask),
        .sw_set(sw_set),
        .ack_mask(ack_mask),
        .raw_status(raw_status),
        .pending_status(pending_status),
        .active_onehot(active_onehot),
        .irq(irq),
        .irq_id(irq_id)
    );

    always #5 clk = ~clk;

    task automatic fail;
        input [1023:0] message;
        begin
            $display("INTERRUPT_CONTROLLER_TB_FAIL %0s", message);
            $fatal(1, "%0s", message);
        end
    endtask

    task automatic drive_cycle;
        input [NUM_SOURCES-1:0] src_event_i;
        input [NUM_SOURCES-1:0] src_level_mode_i;
        input [NUM_SOURCES-1:0] enable_mask_i;
        input [NUM_SOURCES-1:0] sw_set_i;
        input [NUM_SOURCES-1:0] ack_mask_i;
        begin
            @(negedge clk);
            src_event = src_event_i;
            src_level_mode = src_level_mode_i;
            enable_mask = enable_mask_i;
            sw_set = sw_set_i;
            ack_mask = ack_mask_i;
            @(posedge clk);
            #1;
            sw_set = {NUM_SOURCES{1'b0}};
            ack_mask = {NUM_SOURCES{1'b0}};
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        src_event = {NUM_SOURCES{1'b0}};
        src_level_mode = {NUM_SOURCES{1'b0}};
        enable_mask = {NUM_SOURCES{1'b1}};
        sw_set = {NUM_SOURCES{1'b0}};
        ack_mask = {NUM_SOURCES{1'b0}};

        repeat (2) @(posedge clk);
        if (pending_status !== {NUM_SOURCES{1'b0}} || irq !== 1'b0) begin
            fail("reset must clear pending delivery");
        end

        @(negedge clk);
        rst_n = 1'b1;

        drive_cycle(4'b0100, 4'b0000, 4'b1111, 4'b0000, 4'b0000);
        if (pending_status !== 4'b0100 || irq !== 1'b1 || irq_id !== 2 || active_onehot !== 4'b0100) begin
            fail("edge pulse capture mismatch");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0000, 4'b0100);
        if (pending_status !== 4'b0000 || irq !== 1'b0) begin
            fail("acknowledge must clear edge pending");
        end

        drive_cycle(4'b1010, 4'b0000, 4'b1111, 4'b0000, 4'b0000);
        if (pending_status !== 4'b1010 || irq !== 1'b1 || irq_id !== 1 || active_onehot !== 4'b0010) begin
            fail("fixed priority mismatch for simultaneous edges");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0000, 4'b0010);
        if (pending_status !== 4'b1000 || irq !== 1'b1 || irq_id !== 3 || active_onehot !== 4'b1000) begin
            fail("next pending source should surface after ack");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0000, 4'b1000);
        if (pending_status !== 4'b0000 || irq !== 1'b0) begin
            fail("final ack should clear remaining edge pending");
        end

        drive_cycle(4'b0010, 4'b0000, 4'b1101, 4'b0000, 4'b0000);
        if (pending_status !== 4'b0010 || irq !== 1'b0) begin
            fail("masked source should accumulate pending without delivery");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0000, 4'b0000);
        if (pending_status !== 4'b0010 || irq !== 1'b1 || irq_id !== 1) begin
            fail("unmask should expose previously pending source");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0000, 4'b0010);
        if (pending_status !== 4'b0000 || irq !== 1'b0) begin
            fail("ack should clear unmasked pending source");
        end

        drive_cycle(4'b0001, 4'b0001, 4'b1111, 4'b0000, 4'b0000);
        if (pending_status !== 4'b0001 || irq !== 1'b1 || irq_id !== 0 || active_onehot !== 4'b0001) begin
            fail("level source should assert immediately");
        end

        drive_cycle(4'b0001, 4'b0001, 4'b1111, 4'b0000, 4'b0001);
        if (pending_status !== 4'b0001 || irq !== 1'b1 || irq_id !== 0) begin
            fail("ack should not suppress asserted level source");
        end

        drive_cycle(4'b0000, 4'b0001, 4'b1111, 4'b0000, 4'b0000);
        if (pending_status !== 4'b0000 || irq !== 1'b0) begin
            fail("level source should clear after deassertion");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0100, 4'b0000);
        if (pending_status !== 4'b0100 || irq !== 1'b1 || irq_id !== 2) begin
            fail("software set should create pending interrupt");
        end

        drive_cycle(4'b0000, 4'b0000, 4'b1111, 4'b0000, 4'b0100);
        if (pending_status !== 4'b0000 || irq !== 1'b0) begin
            fail("ack should clear software-set pending interrupt");
        end

        $display("INTERRUPT_CONTROLLER_TB_PASS");
        $finish;
    end
endmodule
