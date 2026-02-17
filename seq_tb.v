`timescale 1ns/1ps

`include "Seq_wrapper.v"

module seq_tb;

    reg clk;
    reg reset;
    integer fh;
    integer k;
    integer cycle_count;

    seq uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("processor.vcd");
        $dumpvars(0, seq_tb);
        reset = 1;
        #20;
        reset = 0;
        cycle_count = 0;

        repeat(100) @(posedge clk);

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

        begin
            fh = $fopen("register.txt", "w");
            for (k = 0; k < 32; k = k + 1) begin
                $fdisplay(fh, "%h", uut.reg_file_inst.registers[k]);
            end
            $fdisplay(fh, "%0d", cycle_count + 1);
            $fclose(fh);
            $display("Register contents written to register.txt");
        end

        $finish;

    end

    always @(posedge clk) begin
        if (!reset)
            cycle_count <= cycle_count +1;
    end

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