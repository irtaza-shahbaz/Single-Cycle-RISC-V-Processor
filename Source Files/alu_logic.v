module alu_logic #(
    parameter ALU_WIDTH = 32
)(
    input  [ALU_WIDTH-1:0] op1,
    input  [ALU_WIDTH-1:0] op2,
    input  [3:0] alu_op,
    output reg [ALU_WIDTH-1:0] result
);

    always @(*) begin
        case (alu_op)

            4'b0000: result = op1 + op2;                             // ADD / ADDI / AUIPC
            4'b0001: result = op1 - op2;                             // SUB
            4'b0010: result = op1 << op2[4:0];                      // SLL

            4'b0011: result = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0; // SLT / SLTI
            4'b0100: result = (op1 < op2) ? 32'd1 : 32'd0;                     // SLTU / SLTIU

            4'b0101: result = op1 ^ op2;                             // XOR / XORI
            4'b0110: result = op1 >> op2[4:0];                      // SRL / SRLI
            4'b0111: result = $signed(op1) >>> op2[4:0];           // SRA / SRAI

            4'b1000: result = op1 | op2;                             // OR / ORI
            4'b1001: result = op1 & op2;                             // AND / ANDI

            default: result = 32'd0;

        endcase
    end

endmodule