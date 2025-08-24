`timescale 1ns / 1ps

module core (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] addr_o,
    output wire [31:0] data_o,
    input  wire [31:0] data_i,
    output wire        rd_en_o,
    output wire        wr_en_o
);

    // Registradores internos
    reg [31:0] PC, IR, MDR, A, B, ALUOut;
    reg        prev_ir_write;

    // Fios auxiliares
    wire        alu_zero;
    wire [31:0] alu_result, imm_ext, alu_in1, alu_in2;
    wire [3:0]  alu_control_out;

    // Sinais de controle
    wire        pc_write, ir_write, pc_source;
    wire        reg_write, mem_read_int, is_immediate;
    wire        mem_write_int, pc_write_cond, lorD, memory_to_reg;
    wire [1:0]  aluop, alu_src_a, alu_src_b;

    // Control Unit
    Control_Unit control_unit_inst (
        .clk                (clk),
        .rst_n              (rst_n),
        .instruction_opcode (IR[6:0]),
        .pc_write           (pc_write),
        .ir_write           (ir_write),
        .pc_source          (pc_source),
        .reg_write          (reg_write),
        .memory_read        (mem_read_int),
        .is_immediate       (is_immediate),
        .memory_write       (mem_write_int),
        .pc_write_cond      (pc_write_cond),
        .lorD               (lorD),
        .memory_to_reg      (memory_to_reg),
        .aluop              (aluop),
        .alu_src_a          (alu_src_a),
        .alu_src_b          (alu_src_b)
    );

    // Immediate Generator
    Immediate_Generator imm_gen_inst (
        .instr_i (IR),
        .imm_o   (imm_ext)
    );

    // ALU Control
    ALU_Control alu_control_inst (
        .is_immediate_i(is_immediate),
        .ALU_CO_i      (aluop),
        .FUNC7_i       (IR[31:25]),
        .FUNC3_i       (IR[14:12]),
        .ALU_OP_o      (alu_control_out)
    );

    // ALU
    Alu alu_inst (
        .ALU_OP_i  (alu_control_out),
        .ALU_RS1_i (alu_in1),
        .ALU_RS2_i (alu_in2),
        .ALU_RD_o  (alu_result),
        .ALU_ZR_o  (alu_zero)
    );

    // Register File
    Registers regfile_inst (
        .clk         (clk),
        .wr_en_i     (reg_write),
        .RS1_ADDR_i  (IR[19:15]),
        .RS2_ADDR_i  (IR[24:20]),
        .RD_ADDR_i   (IR[11:7]),
        .data_i      (memory_to_reg ? MDR : ALUOut),
        .RS1_data_o  (),
        .RS2_data_o  ()
    );
    wire [31:0] rs1_data = regfile_inst.RS1_data_o;
    wire [31:0] rs2_data = regfile_inst.RS2_data_o;

    // MUX de operandos ALU
    assign alu_in1 = (alu_src_a == 2'b00) ? PC :
                     (alu_src_a == 2'b01) ? A  :
                                            32'b0;
    assign alu_in2 = (alu_src_b == 2'b00) ? B :
                     (alu_src_b == 2'b01) ? 32'd4 :
                     (alu_src_b == 2'b10) ? imm_ext :
                                            32'b0;

    // Cálculo do próximo PC
    wire [31:0] pc_next = (pc_source == 1'b0) ? alu_result : ALUOut;

    // Interface memória
    assign addr_o  = (lorD == 1'b0) ? PC : ALUOut;
    assign data_o  = B;
    assign rd_en_o = mem_read_int;
    assign wr_en_o = mem_write_int;

    // Lógica sequencial
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC            <= 32'd0;
            IR            <= 32'd0;
            MDR           <= 32'd0;
            A             <= 32'd0;
            B             <= 32'd0;
            ALUOut        <= 32'd0;
            prev_ir_write <= 1'b0;
        end else begin
            // PC update
            if (pc_write || (pc_write_cond && alu_zero))
                PC <= pc_next;

            // Fetch de instrução
            if (ir_write)
                IR <= data_i;

            // LOAD em MDR
            if (mem_read_int && !ir_write)
                MDR <= data_i;

            // Captura A/B
            if (prev_ir_write && !ir_write) begin
                A <= rs1_data;
                B <= rs2_data;
            end

            // ALUOut update
            if (!(pc_write_cond ||
                  (pc_write && reg_write) ||
                  (mem_read_int && !ir_write) ||
                  mem_write_int ||
                  IR[6:0] == 7'b1101111 ||
                  IR[6:0] == 7'b1100111))
                ALUOut <= alu_result;

            prev_ir_write <= ir_write;
        end
    end

endmodule
