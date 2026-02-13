`timescale 1ns/1ps
`include "add64.v"
`include "shift_left.v"
`include "less_than.v"
`include "less_than_u.v"
`include "xor64.v"
`include "shift_right.v"
`include "or64.v"
`include "and64.v"
`include "sub64.v"
`include "shift_right_arithmetic.v"
`include "cla.v"
`include "pg_block.v"
`include "helper.v"

module alu_64_bit(
    input [63:0] a, b,
    input [3:0]  opcode,
    output [63:0] result,
    output cout, carry_flag, overflow_flag, zero_flag
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
    wire [63:0] add_ans, sub_ans, xor_ans, or_ans, and_ans, sll_ans, srl_ans, sra_ans, slt_ans, sltu_ans;
    wire add_cout, add_zero, add_overflow, add_carry;
    wire sub_cout, sub_zero, sub_overflow, sub_carry;
    wire xor_cout, xor_zero, xor_overflow, xor_carry;
    wire or_cout, or_zero, or_overflow, or_carry;
    wire and_cout, and_zero, and_overflow, and_carry;
    wire sll_cout, sll_zero, sll_overflow, sll_carry;
    wire srl_cout, srl_zero, srl_overflow, srl_carry;
    wire sra_cout, sra_zero, sra_overflow, sra_carry;
    wire slt_cout, slt_zero, slt_overflow, slt_carry;
    wire sltu_cout, sltu_zero, sltu_overflow, sltu_carry;

    // declaring the reg bcz in always block of switch case, cannot assign wires
    reg [63:0] ans;
    reg z_flag, o_flag, c_flag, c_out;
    assign cout = c_out;
    assign result = ans;
    assign carry_flag = c_flag;
    assign overflow_flag = o_flag;
    assign zero_flag = z_flag;

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
    
    adder64 inst0(
        .A(a),
        .B(b),
        .S(add_ans),
        .Cout(add_cout),
        .zero_flag(add_zero),
        .carry_flag(add_carry),
        .overflow_flag(add_overflow)
    );
    sub64 inst1(
        .A(a),
        .B(b),
        .S(sub_ans),
        .Cout(sub_cout),
        .zero_flag(sub_zero),
        .carry_flag(sub_carry),
        .overflow_flag(sub_overflow)
    );
    xor64 inst2(
        .A(a),
        .B(b),
        .C(xor_ans),
        .cout(xor_cout),
        .zero_flag(xor_zero),
        .carry_flag(xor_carry),
        .overflow_flag(xor_overflow)
    );
    or64 inst3(
        .A(a),
        .B(b),
        .C(or_ans),
        .cout(or_cout),
        .zero_flag(or_zero),
        .carry_flag(or_carry),
        .overflow_flag(or_overflow)
    );
    and64 inst4(
        .A(a),
        .B(b),
        .C(and_ans),
        .cout(and_cout),
        .zero_flag(and_zero),
        .carry_flag(and_carry),
        .overflow_flag(and_overflow)
    );
    sll64 inst5(
        .A(a),
        .B(b),
        .S(sll_ans),
        .cout(sll_cout),
        .zero_flag(sll_zero),
        .carry_flag(sll_carry),
        .overflow_flag(sll_overflow)
    );
    srl64 inst6(
        .A(a),
        .B(b),
        .S(srl_ans),
        .cout(srl_cout),
        .zero_flag(srl_zero),
        .carry_flag(srl_carry),
        .overflow_flag(srl_overflow)
    );
    sra64 inst7(
        .A(a),
        .B(b),
        .S(sra_ans),
        .cout(sra_cout),
        .zero_flag(sra_zero),
        .carry_flag(sra_carry),
        .overflow_flag(sra_overflow)
    );
    slt64 inst8(
        .A(a),
        .B(b),
        .S(slt_ans),
        .Cout(slt_cout),
        .zero_flag(slt_zero),
        .carry_flag(slt_carry),
        .overflow_flag(slt_overflow)
    );
    sltu64 inst9(
        .A(a),
        .B(b),
        .S(sltu_ans),
        .Cout(sltu_cout),
        .zero_flag(sltu_zero),
        .carry_flag(sltu_carry),
        .overflow_flag(sltu_overflow)
    );

    always @(*) begin
        case(opcode)
            ADD_Oper: begin
                ans = add_ans;
                z_flag = add_zero;
                o_flag = add_overflow;
                c_flag = add_carry;
                c_out = add_cout;
            end
            SLL_Oper: begin
                ans = sll_ans;
                z_flag = sll_zero;
                o_flag = sll_overflow;
                c_flag = sll_carry;
                c_out = sll_cout;
            end
            SLT_Oper: begin
                ans = slt_ans;
                z_flag = slt_zero;
                o_flag = slt_overflow;
                c_flag = slt_carry;
                c_out = slt_cout;
            end
            SLTU_Oper: begin
                ans = sltu_ans;
                z_flag = sltu_zero;
                o_flag = sltu_overflow;
                c_flag = sltu_carry;
                c_out = sltu_cout;
            end
            XOR_Oper: begin
                ans = xor_ans;
                z_flag = xor_zero;
                o_flag = xor_overflow;
                c_flag = xor_carry;
                c_out = xor_cout;
            end
            SRL_Oper: begin
                ans = srl_ans;
                z_flag = srl_zero;
                o_flag = srl_overflow;
                c_flag = srl_carry;
                c_out = srl_cout;
            end
            OR_Oper: begin
                ans = or_ans;
                z_flag = or_zero;
                o_flag = or_overflow;
                c_flag = or_carry;
                c_out = or_cout;
            end
            AND_Oper: begin
                ans = and_ans;
                z_flag = and_zero;
                o_flag = and_overflow;
                c_flag = and_carry;
                c_out = and_cout;
            end
            SUB_Oper: begin
                ans = sub_ans;
                z_flag = sub_zero;
                o_flag = sub_overflow;
                c_flag = sub_carry;
                c_out = sub_cout;
            end
            SRA_Oper: begin
                ans = sra_ans;
                z_flag = sra_zero;
                o_flag = sra_overflow;
                c_flag = sra_carry;
                c_out = sra_cout;
            end
            default: begin
                ans = 64'b0;
                z_flag = 1'b1; // remember that the default result is zero, so this flag shud turn on in default
                o_flag = 1'b0;
                c_flag = 1'b0;
                c_out = 1'b0;
            end
        endcase
    end
endmodule