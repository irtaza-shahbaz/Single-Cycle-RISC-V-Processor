module top (
    input  clk,
    input  reset,
    output [31:0] alu_result_out,
    output MemRW,
    output reg_write_en,
    output [31:0] data_mem_out
);

    // ---------------------- PC Logic ----------------------
    wire [31:0] pc, next_pc, pc_plus4;
    assign pc_plus4 = pc + 32'd4;

    // ---------------------- Instruction Fetch ----------------------
    wire [31:0] instruction;
    inst_mem imem (
        .addr(pc),
        .inst(instruction)
    );

    // ---------------------- Instruction Decode ----------------------
    reg [6:0]  opcode;
    reg [2:0]  funct3;
    reg [6:0]  funct7;
    reg [4:0]  rs1, rs2, rd;

    always @(*) begin
        opcode = instruction[6:0];
        rd     = instruction[11:7];
        funct3 = instruction[14:12];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        funct7 = instruction[31:25];
    end

    // ---------------------- Register File ----------------------
    wire [31:0] reg_data1, reg_data2, write_data;

    reg_file rf (
        .clk(clk),
        .write_en(reg_write_en),
        .rs1(rs1),
        .rs2(rs2),
        .rsW(rd),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // ---------------------- Immediate Generation ----------------------
    wire [31:0] imm_out;
    imm_gen immgen (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    // ---------------------- ALU Logic ----------------------
    wire [3:0] alu_op;
    wire       alu_src;
    wire [31:0] alu_in1;
    wire [31:0] alu_in2;
    wire       a_sel;

    assign alu_in1 = (a_sel) ? pc : reg_data1;
    assign alu_in2 = (alu_src) ? imm_out : reg_data2;

    alu_logic alu (
        .op1(alu_in1),
        .op2(alu_in2),
        .alu_op(alu_op),
        .result(alu_result_out)
    );

    // ---------------------- Data Memory ----------------------
    data_mem dmem (
        .clk(clk),
        .addr(alu_result_out),
        .dataW(reg_data2),
        .funct3(funct3),
        .MemRW(MemRW),
        .dataR(data_mem_out)
    );

    // ---------------------- Writeback Mux ----------------------
    wire mem_to_reg;
    wire [1:0] pc_src;

    assign write_data = (pc_src == 2'b00) ?
                        (mem_to_reg ? data_mem_out : alu_result_out)
                        : pc_plus4;

    // ---------------------- PC Selection ----------------------
    wire [31:0] jalr_target;
    assign jalr_target = (reg_data1 + imm_out) & ~32'd1;

    reg [31:0] next_pc_reg;

    always @(*) begin
        case (pc_src)
            2'b00: next_pc_reg = pc_plus4;
            2'b01: next_pc_reg = pc + imm_out;
            2'b10: next_pc_reg = jalr_target;
            default: next_pc_reg = 32'd0;
        endcase
    end

    assign next_pc = next_pc_reg;

    // -------------------- Program Counter --------------------
    wire [31:0] pc_next, pc_out;

    program_counter pc_inst (
        .clk(clk),
        .rst(reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    assign pc = pc_out;
    assign pc_next = next_pc;

    // -------------------- Branch Comparator --------------------
    wire BrUn, BrEq, BrLt;

    branch_comp branch_comparator(
        .a(reg_data1),
        .b(reg_data2),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLt(BrLt)
    );

    // ---------------------- Control Unit ----------------------
    control_unit cu (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .equal(BrEq),
        .lessThan(BrLt),
        .alu_src(alu_src),
        .a_sel(a_sel),
        .alu_op(alu_op),
        .reg_write_en(reg_write_en),
        .mem_write(MemRW),
        .mem_to_reg(mem_to_reg),
        .pc_src(pc_src),
        .branch_unsigned(BrUn)
    );

endmodule