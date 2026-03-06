// 10 means forward from ALU_ans
// 01 means forward from EX/MEM
// 00 means use the register file data

module branch_forwarding_unit(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_EXMEM,
    input [4:0] rd_IDEX
    input RegWrite_IDEX,
    input RegWrite_EXMEM,
    output reg [1:0] fwdA,
    output reg [1:0] fwdB
);
    always @(*) begin
        if(RegWrite_IDEX && (rd_IDEX != 5'b0) && (rd_IDEX == rs1)) fwdA = 2'b10;
        else if(RegWrite_EXMEM && (rd_EXMEM != 5'b0) && (rd_EXMEM == rs1)) fwdA = 2'b01; 
        else fwdA = b'00;

        if(RegWrite_IDEX && (rd_IDEX != 5'b0) && (rd_IDEX == rs2)) fwdB = 2'b10;
        else if(RegWrite_EXMEM && (rd_EXMEM != 5'b0) && (rd_EXMEM == rs2)) fwdB = 2'b01;
        else fwdB = b'00;
    end
endmodule