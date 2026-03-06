`timescale 1ns/1ps

module IF_ID(
    input reset, // synchronous active high reset
    input clk,
    input flush,
    input stall,
    input [63:0] PC_in,
    input [31:0] inst_in,
    output reg [63_0] PC_out,
    output reg [31:0] inst_out
);
    always@(posedge clk) begin
        if(reset) begin
            PC_out <= 64'b0;
            inst_out <= 32'b0;
        end
        if(!stall) begin
            PC_out <= PC_in;
            inst_out <= inst_in;
        end
        if(flush) begin
            PC_out <= 64'b0;
            inst_out <= 32'b0;
        end
    end
endmodule