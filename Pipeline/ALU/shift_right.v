`timescale 1ns/1ps

module srl64(
    input  [63:0] A, B,
    output [63:0] S
);
    // This uses the fact that abny number can be represented in binary
    // Can be shifted by at max 63. So, the last 6 bits are enuf
    wire [63:0] s1, s2, s3, s4, s5;
    wire [63:0] zero;
    assign zero = 64'b0;

    assign s1 = B[0] ? {zero[63], A[63:1]} : A;
    assign s2 = B[1] ? {zero[63:62], s1[63:2]} : s1;
    assign s3 = B[2] ? {zero[63:60], s2[63:4]} : s2;
    assign s4 = B[3] ? {zero[63:56], s3[63:8]} : s3;
    assign s5 = B[4] ? {zero[63:48], s4[63:16]} : s4;
    assign S = B[5] ? {zero[63:32], s5[63:32]} : s5;
endmodule