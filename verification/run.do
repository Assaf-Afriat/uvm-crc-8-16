# QuestaSim run script for CRC UVM TB.
# Run from verification/: vsim -do run.do
# Or from project root: vsim -do verification/run.do

# UVM_HOME: same fallback as round-robin-arbiter (env, then Questa/MTI paths, then default)
if {[info exists env(UVM_HOME)] && $env(UVM_HOME) != ""} {
  set UVM_HOME $env(UVM_HOME)
} elseif {[info exists env(QUESTASIM_DIR)]} {
  set UVM_HOME "$env(QUESTASIM_DIR)/../verilog_src/uvm-1.1d"
} elseif {[info exists env(MTI_HOME)]} {
  set UVM_HOME "$env(MTI_HOME)/verilog_src/uvm-1.1d"
} else {
  set UVM_HOME "C:/questasim64_2025.1_2/verilog_src/uvm-1.1d"
}

if {[file exists work]} { vdel -all }
vlib work

# RTL
vlog -sv -work work ../rtl/crc_dut.sv

# Interface (no UVM)
vlog -sv -work work tb/crc_if.sv

# UVM from source (like round-robin-arbiter run_uvm.do)
vlog -sv -work work +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv

# CRC UVM package (includes run from verification/, so +incdir+.)
vlog -sv -work work +incdir+$UVM_HOME/src +incdir+. pkg/CrcUvmPkg.sv

# Top
vlog -sv -work work +incdir+$UVM_HOME/src +incdir+. tb/tb_top.sv

# Run: use UVM_TESTNAME from env if set (for regression), else default = full verification (28 packets).
if {[info exists env(UVM_TESTNAME)] && $env(UVM_TESTNAME) != ""} {
  set TEST_NAME $env(UVM_TESTNAME)
} else {
  set TEST_NAME CrcFullCoverageTest
}
vsim -voptargs=+acc -L mtiUvm work.tb_top -sv_seed random +UVM_TESTNAME=$TEST_NAME
run -all
quit -f
