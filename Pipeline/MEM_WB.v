`timescale 1ns/1ps

module MEM_WB(
    input reset, // synchronous active high reset
    input clk,
    input RegWrite_in,
    input MemtoReg_in,
    input [4:0] rd_in,
    input [63:0] ALU_result_in,
    input [63:0] readdata_in,
    output reg RegWrite_out,
    output reg MemtoReg_out,
    output reg [4:0] rd_out,
    output reg [63:0] ALU_result_out,
    output reg [63:0] readdata_out

);

    always @(posedge clk) begin
        if(reset) begin
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
            rd_out <= 5'b0;
            ALU_result_out <= 64'b0;
            readdata_out <= 64'b0;
        end
        else begin
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            rd_out <= rd_in;
            ALU_result_out <= ALU_result_in;
            readdata_out <= readdata_in;
        end
    end

endmodule