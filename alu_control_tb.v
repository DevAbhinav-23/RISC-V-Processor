`include "alu_control.v"

module alu_control_tb;
    reg [1:0] alu_op;
    reg [3:0] instr;  // {funct7[5], funct3}
    wire [3:0] alu_c;

    // Instantiate the Unit Under Test (UUT)
    alu_control uut (
        .alu_op(alu_op),
        .instr(instr),
        .alu_c(alu_c)
    );

    // Helper task to run test
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
            $display("  ALUOp=%02b, Instr[3:0]=0b%04b (funct7_6=%b, funct3=%03b)",
                     alu_op, instr, instr[3], instr[2:0]);
            $display("  ALU control: 0b%04b (expected 0b%04b)", alu_c, expected_alu_c);
            if (alu_c === expected_alu_c)
                $display("  Status: PASS");
            else
                $display("  Status: FAIL");
            $display("");
        end
    endtask

    // Test sequence
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

        // Test 1: ALUOp = 00 (Load/Store) - should be ADD
        $display("--- ALUOp = 00 (Load/Store) ---");
        run_test(2'b00, 4'b0000, 4'b0000, "Load/Store - ADD (instr ignored)");
        run_test(2'b00, 4'b1111, 4'b0000, "Load/Store - ADD (any instr)");

        // Test 2: ALUOp = 01 (Branch) - should be SUB
        $display("--- ALUOp = 01 (Branch) ---");
        run_test(2'b01, 4'b0000, 4'b1000, "Branch - SUB (instr ignored)");
        run_test(2'b01, 4'b1111, 4'b1000, "Branch - SUB (any instr)");

        // Test 3: ALUOp = 10 (R-type) - use funct7[5] and funct3
        $display("--- ALUOp = 10 (R-type) ---");
        // ADD: funct7[5]=0, funct3=000 -> 0000
        run_test(2'b10, 4'b0000, 4'b0000, "R-type ADD (funct7_6=0, funct3=000)");
        // SUB: funct7[5]=1, funct3=000 -> 1000
        run_test(2'b10, 4'b1000, 4'b1000, "R-type SUB (funct7_6=1, funct3=000)");
        // AND: funct7[5]=0, funct3=111 -> 0111
        run_test(2'b10, 4'b0111, 4'b0111, "R-type AND (funct7_6=0, funct3=111)");
        // OR: funct7[5]=0, funct3=110 -> 0110
        run_test(2'b10, 4'b0110, 4'b0110, "R-type OR (funct7_6=0, funct3=110)");
        // XOR: funct7[5]=0, funct3=100 -> 0100
        run_test(2'b10, 4'b0100, 4'b0100, "R-type XOR (funct7_6=0, funct3=100)");
        // SLL: funct7[5]=0, funct3=001 -> 0001
        run_test(2'b10, 4'b0001, 4'b0001, "R-type SLL (funct7_6=0, funct3=001)");
        // SRL: funct7[5]=0, funct3=101 -> 0101
        run_test(2'b10, 4'b0101, 4'b0101, "R-type SRL (funct7_6=0, funct3=101)");
        // SRA: funct7[5]=1, funct3=101 -> 1101
        run_test(2'b10, 4'b1101, 4'b1101, "R-type SRA (funct7_6=1, funct3=101)");
        // SLT: funct7[5]=0, funct3=010 -> 0010
        run_test(2'b10, 4'b0010, 4'b0010, "R-type SLT (funct7_6=0, funct3=010)");
        // SLTU: funct7[5]=0, funct3=011 -> 0011
        run_test(2'b10, 4'b0011, 4'b0011, "R-type SLTU (funct7_6=0, funct3=011)");

        // Test 4: ALUOp = 11 (I-type) - use funct3, funct7 for shifts only
        $display("--- ALUOp = 11 (I-type immediate) ---");
        // ADDI: funct3=000 -> 0000
        run_test(2'b11, 4'b0000, 4'b0000, "I-type ADDI (funct3=000)");
        // ANDI: funct3=111 -> 0111
        run_test(2'b11, 4'b0111, 4'b0111, "I-type ANDI (funct3=111)");
        // ORI: funct3=110 -> 0110
        run_test(2'b11, 4'b0110, 4'b0110, "I-type ORI (funct3=110)");
        // XORI: funct3=100 -> 0100
        run_test(2'b11, 4'b0100, 4'b0100, "I-type XORI (funct3=100)");
        // SLTI: funct3=010 -> 0010
        run_test(2'b11, 4'b0010, 4'b0010, "I-type SLTI (funct3=010)");
        // SLTIU: funct3=011 -> 0011
        run_test(2'b11, 4'b0011, 4'b0011, "I-type SLTIU (funct3=011)");
        // SLLI: funct3=001 -> 0001 (uses shamt, funct7[5]=0)
        run_test(2'b11, 4'b0001, 4'b0001, "I-type SLLI (funct3=001)");
        // SRLI: funct3=101, funct7[5]=0 -> 0101
        run_test(2'b11, 4'b0101, 4'b0101, "I-type SRLI (funct7_6=0, funct3=101)");
        // SRAI: funct3=101, funct7[5]=1 -> 1101
        run_test(2'b11, 4'b1101, 4'b1101, "I-type SRAI (funct7_6=1, funct3=101)");

        // Test 5: Default case
        $display("--- Default case ---");
        run_test(2'bXX, 4'b0000, 4'b0000, "Default (should be ADD)");

        $display("========================================");
        $display("Test completed!");
        $display("========================================");
        $finish;
    end

endmodule
