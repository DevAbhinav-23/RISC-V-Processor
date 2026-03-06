`timescale 1ns/1ps

module mux_4x1(
    input [63:0] a,b,c,
    input [1:0] sel,
    output reg [63:0] out
);
    always @(*) begin
        if(sel == 2'b00) begin
            out = a;
        end
        else if(sel == 2'b01) begin
            out = b;
        end
        else if(sel == 2'b10) begin
            out = c;
        end
        else begin
            out = 64'b0;
        end
    end
endmodule