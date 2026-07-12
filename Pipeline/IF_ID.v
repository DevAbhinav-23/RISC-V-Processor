`timescale 1ns/1ps

module IF_ID(
    input reset, // synchronous active high reset
    input clk,
    input flush,
    input stall,
    input [63:0] PC_in,
    input [31:0] inst_in,
    input predict_taken_in,
    output reg [63:0] PC_out,
    output reg [31:0] inst_out,
    output reg predict_taken_out
);
    always@(posedge clk) begin
        if(reset) begin
            PC_out <= 64'b0;
            inst_out <= 32'b0;
            predict_taken_out <= 1'b0;
        end
        else if(flush) begin
            PC_out <= 64'b0;
            inst_out <= 32'b0;
            predict_taken_out <= 1'b0;
        end
        else if(!stall) begin
            PC_out <= PC_in;
            inst_out <= inst_in;
            predict_taken_out <= predict_taken_in;
        end
    end
endmodule