module CLA( // 4 bit CLA using the research paper referred for VLSID project
    input [3:0] A, B,
    input Cin,
    output [3:0] S,
    output Cout
);
    wire [3:0] p_not;
    wire [3:0] g_not;
    wire [3:0] C; // carry bits
    wire [3:0] inter; // ai ^ bi

    wire Cin_not, C0_inter;
    wire C1_1, C1_2, C1_inter;
    wire C2_1, C2_2, C2_inter;
    wire C3_1, C3_2, C3_inter_01, C3_inter_02, C3_inter_03, C3_inter_04;

    pg_block pg0(A[0], B[0], p_not[0], g_not[0], inter[0]);
    pg_block pg1(A[1], B[1], p_not[1], g_not[1], inter[1]);
    pg_block pg2(A[2], B[2], p_not[2], g_not[2], inter[2]);
    pg_block pg3(A[3], B[3], p_not[3], g_not[3], inter[3]);

    // Carry C0
    not(Cin_not, Cin);
    or(C0_inter, p_not[0], Cin_not);
    nand(C[0], g_not[0], C0_inter);

    // Carry C1
    helper h1(g_not[1], p_not[1], g_not[0], p_not[0], C1_1, C1_2);
    and(C1_inter, Cin, C1_2);
    or(C[1], C1_1, C1_inter);

    // Carry C2
    helper h2(g_not[2], p_not[2], g_not[1], p_not[1], C2_1, C2_2);
    and(C2_inter, C[0], C2_2);
    or(C[2], C2_1, C2_inter);

    // Carry C3
    helper h3(g_not[3], p_not[3], g_not[2], p_not[2], C3_1, C3_2);
    and(C3_inter_01, C3_2, C1_1);
    nor(C3_inter_02, C3_inter_01, C3_1);
    nand(C3_inter_03, C3_2, C1_2);
    or(C3_inter_04, Cin_not, C3_inter_03);
    nand(C[3], C3_inter_02, C3_inter_04);

    // Final sum bits
    xor(S[0], Cin,  inter[0]);
    xor(S[1], C[0], inter[1]);
    xor(S[2], C[1], inter[2]);
    xor(S[3], C[2], inter[3]);

    // Carry out
    assign Cout = C[3];
endmodule