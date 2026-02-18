`timescale 1ns/1ps

module control_tb;
    reg [6:0] opcode;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    control dut(
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );
    
    task check;
        input exp_Branch, exp_MemRead, exp_MemtoReg;
        input exp_MemWrite, exp_ALUSrc, exp_RegWrite;
        input [1:0] exp_ALUOp;
        begin
            #1;
            if((exp_Branch   !== 1'bx && Branch   !== exp_Branch)   ||
               (exp_MemRead  !== 1'bx && MemRead  !== exp_MemRead)  ||
               (exp_MemtoReg !== 1'bx && MemtoReg !== exp_MemtoReg) ||
               (exp_MemWrite !== 1'bx && MemWrite !== exp_MemWrite) ||
               (exp_ALUSrc   !== 1'bx && ALUSrc   !== exp_ALUSrc)   ||
               (exp_RegWrite !== 1'bx && RegWrite !== exp_RegWrite) ||
               (exp_ALUOp    !== 2'bx && ALUOp    !== exp_ALUOp))
            begin
                fail_count = fail_count + 1;
                $display("FAIL opcode=%b | B=%b MR=%b M2R=%b MW=%b AS=%b RW=%b ALUOp=%b", opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);
            end
            else begin
                pass_count = pass_count + 1;
                $display("PASS: opcode=%b", opcode);
            end
        end
    endtask

    initial begin
        $display("---- CONTROL UNIT TEST ----");

        $display("R format instruction");
        opcode = 7'b0110011;
        check(0, 0, 0, 0, 0, 1, 2'b10);

        $display("I format instruction");
        opcode = 7'b0010011;
        check(0, 0, 0, 0, 1, 1, 2'b11);

        $display("Load instruction");
        opcode = 7'b0000011;
        check(0, 1, 1, 0, 1, 1, 2'b00);

        $display("Store instruction");
        opcode = 7'b0100011;
        // MemtoReg is don't care (1'bx)
        check(0, 0, 1'bx, 1, 1, 0, 2'b00); 

        $display("Branch instruction");
        opcode = 7'b1100011;
        // MemtoReg is don't care (1'bx)
        check(1, 0, 1'bx, 0, 0, 0, 2'b01); 

        /* NOTE:
        When we optimize logic using K-maps or Boolean algebra, we treat 
        impossible/invalid states as don't cares. Because of this, if you 
        feed the logic a garbage opcode like 7'b1111111, the gates 
        might randomly output MemWrite=1
        So, assuming the instruction decoder will only receive valid opcodes.
        */

        $display("--------------------------------");
        $display("TOTAL TESTS : %0d", pass_count + fail_count);
        $display("PASSED      : %0d", pass_count);
        $display("FAILED      : %0d", fail_count);
        $display("--------------------------------");

        if(fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule