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
    wire [63:0] immgen_out;
    wire [31:0] IF_ID_instr;
    wire [63:0] IF_ID_pc;

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
    )
endmodule