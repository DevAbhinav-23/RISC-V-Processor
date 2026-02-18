`timescale 1ns/1ps

`include "alu_control.v"

module alu_control_tb;
    reg [1:0] alu_op;
    reg [3:0] instr;  // {funct7[5], funct3}
    wire [3:0] alu_c;

    integer pass_count = 0;
    integer fail_count = 0;

    alu_control uut (
        .alu_op(alu_op),
        .instr(instr),
        .alu_c(alu_c)
    );

    task run_test;
        input [1:0] test_alu_op;
        input [3:0] test_instr;
        input [3:0] expected_alu_c;
        input [256*8-1:0] description;
        begin
            alu_op = test_alu_op;
            instr = test_instr;
            #5;
            $display("Test: %s", description);
            $display("  ALUOp=%02b, Instr[3:0]=0b%04b (funct7_6=%b, funct3=%03b)", alu_op, instr, instr[3], instr[2:0]);
            $display("  ALU control: 0b%04b (expected 0b%04b)", alu_c, expected_alu_c);
            if (alu_c === expected_alu_c) begin
                $display("  Status: PASS");
                pass_count = pass_count + 1;
            end
            else begin
                $display("  Status: FAIL");
                fail_count = fail_count + 1;
            end
            $display("");
        end
    endtask

    initial begin
        $display("========================================");
        $display("ALU Control Unit Test Bench");
        $display("========================================");
        $display("ALUOp encoding:");
        $display("  00 = Load/Store (ADD)");
        $display("  01 = Branch (SUB)");
        $display("  10 = R-type (use funct7/funct3)");
        $display("  11 = I-type (use funct3)");
        $display("");

        $display("--- ALUOp = 00 (Load/Store) ---");
        run_test(2'b00, 4'b0000, 4'b0000, "Load/Store - ADD (instr ignored)");
        run_test(2'b00, 4'b1111, 4'b0000, "Load/Store - ADD (any instr)");

        $display("--- ALUOp = 01 (Branch) ---");
        run_test(2'b01, 4'b0000, 4'b1000, "Branch - SUB (instr ignored)");
        run_test(2'b01, 4'b1111, 4'b1000, "Branch - SUB (any instr)");

        $display("--- ALUOp = 10 (R-type) ---");
        run_test(2'b10, 4'b0000, 4'b0000, "R-type ADD (funct7_6=0, funct3=000)");
        run_test(2'b10, 4'b1000, 4'b1000, "R-type SUB (funct7_6=1, funct3=000)");
        run_test(2'b10, 4'b0111, 4'b0111, "R-type AND (funct7_6=0, funct3=111)");
        run_test(2'b10, 4'b0110, 4'b0110, "R-type OR (funct7_6=0, funct3=110)");
        run_test(2'b10, 4'b0100, 4'b0100, "R-type XOR (funct7_6=0, funct3=100)");
        run_test(2'b10, 4'b0001, 4'b0001, "R-type SLL (funct7_6=0, funct3=001)");
        run_test(2'b10, 4'b0101, 4'b0101, "R-type SRL (funct7_6=0, funct3=101)");
        run_test(2'b10, 4'b1101, 4'b1101, "R-type SRA (funct7_6=1, funct3=101)");
        run_test(2'b10, 4'b0010, 4'b0010, "R-type SLT (funct7_6=0, funct3=010)");
        run_test(2'b10, 4'b0011, 4'b0011, "R-type SLTU (funct7_6=0, funct3=011)");

        $display("--- ALUOp = 11 (I-type immediate) ---");
        run_test(2'b11, 4'b0000, 4'b0000, "I-type ADDI (funct3=000)");
        run_test(2'b11, 4'b0111, 4'b0111, "I-type ANDI (funct3=111)");
        run_test(2'b11, 4'b0110, 4'b0110, "I-type ORI (funct3=110)");
        run_test(2'b11, 4'b0100, 4'b0100, "I-type XORI (funct3=100)");
        run_test(2'b11, 4'b0010, 4'b0010, "I-type SLTI (funct3=010)");
        run_test(2'b11, 4'b0011, 4'b0011, "I-type SLTIU (funct3=011)");
        run_test(2'b11, 4'b0001, 4'b0001, "I-type SLLI (funct3=001)");
        run_test(2'b11, 4'b0101, 4'b0101, "I-type SRLI (funct7_6=0, funct3=101)");
        run_test(2'b11, 4'b1101, 4'b1101, "I-type SRAI (funct7_6=1, funct3=101)");

        $display("--- Default case ---");
        run_test(2'bXX, 4'b0000, 4'b0000, "Default (should be ADD)");

        $display("========================================");
        $display("Test completed");
        $display("========================================");
        if(fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $finish;
    end

endmodule