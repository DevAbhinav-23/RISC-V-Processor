module shift_left_1(
    input [63:0] inp,
    output [63:0] out
);
    assign out = {inp[62:0], 1'b0};
endmodule