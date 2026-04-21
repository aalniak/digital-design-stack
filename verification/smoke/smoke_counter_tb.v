`timescale 1ns/1ps

module smoke_counter_tb;
    reg clk;
    reg rst_n;
    wire [3:0] count;

    smoke_counter #(.WIDTH(4)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        if (count !== 4'd5) begin
            $display("SMOKE_SIM_FAIL count=%0d", count);
            $finish_and_return(1);
        end

        $display("SMOKE_SIM_PASS count=%0d", count);
        $finish;
    end
endmodule
