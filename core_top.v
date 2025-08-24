`timescale 1ns / 1ps

module core_top #(
    parameter MEMORY_FILE = "programa.txt"
) (
    input  wire        clk,
    input  wire        rst_n,
    output wire [7:0]  leds
);

    // -------- Core ⇄ Barramento
    wire [31:0] core_addr, core_wdata, core_rdata;
    wire        core_rd_en, core_wr_en;

    core core_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .addr_o  (core_addr),
        .data_o  (core_wdata),
        .data_i  (core_rdata),
        .rd_en_o (core_rd_en),
        .wr_en_o (core_wr_en)
    );

    // -------- Memória
    wire        mem_rd_en, mem_wr_en;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    Memory #(.MEMORY_FILE(MEMORY_FILE)) mem (
        .clk     (clk),

        .rd_en_i (mem_rd_en),
        .wr_en_i (mem_wr_en),
        .addr_i  (mem_addr),
        .data_i  (mem_wdata),
        .data_o  (mem_rdata),
        .ack_o   ()              // não usamos ACK
    );

    // -------- Periférico de LEDs
    wire        per_rd_en, per_wr_en;
    wire [31:0] per_addr, per_wdata, per_rdata;

    led_peripheral u_led (
        .clk     (clk),
        .rst_n   (rst_n),
        .rd_en_i (per_rd_en),
        .wr_en_i (per_wr_en),
        .addr_i  (per_addr),
        .data_i  (per_wdata),
        .data_o  (per_rdata),
        .leds_o  (leds)
    );

    // -------- Interconexão de barramento
    // Mapa: 0x0000_0000..0x7FFF_FFFF = memória
    //       0x8000_0000..0x8000_000F = LEDs
    bus_interconnect u_bus (
        // do core
        .proc_rd_en_i (core_rd_en),
        .proc_wr_en_i (core_wr_en),
        .proc_data_o  (core_wdata),
        .proc_addr_i  (core_addr),
        .proc_data_i  (core_rdata),

        // para memória
        .mem_rd_en_o  (mem_rd_en),
        .mem_wr_en_o  (mem_wr_en),
        .mem_data_o   (mem_rdata),
        .mem_addr_o   (mem_addr),
        .mem_data_i   (mem_wdata),

        // para periférico
        .periph_rd_en_o (per_rd_en),
        .periph_wr_en_o (per_wr_en),
        .periph_data_o  (per_rdata),
        .periph_addr_o  (per_addr),
        .periph_data_i  (per_wdata)
    );

endmodule
