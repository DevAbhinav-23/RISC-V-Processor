module control(
    input [6:0] opcode,
    output Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output [1:0] ALUOp
);
    // I am following the RISC-V edition book convention guys, just go through the sections 4.3 and 4.4 of the TB to understand this
    // 00 is load/store, 01 is branch, 10 is for R format and 11 is for I format
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
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemtoReg_reg = 1'b0;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                RegWrite_reg = 1'b1;
                ALUOp_reg = 2'b10;
            end
            I: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemtoReg_reg = 1'b0;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b1;
                RegWrite_reg = 1'b1;
                ALUOp_reg = 2'b11;
            end
            I_ld: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b1;
                MemtoReg_reg = 1'b1;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b1;
                RegWrite_reg = 1'b1;
                ALUOp_reg = 2'b00;
            end
            B: begin
                Branch_reg = 1'b1;
                MemRead_reg = 1'b0;
                MemtoReg_reg = 1'b0;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0; // doesn't matter if it's 0 or 1 bcz it is added by the PC adder and ALU operands are lite for it
                RegWrite_reg = 1'b0;
                ALUOp_reg = 2'b01;
            end
            S: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemtoReg_reg = 1'b0;
                MemWrite_reg = 1'b1;
                ALUSrc_reg = 1'b1;
                RegWrite_reg = 1'b0;
                ALUOp_reg = 2'b00;
            end
            default: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemtoReg_reg = 1'b0;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                RegWrite_reg = 1'b0;
                ALUOp_reg = 2'b00;
            end
        endcase
    end
endmodule