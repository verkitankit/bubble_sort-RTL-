`timescale 1ns / 1ps
module memory_block #(
  parameter ADDR_WIDTH = 10,
  parameter DATA_WIDTH = 16,
  parameter DEPTH = 1024
)(
  input  logic clk,
  input  logic mem_read,
  input  logic mem_write,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out
);

  logic [DATA_WIDTH-1:0] mem_array [0:DEPTH-1];

  // Write on clock edge
  always_ff @(posedge clk) begin
    if (mem_write)
      mem_array[addr] <= data_in;
  end

  // Combinational read
  assign data_out = mem_read ? mem_array[addr] : '0;

endmodule
