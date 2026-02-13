`include "ALU/alu.v"
`include "ALU/add64.v"
`include "mux.v"
`include "shift_left_1.v"

module seq(
    input clk
);
    wire temp1, temp2; // couts of both the adders 
    wire [63:0] pc_out, pc_in; // pc block input and output
    wire [63:0] shift_left_out; // shift left by 2 immediate output
    wire [63:0] pc_mux_0, pc_mux_1; // pc_mux input signals
    wire pc_ctrl;
    wire branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite;
    wire zero_flag;
    wire [63:0] opA, opB, ALU_result;
    wire [3:0] ALU_ctrl_out;

    alu_64_bit(
        .a(opA),
        .b(opB),
        .opcode(ALU_ctrl_out),
        .result(ALU_result),
        .zero_flag(zero_flag)
    );

    adder64 pc_adder(
        .A(pc_out),
        .B(64'd4),
        .S(pc_mux_0),
        .Cin(1'b0),
        .Cout(temp1)
    );

    adder64 shift_adder(
        .A(pc_out),
        .B(shift_left_out),
        .S(pc_mux_1),
        .Cin(1'b0),
        .Cout(temp2)
    );

    and (pc_ctrl, branch, zero_flag);

    mux pc_mux(
        .a(pc_mux_0),
        .b(pc_mux_1),
        .sel(pc_ctrl),
        .out(pc_in)
    );

    shift_left_1 left_inst(
        .inp(imm_gen_out),
        .out(shift_left_out)
    );
endmodule