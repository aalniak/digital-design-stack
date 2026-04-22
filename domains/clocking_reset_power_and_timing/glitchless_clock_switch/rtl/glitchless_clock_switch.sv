module glitchless_clock_switch #(
    parameter integer DEFAULT_SOURCE = 0,
    parameter integer STATUS_EN = 1
) (
    input  wire clk_a,
    input  wire clk_b,
    input  wire rst_n,
    input  wire select_req,
    output wire switched_clk,
    output wire active_select,
    output wire active_select_valid,
    output wire source_a_active,
    output wire source_b_active,
    output wire switch_busy
);
    reg select_a_meta_q;
    reg select_a_sync_q;
    reg select_b_meta_q;
    reg select_b_sync_q;
    reg gate_b_meta_in_a_q;
    reg gate_b_sync_in_a_q;
    reg gate_a_meta_in_b_q;
    reg gate_a_sync_in_b_q;
    reg gate_a_q;
    reg gate_b_q;
    wire active_select_int;
    wire active_select_valid_int;
    wire switch_busy_int;

    assign active_select_int = gate_b_q;
    assign active_select_valid_int = gate_a_q || gate_b_q;
    assign switch_busy_int = rst_n && ((!active_select_valid_int) || (select_req != active_select_int));

    assign source_a_active = (STATUS_EN != 0) ? gate_a_q : 1'b0;
    assign source_b_active = (STATUS_EN != 0) ? gate_b_q : 1'b0;
    assign active_select_valid = (STATUS_EN != 0) ? active_select_valid_int : 1'b0;
    assign active_select = (STATUS_EN != 0) ? active_select_int : 1'b0;
    assign switch_busy = (STATUS_EN != 0) ? switch_busy_int : 1'b0;
    assign switched_clk = (gate_a_q ? clk_a : 1'b0) | (gate_b_q ? clk_b : 1'b0);

    initial begin
        if ((DEFAULT_SOURCE != 0) && (DEFAULT_SOURCE != 1)) begin
            $fatal(1, "glitchless_clock_switch requires DEFAULT_SOURCE to be 0 or 1");
        end
        if ((STATUS_EN != 0) && (STATUS_EN != 1)) begin
            $fatal(1, "glitchless_clock_switch requires STATUS_EN to be 0 or 1");
        end
    end

    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            select_a_meta_q <= DEFAULT_SOURCE;
            select_a_sync_q <= DEFAULT_SOURCE;
            gate_b_meta_in_a_q <= (DEFAULT_SOURCE == 1);
            gate_b_sync_in_a_q <= (DEFAULT_SOURCE == 1);
        end
        else begin
            select_a_meta_q <= select_req;
            select_a_sync_q <= select_a_meta_q;
            gate_b_meta_in_a_q <= gate_b_q;
            gate_b_sync_in_a_q <= gate_b_meta_in_a_q;
        end
    end

    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            select_b_meta_q <= DEFAULT_SOURCE;
            select_b_sync_q <= DEFAULT_SOURCE;
            gate_a_meta_in_b_q <= (DEFAULT_SOURCE == 0);
            gate_a_sync_in_b_q <= (DEFAULT_SOURCE == 0);
        end
        else begin
            select_b_meta_q <= select_req;
            select_b_sync_q <= select_b_meta_q;
            gate_a_meta_in_b_q <= gate_a_q;
            gate_a_sync_in_b_q <= gate_a_meta_in_b_q;
        end
    end

    // Each source gate turns off as soon as its source is no longer requested, then waits
    // for a synchronized "other gate is low" observation before enabling the new source.
    // Both gate controls only update on the low phase of their own source clock.
    always @(negedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            gate_a_q <= (DEFAULT_SOURCE == 0);
        end
        else if (select_a_sync_q) begin
            gate_a_q <= 1'b0;
        end
        else begin
            gate_a_q <= !gate_b_sync_in_a_q;
        end
    end

    always @(negedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            gate_b_q <= (DEFAULT_SOURCE == 1);
        end
        else if (!select_b_sync_q) begin
            gate_b_q <= 1'b0;
        end
        else begin
            gate_b_q <= !gate_a_sync_in_b_q;
        end
    end
endmodule
