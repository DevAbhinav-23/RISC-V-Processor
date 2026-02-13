`timescale 1ns/1ps

module and64(
    input [63:0] A, B,
    output [63:0] C,
    output zero_flag, carry_flag, overflow_flag, cout
);
    genvar i;
    generate 
        for(i = 0; i < 64; i = i + 1) begin : gen
            and(C[i], A[i], B[i]);
        end
    endgenerate
    assign zero_flag = (C == 64'b0);
    assign carry_flag = 1'b0;
    assign overflow_flag = 1'b0;
    assign cout = 1'b0;
endmodule