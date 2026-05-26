module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    input        equal,
    input        lessThan,

    output reg        alu_src,
    output reg        a_sel,
    output reg [3:0]  alu_op,
    output reg        reg_write_en,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg [1:0]  pc_src,
    output reg        branch_unsigned
);

    always @(*) begin
        // Defaults
        alu_src         = 0;
        alu_op          = 4'b0000;
        reg_write_en    = 0;
        mem_write       = 0;
        mem_to_reg      = 0;
        a_sel           = 0;
        pc_src          = 2'b00;
        branch_unsigned = 0;

        case (opcode)

            // ---------------- R-TYPE ----------------
            7'b0110011: begin
                alu_src      = 0;
                reg_write_en = 1;

                case ({funct7, funct3})
                    10'b0000000000: alu_op = 4'b0000; // add
                    10'b0100000000: alu_op = 4'b0001; // sub
                    10'b0000000001: alu_op = 4'b0010; // sll
                    10'b0000000010: alu_op = 4'b0011; // slt
                    10'b0000000011: alu_op = 4'b0100; // sltu
                    10'b0000000100: alu_op = 4'b0101; // xor
                    10'b0000000101: alu_op = 4'b0110; // srl
                    10'b0100000101: alu_op = 4'b0111; // sra
                    10'b0000000110: alu_op = 4'b1000; // or
                    10'b0000000111: alu_op = 4'b1001; // and
                    default: alu_op = 4'b1111;
                endcase
            end

            // ---------------- I-TYPE ALU ----------------
            7'b0010011: begin
                alu_src      = 1;
                reg_write_en = 1;

                case (funct3)
                    3'b000: alu_op = 4'b0000; // addi
                    3'b010: alu_op = 4'b0011; // slti
                    3'b011: alu_op = 4'b0100; // sltiu
                    3'b100: alu_op = 4'b0101; // xori
                    3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                    3'b110: alu_op = 4'b1000; // ori
                    3'b111: alu_op = 4'b1001; // andi
                    default: alu_op = 4'b1111;
                endcase
            end

            // ---------------- LOAD ----------------
            7'b0000011: begin
                alu_src      = 1;
                reg_write_en = 1;
                mem_write    = 0;
                mem_to_reg   = 1;
                alu_op       = 4'b0000;
            end

            // ---------------- STORE ----------------
            7'b0100011: begin
                alu_src    = 1;
                mem_write  = 1;
                alu_op     = 4'b0000;
            end

            // ---------------- BRANCH ----------------
            7'b1100011: begin
                alu_src         = 0;
                branch_unsigned = (funct3 == 3'b110 || funct3 == 3'b111);

                case (funct3)
                    3'b000: if (equal)     pc_src = 2'b01;
                    3'b001: if (!equal)    pc_src = 2'b01;
                    3'b100: if (lessThan)  pc_src = 2'b01;
                    3'b101: if (!lessThan) pc_src = 2'b01;
                    3'b110: if (lessThan)  pc_src = 2'b01;
                    3'b111: if (!lessThan) pc_src = 2'b01;
                endcase
            end

            // ---------------- JAL ----------------
            7'b1101111: begin
                a_sel        = 1;
                reg_write_en = 1;
                pc_src       = 2'b01;
            end

            // ---------------- JALR ----------------
            7'b1100111: begin
                reg_write_en = 1;
                pc_src       = 2'b10;
            end

            // ---------------- LUI ----------------
            7'b0110111: begin
                alu_src      = 1;
                reg_write_en = 1;
                alu_op       = 4'b0000;
            end

            // ---------------- AUIPC ----------------
            7'b0010111: begin
                a_sel        = 1;
                alu_src      = 1;
                reg_write_en = 1;
                alu_op       = 4'b0000;
            end

            default: begin
                alu_op = 4'b1111;
            end
        endcase
    end

endmodule