module immgen(
    input [31:0] instr,output reg [63:0] imm
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    always @(*) begin
        case(opcode)
            7'b0100011: begin
                imm = {{52{instr[31]}},instr[31:25],instr[11:7]};
            end
            7'b0010011: begin
                if (funct3 == 3'b001 || funct3 == 3'b101) begin
                    imm = {58'b0, instr[25:20]};   
                end 
                else begin
                    imm = {{52{instr[31]}}, instr[31:20]};
                end
            end
            7'b0000011: begin
                imm = {{52{instr[31]}},instr[31:20]};
            end
            7'b1100011: begin
                imm = {{52{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]};
            end
            default: imm = 64'b0;
        endcase
    end
endmodule