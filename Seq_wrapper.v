`include "ALU/alu.v"
`include "ALU/add64.v"
`include "mux.v"
`include "shift_left_1.v"
`include "control.v"
`include "alu_control.v"
`include "immgen.v"
`include "pc.v"

module seq(
    input clk, reset // synchronous active high reset for the memory blocks
);
    wire [31:0] instruction; // as the name suggest, instruction
    wire temp1, temp2; // couts of both the adders. useless stuff, just there as floating
    wire [63:0] pc_out, pc_in; // pc block input and output
    wire [63:0] shift_left_out; // shift left by 1 immediate output
    wire [63:0] pc_mux_0, pc_mux_1; // pc_mux input signals
    wire [63:0] imm_gen_out; // immediate generate block output
    wire pc_ctrl; // pc_mux control signal which is the and of branch and zero flag
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite; // control block outputs
    wire [1:0] ALUOp; // 2 bit output of the control block
    wire zero_flag; // ALU output
    wire [63:0] opA, opB, ALU_result; // ALU inputs and outputs
    wire [3:0] ALU_ctrl_out; // ALU control output
    wire [6:0] opcode; // opcode for the control block
    assign opcode = instruction[6:0];
    wire [3:0] instr; // the 4 bit signal to the ALU_Control block
    assign instr = {instruction[30], instruction[14:12]};

    alu_64_bit ALU(
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

    and (pc_ctrl, Branch, zero_flag);

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

    control ctrl_inst(
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    pc pc_inst(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    immgen immgen_inst(
        .instr(instruction), 
        .imm(imm_gen_out)
    );

    alu_control alu_control_inst(
        .alu_op(ALUOp),
        .instr(instr),
        .alu_c(ALU_ctrl_out)
    );
endmodule