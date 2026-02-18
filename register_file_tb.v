`timescale 1ns/1ps

`include "register_file.v"

module register_file_tb;
    reg clk;
    reg reset;
    reg register_write;
    reg [4:0] reg1_r;
    reg [4:0] reg2_r;
    reg [4:0] reg1_w;
    reg [63:0] data_to_w;
    wire [63:0] output1_r;
    wire [63:0] output2_r;

    // Instantiate the register file
    register_file uut (
        .clk(clk),
        .reset(reset),
        .register_write(register_write),
        .reg1_r(reg1_r),
        .reg2_r(reg2_r),
        .reg1_w(reg1_w),
        .data_to_w(data_to_w),
        .output1_r(output1_r),
        .output2_r(output2_r)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========================================");
        $display("Register File Test Bench");
        $display("========================================");

        reset = 0;
        register_write = 0;
        reg1_r = 5'b0;
        reg2_r = 5'b0;
        reg1_w = 5'b0;
        data_to_w = 64'b0;

        $display("\nTest 1: Reset");
        reset = 1;
        #10;
        reset = 0;
        reg1_r = 5'd1;
        reg2_r = 5'd2;
        #5;
        $display("After reset: reg1=%0d, output1_r=%0d (expected 0)", reg1_r, output1_r);
        $display("After reset: reg2=%0d, output2_r=%0d (expected 0)", reg2_r, output2_r);

        $display("\nTest 2: Write and Read");
        @(posedge clk);
        reg1_w = 5'd5;
        data_to_w = 64'hDEADBEEFCAFEBABE;
        register_write = 1;
        @(posedge clk);
        register_write = 0;
        reg1_r = 5'd5;
        #5;
        $display("Write 0x%h to reg5, Read reg5: 0x%h", data_to_w, output1_r);

        $display("\nTest 3: Multiple registers");
        @(posedge clk);
        reg1_w = 5'd10;
        data_to_w = 64'h123456789ABCDEF0;
        register_write = 1;
        @(posedge clk);
        register_write = 0;
        reg1_r = 5'd5;
        reg2_r = 5'd10;
        #5;
        $display("Read reg5: 0x%h (expected 0xDEADBEEFCAFEBABE)", output1_r);
        $display("Read reg10: 0x%h (expected 0x123456789ABCDEF0)", output2_r);

        $display("\nTest 4: x0 hardwired to 0");
        @(posedge clk);
        reg1_w = 5'd0;
        data_to_w = 64'hFFFFFFFFFFFFFFFF;
        register_write = 1;
        @(posedge clk);
        register_write = 0;
        reg1_r = 5'd0;
        #5;
        $display("Write to x0, Read x0: 0x%h (expected 0x0000000000000000)", output1_r);

        $display("\nTest 5: Read old data during write");
        @(posedge clk);
        reg1_w = 5'd15;
        data_to_w = 64'hAAAAAAAA55555555;
        register_write = 1;
        reg1_r = 5'd15;  // Read same register being written
        @(posedge clk);
        register_write = 0;
        #5;
        $display("After write to reg15: 0x%h (expected 0xAAAAAAAA55555555)", output1_r);

        $display("\nTest 6: Testing multiple registers");
        @(posedge clk);
        register_write = 0;
        #5;
        $display("Test completed!");
        $display("========================================");
        $finish;
    end

endmodule