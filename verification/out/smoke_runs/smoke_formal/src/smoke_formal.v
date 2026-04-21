module smoke_formal(
    input  wire a,
    input  wire b,
    output wire y
);
    assign y = a & b;

    always @(*) begin
        assert (y == (a & b));
    end
endmodule
