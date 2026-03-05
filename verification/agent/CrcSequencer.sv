// FILE: CrcSequencer.sv
// DESCRIPTION: UVM sequencer for CrcSeqItem.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcSequencer
class CrcSequencer extends uvm_sequencer #(CrcSeqItem);
  `uvm_component_utils(CrcSequencer)
  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction
endclass
