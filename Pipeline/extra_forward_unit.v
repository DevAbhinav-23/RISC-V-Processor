`timescale 1ns/1ps
module extra_forward_unit(
    input [4:0] rd,
    input [4:0] rs,
    input MemRead,
    input MemWrite,
    output reg ef_mux_select
);
    wire check;
    assign check = MemRead&MemWrite;

    always @(*) begin
        if((rd == rs) && (rd != 5'b0) && (check)) begin
            ef_mux_select = 1'b1; // if mux select line is 1 then forwarding data will go into the write data
        end
        else begin
            ef_mux_select = 1'b0; // if mux select line is 0 normal data coming from 
        end
    end
endmodule