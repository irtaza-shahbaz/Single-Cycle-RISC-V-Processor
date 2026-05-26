module program_counter(
    input clk,
    input rst,
    input [31:0] pc_next,
    output reg [31:0] pc_out
);

always @(posedge clk) begin
    if (rst)
        pc_out <= 32'd0;
    else
        pc_out <= pc_next;
end

endmodule
