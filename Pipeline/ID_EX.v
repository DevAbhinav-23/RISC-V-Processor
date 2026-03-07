`timescale 1ns/1ps

module ID_EX(
    input reset,
    input clk,

    input [63:0] read_data1_in,
    input [63:0] read_data2_in,
    input [63:0] imm_in,
    input [3:0] funct_in,
    input [4:0] rd_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,

    input [1:0] ALUOp_in,
    input ALUSrc_in,
    input MemRead_in,
    input MemtoReg_in,
    input MemWrite_in,
    input RegWrite_in,

    output reg [63:0] read_data1_out,
    output reg [63:0] read_data2_out,
    output reg [63:0] imm_out,
    output reg [3:0] funct_out,
    output reg [4:0] rd_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,

    output reg [1:0] ALUOp_out,
    output reg ALUSrc_out,
    output reg MemRead_out,
    output reg MemtoReg_out,
    output reg MemWrite_out,
    output reg RegWrite_out
);
    always @(posedge clk) begin
        if (reset) begin
            read_data1_out    <= 64'b0;
            read_data2_out    <= 64'b0;
            imm_out           <= 64'b0;
            funct_out          <= 4'b0;
            rd_out            <= 5'b0;
            ALUOp_out         <= 2'b0;
            ALUSrc_out        <= 1'b0;
            MemRead_out       <= 1'b0;
            MemtoReg_out      <= 1'b0;
            MemWrite_out      <= 1'b0;
            RegWrite_out      <= 1'b0;
            rs2_out           <= 5'b0;
            rs1_out           <= 5'b0;
        end
        else begin
            read_data1_out    <= read_data1_in;
            read_data2_out    <= read_data2_in;
            imm_out           <= imm_in;
            funct_out         <= funct_in;
            rd_out            <= rd_in;
            ALUOp_out         <= ALUOp_in;
            ALUSrc_out        <= ALUSrc_in;
            MemRead_out       <= MemRead_in;
            MemtoReg_out      <= MemtoReg_in;
            MemWrite_out      <= MemWrite_in;
            RegWrite_out      <= RegWrite_in;
            rs2_out           <= rs2_in;
            rs1_out           <= rs1_in
        end
    end
endmodule
