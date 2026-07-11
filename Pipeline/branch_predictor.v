module branch_predictor(
    input clk,
    input reset,

    // Lookup
    input  [63:0] pc,
    output predict_taken,

    input update,
    input [63:0] update_pc,
    input actual_taken
);

    reg [1:0] BHT [0:63];
    wire [5:0] index;

    assign index = pc[7:2];
    wire [1:0] state;

    assign state = BHT[index];
    assign predict_taken = state[1];

    wire [5:0] update_index;

    assign update_index = update_pc[7:2];

    integer i;
    always@(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 64; i = i + 1) begin
            BHT[i] <= 2'b01;
        end
    end
    else if (update) begin
        case (BHT[update_index])
            2'b00: BHT[update_index] <= actual_taken ? 2'b01 : 2'b00;
            2'b01: BHT[update_index] <= actual_taken ? 2'b10 : 2'b00;
            2'b10: BHT[update_index] <= actual_taken ? 2'b11 : 2'b01;
            2'b11: BHT[update_index] <= actual_taken ? 2'b11 : 2'b10;
            default: BHT[update_index] <= 2'b01;
        endcase
    end
end

endmodule