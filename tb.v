`timescale 1ns/1ps

module tb;

  // Sinais
  reg        clk;
  reg        rst_n;
  wire [7:0] leds;

  // Vars auxiliares
  integer vcd_fd;
  integer fd;
  integer i;
  reg [7:0] esperado;

  // Clock 100 MHz 
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // DUT
  core_top #(.MEMORY_FILE("programa.txt")) dut (
    .clk  (clk),
    .rst_n(rst_n),
    .leds (leds)
  );

  initial begin
    // Reset síncrono simples
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;

    // Cria saida.vcd sem poluir stdout
    vcd_fd = $fopen("saida.vcd","w");
    if (vcd_fd) $fclose(vcd_fd);

    // O run.sh copia test/teste$N.txt -> teste.txt ; então lemos "teste.txt"
    // Arquivo deve ter UMA palavra hex (ex.: 0f)
    esperado = 8'h00;  // default
    fd = $fopen("teste.txt","r");
    if (fd) begin
      if ($fscanf(fd, "%h", esperado) != 1) esperado = 8'h00;
      $fclose(fd);
    end

    // Espera até LEDs == esperado (timeout para não travar)
    for (i = 0; i < 20000; i = i + 1) begin
      @(posedge clk);
      if (leds === esperado) begin
        $display("=== OK Escrita nos LEDS passou: obtive %h", leds);
        $finish;
      end
    end

    // Timeout: não bateu
    $display("=== ERRO Escrita nos LEDS falhou: esperava %h, obtive %h", esperado, leds);
    $finish;
  end

endmodule
