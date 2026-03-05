// FILE: CrcEnv.sv
// DESCRIPTION: Top env: agent, scoreboard, coverage; TLM connect in connect_phase.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcEnv
class CrcEnv extends uvm_env;
  CrcAgent      m_agent;
  CrcScoreboard m_sb;
  CrcCoverage   m_cov;

  `uvm_component_utils(CrcEnv)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent = CrcAgent::type_id::create("m_agent", this);
    m_sb    = CrcScoreboard::type_id::create("m_sb", this);
    m_cov   = CrcCoverage::type_id::create("m_cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agent.m_monitor.m_ap.connect(m_sb.m_export);
    m_agent.m_monitor.m_ap.connect(m_cov.m_export);
  endfunction
endclass
