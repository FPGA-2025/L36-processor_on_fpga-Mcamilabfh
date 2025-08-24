module Registers (
    input  wire clk,
    input  wire wr_en_i,
    
    input  wire [4:0] RS1_ADDR_i,
    input  wire [4:0] RS2_ADDR_i,
    input  wire [4:0] RD_ADDR_i,

    input  wire [31:0] data_i,
    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);

  // Internal register storage
    reg [31:0] regs [0:31];

    // Asynchronous reads
    assign RS1_data_o = (RS1_ADDR_i != 5'd0) ? regs[RS1_ADDR_i] : 32'd0;
    assign RS2_data_o = (RS2_ADDR_i != 5'd0) ? regs[RS2_ADDR_i] : 32'd0;

    // Synchronous write at rising edge
    always @(posedge clk) begin
        if (wr_en_i && (RD_ADDR_i != 5'd0)) begin
            regs[RD_ADDR_i] <= data_i;
        end
    end

endmodule