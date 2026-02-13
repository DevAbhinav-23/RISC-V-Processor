`timescale 1ns/1ps

module sll64(
    input  [63:0] A, B,
    output [63:0] S,
    output cout, carry_flag, zero_flag, overflow_flag
); 
    // This uses the fact that any number can be represented in binary
    // Can be shifted by at max 63. So, the last 6 bits are enuf
    wire [63:0] s1, s2, s3, s4, s5;
    wire [63:0] zero;
    assign zero = 64'b0; 

    assign s1 = B[0] ? {A[62:0], zero[63]} : A;
    assign s2 = B[1] ? {s1[61:0], zero[63:62]} : s1;
    assign s3 = B[2] ? {s2[59:0], zero[63:60]} : s2;
    assign s4 = B[3] ? {s3[55:0], zero[63:56]} : s3;
    assign s5 = B[4] ? {s4[47:0], zero[63:48]} : s4;
    assign S = B[5] ? {s5[31:0], zero[63:32]} : s5;

    assign zero_flag = (S == 64'b0);
    assign carry_flag = 1'b0;
    assign overflow_flag = A[63] ^ S[63];
    assign cout = 1'b0;
endmodule