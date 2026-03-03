`timescale 1ns/1ps

`include "instruction_mem.v"

module instruction_mem_tb;
    reg clk;
    reg reset;
    reg [11:0] addr;
    wire [31:0] instr;

    instruction_mem uut (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .instr(instr)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer file;
    
    initial begin
        file = $fopen("test_instructions.txt", "w");
        
        // Instruction 0: 0x00500113 = addi x2, x0, 5
        $fwrite(file, "%h\n", 8'h00);
        $fwrite(file, "%h\n", 8'h50);
        $fwrite(file, "%h\n", 8'h01);
        $fwrite(file, "%h\n", 8'h13);
        
        // Instruction 1: 0x00A00193 = addi x3, x0, 10
        $fwrite(file, "%h\n", 8'h00);
        $fwrite(file, "%h\n", 8'hA0);
        $fwrite(file, "%h\n", 8'h01);
        $fwrite(file, "%h\n", 8'h93);
        
        // Instruction 2: 0x003102B3 = add x5, x2, x3
        $fwrite(file, "%h\n", 8'h00);
        $fwrite(file, "%h\n", 8'h31);
        $fwrite(file, "%h\n", 8'h02);
        $fwrite(file, "%h\n", 8'hB3);
        
        // Instruction 3: 0x0020F233 = and x4, x1, x2
        $fwrite(file, "%h\n", 8'h00);
        $fwrite(file, "%h\n", 8'h20);
        $fwrite(file, "%h\n", 8'hF2);
        $fwrite(file, "%h\n", 8'h33);
        
        $fclose(file);
        
        $display("Created test_instructions.txt");
    end

    initial begin
        #1;
        
        $display("========================================");
        $display("Instruction Memory Test Bench");
        $display("========================================");

        reset = 0;
        addr = 12'h000;

        #10;

        // Test 1: Read instruction at address 0
        $display("\nTest 1: Read instruction at address 0");
        addr = 12'h000;
        #5;
        $display("Address: 0x%h", addr);
        $display("Instruction: 0x%h (expected: 0x00500113 = addi x2, x0, 5)", instr);

        // Test 2: Read instruction at address 4
        $display("\nTest 2: Read instruction at address 4");
        addr = 12'h004;
        #5;
        $display("Address: 0x%h", addr);
        $display("Instruction: 0x%h (expected: 0x00A00193 = addi x3, x0, 10)", instr);

        // Test 3: Read instruction at address 8
        $display("\nTest 3: Read instruction at address 8");
        addr = 12'h008;
        #5;
        $display("Address: 0x%h", addr);
        $display("Instruction: 0x%h (expected: 0x003102B3 = add x5, x2, x3)", instr);

        // Test 4: Read instruction at address 12
        $display("\nTest 4: Read instruction at address 12");
        addr = 12'h00C;
        #5;
        $display("Address: 0x%h", addr);
        $display("Instruction: 0x%h (expected: 0x0020F233 = and x4, x1, x2)", instr);

        // Test 5: Sequential reads
        $display("\nTest 5: Sequential reads");
        addr = 12'h000;
        #5;
        $display("Addr 0x000: 0x%h", instr);
        addr = 12'h004;
        #5;
        $display("Addr 0x004: 0x%h", instr);
        addr = 12'h008;
        #5;
        $display("Addr 0x008: 0x%h", instr);
        addr = 12'h00C;
        #5;
        $display("Addr 0x00C: 0x%h", instr);

        // Test 6: Address boundary (beyond loaded data)
        $display("\nTest 6: Address beyond loaded data");
        addr = 12'h100;
        #5;
        $display("Address: 0x%h", addr);
        $display("Instruction: 0x%h (expected: 0x00000000)", instr);

        $display("\n========================================");
        $display("Test completed!");
        $display("========================================");
        
        $finish;
    end

endmodule
