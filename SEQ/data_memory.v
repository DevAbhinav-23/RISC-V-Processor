`define TOTL_SIZE 1024

module data_memory(
    input clk,
    input reset,
    input mem_r,
    input mem_w,
    input [63:0] addr,
    input [63:0] input_w,
    output reg [63:0] output_w
);

    reg [7:0] mem [0:`TOTL_SIZE-1];
    integer i;


    always @(*) begin
        if (mem_r == 1'b1 && addr + 7 < `TOTL_SIZE) begin
            output_w[7:0]   = mem[addr+7];
            output_w[15:8]  = mem[addr+6];
            output_w[23:16] = mem[addr+5];
            output_w[31:24] = mem[addr+4];
            output_w[39:32] = mem[addr+3];
            output_w[47:40] = mem[addr+2];
            output_w[55:48] = mem[addr+1];
            output_w[63:56] = mem[addr];
        end
        else begin
            output_w = 64'b0;
        end
    end


    always @(posedge clk) begin
        if (reset == 1'b1) begin
            for (i = 0; i < `TOTL_SIZE; i = i + 1) begin
                mem[i] <= 8'b0;
            end
        end
        else if (mem_w == 1'b1 && addr + 7 < `TOTL_SIZE) begin

            mem[addr]   <= input_w[63:56];
            mem[addr+1] <= input_w[55:48];
            mem[addr+2] <= input_w[47:40];
            mem[addr+3] <= input_w[39:32];
            mem[addr+4] <= input_w[31:24];
            mem[addr+5] <= input_w[23:16];
            mem[addr+6] <= input_w[15:8];
            mem[addr+7] <= input_w[7:0];
        end
    end

endmodule
