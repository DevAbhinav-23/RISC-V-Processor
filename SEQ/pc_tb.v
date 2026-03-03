`timescale 1ns / 1ps

`include "pc.v"

module pc_tb;
    reg clk;
    reg reset;
    reg [63:0] pc_in;
    wire [63:0] pc_out;
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    pc uut(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    
    task run_test;
        input [63:0] test_pc_in;
        input test_reset;
        input [63:0] expected_pc_out;
        begin
            pc_in = test_pc_in;
            reset = test_reset;
            
            @(posedge clk);
            #2; 
            
            $display("\nTest Case %0d:", pass_count + fail_count);
            $display("Test: pc_in = %h", pc_in);
            $display("      reset = %b", reset);
            $display("      Expected pc_out = %h", expected_pc_out);
            $display("      Actual pc_out = %h", pc_out);

            if (pc_out === expected_pc_out) begin
                $display("      Status: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("      Status: FAIL");
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    initial begin      
        reset = 0;
        pc_in = 64'h0;
        #10;
        
        run_test(64'hDEADBEEFDEADBEEF, 1, 64'h0);
        run_test(64'h0000000000000004, 0, 64'h0000000000000004); 
        run_test(64'h0000000080000000, 0, 64'h0000000080000000); 
        run_test(64'hFFFFFFFFFFFFFFFC, 0, 64'hFFFFFFFFFFFFFFFC);
        run_test(64'h0000000000001000, 1, 64'h0);
        run_test(64'h0000000000000008, 0, 64'h0000000000000008);
        run_test(64'h000000000000000C, 0, 64'h000000000000000C);        
        run_test(64'h0000000000002000, 0, 64'h0000000000002000);
        run_test(64'h0000000000002004, 1, 64'h0);
        
        #10;
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