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
`include "branch_forwarding_unit.v"
`include "hazard_detection.v"

module pipeline(
    input clk,
    input reset
);
    wire temp1, temp2; // adders carry flag temp floating wires
    wire pc_ctrl;
    wire [63:0] pc_in, pc_out, final_pc_in;
    wire [63:0] pc_adder_out, branch_adder_out;
    wire [63:0] immgen_out; // goes into ID/EX
    wire [31:0] IF_ID_instr; // funct3, funct7's one bit and rd and rs2 addresses go into this
    wire [63:0] IF_ID_pc;
    wire [63:0] branchfwd_A, branchfwd_B, xor_ans;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite; // control block outputs which go into ID/EX (all go except branch)
    wire [1:0] ALUOp; // 2 bit output of the control block which also goes into ID/EX
    wire [1:0] sel_br_a, sel_br_b, sel_a, sel_b;
    wire [63:0] ALU_mux_out, fwd_A, fwd_B;
    wire [3:0] ALU_ctrl_out; // ALU's opcode kind of thing
    wire [31:0] instruction;
    wire ef_mux_select;
    wire [63:0] read1,read2;
    wire [63:0] read1_ex,read2_ex;
    wire [1:0] ALUOp_ex;
    wire MemRead_ex,MemtoReg_ex,RegWrite_ex,ALUSrc_ex,MemWrite_ex;
    wire [63:0] imm_out_ex;
    wire [4:0] rd_ex,rs1_ex,rs2_ex;
    wire [3:0] funct_ex;
    wire [63:0] ALU_result;
    wire [63:0] ALU_result_mem,ALU_rs2_mem;
    wire [4:0] rd_mem,rs2_mem;
    wire MemRead_mem,MemtoReg_mem,MemWrite_mem,RegWrite_mem;
    wire MemRead_wb,MemtoReg_wb,RegWrite_wb;
    wire [4:0] rd_wb;
    wire [63:0] ALU_result_wb;
    wire [63:0] data_to_write;
    wire [63:0] read_data_memory, read_data_memory_wb;
    wire [63:0] datamemory_in;
    wire stall;

    hazard_detection hazard_detection_inst(
        .rs1_IFID(IF_ID_instr[19:15]),
        .rs2_IFID(IF_ID_instr[24:20]),
        .Branch_IFID(Branch),
        .MemWrite_IFID(MemWrite),
        .rd_IDEX(rd_ex),
        .MemRead_IDEX(MemRead_ex),
        .RegWrite_IDEX(RegWrite_ex),
        .rd_EXMEM(rd_mem),
        .MemRead_EXMEM(MemRead_mem),
        .stall(stall)
    );

    wire idex_MemRead = stall ? 1'b0 : MemRead;
    wire idex_MemtoReg = stall ? 1'b0 : MemtoReg;
    wire idex_MemWrite = stall ? 1'b0 : MemWrite;
    wire idex_ALUSrc = stall ? 1'b0 : ALUSrc;
    wire idex_RegWrite = stall ? 1'b0 : RegWrite;
    wire [1:0] idex_ALUOp = stall ? 2'b00 : ALUOp;

    assign final_pc_in = stall ? pc_out : pc_in;

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

    wire zero_flag = (xor_ans == 64'b0);
    assign pc_ctrl = zero_flag & Branch;

    mux_4x1 branchfwdA(
        .a(read1),
        .b(ALU_result_mem),
        .c(64'b0),
        .d(data_to_write),
        .sel(sel_br_a),
        .out(branchfwd_A)
    );

    mux_4x1 branchfwdB(
        .a(read2),
        .b(ALU_result_mem),
        .c(64'b0),
        .d(data_to_write),
        .sel(sel_br_b),
        .out(branchfwd_B)
    );

    branch_forwarding_unit b_fwd(
        .rs1(IF_ID_instr[19:15]),
        .rs2(IF_ID_instr[24:20]),
        // .rd_IDEX(rd_ex),
        .rd_EXMEM(rd_mem),
        .rd_MEMWB(rd_wb),
        .RegWrite_MEMWB(RegWrite_wb),
        // .RegWrite_IDEX(RegWrite_ex),
        .RegWrite_EXMEM(RegWrite_mem),
        .fwdA(sel_br_a),
        .fwdB(sel_br_b)
    );

    control ctrl_inst(
        .opcode(IF_ID_instr[6:0]),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    alu_control alu_control_inst(
        .ALUOp(ALUOp_ex),
        .instr(funct_ex),
        .alu_c(ALU_ctrl_out)
    );

    mux ALUmux(
        .a(fwd_B),
        .b(imm_out_ex),
        .sel(ALUSrc_ex),
        .out(ALU_mux_out)
    );

    mux_4x1 fwdA(
        .a(read1_ex),
        .b(data_to_write),
        .c(ALU_result_mem),
        .d(64'b0),
        .sel(sel_a),
        .out(fwd_A)
    );

    mux_4x1 fwdB(
        .a(read2_ex),
        .b(data_to_write),
        .c(ALU_result_mem),
        .d(64'b0),
        .sel(sel_b),
        .out(fwd_B)
    );

    alu_64_bit alu_64_bit_inst(
        .a(fwd_A),
        .b(ALU_mux_out),
        .opcode(ALU_ctrl_out),
        .result(ALU_result)
    );

   register_file reg_file_inst(
        .clk(clk),
        .reset(reset),
        .register_write(RegWrite_wb),
        .reg1_r(IF_ID_instr[19:15]),
        .reg2_r(IF_ID_instr[24:20]),
        .reg1_w(rd_wb),
        .data_to_w(data_to_write),
        .output1_r(read1),
        .output2_r(read2)
    );

    data_memory data_mem_inst(
        .clk(clk),
        .reset(reset),
        .mem_r(MemRead_mem),
        .mem_w(MemWrite_mem),
        .addr(ALU_result_mem),
        .input_w(datamemory_in),
        .output_w(read_data_memory)
    );

    instruction_mem instruction_mem_inst(
        .clk(clk),
        .reset(reset),
        .addr(pc_out[11:0]), // in instruction memory we have 4096 bytes available thus only 12 bits is enough to describe the address.
        .instr(instruction)
    );

    pc pc_inst(
        .clk(clk),
        .reset(reset),
        .pc_in(final_pc_in),
        .pc_out(pc_out)
    );

    mux WB_mux(
        .a(ALU_result_wb),
        .b(read_data_memory_wb),
        .sel(MemtoReg_wb),
        .out(data_to_write)
    );

    extra_forward_unit extra_forward_unit_int(
        .rd(rd_wb),
        .rs(rs2_mem),
        .MemRead(MemRead_wb),
        .MemWrite(MemWrite_mem),
        .ef_mux_select(ef_mux_select)
    );

    forwarding_unit forwarding_unit_int(
        .rs1(rs1_ex),
        .rs2(rs2_ex),
        .rd_EXMEM(rd_mem),
        .rd_MEMWB(rd_wb),
        .RegWrite_MEMWB(RegWrite_wb),
        .RegWrite_EXMEM(RegWrite_mem),
        .fwdA(sel_a),
        .fwdB(sel_b)
    );

    IF_ID IF_ID_register(
        .reset(reset),
        .clk(clk),
        .flush(pc_ctrl & !stall), // basically, one flushes if branch is true and u make sure u r not stalling because when stall is 1, the crct inputs are there to compare 
        .stall(stall),
        .PC_in(pc_out),
        .inst_in(instruction),
        .PC_out(IF_ID_pc),
        .inst_out(IF_ID_instr)
    );

    ID_EX ID_EX_register(
        .reset(reset),
        .clk(clk),
        .read_data1_in(read1),
        .read_data2_in(read2),
        .imm_in(immgen_out),
        .funct_in({IF_ID_instr[30],IF_ID_instr[14:12]}),
        .rd_in(IF_ID_instr[11:7]),
        .rs1_in(IF_ID_instr[19:15]),
        .rs2_in(IF_ID_instr[24:20]),
        .ALUOp_in(idex_ALUOp),
        .ALUSrc_in(idex_ALUSrc),
        .MemRead_in(idex_MemRead),
        .MemtoReg_in(idex_MemtoReg),
        .MemWrite_in(idex_MemWrite),
        .RegWrite_in(idex_RegWrite),
        .read_data1_out(read1_ex),
        .read_data2_out(read2_ex),
        .imm_out(imm_out_ex),
        .funct_out(funct_ex),
        .rd_out(rd_ex),
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .ALUOp_out(ALUOp_ex),
        .ALUSrc_out(ALUSrc_ex),
        .MemRead_out(MemRead_ex),
        .MemtoReg_out(MemtoReg_ex),
        .MemWrite_out(MemWrite_ex),
        .RegWrite_out(RegWrite_ex)
    );

    EX_MEM EX_MEM_register(
        .reset(reset),
        .clk(clk),
        .ALU_ans_in(ALU_result),
        .ALU_rs2_in(fwd_B),
        .rd_in(rd_ex),
        .rs2_in(rs2_ex),
        .MemRead_in(MemRead_ex),
        .MemtoReg_in(MemtoReg_ex),
        .MemWrite_in(MemWrite_ex),
        .RegWrite_in(RegWrite_ex),
        .ALU_ans_out(ALU_result_mem),
        .ALU_rs2_out(ALU_rs2_mem),
        .rd_out(rd_mem),
        .rs2_out(rs2_mem),
        .MemRead_out(MemRead_mem),
        .MemtoReg_out(MemtoReg_mem),
        .MemWrite_out(MemWrite_mem),
        .RegWrite_out(RegWrite_mem)
    );

    MEM_WB MEM_WB_register(
        .reset(reset),
        .clk(clk),
        .RegWrite_in(RegWrite_mem),
        .MemtoReg_in(MemtoReg_mem),
        .MemRead_in(MemRead_mem),
        .rd_in(rd_mem),
        .ALU_result_in(ALU_result_mem),
        .readdata_in(read_data_memory),
        .RegWrite_out(RegWrite_wb),
        .MemtoReg_out(MemtoReg_wb),
        .MemRead_out(MemRead_wb),
        .rd_out(rd_wb),
        .ALU_result_out(ALU_result_wb),
        .readdata_out(read_data_memory_wb)
    );

    mux extra_ld_mux(
        .a(ALU_rs2_mem),
        .b(data_to_write),
        .sel(ef_mux_select),
        .out(datamemory_in)
    );
endmodule