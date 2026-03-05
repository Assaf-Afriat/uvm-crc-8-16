// FILE: CrcMonitor.sv
// DESCRIPTION: Observes DUT; on crc_valid writes CrcResultTxn (stream + crc_out) to analysis port.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcMonitor
// DESCRIPTION: Samples DUT; collects bytes when data_valid; on crc_valid emits CrcResultTxn.
class CrcMonitor extends uvm_monitor;
  virtual crc_if m_vif;
  uvm_analysis_port #(CrcResultTxn) m_ap;
  byte             m_byte_q[$];
  bit              m_mode_serial;
  `uvm_component_utils(CrcMonitor)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_ap = new("m_ap", this);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "m_vif", m_vif))
      `uvm_fatal("CFG", "CrcMonitor: virtual interface not found")
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever collect_result();
  endtask

  task collect_result();
    CrcResultTxn txn;
    bit          m_bit_q[$];
    m_byte_q.delete();
    wait(m_vif.rst_n === 1);
    forever begin
      @(negedge m_vif.clk);  // sample after posedge so driver/DUT updates are visible
      if (m_vif.start) m_byte_q.delete();
      // Emit on crc_valid before pushing new data so crc_out matches current stream
      if (m_vif.crc_valid && m_byte_q.size() > 0) begin
        txn = CrcResultTxn::type_id::create("txn");
        txn.m_data = new[m_byte_q.size()];
        for (int i = 0; i < m_byte_q.size(); i++) txn.m_data[i] = m_byte_q[i];
        txn.m_mode_serial = m_mode_serial;
        txn.m_crc_out = m_vif.crc_out;
        m_ap.write(txn);
      end
      if (m_vif.data_valid) begin
        if (m_byte_q.size() == 0) m_mode_serial = m_vif.mode_serial;
        if (m_vif.mode_serial) begin
          m_bit_q.push_back(m_vif.data_in[0]);
          if (m_bit_q.size() == 8) begin
            byte b;
            for (int i = 0; i < 8; i++) b[i] = m_bit_q[i];
            m_byte_q.push_back(b);
            m_bit_q.delete();
          end
        end else
          m_byte_q.push_back(m_vif.data_in);
      end
    end
  endtask
endclass
