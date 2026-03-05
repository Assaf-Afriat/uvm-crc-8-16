// FILE: CrcSeqItem.sv
// DESCRIPTION: Sequence item for CRC stimulus: mode and stream of bytes (MSB first).
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcSeqItem
// DESCRIPTION: One transaction to drive: serial or parallel mode, and a list of bytes (first byte = MSB of message).
class CrcSeqItem extends uvm_sequence_item;
  rand bit         m_mode_serial;  // 1=serial, 0=parallel
  rand byte        m_data[];      // Bytes to send; m_data[0] = first (MSB of message)
  rand bit         m_start;       // Assert start before this item (re-init CRC)

  constraint C_LEN { m_data.size() inside {[1:32]}; }

  `uvm_object_utils_begin(CrcSeqItem)
    `uvm_field_int(m_mode_serial, UVM_ALL_ON)
    `uvm_field_array_int(m_data, UVM_ALL_ON)
    `uvm_field_int(m_start, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string i_name = "CrcSeqItem");
    super.new(i_name);
  endfunction
endclass

// CLASS: CrcResultTxn
// DESCRIPTION: Result from monitor: stream that was sent + CRC output when crc_valid.
class CrcResultTxn extends uvm_sequence_item;
  byte        m_data[];
  bit         m_mode_serial;
  logic [15:0] m_crc_out;

  `uvm_object_utils_begin(CrcResultTxn)
    `uvm_field_array_int(m_data, UVM_ALL_ON)
    `uvm_field_int(m_mode_serial, UVM_ALL_ON)
    `uvm_field_int(m_crc_out, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string i_name = "CrcResultTxn");
    super.new(i_name);
  endfunction
endclass
