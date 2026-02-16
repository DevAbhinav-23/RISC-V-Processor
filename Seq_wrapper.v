`include "ALU/alu.v"
`include "mux.v"
`include "shift_left_1.v"
`include "control.v"
`include "alu_control.v"
`include "immgen.v"
`include "pc.v"
`include "instruction_mem.v"
`include "data_memory.v"
`include "register_file.v"

module seq(
    input clk, reset // synchronous active high reset for the memory blocks
);
    wire [31:0] instruction; // as the name suggest, instruction
    wire temp; // couts of the adder. useless stuff, just there as floating
    wire [63:0] pc_out, pc_in; // pc block input and output
    wire [63:0] shift_left_out; // shift left by 1 immediate output
    wire [63:0] second_op; // the second operand of the PC_Adder
    wire [63:0] imm_gen_out; // immediate generate block output
    wire pc_ctrl; // pc_mux control signal which is the and of branch and zero flag
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite; // control block outputs
    wire [1:0] ALUOp; // 2 bit output of the control block
    wire zero_flag; // ALU output
    wire [63:0] opA, opB, ALU_result; // ALU inputs and outputs
    wire [63:0] read_data_1, read_data_2; // register file outputs
    wire [3:0] ALU_ctrl_out; // ALU control output
    wire [6:0] opcode; // opcode for the control block
    wire [63:0] read_data; // data memory output
    wire [63:0] write_data; // write data for the register file
    assign opcode = instruction[6:0];
    wire [3:0] instr; // the 4 bit signal to the ALU_Control block
    assign instr = {instruction[30], instruction[14:12]};
    assign opA = read_data_1;

    alu_64_bit ALU(
        .a(opA),
        .b(opB),
        .opcode(ALU_ctrl_out),
        .result(ALU_result),
        .zero_flag(zero_flag)
    );

    adder64 pc_adder(
        .A(pc_out),
        .B(second_op),
        .S(pc_in),
        .Cin(1'b0),
        .Cout(temp)
    );

    and (pc_ctrl, Branch, zero_flag);

    mux pc_mux(
        .a(64'd4),
        .b(shift_left_out),
        .sel(pc_ctrl),
        .out(second_op)
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

    instruction_mem instruction_mem_inst(
        .clk(clk),
        .reset(reset),
        .addr(pc_out[11:0]), // in instruction memory we have 4096 bytes available thus only 12 bits is enough to describe the address.
        .instr(instruction)
    );

    mux alu_mux(
        .a(read_data_2),
        .b(imm_gen_out),
        .sel(ALUSrc),
        .out(opB)
    );

    mux mem_mux(
        .a(ALU_result),
        .b(read_data),
        .sel(MemtoReg),
        .out(write_data)
    );

    register_file reg_file_inst(
        .clk(clk),
        .reset(reset),
        .register_write(RegWrite),
        .reg1_r(instruction[19:15]),
        .reg2_r(instruction[24:20]),
        .reg1_w(instruction[11:7]),
        .data_to_w(write_data),
        .output1_r(read_data_1),
        .output2_r(read_data_2)
    );

    data_memory data_mem_inst(
        .clk(clk),
        .reset(reset),
        .mem_r(MemRead),
        .mem_w(MemWrite),
        .addr(ALU_result),
        .input_w(read_data_2),
        .output_w(read_data)
    );
endmodule