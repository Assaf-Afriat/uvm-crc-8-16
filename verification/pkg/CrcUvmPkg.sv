// FILE: CrcUvmPkg.sv
// DESCRIPTION: CRC UVM package: agent, env, sequences, tests.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

package CrcUvmPkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "agent/CrcSeqItem.sv"
  `include "agent/CrcDriver.sv"
  `include "agent/CrcMonitor.sv"
  `include "agent/CrcSequencer.sv"
  `include "agent/CrcAgent.sv"
  `include "env/CrcConfig.sv"
  `include "env/CrcScoreboard.sv"
  `include "env/CrcCoverage.sv"
  `include "env/CrcEnv.sv"
  `include "sequences/CrcSequences.sv"
  `include "tests/CrcTests.sv"
endpackage
