// FILE: tb_crc_zero_order.sv
// DESCRIPTION: Zero-order testbench for CRC-8 DUT. Operation only: one serial and one parallel run; pass = same CRC for same byte and crc_valid timing.
// AUTHOR: zero-order-test (workflow)
// DATE: 2025-03-05

`timescale 1ns / 1ps

module tb_crc_zero_order;

  localparam real CLK_PERIOD_NS = 10.0;
  localparam logic [7:0] TEST_BYTE = 8'hA5;  // Same byte used for serial and parallel; CRCs must match.
  localparam logic [7:0] CRC8_POLY = 8'h07;

  // Reference: CRC-8 Galois LSB-first, poly 0x07, init 0 (matches DUT)
  function automatic logic [7:0] ref_crc8_byte(logic [7:0] data);
    logic [7:0] crc = '0;
    for (int i = 0; i < 8; i++) begin
      logic fb = (crc[7] ^ data[i]);
      crc = (crc << 1) ^ (CRC8_POLY & {8{fb}});
    end
    return crc;
  endfunction

  logic        clk;
  logic        rst_n;
  logic        mode_serial;
  logic [7:0]  data_in;
  logic        data_valid;
  logic        start;
  logic [15:0] crc_out;
  logic        crc_valid;

  logic [15:0] crc_serial;   // Captured when crc_valid after serial run
  logic [15:0] crc_parallel; // Captured when crc_valid after parallel run
  logic        serial_done;
  logic        parallel_done;
  logic        pass;

  // DUT: CRC-8, polynomial 0x07, init 0, no final XOR
  crc_dut #(
    .CRC_WIDTH ( 8 ),
    .POLYNOMIAL( 16'h0007 ),
    .INIT      ( 16'h0000 ),
    .FINAL_XOR ( 16'h0000 )
  ) u_dut (
    .clk         ( clk ),
    .rst_n       ( rst_n ),
    .mode_serial ( mode_serial ),
    .data_in     ( data_in ),
    .data_valid  ( data_valid ),
    .start       ( start ),
    .crc_out     ( crc_out ),
    .crc_valid   ( crc_valid )
  );

  initial begin : clk_gen
    clk = 0;
    forever #(CLK_PERIOD_NS/2.0) clk = ~clk;
  end

  initial begin : test_seq
    rst_n       = 0;
    mode_serial = 1;
    data_in     = '0;
    data_valid  = 0;
    start       = 0;
    serial_done   = 0;
    parallel_done = 0;

    repeat (3) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    // ---- Serial run: send TEST_BYTE LSB first (1 bit per cycle) ----
    mode_serial = 1;
    for (int i = 0; i < 8; i++) begin
      @(posedge clk);
      data_in[0] = TEST_BYTE[i];
      data_valid = 1;
      @(posedge clk);
      data_valid = 0;
    end
    // One cycle after last bit: sample at negedge + small delay to avoid simulator race
    @(posedge clk);
    @(negedge clk);
    #1;
    crc_serial = crc_out;
    serial_done = 1;
    repeat (2) @(posedge clk);

    // ---- Start new CRC, then parallel run: one byte ----
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;
    mode_serial = 0;
    data_in = TEST_BYTE;
    data_valid = 1;
    @(posedge clk);
    data_valid = 0;
    @(posedge clk);
    @(negedge clk);
    #1;
    crc_parallel = crc_out;
    parallel_done = 1;
    repeat (2) @(posedge clk);

    // ---- Pass: serial/parallel match AND match reference ----
    begin
      logic [7:0] expected = ref_crc8_byte(TEST_BYTE);
      pass = serial_done && parallel_done && (crc_serial[7:0] == crc_parallel[7:0]) && (crc_serial[7:0] == expected);
      if (pass)
        $display("[PASS] Zero-order: serial and parallel CRC match for byte 0x%02h -> CRC-8 = 0x%02h (expected 0x%02h)", TEST_BYTE, crc_serial[7:0], expected);
      else
        $display("[FAIL] Zero-order: serial=0x%02h parallel=0x%02h expected=0x%02h (serial_done=%b parallel_done=%b)", crc_serial[7:0], crc_parallel[7:0], expected, serial_done, parallel_done);
    end

    repeat (5) @(posedge clk);
    $finish;
  end

endmodule
