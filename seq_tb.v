`include "Seq_wrapper.v"

module processor_tb;
    reg clk;
    reg reset;
    
    // Instantiate the processor
    seq processor (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("RISC-V Processor - ADD Operation Test");
        $display("========================================");
        $display("Program:");
        $display("  0x00: li x5, 5       (x5 = 5)");
        $display("  0x04: li x6, 10      (x6 = 10)");
        $display("  0x08: add x7, x5, x6 (x7 = 15)");
        $display("  0x0C: add x8, x7, x5 (x8 = 20)");
        $display("");
        
        // Initialize VCD dump for waveform viewing
        $dumpfile("processor.vcd");
        $dumpvars(0, processor_tb);
        
        // Reset sequence
        reset = 1;
        #20;  // Hold reset for 2 clock cycles
        reset = 0;
        
        $display("Starting execution...");
        $display("");
        
        // Run for 20 clock cycles (enough for 4 instructions)
        repeat(20) begin
            @(posedge clk);
        end
        
        $display("========================================");
        $display("Execution Complete!");
        $display("========================================");
        $display("");
        $display("Final Register Values:");
        $display("  x5 = %0d (expected: 5)", $signed(processor.reg_file_inst.registers[5]));
        $display("  x6 = %0d (expected: 10)", $signed(processor.reg_file_inst.registers[6]));
        $display("  x7 = %0d (expected: 15)", $signed(processor.reg_file_inst.registers[7]));
        $display("  x8 = %0d (expected: 20)", $signed(processor.reg_file_inst.registers[8]));
        $display("");
        
        // Check results
        if ($signed(processor.reg_file_inst.registers[5]) == 5 &&
            $signed(processor.reg_file_inst.registers[6]) == 10 &&
            $signed(processor.reg_file_inst.registers[7]) == 15 &&
            $signed(processor.reg_file_inst.registers[8]) == 20)
            $display("SUCCESS: All ADD operations completed correctly!");
        else
            $display("FAILURE: Register values do not match expected values.");
        
        $display("========================================");
        
        $finish;
    end
    
    // Monitor execution
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time=%0t | PC=0x%h | Instr=0x%h", 
                     $time, processor.pc_out, processor.instruction);
        end
    end
    
endmodule
