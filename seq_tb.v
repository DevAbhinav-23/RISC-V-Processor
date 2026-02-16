`timescale 1ns/1ps

`include "Seq_wrapper.v"

module seq_tb;

    reg clk;
    reg reset;

    // Instantiate processor
    seq uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Reset and run
    initial begin

        $dumpfile("processor.vcd");
        $dumpvars(0, seq_tb);

        $display("==========================================");
        $display("      RISC-V Processor Full Test");
        $display("==========================================");

        reset = 1;
        #20;
        reset = 0;

        // Run enough cycles
        repeat(50) @(posedge clk);

        $display("\n==========================================");
        $display("Final Register Values:");
        $display("==========================================");

        $display("x1  = %0d", $signed(uut.reg_file_inst.registers[1]));
        $display("x2  = %0d", $signed(uut.reg_file_inst.registers[2]));
        $display("x3  = %0d", $signed(uut.reg_file_inst.registers[3]));
        $display("x4  = %0d", $signed(uut.reg_file_inst.registers[4]));
        $display("x5  = %0d", $signed(uut.reg_file_inst.registers[5]));
        $display("x6  = %0d", $signed(uut.reg_file_inst.registers[6]));
        $display("x7  = %0d", $signed(uut.reg_file_inst.registers[7]));
        $display("x10 = %0d", $signed(uut.reg_file_inst.registers[10]));
        $display("x11 = %0d", $signed(uut.reg_file_inst.registers[11]));
        $display("x13 = %0d", $signed(uut.reg_file_inst.registers[13]));


        $display("\n==========================================");
        $display("Memory Values:");
        $display("==========================================");

        $display("mem[10] = %0d",
        $signed({
        uut.data_mem_inst.mem[13],
        uut.data_mem_inst.mem[12],
        uut.data_mem_inst.mem[11],
        uut.data_mem_inst.mem[10],
        uut.data_mem_inst.mem[9],
        uut.data_mem_inst.mem[8],
        uut.data_mem_inst.mem[7],
        uut.data_mem_inst.mem[6]
        }));


        $display("mem[13] = %0d",
        $signed({
        uut.data_mem_inst.mem[16],
        uut.data_mem_inst.mem[15],
        uut.data_mem_inst.mem[14],
        uut.data_mem_inst.mem[13],
        uut.data_mem_inst.mem[12],
        uut.data_mem_inst.mem[11],
        uut.data_mem_inst.mem[10],
        uut.data_mem_inst.mem[9]
        }));


        $display("\n==========================================");
        $display("Simulation Finished");
        $display("==========================================");

        $finish;

    end


    // Live monitor
    always @(posedge clk)
    begin

        if(!reset)
        begin

            $display(
            "Time=%0t PC=%h Instr=%h",
            $time,
            uut.pc_out,
            uut.instruction
            );

        end

    end


endmodule