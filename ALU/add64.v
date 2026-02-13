`timescale 1ns/1ps

module adder64(
    input [63:0] A, B,
    output [63:0] S,
    input Cin,
    output Cout,
    output zero_flag
);
    wire [16:0] C; // intermediate carry outs. note that there are 16 + 1 = 17 carries
    assign C[0] = Cin;
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
endmodule