`define REG_MEM_SIZE 32

module register_file(
    input clk,
    input reset,
    input register_write,
    input [4:0] reg1_r,
    input [4:0] reg2_r,
    input [4:0] reg1_w,
    input [63:0] data_to_w,
    output [63:0] output1_r,
    output [63:0] output2_r
);

    reg [63:0] registers [0:`REG_MEM_SIZE-1];
    integer i;

    assign output1_r = (reg1_r == 5'b0) ? 64'b0 : registers[reg1_r];
    assign output2_r = (reg2_r == 5'b0) ? 64'b0 : registers[reg2_r];



    always @(posedge clk) begin
        if (reset == 1'b1) begin
            for (i = 0; i < `REG_MEM_SIZE; i = i + 1) begin
                registers[i] <= 64'b0;
            end
        end
        else begin
            if (register_write == 1'b1 && reg1_w != 5'b0) begin
                registers[reg1_w] <= data_to_w;
            end
        end
    end



endmodule
