`define IMEM_SIZE 4096

module instruction_mem(
    input clk,
    input reset,
    input [11:0] addr,
    output reg [31:0] instr
);

    reg [7:0] mem [0:`IMEM_SIZE-1];
    reg [7:0] value;
    integer file;
    integer i;
    integer r;

    initial begin
        file = $fopen("instructions.txt","r");

         if (file == 0) begin
            $display("Error: Could not open instructions.txt");
            $finish;
        end

        i = 0;
        while(!$feof(file) && i<`IMEM_SIZE) begin
            r = $fscanf(file,"%h\n", value);
            if(r == 1)begin
                mem[i] =  value;
                i = i+1;
            end
            
        end
        $fclose(file);
    end 
    always @(*) begin
        if(addr + 3 < `IMEM_SIZE) begin
            instr[7:0] = mem[addr+3];
            instr[15:8] = mem[addr+2];
            instr[23:16] = mem[addr+1];
            instr[31:24] = mem[addr];
        end
        else begin
            instr = 32'b0;
        end
    end
    



endmodule
