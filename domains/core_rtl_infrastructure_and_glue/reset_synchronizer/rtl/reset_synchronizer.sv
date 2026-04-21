module reset_synchronizer #(
    parameter integer STAGES = 2,
    parameter bit ACTIVE_LOW = 1'b1,
    parameter bit ASYNC_ASSERT = 1'b1
) (
    input  wire clk,
    input  wire rst_in,
    output wire rst_out,
    output wire release_done
);
    localparam [STAGES-1:0] ASSERTED_VECTOR = {STAGES{1'b1}};
    (* async_reg = "true" *) reg [STAGES-1:0] sync_q;

    wire rst_asserted = ACTIVE_LOW ? ~rst_in : rst_in;

    initial begin
        if (STAGES < 2) begin
            $fatal(1, "reset_synchronizer requires STAGES >= 2");
        end
    end

    generate
        if (ASYNC_ASSERT) begin : gen_async_assert
            always @(posedge clk or posedge rst_asserted) begin
                if (rst_asserted) begin
                    sync_q <= ASSERTED_VECTOR;
                end
                else begin
                    sync_q <= {sync_q[STAGES-2:0], 1'b0};
                end
            end
        end
        else begin : gen_sync_assert
            always @(posedge clk) begin
                if (rst_asserted) begin
                    sync_q <= ASSERTED_VECTOR;
                end
                else begin
                    sync_q <= {sync_q[STAGES-2:0], 1'b0};
                end
            end
        end
    endgenerate

    assign release_done = (sync_q[STAGES-1] == 1'b0);
    assign rst_out = ACTIVE_LOW ? release_done : ~release_done;
endmodule
