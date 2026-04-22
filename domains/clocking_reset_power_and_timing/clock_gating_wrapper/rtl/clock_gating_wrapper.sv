module clock_gating_wrapper #(
    parameter integer DEFAULT_ENABLE = 0,
    parameter integer ACTIVE_HIGH_ENABLE = 1,
    parameter integer TEST_BYPASS_EN = 1,
    parameter integer BYPASS_EN = 1,
    parameter integer FPGA_SAFE_MODE = 0,
    parameter integer ENABLE_SYNC_STAGES = 2
) (
    input  wire clk_in,
    input  wire rst_n,
    input  wire enable_req,
    input  wire test_bypass,
    input  wire bypass,
    output wire gated_clk,
    output wire domain_ce,
    output wire gate_open,
    output wire override_active
);
    localparam integer SYNC_REG_WIDTH = (ENABLE_SYNC_STAGES < 1) ? 1 : ENABLE_SYNC_STAGES;
    localparam [SYNC_REG_WIDTH-1:0] DEFAULT_ENABLE_VECTOR = DEFAULT_ENABLE ? {SYNC_REG_WIDTH{1'b1}} : {SYNC_REG_WIDTH{1'b0}};

    reg [SYNC_REG_WIDTH-1:0] enable_sync_q;
    reg gate_latched_q;

    wire enable_normalized;
    wire enable_qualified;
    wire test_bypass_enabled;
    wire bypass_enabled;
    wire gate_request;

    assign enable_normalized = ACTIVE_HIGH_ENABLE ? enable_req : !enable_req;
    assign enable_qualified = (ENABLE_SYNC_STAGES < 1) ? enable_normalized : enable_sync_q[SYNC_REG_WIDTH-1];
    assign test_bypass_enabled = (TEST_BYPASS_EN != 0) ? test_bypass : 1'b0;
    assign bypass_enabled = (BYPASS_EN != 0) ? bypass : 1'b0;
    assign gate_request = enable_qualified || test_bypass_enabled || bypass_enabled;

    assign override_active = rst_n && (test_bypass_enabled || bypass_enabled);
    assign gate_open = gate_latched_q;
    assign domain_ce = gate_latched_q;
    assign gated_clk = (FPGA_SAFE_MODE != 0) ? clk_in : (gate_latched_q ? clk_in : 1'b0);

    initial begin
        if ((DEFAULT_ENABLE != 0) && (DEFAULT_ENABLE != 1)) begin
            $fatal(1, "clock_gating_wrapper requires DEFAULT_ENABLE to be 0 or 1");
        end
        if ((ACTIVE_HIGH_ENABLE != 0) && (ACTIVE_HIGH_ENABLE != 1)) begin
            $fatal(1, "clock_gating_wrapper requires ACTIVE_HIGH_ENABLE to be 0 or 1");
        end
        if ((TEST_BYPASS_EN != 0) && (TEST_BYPASS_EN != 1)) begin
            $fatal(1, "clock_gating_wrapper requires TEST_BYPASS_EN to be 0 or 1");
        end
        if ((BYPASS_EN != 0) && (BYPASS_EN != 1)) begin
            $fatal(1, "clock_gating_wrapper requires BYPASS_EN to be 0 or 1");
        end
        if ((FPGA_SAFE_MODE != 0) && (FPGA_SAFE_MODE != 1)) begin
            $fatal(1, "clock_gating_wrapper requires FPGA_SAFE_MODE to be 0 or 1");
        end
        if (ENABLE_SYNC_STAGES < 0) begin
            $fatal(1, "clock_gating_wrapper requires ENABLE_SYNC_STAGES >= 0");
        end
    end

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            enable_sync_q <= DEFAULT_ENABLE_VECTOR;
        end
        else if (ENABLE_SYNC_STAGES >= 1) begin
            if (SYNC_REG_WIDTH == 1) begin
                enable_sync_q[0] <= enable_normalized;
            end
            else begin
                enable_sync_q <= {enable_sync_q[SYNC_REG_WIDTH-2:0], enable_normalized};
            end
        end
    end

    // Latch the gate request only while the source clock is low so the gate state
    // cannot change during the high phase and create a spurious pulse.
    always @(negedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            gate_latched_q <= DEFAULT_ENABLE;
        end
        else begin
            gate_latched_q <= gate_request;
        end
    end
endmodule
