`timescale 1ns/1ps
`include "data_memory.v"
module data_memory_tb;
    reg clk;
    reg reset;
    reg mem_r;
    reg mem_w;
    reg [63:0] addr;
    reg [63:0] input_w;
    wire [63:0] output_w;
    // Instantiate the data memory
    data_memory uut (
        .clk(clk),
        .reset(reset),
        .mem_r(mem_r),
        .mem_w(mem_w),
        .addr(addr),
        .input_w(input_w),
        .output_w(output_w)
    );
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    // Test sequence
    initial begin
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);
        
        $display("========================================");
        $display("Data Memory Test Bench");
        $display("Big-endian byte ordering");
        $display("========================================");
        // Initialize
        reset = 0;
        mem_r = 0;
        mem_w = 0;
        addr = 64'b0;
        input_w = 64'b0;
        // Test 1: Reset
        $display("\nTest 1: Reset");
        reset = 1;
        #10;
        reset = 0;
        mem_r = 1;
        addr = 64'd0;
        #5;
        $display("After reset, read addr 0: 0x%h (expected 0x0000000000000000)", output_w);
        mem_r = 0;
        // Test 2: Write 64-bit data and read back (Big-endian)
        $display("\nTest 2: Write and Read (Big-endian)");
        @(posedge clk);
        addr = 64'd0;
        input_w = 64'hDEADBEEFCAFEBABE;
        mem_w = 1;
        @(posedge clk);
        mem_w = 0;
        mem_r = 1;
        #5;
        $display("Write 0x%h to addr 0", input_w);
        $display("Read from addr 0: 0x%h", output_w);
        $display("Big-endian storage: mem[0]=0x%h, mem[1]=0x%h, mem[2]=0x%h, mem[3]=0x%h", 
                 uut.mem[0], uut.mem[1], uut.mem[2], uut.mem[3]);
        $display("Big-endian storage: mem[4]=0x%h, mem[5]=0x%h, mem[6]=0x%h, mem[7]=0x%h", 
                 uut.mem[4], uut.mem[5], uut.mem[6], uut.mem[7]);
        // Test 3: Write to another address
        $display("\nTest 3: Write to address 8");
        mem_r = 0;
        @(posedge clk);
        addr = 64'd8;
        input_w = 64'h123456789ABCDEF0;
        mem_w = 1;
        @(posedge clk);
        mem_w = 0;
        mem_r = 1;
        #5;
        $display("Write 0x%h to addr 8", input_w);
        $display("Read from addr 8: 0x%h", output_w);
        mem_r = 0;
        // Test 4: Read from first address again
        $display("\nTest 4: Verify previous data intact");
        addr = 64'd0;
        mem_r = 1;
        #5;
        $display("Read from addr 0: 0x%h (expected 0xDEADBEEFCAFEBABE)", output_w);
        mem_r = 0;
        // Test 5: Write without mem_w enabled
        $display("\nTest 5: Write disabled test");
        @(posedge clk);
        addr = 64'd0;
        input_w = 64'hFFFFFFFFFFFFFFFF;
        mem_w = 0;  // Write disabled
        @(posedge clk);
        mem_r = 1;
        #5;
        $display("Write disabled, read addr 0: 0x%h (expected 0xDEADBEEFCAFEBABE)", output_w);
        mem_r = 0;
        // Test 6: Read without mem_r enabled
        $display("\nTest 6: Read disabled test");
        addr = 64'd0;
        mem_r = 0;
        #5;
        $display("mem_r=0, output_w: 0x%h (expected 0x0000000000000000)", output_w);
        // Test 7: Unaligned address
        $display("\nTest 7: Unaligned access (addr=4)");
        @(posedge clk);
        addr = 64'd4;
        input_w = 64'hAABBCCDDEEFF0011;
        mem_w = 1;
        @(posedge clk);
        mem_w = 0;
        mem_r = 1;
        #5;
        $display("Write 0x%h to addr 4", input_w);
        $display("Read from addr 4: 0x%h", output_w);
        mem_r = 0;
        $display("\n========================================");
        $display("Test completed!");
        $display("========================================");
        $finish;
    end
endmodule