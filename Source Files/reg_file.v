module reg_file #(
    parameter REGF_WIDTH = 32
)(
    input clk,
    input write_en,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rsW,
    input [REGF_WIDTH-1:0] write_data,
    output [REGF_WIDTH-1:0] read_data1,
    output [REGF_WIDTH-1:0] read_data2
);

    reg [REGF_WIDTH-1:0] reg_file [0:31];

    // Read ports (x0 is hardwired to 0 in RISC-V)
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : reg_file[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : reg_file[rs2];

    initial begin
        $readmemh("reg_init.mem", reg_file);
    end

    // Write port (synchronous)
    always @(posedge clk) begin
        if (write_en && rsW != 5'd0) begin
            reg_file[rsW] <= write_data;
        end
    end

endmodule