`timescale 1ns/1ps

`include "pipeline_wrapper.v"

module pipe_tb; 

    reg clk;
    reg reset;
    integer fh;
    integer k;
    integer i;
    integer cycle_count;

    pipeline uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("processor_pipeline.vcd");
        $dumpvars(0, pipe_tb);
        reset = 1;
        cycle_count = 0;
        #20;
        reset = 0;
    end

    always @(posedge clk)
    begin
        if (!reset)
            cycle_count <= cycle_count + 1;
    end

    always @(posedge clk)
    begin
        if(!reset)
        begin
            if(uut.instruction == 32'h00000000)
            begin

                $display("------ Register File Contents ------");

                for (i = 0; i < 32; i = i + 1)
                begin
                    $display("x%0d = %0d", i, $signed(uut.reg_file_inst.registers[i]));
                end

                $display("------------------------------------");
                $display("Total cycles = %0d", cycle_count + 1);

                fh = $fopen("register_file.txt", "w");

                for (k = 0; k < 32; k = k + 1)
                    $fdisplay(fh, "%h", uut.reg_file_inst.registers[k]);

                $fdisplay(fh, "%0d", cycle_count + 1);

                $fclose(fh);
                $finish;
            end
        end
    end

endmodule