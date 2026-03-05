// FILE: CrcCoverage.sv
// DESCRIPTION: Coverage subscriber; samples mode, byte count, config from CrcResultTxn + config.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcCoverage
// DESCRIPTION: uvm_analysis_imp on monitor port; covers mode, data length, poly/init/final_xor per plan.
class CrcCoverage extends uvm_component;
  uvm_analysis_imp #(CrcResultTxn, CrcCoverage) m_export;
  CrcConfig m_cfg;
  bit       m_mode_serial;
  int       m_len;
  bit [15:0] m_poly, m_init, m_fx;

  covergroup CrcCg;
    option.per_instance = 1;
    cp_mode: coverpoint m_mode_serial { bins serial = {1}; bins parallel = {0}; }
    cp_len:  coverpoint m_len { bins one = {1}; bins few = {[2:4]}; bins many = {[5:16]}; }
    cp_poly: coverpoint m_poly { bins crc8  = {16'h0007}; bins crc16 = {16'h1021}; }
    cp_init: coverpoint m_init { bins zero = {0}; bins non_zero = {[1:65535]}; }
    cp_fx:   coverpoint m_fx   { bins zero = {0}; bins non_zero = {[1:65535]}; }
  endgroup

  `uvm_component_utils(CrcCoverage)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
    CrcCg = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_export = new("m_export", this);
    if (!uvm_config_db#(CrcConfig)::get(this, "", "m_cfg", m_cfg) || m_cfg == null)
      `uvm_fatal("CFG", "CrcCoverage: CrcConfig not found")
  endfunction

  virtual function void write(CrcResultTxn txn);
    m_mode_serial = txn.m_mode_serial;
    m_len = txn.m_data.size();
    m_poly = m_cfg.m_polynomial;
    m_init = m_cfg.m_init;
    m_fx   = m_cfg.m_final_xor;
    CrcCg.sample();
  endfunction
endclass
