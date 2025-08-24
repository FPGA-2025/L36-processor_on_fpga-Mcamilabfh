module led_peripheral(
    input  wire        clk,
    input  wire        rst_n,

    // ligação com o processador
    input  wire        rd_en_i,
    input  wire        wr_en_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o,

    // ligação com o mundo externo
    output wire [7:0]  leds_o
);
    // só usamos os 4 LSBs do endereço (0x0 e 0x4)
    wire [3:0] effective_address = addr_i[3:0];

    // registrador que segura o estado dos LEDs
    reg [7:0] led_reg;

    // escrita no offset 0x00
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_reg <= 8'h00;
        end else if (wr_en_i && (effective_address == 4'h0)) begin
            led_reg <= data_i[7:0];
        end
    end

    // leitura no offset 0x04 (zero-extend)
    assign data_o = (rd_en_i && (effective_address == 4'h4)) ?
                    {24'b0, led_reg} : 32'b0;

    // saída para a placa
    assign leds_o = led_reg;

endmodule
