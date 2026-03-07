`timescale 1ns/1ps

`include "alu.v"
`include "mux.v"
`include "mux_4x1.v"
`include "control.v"
`include "alu_control.v"
`include "immgen.v"
`include "pc.v"
`include "instruction_mem.v"
`include "data_memory.v"
`include "register_file.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"
`include "forwarding_unit.v"
`include "extra_forward_unit.v"
`include "branch_forward_unit.v"
`include "hazard_detection.v"

module pipeline(
    input clk,
    input reset
);
    wire temp1, temp2; // adders carry flag temp floating wires
    wire pc_ctrl;
    wire [63:0] pc_in, pc_out;
    wire [63:0] pc_adder_out, branch_adder_out;
    wire [63:0] immgen_out; // goes into ID/EX
    wire [31:0] IF_ID_instr; // funct3, funct7's one bit and rd and rs2 addresses go into this
    wire [63:0] IF_ID_pc;
    wire [63:0] branchfwd_A, branchfwd_B, xor_ans;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite; // control block outputs which go into ID/EX (all go except branch)
    wire [1:0] ALUOp; // 2 bit output of the control block which also goes into ID/EX
    wire [1:0] sel_br_a, sel_br_b, sel_a, sel_b;
    wire [63:0] ALU_mux_out, fwd_A, fwd_B,
    wire [3:0] ALU_ctrl_out; // ALU's opcode kind of thing
    wire [31:0] instruction;

    mux pc_mux(
        .a(pc_adder_out),
        .b(branch_adder_out),
        .sel(pc_ctrl),
        .out(pc_in)
    );

    adder64 pc_adder(
        .A(pc_out),
        .B(64'd4),
        .S(pc_adder_out),
        .Cin(1'b0),
        .Cout(temp1)
    );

    adder64 branch_adder(
        .A(IF_ID_pc),
        .B(immgen_out),
        .S(branch_adder_out),
        .Cin(1'b0),
        .Cout(temp2)
    );

    immgen immgen_inst(
        .instr(IF_ID_instr),
        .imm(immgen_out)
    );

    xor64 xor_inst(
        .A(branchfwd_A),
        .B(branchfwd_B),
        .C(xor_ans)
    );

    wire zero_flag;
    assign zero_flag = (xor_ans == 64'b0);
    assign pc_ctrl = zero_flag & Branch;

    mux_4x1 branchfwdA(
        .a(),
        .b(),
        .c(),
        .sel(sel_br_a),
        .out(branchfwd_A)
    );

    mux_4x1 branchfwdB(
        .a(),
        .b(),
        .c(),
        .sel(sel_br_b),
        .out(branchfwd_B)
    );

    branch_forwarding_unit b_fwd(
        .rs1(IF_ID_instr[19:15]),
        .rs2(IF_ID_instr[24:20]),
        .rd_EXMEM(),
        .rd_MEMWB(),
        .RegWrite_IDEX(),
        .RegWrite_EXMEM(),
        .fwdA(sel_br_a),
        .fwdB(sel_br_a)
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

    alu_control alu_control_inst(
        .ALUOp(),
        .instr(),
        .alu_c(ALU_ctrl_out)
    );

    mux ALUmux(
        .a(fwd_B),
        .b(immgen_out),
        .sel(),
        .out(ALU_mux_out)
    );

    mux_4x1 fwdA(
        .a(),
        .b(),
        .c(),
        .sel(sel_a),
        .out(fwd_A)
    );

    mux_4x1 fwdB(
        .a(),
        .b(),
        .c(),
        .sel(sel_b),
        .out(fwd_B)
    );

    alu_64_bit(
        .a(fwd_A),
        .b(ALU_mux_out),
        .opcode(ALU_ctrl_out),
        .result()
    );

   register_file reg_file_inst(
        .clk(clk),
        .reset(reset),
        .register_write(),
        .reg1_r(),
        .reg2_r(),
        .reg1_w(),
        .data_to_w(),
        .output1_r(),
        .output2_r()
    );

    data_memory data_mem_inst(
        .clk(clk),
        .reset(reset),
        .mem_r(),
        .mem_w(),
        .addr(),
        .input_w(),
        .output_w()
    );

    instruction_mem instruction_mem_inst(
        .clk(clk),
        .reset(reset),
        .addr(pc_out), // in instruction memory we have 4096 bytes available thus only 12 bits is enough to describe the address.
        .instr(instruction)
    );

    pc pc_inst(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    mux WB_mux(
        .a(),
        .b(),
        .sel(),
        .out()
    );

    extra_forward_unit extra_forward_unit_int(
        .rd(),
        .rs(),
        .MemRead(),
        .MemWrite(),
        .ef_mux_select()
    );

    IF_ID IF_ID_register(
        .reset(reset),
        .clk(clk),
        .flush(),
        .stall(),
        .PC_in(pc_out),
        .inst_in(instruction),
        .PC_out(IF_ID_pc),
        .inst_out(IF_ID_instr)
    );
endmodule