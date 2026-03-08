`timescale 1ns/1ps

module and64(
    input [63:0] A, B,
    output [63:0] C
);
    genvar i;
    generate 
        for(i = 0; i < 64; i = i + 1) begin : gen
            and(C[i], A[i], B[i]);
        end
    endgenerate
endmodule