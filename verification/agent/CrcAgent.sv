// FILE: CrcAgent.sv
// DESCRIPTION: CRC agent: driver, monitor, sequencer; vif from config_db.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcAgent
class CrcAgent extends uvm_agent;
  CrcDriver     m_driver;
  CrcMonitor    m_monitor;
  CrcSequencer  m_sequencer;

  `uvm_component_utils(CrcAgent)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_monitor   = CrcMonitor::type_id::create("m_monitor", this);
    m_sequencer = CrcSequencer::type_id::create("m_sequencer", this);
    m_driver    = CrcDriver::type_id::create("m_driver", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass
