// FILE: CrcDriver.sv
// DESCRIPTION: Drives DUT per protocol: serial 1 bit/cycle LSB first, parallel 8 bits/cycle.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcDriver
// DESCRIPTION: Gets CrcSeqItem from sequencer; drives mode_serial, data_in, data_valid, start via vif.
class CrcDriver extends uvm_driver #(CrcSeqItem);
  virtual crc_if m_vif;
  CrcSeqItem     m_req;

  `uvm_component_utils(CrcDriver)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "m_vif", m_vif))
      `uvm_fatal("CFG", "CrcDriver: virtual interface not found")
  endfunction

  virtual task run_phase(uvm_phase phase);
    wait(m_vif.rst_n === 1);
    repeat(2) @(m_vif.cb);  // let DUT and bus settle after reset
    forever begin
      seq_item_port.get_next_item(m_req);
      drive_item(m_req);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(CrcSeqItem i_req);
    if (i_req.m_start) begin
      m_vif.cb.start <= 1;
      m_vif.cb.data_valid <= 0;
      @(m_vif.cb);
      m_vif.cb.start <= 0;
      @(m_vif.cb);
    end
    m_vif.cb.mode_serial <= i_req.m_mode_serial;
    for (int b = 0; b < i_req.m_data.size(); b++) begin
      if (i_req.m_mode_serial) begin
        for (int i = 0; i < 8; i++) begin
          m_vif.cb.data_in <= i_req.m_data[b][i];
          m_vif.cb.data_valid <= 1;
          @(m_vif.cb);
        end
        m_vif.cb.data_valid <= 0;
        @(m_vif.cb);
      end else begin
        m_vif.cb.data_in <= i_req.m_data[b];
        m_vif.cb.data_valid <= 1;
        @(m_vif.cb);
        m_vif.cb.data_valid <= 0;
        @(m_vif.cb);
      end
    end
  endtask
endclass
