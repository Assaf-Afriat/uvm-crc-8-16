// FILE: crc_if.sv
// DESCRIPTION: DUT interface for CRC-8/16; connects driver and monitor to RTL signals.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

interface crc_if (input logic clk);
  logic        rst_n;
  logic        mode_serial;
  logic [7:0]  data_in;
  logic        data_valid;
  logic        start;
  logic [15:0] crc_out;
  logic        crc_valid;

  clocking cb @(posedge clk);
    output rst_n, mode_serial, data_in, data_valid, start;
    input  crc_out, crc_valid;
  endclocking

  modport dut (
    input  clk, rst_n, mode_serial, data_in, data_valid, start,
    output crc_out, crc_valid
  );

  modport tb (clocking cb, ref clk, ref rst_n, ref data_in, ref data_valid, ref mode_serial, ref start, ref crc_out, ref crc_valid);
endinterface
