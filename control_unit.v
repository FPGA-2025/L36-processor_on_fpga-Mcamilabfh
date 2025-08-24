module Control_Unit (
    input wire clk,
    input wire rst_n,
    input wire [6:0] instruction_opcode,
    output reg pc_write,
    output reg ir_write,
    output reg pc_source,
    output reg reg_write,
    output reg memory_read,
    output reg is_immediate,
    output reg memory_write,
    output reg pc_write_cond,
    output reg lorD,
    output reg memory_to_reg,
    output reg [1:0] aluop,
    output reg [1:0] alu_src_a,
    output reg [1:0] alu_src_b
);

 // State encoding
    parameter FETCH    = 4'd0;
    parameter DECODE   = 4'd1;
    parameter MEMADR   = 4'd2;
    parameter MEMREAD  = 4'd3;
    parameter MEMWB    = 4'd4;
    parameter MEMWRITE = 4'd5;
    parameter EXECUTE  = 4'd6;
    parameter ALUWB    = 4'd7;
    parameter BRANCH   = 4'd8;
    parameter JAL      = 4'd9;
    parameter JALR     = 4'd10;
    parameter AUIPC    = 4'd11;
    parameter LUI      = 4'd12;

    // Opcodes
    parameter OPC_LW    = 7'b0000011;
    parameter OPC_SW    = 7'b0100011;
    parameter OPC_RTYPE = 7'b0110011;
    parameter OPC_ITYPE = 7'b0010011;
    parameter OPC_JAL   = 7'b1101111;
    parameter OPC_BRANCH= 7'b1100011;
    parameter OPC_JALR  = 7'b1100111;
    parameter OPC_AUIPC = 7'b0010111;
    parameter OPC_LUI   = 7'b0110111;

// Internal state regs
reg [3:0] state;
reg [3:0] next_state;

// State register update
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= FETCH;
    else
        state <= next_state;
end

// Next-state logic
always @(*) begin
    case (state)
        FETCH:    next_state = DECODE;
        DECODE:   begin
            case (instruction_opcode)
                OPC_LW, OPC_SW:       next_state = MEMADR;
                OPC_RTYPE, OPC_ITYPE,
                OPC_AUIPC, OPC_LUI:   next_state = EXECUTE;
                OPC_BRANCH:           next_state = BRANCH;
                OPC_JAL:              next_state = JAL;
                OPC_JALR:             next_state = JALR;
                default:              next_state = FETCH;
            endcase
        end
        MEMADR:   next_state = (instruction_opcode == OPC_LW) ? MEMREAD : MEMWRITE;
        MEMREAD:  next_state = MEMWB;
        MEMWB:    next_state = FETCH;
        MEMWRITE: next_state = FETCH;
        EXECUTE:  next_state = ALUWB;
        ALUWB:    next_state = FETCH;
        BRANCH:   next_state = FETCH;
        JAL:      next_state = ALUWB;
        JALR:     next_state = ALUWB;
        default:  next_state = FETCH;
    endcase
end

// Output control signals
always @(*) begin
    // defaults
    pc_write       = 1'b0;
    ir_write       = 1'b0;
    pc_source      = 1'b0;
    reg_write      = 1'b0;
    memory_read    = 1'b0;
    memory_write   = 1'b0;
    pc_write_cond  = 1'b0;
    lorD           = 1'b0;
    memory_to_reg  = 1'b0;
    is_immediate   = 1'b0;
    aluop          = 2'b00;
    alu_src_a      = 2'b00;
    alu_src_b      = 2'b00;

    case (state)
        FETCH: begin
            memory_read  = 1'b1;
            ir_write     = 1'b1;
            pc_write     = 1'b1;
            pc_source    = 1'b0;
            alu_src_a    = 2'b00;
            alu_src_b    = 2'b01;
            aluop        = 2'b00;
        end
        DECODE: begin
            alu_src_a    = 2'b10;
            alu_src_b    = 2'b10;
            aluop        = 2'b00;
        end
        MEMADR: begin
            alu_src_a    = 2'b01;
            alu_src_b    = 2'b10;
            aluop        = 2'b00;
        end
        MEMREAD: begin
            memory_read = 1'b1;
            lorD        = 1'b1;
        end
        MEMWB: begin
            reg_write     = 1'b1;
            memory_to_reg = 1'b1;
        end
        MEMWRITE: begin
            memory_write = 1'b1;
            lorD         = 1'b1;
        end
        EXECUTE: begin
            case (instruction_opcode)
                OPC_RTYPE: begin
                    alu_src_a    = 2'b01;
                    alu_src_b    = 2'b00;
                    aluop        = 2'b10;
                    is_immediate = 1'b0;
                end
                OPC_ITYPE: begin
                    alu_src_a    = 2'b01;
                    alu_src_b    = 2'b10;
                    aluop        = 2'b10;
                    is_immediate = 1'b1;
                end
                OPC_AUIPC: begin
                    alu_src_a    = 2'b10;
                    alu_src_b    = 2'b10;
                    aluop        = 2'b00;
                    is_immediate = 1'b0;
                end
                OPC_LUI: begin
                    alu_src_a    = 2'b11;
                    alu_src_b    = 2'b10;
                    aluop        = 2'b00;
                    is_immediate = 1'b0;
                end
                default: begin
                    alu_src_a    = 2'b01;
                    alu_src_b    = 2'b11;
                    aluop        = 2'b00;
                    is_immediate = 1'b0;
                end
            endcase
        end
        ALUWB: begin
            reg_write     = 1'b1;
            memory_to_reg = 1'b0;
        end
        BRANCH: begin
            alu_src_a     = 2'b01;
            alu_src_b     = 2'b00;
            aluop         = 2'b01;
            pc_write_cond = 1'b1;
            pc_source     = 1'b1;
        end
        JAL: begin
            pc_write   = 1'b1;
            pc_source  = 1'b1;
            alu_src_a  = 2'b10;
            alu_src_b  = 2'b01;
        end
        JALR: begin
            pc_write      = 1'b1;
            pc_source     = 1'b1;
            is_immediate  = 1'b1;
            alu_src_a     = 2'b10;
            alu_src_b     = 2'b01;
        end
    endcase
end

endmodule
