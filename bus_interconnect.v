module bus_interconnect (
    // sinais vindos do processador
    input  wire        proc_rd_en_i,
    input  wire        proc_wr_en_i,
    input  wire [31:0] proc_data_o,   // dado SAINDO do core
    input  wire [31:0] proc_addr_i,
    output wire [31:0] proc_data_i,   // dado INDO para o core

    // sinais que vão para a memória
    output wire        mem_rd_en_o,
    output wire        mem_wr_en_o,
    input  wire [31:0] mem_data_o,    // dado vindo da memória
    output wire [31:0] mem_addr_o,
    output wire [31:0] mem_data_i,    // dado indo para a memória

    // sinais que vão para o periférico
    output wire        periph_rd_en_o,
    output wire        periph_wr_en_o,
    input  wire [31:0] periph_data_o, // dado vindo do periférico
    output wire [31:0] periph_addr_o,
    output wire [31:0] periph_data_i  // dado indo para o periférico
);

    // Endereços:
    // 0x0000_0000 .. 0x7FFF_FFFF -> memória
    // 0x8000_0000 .. 0x8000_000F -> LEDs
    wire sel_leds = (proc_addr_i[31:4] == 28'h8000000);
    wire sel_mem  = ~sel_leds && (proc_addr_i[31] == 1'b0);

    // Repasse para a memória
    assign mem_rd_en_o = sel_mem  ? proc_rd_en_i : 1'b0;
    assign mem_wr_en_o = sel_mem  ? proc_wr_en_i : 1'b0;
    assign mem_addr_o  = proc_addr_i;
    assign mem_data_i  = proc_data_o;

    // Repasse para o periférico (LEDs)
    assign periph_rd_en_o = sel_leds ? proc_rd_en_i : 1'b0;
    assign periph_wr_en_o = sel_leds ? proc_wr_en_i : 1'b0;
    assign periph_addr_o  = proc_addr_i;
    assign periph_data_i  = proc_data_o;

    // Retorno para o processador (mux de leitura)
    assign proc_data_i = sel_mem  ? mem_data_o :
                         sel_leds ? periph_data_o :
                         32'b0;

endmodule
