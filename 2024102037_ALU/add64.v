`timescale 1ns/1ps

module adder64(
    input [63:0] A, B,
    output [63:0] S,
    output Cout,
    output zero_flag, carry_flag, overflow_flag
);
    wire [16:0] C; // intermediate carry outs. note that there are 16 + 1 = 17 carries
    assign C[0] = 1'b0;
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1) begin : chain
            CLA cla_inst(
                .A(A[(i + 1)*4 - 1 : i*4]),
                .B(B[(i + 1)*4 - 1 : i*4]),
                .Cin(C[i]),
                .S(S[(i + 1)*4 - 1 : i*4]),
                .Cout(C[i + 1])
            );
        end
    endgenerate
    assign Cout = C[16];
    assign zero_flag = (S == 64'b0);
    assign carry_flag = C[16];
    assign overflow_flag = (~(A[63] ^ B[63])) & (A[63] ^ S[63]); // both inputs are same sign but the output is of different sign, then it is overflow
endmodule