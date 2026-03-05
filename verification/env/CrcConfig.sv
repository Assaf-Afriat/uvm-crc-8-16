// FILE: CrcConfig.sv
// DESCRIPTION: DUT/reference config: width, polynomial, init, final_xor.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcConfig
class CrcConfig extends uvm_object;
  int         m_crc_width;   // 8 or 16
  bit [15:0]  m_polynomial;
  bit [15:0]  m_init;
  bit [15:0]  m_final_xor;

  `uvm_object_utils_begin(CrcConfig)
    `uvm_field_int(m_crc_width, UVM_ALL_ON)
    `uvm_field_int(m_polynomial, UVM_ALL_ON)
    `uvm_field_int(m_init, UVM_ALL_ON)
    `uvm_field_int(m_final_xor, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string i_name = "CrcConfig");
    super.new(i_name);
  endfunction
endclass
