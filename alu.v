module Alu (
    input  wire [3:0]  ALU_OP_i,
    input  wire [31:0] ALU_RS1_i,
    input  wire [31:0] ALU_RS2_i,

    output  reg [31:0] ALU_RD_o,
    output wire ALU_ZR_o
);

// Definição dos opcodes da ALU
localparam AND             = 4'b0000;
localparam OR              = 4'b0001;
localparam SUM             = 4'b0010;
localparam SUB             = 4'b1010;
localparam GREATER_EQUAL   = 4'b1100;
localparam GREATER_EQUAL_U = 4'b1101;
localparam SLT             = 4'b1110;
localparam SLT_U           = 4'b1111;
localparam SHIFT_LEFT      = 4'b0100;
localparam SHIFT_RIGHT     = 4'b0101;
localparam SHIFT_RIGHT_A   = 4'b0111;
localparam XOR             = 4'b1000;
localparam NOR             = 4'b1001;
localparam EQUAL           = 4'b0011;

always @(*) begin
    case (ALU_OP_i)
    AND: ALU_RD_o = ALU_RS1_i & ALU_RS2_i;
    OR: ALU_RD_o = ALU_RS1_i | ALU_RS2_i;
    SUM: ALU_RD_o = ALU_RS1_i + ALU_RS2_i;
    SUB: ALU_RD_o = ALU_RS1_i - ALU_RS2_i;
    GREATER_EQUAL: ALU_RD_o = ($signed(ALU_RS1_i) >= $signed(ALU_RS2_i)) ? 32'd1 : 32'd0;
    GREATER_EQUAL_U: ALU_RD_o = (ALU_RS1_i >= ALU_RS2_i) ? 32'd1 : 32'd0;
    SLT: ALU_RD_o = ($signed(ALU_RS1_i) < $signed(ALU_RS2_i)) ? 32'd1 : 32'd0;
    SLT_U: ALU_RD_o = (ALU_RS1_i < ALU_RS2_i) ? 32'd1 : 32'd0;
    SHIFT_LEFT:     ALU_RD_o = ALU_RS1_i << ALU_RS2_i[4:0];
    SHIFT_RIGHT:    ALU_RD_o = ALU_RS1_i >> ALU_RS2_i[4:0];
    SHIFT_RIGHT_A:  ALU_RD_o = $signed(ALU_RS1_i) >>> ALU_RS2_i[4:0];
    XOR: ALU_RD_o = ALU_RS1_i ^ ALU_RS2_i;
    NOR: ALU_RD_o = ~(ALU_RS1_i | ALU_RS2_i);  
    EQUAL: ALU_RD_o = (ALU_RS1_i == ALU_RS2_i) ? 32'd1 : 32'd0;
    default: ALU_RD_o = 32'd0;

    endcase
end

assign ALU_ZR_o = (ALU_RD_o == 32'd0);

endmodule
