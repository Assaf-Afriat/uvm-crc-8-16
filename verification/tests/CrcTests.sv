// FILE: CrcTests.sv
// DESCRIPTION: Base test and concrete tests per verification plan.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// BASE TEST: set config, create env, set default sequence (smoke).
class CrcBaseTest extends uvm_test;
  CrcEnv    m_env;
  CrcConfig m_cfg;

  `uvm_component_utils(CrcBaseTest)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = CrcConfig::type_id::create("m_cfg");
    m_cfg.m_crc_width  = 8;
    m_cfg.m_polynomial = 16'h0007;
    m_cfg.m_init       = 16'h0000;
    m_cfg.m_final_xor  = 16'h0000;
    uvm_config_db#(CrcConfig)::set(this, "*", "m_cfg", m_cfg);
    m_env = CrcEnv::type_id::create("m_env", this);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcSerialSmokeSeq::type_id::get());
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #10000;  // allow default sequence to complete
    phase.drop_objection(this);
  endtask

  virtual function void report_phase(uvm_phase phase);
    if (m_env.m_sb.m_mismatch > 0)
      `uvm_error("TEST", $sformatf("Scoreboard had %0d mismatch(es)", m_env.m_sb.m_mismatch))
  endfunction
endclass

// --- Serial smoke: one byte 0xA5 serial
class CrcSerialSmokeTest extends CrcBaseTest;
  `uvm_component_utils(CrcSerialSmokeTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcSerialSmokeSeq::type_id::get());
  endfunction
endclass

// --- Parallel smoke: one byte 0xA5 parallel
class CrcParallelSmokeTest extends CrcBaseTest;
  `uvm_component_utils(CrcParallelSmokeTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcParallelSmokeSeq::type_id::get());
  endfunction
endclass

// --- Serial multi-byte: random 1-16 bytes
class CrcSerialMultiByteTest extends CrcBaseTest;
  `uvm_component_utils(CrcSerialMultiByteTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcEmptySeq::type_id::get());
  endfunction
  virtual task run_phase(uvm_phase phase);
    CrcMultiByteSeq seq;
    seq = CrcMultiByteSeq::type_id::create("seq");
    seq.m_serial = 1;
    phase.raise_objection(this);
    seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass

// --- Parallel multi-byte
class CrcParallelMultiByteTest extends CrcBaseTest;
  `uvm_component_utils(CrcParallelMultiByteTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcEmptySeq::type_id::get());
  endfunction
  virtual task run_phase(uvm_phase phase);
    CrcMultiByteSeq seq;
    seq = CrcMultiByteSeq::type_id::create("seq");
    seq.m_serial = 0;
    phase.raise_objection(this);
    seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass

// --- Reset/start
class CrcResetStartTest extends CrcBaseTest;
  `uvm_component_utils(CrcResetStartTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcResetStartSeq::type_id::get());
  endfunction
endclass

// --- Poly preset (same config as base; DUT build must match)
class CrcPolyPresetTest extends CrcBaseTest;
  `uvm_component_utils(CrcPolyPresetTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcParallelSmokeSeq::type_id::get());
  endfunction
endclass

// --- Init and final XOR (test sets non-zero; DUT build must use same)
class CrcInitFinalXorTest extends CrcBaseTest;
  `uvm_component_utils(CrcInitFinalXorTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg.m_init      = 16'h00FF;
    m_cfg.m_final_xor = 16'h00FF;
    uvm_config_db#(CrcConfig)::set(this, "*", "m_cfg", m_cfg);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcInitFinalXorSeq::type_id::get());
  endfunction
endclass


// --- Width: CRC-8 on main top (config stays default 8, 0x07)
class CrcWidthTest extends CrcBaseTest;
  `uvm_component_utils(CrcWidthTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcParallelSmokeSeq::type_id::get());
  endfunction
endclass

// --- CRC-16 build only: run on tb_top_crc16 (run_crc16.do). Config width=16, poly=0x1021 to match DUT.
class CrcWidthTestCrc16 extends CrcBaseTest;
  `uvm_component_utils(CrcWidthTestCrc16)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg.m_crc_width  = 16;
    m_cfg.m_polynomial = 16'h1021;
    m_cfg.m_init       = 16'h0000;
    m_cfg.m_final_xor  = 16'h0000;
    uvm_config_db#(CrcConfig)::set(this, "*", "m_cfg", m_cfg);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcParallelSmokeSeq::type_id::get());
  endfunction
endclass

// --- Full coverage (virtual sequence: serial + parallel smoke, multi-byte serial/parallel, reset/start)
// Runs 28 packets; sequence started explicitly so all complete (no fixed delay).
class CrcFullCoverageTest extends CrcBaseTest;
  `uvm_component_utils(CrcFullCoverageTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcEmptySeq::type_id::get());
  endfunction
  virtual task run_phase(uvm_phase phase);
    CrcFullCoverageSeq seq;
    phase.raise_objection(this);
    seq = CrcFullCoverageSeq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);  // blocks until all 28 items done
    phase.drop_objection(this);
  endtask
endclass

// --- All variations: serial/parallel, 1/2/4/8 byte, all-zero/all-one/mixed, random. Uses start=1 between groups (re-init, no hw reset).
class CrcAllVariationsTest extends CrcBaseTest;
  `uvm_component_utils(CrcAllVariationsTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcEmptySeq::type_id::get());
  endfunction
  virtual task run_phase(uvm_phase phase);
    CrcAllVariationsSeq seq;
    phase.raise_objection(this);
    seq = CrcAllVariationsSeq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass

// --- Corner inputs: directed corner-case data (0x00, 0xFF, 0x01, 0x80, all-zero/all-one buffers, etc.). start=1 before each.
class CrcCornerInputsTest extends CrcBaseTest;
  `uvm_component_utils(CrcCornerInputsTest)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_agent.m_sequencer.run_phase", "default_sequence", CrcEmptySeq::type_id::get());
  endfunction
  virtual task run_phase(uvm_phase phase);
    CrcCornerInputsSeq seq;
    phase.raise_objection(this);
    seq = CrcCornerInputsSeq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass
