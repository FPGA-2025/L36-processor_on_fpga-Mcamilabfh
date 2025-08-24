module ALU_Control (
    input  wire        is_immediate_i,
    input  wire [1:0]  ALU_CO_i,
    input  wire [6:0]  FUNC7_i,
    input  wire [2:0]  FUNC3_i,
    output reg  [3:0]  ALU_OP_o
);

always @(*) begin
    case (ALU_CO_i)
        // 00: LOAD/STORE → soma (ADD)
        2'b00: ALU_OP_o = 4'b0010;

        // 01: BRANCH → um código por condição de branch
        2'b01: begin
            case (FUNC3_i)
                3'b000: ALU_OP_o = 4'b1010; // BEQ  → SUB
                3'b001: ALU_OP_o = 4'b0011; // BNE  → EQUAL
                3'b100: ALU_OP_o = 4'b1100; // BLT  → GREATER_EQUAL
                3'b101: ALU_OP_o = 4'b1110; // BGE  → SLT
                3'b110: ALU_OP_o = 4'b1101; // BLTU → GREATER_EQUAL_U
                3'b111: ALU_OP_o = 4'b1111; // BGEU → SLT_U
                default:        ALU_OP_o = 4'b1010; // SUB (fallback)
            endcase
        end

        // 10: ALU / ALUI → decodifica R-type (funct7+funct3) vs I-type (funct3 apenas)
        2'b10: begin
            case (FUNC3_i)
                3'b000: begin
                    if (!is_immediate_i && FUNC7_i[5])
                        ALU_OP_o = 4'b1010; // SUB
                    else
                        ALU_OP_o = 4'b0010; // ADD / ADDI
                end
                3'b111: ALU_OP_o = 4'b0000; // AND / ANDI
                3'b110: ALU_OP_o = 4'b0001; // OR  / ORI
                3'b100: ALU_OP_o = 4'b1000; // XOR / XORI
                3'b010: ALU_OP_o = 4'b1110; // SLT / SLTI
                3'b011: ALU_OP_o = 4'b1111; // SLTU/ SLTIU
                3'b001: ALU_OP_o = 4'b0100; // SLL / SLLI
                3'b101: begin
                    // SRL/SRLI vs SRA/SRAI
                    if (FUNC7_i[5])
                        ALU_OP_o = 4'b0111; // SRA / SRAI
                    else
                        ALU_OP_o = 4'b0101; // SRL / SRLI
                end
                default: ALU_OP_o = 4'b0000; 
            endcase
        end

        // 11: inválido → safe default
        default: ALU_OP_o = 4'b0000;
    endcase
end

endmodule
