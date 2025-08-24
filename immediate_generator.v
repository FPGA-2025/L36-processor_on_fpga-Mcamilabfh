module Immediate_Generator (
    input wire [31:0] instr_i,  // Entrada: Instrução
    output reg [31:0] imm_o     // Saída: Imediato extraído da instrução
);


localparam LW_OPCODE        = 7'b0000011;
localparam SW_OPCODE        = 7'b0100011;
localparam JAL_OPCODE       = 7'b1101111;
localparam LUI_OPCODE       = 7'b0110111;
localparam JALR_OPCODE      = 7'b1100111;
localparam AUIPC_OPCODE     = 7'b0010111;
localparam BRANCH_OPCODE    = 7'b1100011;
localparam IMMEDIATE_OPCODE = 7'b0010011;

  wire [6:0] opcode = instr_i[6:0];
    wire [2:0] funct3 = instr_i[14:12];

    always @(*) begin
        case (opcode)
            // I-type: ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, JALR, LW
            IMMEDIATE_OPCODE,
            JALR_OPCODE,
            LW_OPCODE: begin
                // Shift immediate (SLLI, SRLI, SRAI): zero-extend shamt
                if (opcode == IMMEDIATE_OPCODE && (funct3 == 3'b001 || funct3 == 3'b101)) begin
                    imm_o = {27'b0, instr_i[24:20]}; // shamt
                end else begin
                    // Sign-extend 12-bit immediate
                    imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
                end
            end

            // S-type: SW
            SW_OPCODE: begin
                // imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
                imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            end

            // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
            BRANCH_OPCODE: begin
                // imm[12] = instr[31], imm[10:5] = instr[30:25]
                // imm[4:1] = instr[11:8], imm[11] = instr[7], imm[0] = 0
                imm_o = {{19{instr_i[31]}}, instr_i[31],
                         instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            end

            // U-type: LUI, AUIPC
            LUI_OPCODE,
            AUIPC_OPCODE: begin
                // imm[31:12] = instr[31:12], lower 12 bits zero
                imm_o = {instr_i[31:12], 12'b0};
            end

            // J-type: JAL
            JAL_OPCODE: begin
                // imm[20] = instr[31], imm[10:1] = instr[30:21]
                // imm[11] = instr[20], imm[19:12] = instr[19:12], imm[0] = 0
                imm_o = {{11{instr_i[31]}}, instr_i[31],
                         instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            end

            default: begin
                imm_o = 32'b0;
            end
        endcase
    end

    
endmodule