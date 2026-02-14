module control(
    input [6:0] opcode,
    output Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output [1:0] ALUOp
);
    // I am following the RISC-V edition book convention guys, just go through the sections 4.3 and 4.4 of the TB to understand this
    localparam R = 7'b0110011;
    localparam I = 7'b0010011;
    localparam I_ld = 7'b0000011;
    localparam B = 7'b1100011;
    localparam S = 7'b0100011;

    reg Branch_reg, MemRead_reg, MemtoReg_reg, MemWrite_reg, ALUSrc_reg, RegWrite_reg;
    reg [1:0] ALUOp_reg;
    // using reg cause cannot assign wires in always block
    assign Branch = Branch_reg;
    assign MemRead = MemRead_reg;
    assign MemtoReg = MemtoReg_reg;
    assign MemWrite = MemWrite_reg;
    assign ALUSrc = ALUSrc_reg;
    assign RegWrite = RegWrite_reg;
    assign ALUOp = ALUOp_reg;
    always @(*) begin
        case(opcode)
            R: begin

            end
        endcase
    end
endmodule