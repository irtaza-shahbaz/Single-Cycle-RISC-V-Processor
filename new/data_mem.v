module data_mem (
    input  clk,
    input  [31:0] addr,
    input  [31:0] dataW,
    input  [2:0]  funct3,
    input         MemRW,
    output reg [31:0] dataR
);

    reg [31:0] memory [0:255];  // 1KB RAM (256 words)

    wire [31:0] word_addr;
    assign word_addr = addr[31:2];

    wire [31:0] word_data;
    assign word_data = memory[word_addr];

    // ---------------- LOAD (combinational read) ----------------
    always @(*) begin
        case (funct3)

            3'b000: begin // lb
                case (addr[1:0])
                    2'b00: dataR = {{24{word_data[7]}},  word_data[7:0]};
                    2'b01: dataR = {{24{word_data[15]}}, word_data[15:8]};
                    2'b10: dataR = {{24{word_data[23]}}, word_data[23:16]};
                    2'b11: dataR = {{24{word_data[31]}}, word_data[31:24]};
                endcase
            end

            3'b001: begin // lh
                case (addr[1])
                    1'b0: dataR = {{16{word_data[15]}}, word_data[15:0]};
                    1'b1: dataR = {{16{word_data[31]}}, word_data[31:16]};
                endcase
            end

            3'b010: begin // lw
                dataR = word_data;
            end

            3'b100: begin // lbu
                case (addr[1:0])
                    2'b00: dataR = {24'd0, word_data[7:0]};
                    2'b01: dataR = {24'd0, word_data[15:8]};
                    2'b10: dataR = {24'd0, word_data[23:16]};
                    2'b11: dataR = {24'd0, word_data[31:24]};
                endcase
            end

            3'b101: begin // lhu
                case (addr[1])
                    1'b0: dataR = {16'd0, word_data[15:0]};
                    1'b1: dataR = {16'd0, word_data[31:16]};
                endcase
            end

            default: dataR = 32'd0;

        endcase
    end

    // ---------------- STORE (synchronous write) ----------------
    always @(posedge clk) begin
        if (MemRW) begin
            case (funct3)

                3'b000: begin // sb
                    case (addr[1:0])
                        2'b00: memory[word_addr][7:0]   <= dataW[7:0];
                        2'b01: memory[word_addr][15:8]  <= dataW[7:0];
                        2'b10: memory[word_addr][23:16] <= dataW[7:0];
                        2'b11: memory[word_addr][31:24] <= dataW[7:0];
                    endcase
                end

                3'b001: begin // sh
                    case (addr[1])
                        1'b0: memory[word_addr][15:0]  <= dataW[15:0];
                        1'b1: memory[word_addr][31:16] <= dataW[15:0];
                    endcase
                end

                3'b010: begin // sw
                    memory[word_addr] <= dataW;
                end

            endcase
        end
    end

    initial begin
        $readmemh("data_mem.mem", memory);
    end

endmodule