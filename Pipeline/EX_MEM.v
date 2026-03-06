`timescale 1ns/1ps

module EX_MEM(
    input reset, // synchronous active high reset
    input clk, 
    input [63:0] ALU_ans_in,
    input [63:0] ALU_rs2_in,
    input [4:0] rd_in,
    input [4:0] rs2_in, // extra forwarding unit kosam for sd ld dependent on previous load
    input MemWrite_in,
    input MemRead_in,
    input MemtoReg_in,
    input RegWrite_in,
    output reg [4:0] rd_out,
    output reg MemtoReg_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg [63:0] ALU_ans_out,
    output reg [63:0] ALU_rs2_out,
    output reg [4:0] rs2_out
);
    always @(posedge clk) begin
        if(reset) begin
            rd_out <= 5'b0;
            MemtoReg_out <= 1'b0;
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            ALU_ans_out <= 64'b0;
            ALU_rs2_out <= 64'b0;
            rs2_out <= 5'b0;
        end
        else begin
            rd_out <= rd_in;
            MemtoReg_out <= MemtoReg_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            ALU_ans_out <= ALU_ans_in;
            ALU_rs2_out <= ALU_rs2_in;
            rs2_out <= rs2_in;
        end
    end
endmodule