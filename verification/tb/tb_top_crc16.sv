// FILE: tb_top_crc16.sv
// DESCRIPTION: Top for CRC-16 build: DUT with CRC_WIDTH=16, POLYNOMIAL=0x1021 (CRC-16-CCITT style).
// Use with run_crc16.do; run CrcWidthTestCrc16 to verify R3/R4 (width 16, poly 0x1021).
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

import uvm_pkg::*;
import CrcUvmPkg::*;

module tb_top_crc16;
  logic clk;
  initial begin clk = 0; forever #5 clk = ~clk; end

  crc_if m_vif(clk);

  crc_dut #(
    .CRC_WIDTH(16),
    .POLYNOMIAL(16'h1021),
    .INIT(16'h0000),
    .FINAL_XOR(16'h0000)
  ) dut (
    .clk(clk),
    .rst_n(m_vif.rst_n),
    .mode_serial(m_vif.mode_serial),
    .data_in(m_vif.data_in),
    .data_valid(m_vif.data_valid),
    .start(m_vif.start),
    .crc_out(m_vif.crc_out),
    .crc_valid(m_vif.crc_valid)
  );

  initial begin
    m_vif.rst_n = 0;
    uvm_config_db#(virtual crc_if)::set(null, "uvm_test_top.*", "m_vif", m_vif);
    run_test();
  end
  initial begin
    #100;
    m_vif.rst_n = 1;
  end
endmodule
