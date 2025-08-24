`timescale 1ns / 1ps

module Memory #(
    parameter MEMORY_SIZE = 1024,
    parameter MEMORY_FILE = ""
) (
    input  wire        clk,
    input  wire        rd_en_i,
    input  wire        wr_en_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o,
    output wire        ack_o
);

    // Memória interna de palavras
    reg [31:0] memory [0:MEMORY_SIZE-1];
    integer i;

    // Inicializa tudo com NOP (0x00000013) e depois carrega o programa
    initial begin
        for (i = 0; i < MEMORY_SIZE; i = i + 1)
            memory[i] = 32'h00000013;
        if (MEMORY_FILE != "") begin
            $readmemh(MEMORY_FILE, memory);
        end
    end

    // Escrita síncrona (STORE)
    always @(posedge clk) begin
        if (wr_en_i) begin
            memory[addr_i[31:2]] <= data_i;
        end
    end

    // Leitura incondicional (instr + dados)
    assign data_o = memory[addr_i[31:2]];
    assign ack_o  = 1'b1;

endmodule
