module control(
    input [6:0] opcode,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg [1:0] ALUOp
);

    localparam R    = 7'b0110011;
    localparam I    = 7'b0010011;
    localparam I_ld = 7'b0000011;
    localparam B    = 7'b1100011;
    localparam S    = 7'b0100011;

    reg [1:0] ALUOp_reg;

    always @(*) begin
        case(opcode)
            R:    ALUOp_reg = 2'b10;
            I:    ALUOp_reg = 2'b11;
            I_ld: ALUOp_reg = 2'b00;
            B:    ALUOp_reg = 2'b01;
            S:    ALUOp_reg = 2'b00;
            default: ALUOp_reg = 2'b00;
        endcase
    end

    always @(*) begin
        if(opcode != 7'b0) begin
            ALUOp   = ALUOp_reg;
            ALUSrc  = ~(ALUOp_reg[0] ^ ALUOp_reg[1]);
            Branch  = (~ALUOp_reg[1]) & ALUOp_reg[0];
            MemRead = ~((ALUOp_reg[1] | ALUOp_reg[0])) & (~opcode[5]);
            MemtoReg= ~((ALUOp_reg[1] | ALUOp_reg[0]));
            MemWrite= ~((ALUOp_reg[1] | ALUOp_reg[0])) & (opcode[5]);
            RegWrite= (~((ALUOp_reg[1] | ALUOp_reg[0])) & (~opcode[5])) | ALUOp_reg[1];
        end
        else begin
            ALUOp   = 2'b00;
            ALUSrc  = 1'b0;
            Branch  = 1'b0;
            MemRead = 1'b0;
            MemtoReg= 1'b0;
            MemWrite= 1'b0;
            RegWrite= 1'b0;
        end
    end

endmodule