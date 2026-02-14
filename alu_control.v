module alu_control(
    input  [1:0] alu_op,
    input  [3:0] instr,
    output reg [3:0] alu_c
);

    wire funct7_6 = instr[3];
    wire [2:0] funct3 = instr[2:0];

    always @(*) begin
        case (alu_op)
            2'b00: begin
                alu_c = 4'b0000;
            end
            2'b01: begin
                alu_c = 4'b1000;
            end
            2'b10: begin
                if(funct3 == 3'b000)
                    if(funct7_6 == 1'b0)
                        alu_c = 4'b0000;
                    else
                        alu_c = 4'b1000;
                else if(funct3 == 3'b100)
                    alu_c = 4'b0100;
                else if(funct3 == 3'b110)
                    alu_c = 4'b0110;
                else if(funct3 == 3'b111)
                    alu_c = 4'b0111;
                else if(funct3 == 3'b001)
                    alu_c = 4'b0001;
                else if(funct3 == 3'b101)
                    if(funct7_6 == 1'b0)
                        alu_c = 4'b0101;
                    else
                        alu_c = 4'b1101;
                else if(funct3 == 3'b010)
                    alu_c = 4'b0010;
                else
                    alu_c = 4'b0011;
            end
            2'b11: begin
                if (funct3 == 3'b000)
                    alu_c = 4'b0000;
                else if (funct3 == 3'b100)
                    alu_c = 4'b0100;
                else if (funct3 == 3'b110)
                    alu_c = 4'b0110;
                else if (funct3 == 3'b111)
                    alu_c = 4'b0111;
                else if (funct3 == 3'b001)
                    alu_c = 4'b0001;
                else if (funct3 == 3'b101)
                    if (funct7_6 == 1'b0)
                        alu_c = 4'b0101;
                    else
                        alu_c = 4'b1101;
                else if (funct3 == 3'b010)
                    alu_c = 4'b0010;
                else
                    alu_c = 4'b0011;
            end

            default : alu_c = 4'b0000;
        endcase
    end

endmodule
