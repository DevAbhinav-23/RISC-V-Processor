`timescale 1ns/1ps
`include "ALU/add64.v"
`include "ALU/shift_left.v"
`include "ALU/xor64.v"
`include "ALU/shift_right.v"
`include "ALU/or64.v"
`include "ALU/and64.v"
`include "ALU/shift_right_arithmetic.v"
`include "ALU/cla.v"
`include "ALU/pg_block.v"
`include "ALU/helper.v"

module alu_64_bit(
    input [63:0] a, b,
    input [3:0]  opcode,
    output [63:0] result
);
    // ADD_Oper  = 4'b0000,
    // SLL_Oper  = 4'b0001,
    // SLT_Oper  = 4'b0010,
    // SLTU_Oper = 4'b0011,
    // XOR_Oper  = 4'b0100,
    // SRL_Oper  = 4'b0101,
    // OR_Oper   = 4'b0110,
    // AND_Oper  = 4'b0111,
    // SUB_Oper  = 4'b1000,
    // SRA_Oper  = 4'b1101;
    localparam ADD_Oper  = 4'b0000,
               SLL_Oper  = 4'b0001,
               SLT_Oper  = 4'b0010,
               SLTU_Oper = 4'b0011,
               XOR_Oper  = 4'b0100,
               SRL_Oper  = 4'b0101,
               OR_Oper   = 4'b0110,
               AND_Oper  = 4'b0111,
               SUB_Oper  = 4'b1000,
               SRA_Oper  = 4'b1101;
               
    wire [63:0] add_ans, xor_ans, or_ans, and_ans, sll_ans, srl_ans, sra_ans, slt_ans, sltu_ans;
    wire cout;
    // declaring the reg bcz in always block of switch case, cannot assign wires
    reg [63:0] ans;
    assign result = ans;
    wire cin;
    assign cin = (opcode == SUB_Oper)  | (opcode == SLT_Oper)  | (opcode == SLTU_Oper); // cin = 1 for these 3 operations else 0
    wire [63:0] b_inv;
    xor64 b_flip(
        .A(b),
        .B({64{cin}}),
        .C(b_inv)
    ); // b_inv = b for cin = 0, b_inv = ~b for cin = 1;
    
    adder64 inst0(
        .A(a),
        .B(b_inv),
        .S(add_ans),
        .Cin(cin),
        .Cout(cout)
    );
    xor64 inst1(
        .A(a),
        .B(b),
        .C(xor_ans)
    );
    or64 inst2(
        .A(a),
        .B(b),
        .C(or_ans)
    );
    and64 inst3(
        .A(a),
        .B(b),
        .C(and_ans)
    );
    sll64 inst4(
        .A(a),
        .B(b),
        .S(sll_ans)
    );
    srl64 inst5(
        .A(a),
        .B(b),
        .S(srl_ans)
    );
    sra64 inst6(
        .A(a),
        .B(b),
        .S(sra_ans)
    );
    wire overflow;
    assign overflow = (a[63] ^ b[63]) & (add_ans[63] ^ a[63]);
    assign slt_ans = {63'b0, add_ans[63] ^ overflow}; 
    assign sltu_ans = {63'b0, ~cout}; // if borrow is happening, A < B and borrow = ~cout, where cout is the final bit carry of the 64 bit adder
    always @(*) begin
        case(opcode)
            ADD_Oper: ans = add_ans;
            SLL_Oper: ans = sll_ans;
            SLT_Oper: ans = slt_ans;
            SLTU_Oper: ans = sltu_ans;
            XOR_Oper: ans = xor_ans;
            SRL_Oper: ans = srl_ans;
            OR_Oper: ans = or_ans;
            AND_Oper: ans = and_ans;
            SUB_Oper: ans = add_ans;
            SRA_Oper: ans = sra_ans;
            default: ans = 64'b0;
        endcase
    end
endmodule