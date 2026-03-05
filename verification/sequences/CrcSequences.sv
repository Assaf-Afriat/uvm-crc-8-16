// FILE: CrcSequences.sv
// DESCRIPTION: Base and concrete sequences for CRC stimulus.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// BASE SEQUENCE
class CrcBaseSeq extends uvm_sequence #(CrcSeqItem);
  `uvm_object_utils(CrcBaseSeq)
  function new(string i_name = "CrcBaseSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    // Override in derived sequences
  endtask
endclass

// Empty sequence (for tests that start sequence manually in run_phase)
class CrcEmptySeq extends CrcBaseSeq;
  `uvm_object_utils(CrcEmptySeq)
  function new(string i_name = "CrcEmptySeq");
    super.new(i_name);
  endfunction
  virtual task body();
    // no items
  endtask
endclass

// Single byte 0xA5, serial mode (smoke)
class CrcSerialSmokeSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcSerialSmokeSeq)
  function new(string i_name = "CrcSerialSmokeSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
  endtask
endclass

// Single byte 0xA5, parallel mode (smoke)
class CrcParallelSmokeSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcParallelSmokeSeq)
  function new(string i_name = "CrcParallelSmokeSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
  endtask
endclass

// Multi-byte random: 1-16 bytes, random data. Repeats m_num_items times (default 16) for full verification.
class CrcMultiByteSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcMultiByteSeq)
  bit m_serial;       // 1=serial, 0=parallel
  int m_num_items = 16;  // number of back-to-back transactions
  function new(string i_name = "CrcMultiByteSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    for (int k = 0; k < m_num_items; k++)
      `uvm_do_with(it, { it.m_mode_serial == m_serial; it.m_start == 0; })
  endtask
endclass

// Reset/start: one item with start=1, then data
class CrcResetStartSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcResetStartSeq)
  function new(string i_name = "CrcResetStartSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    // First transfer with start
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 1; })
    // Second without start (continues from same config)
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
  endtask
endclass

// Init/final XOR: directed data with non-zero init/final_xor (config set by test)
class CrcInitFinalXorSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcInitFinalXorSeq)
  function new(string i_name = "CrcInitFinalXorSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h01; it.m_start == 1; })
  endtask
endclass

// Virtual sequence: runs all main-top scenarios with many packets for full functional coverage.
// Use with CrcFullCoverageTest. (CrcInitFinalXorTest requires a separate top/run.)
class CrcFullCoverageSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcFullCoverageSeq)
  function new(string i_name = "CrcFullCoverageSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    `uvm_info("SEQ", "CrcFullCoverageSeq: running 28 transactions (1 serial smoke + 1 parallel smoke + 12 serial multi + 12 parallel multi + 2 reset/start)", UVM_LOW)
    // Serial smoke (1)
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
    // Parallel smoke (1)
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
    // Multi-byte serial: 12 random-length items
    for (int k = 0; k < 12; k++)
      `uvm_do_with(it, { it.m_mode_serial == 1; it.m_start == 0; })
    // Multi-byte parallel: 12 random-length items
    for (int k = 0; k < 12; k++)
      `uvm_do_with(it, { it.m_mode_serial == 0; it.m_start == 0; })
    // Reset/start: start then continue (2)
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
  endtask
endclass

// All CRC variations on same DUT build. Uses start=1 (re-init) between variation groups so no hardware reset needed.
// Covers: serial/parallel, 1/2/4/8/16 byte, all-zero/all-one/mixed data, random multi-byte.
class CrcAllVariationsSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcAllVariationsSeq)
  function new(string i_name = "CrcAllVariationsSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    `uvm_info("SEQ", "CrcAllVariationsSeq: testing all variations; start=1 used between groups to re-init CRC", UVM_LOW)
    // --- Serial: single-byte variations (start=1 re-inits before each)
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'h01; it.m_start == 1; })
    // --- Serial: 2-byte
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'hFF; it.m_data[1] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h01; it.m_start == 1; })
    // --- Serial: random multi-byte (4 items, start before first only)
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_start == 1; })
    repeat (3) `uvm_do_with(it, { it.m_mode_serial == 1; it.m_start == 0; })
    // --- Parallel: single-byte variations
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 1; })
    // --- Parallel: 2-, 4-, 8-byte
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h01; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 4; it.m_data[0] == 8'h00; it.m_data[1] == 8'h00; it.m_data[2] == 8'h00; it.m_data[3] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 4; it.m_data[0] == 8'hFF; it.m_data[1] == 8'hFF; it.m_data[2] == 8'hFF; it.m_data[3] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 8; it.m_data[0] == 8'hAA; it.m_data[1] == 8'h55; it.m_data[2] == 8'hAA; it.m_data[3] == 8'h55; it.m_data[4] == 8'hAA; it.m_data[5] == 8'h55; it.m_data[6] == 8'hAA; it.m_data[7] == 8'h55; it.m_start == 1; })
    // --- Parallel: random multi-byte (4 items)
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_start == 1; })
    repeat (3) `uvm_do_with(it, { it.m_mode_serial == 0; it.m_start == 0; })
    // --- Reset/start behavior: start then continue without start
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 0; })
  endtask
endclass

// Corner-case and stress inputs; start=1 before each to get clean CRC state. Maximizes coverage on data patterns.
class CrcCornerInputsSeq extends CrcBaseSeq;
  `uvm_object_utils(CrcCornerInputsSeq)
  function new(string i_name = "CrcCornerInputsSeq");
    super.new(i_name);
  endfunction
  virtual task body();
    CrcSeqItem it;
    `uvm_info("SEQ", "CrcCornerInputsSeq: corner inputs (start=1 before each); serial and parallel", UVM_LOW)
    // Serial: single-byte corners
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'h01; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'h80; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 1; it.m_data[0] == 8'hA5; it.m_start == 1; })
    // Serial: 2-byte corners
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'hFF; it.m_data[1] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h01; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'h01; it.m_data[1] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 2; it.m_data[0] == 8'hAA; it.m_data[1] == 8'h55; it.m_start == 1; })
    // Serial: 4-byte all-zero, all-one
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 4; it.m_data[0] == 8'h00; it.m_data[1] == 8'h00; it.m_data[2] == 8'h00; it.m_data[3] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 1; it.m_data.size() == 4; it.m_data[0] == 8'hFF; it.m_data[1] == 8'hFF; it.m_data[2] == 8'hFF; it.m_data[3] == 8'hFF; it.m_start == 1; })
    // Parallel: same single-byte corners
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'hFF; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'h01; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 1; it.m_data[0] == 8'h80; it.m_start == 1; })
    // Parallel: 2- and 4-byte corners
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 2; it.m_data[0] == 8'h00; it.m_data[1] == 8'h01; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 4; it.m_data[0] == 8'h00; it.m_data[1] == 8'h00; it.m_data[2] == 8'h00; it.m_data[3] == 8'h00; it.m_start == 1; })
    `uvm_do_with(it, { it.m_mode_serial == 0; it.m_data.size() == 4; it.m_data[0] == 8'hFF; it.m_data[1] == 8'hFF; it.m_data[2] == 8'hFF; it.m_data[3] == 8'hFF; it.m_start == 1; })
    // Random-length items with start to hit various lengths (1..32 bytes)
    repeat (8) `uvm_do_with(it, { it.m_start == 1; })
  endtask
endclass
