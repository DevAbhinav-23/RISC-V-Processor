module btb(
    input clk,
    input reset,

    // Lookup (IF stage)
    input  [63:0] pc,
    output reg hit,
    output reg [63:0] predicted_target,

    // Update (ID stage)
    input update,
    input [63:0] update_pc,
    input [63:0] update_target
);

    reg valid [0:63];
    reg [55:0] tag [0:63];
    reg [63:0] target [0:63];

    wire [5:0] lookup_index;
    wire [5:0] update_index;   

    assign lookup_index = pc[7:2];
    assign update_index = update_pc[7:2]; 

    always @(*) begin
        if (valid[lookup_index] && tag[lookup_index] == pc[63:8]) begin
            hit = 1'b1;
            predicted_target = target[lookup_index];
        end else begin
            hit = 1'b0;
            predicted_target = 64'b0;
        end
    end

    integer i;

    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < 64; i = i + 1)
                valid[i] <= 1'b0;
        end

        else if(update) begin
            valid[update_index] <= 1'b1;
            tag[update_index] <= update_pc[63:8];
            target[update_index] <= update_target;
        end
    end

    
endmodule