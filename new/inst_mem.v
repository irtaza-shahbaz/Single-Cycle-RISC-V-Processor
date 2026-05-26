module inst_mem (
    input  [31:0] addr,
    output [31:0] inst
);

    // 2KB of instruction memory = 256 words (32-bit each)
    reg [31:0] memory [0:255];

    // Word-aligned access (ignore lower 2 bits)
    assign inst = memory[addr[31:2]];

    initial begin
        $readmemh("instructions.mem", memory);
    end

endmodule