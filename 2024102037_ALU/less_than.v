`timescale 1ns/1ps

module slt64(
    input [63:0] A, B,
    output [63:0] S,
    output Cout,
    output zero_flag, carry_flag, overflow_flag
);
    wire [63:0] B_inv, Difference;
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : gen
            not(B_inv[i], B[i]);
        end
    endgenerate
    wire [16:0] C; // intermediate carry outs. note that there are 16 + 1 = 17 carries
    assign C[0] = 1'b1;
    generate
        for(i = 0; i < 16; i = i + 1) begin : chain
            CLA cla_inst(
                .A(A[(i + 1)*4 - 1 : i*4]),
                .B(B_inv[(i + 1)*4 - 1 : i*4]),
                .Cin(C[i]),
                .S(Difference[(i + 1)*4 - 1 : i*4]),
                .Cout(C[i + 1])
            );
        end
    endgenerate
    assign S[63:1] = 63'b0;
    wire diff, w1, same, w2;
    xor(diff, A[63], B[63]);
    and(w1, diff, A[63]);
    xnor(same, A[63], B[63]);
    and(w2, same, Difference[63]);
    or(S[0], w1, w2);
    assign Cout = 1'b0;
    assign zero_flag = ~S[0];
    assign carry_flag = 1'b0;
    assign overflow_flag = 1'b0;
endmodule