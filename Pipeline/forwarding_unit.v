// 10 means forward from EX/MEM
// 01 means forward from MEM/WB
// 00 means use the register file data

module forwarding_unit(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_EXMEM,
    input [4:0] rd_MEMWB,
    input RegWrite_MEMWB,
    input RegWrite_EXMEM,
    output reg [1:0] fwdA,
    output reg [1:0] fwdB
);
    always @(*) begin
        if(RegWrite_EXMEM && (rd_EXMEM != 5'b0) && (rd_EXMEM == rs1)) fwdA = 2'b10; 
        else if(RegWrite_MEMWB && (rd_MEMWB != 5'b0) && (rd_MEMWB == rs1)) fwdA = 2'b01;
        else fwdA = 2'b00;

        if(RegWrite_EXMEM && (rd_EXMEM != 5'b0) && (rd_EXMEM == rs2)) fwdB = 2'b10;
        else if(RegWrite_MEMWB && (rd_MEMWB != 5'b0) && (rd_MEMWB == rs2)) fwdB = 2'b01;
        else fwdB = 2'b00;
    end
endmodule