# QuestaSim run script for CRC-16 build (DUT CRC_WIDTH=16, POLYNOMIAL=0x1021).
# Run from verification/: vsim -do run_crc16.do
# Default test: CrcWidthTestCrc16. Override with env UVM_TESTNAME or +UVM_TESTNAME=...

# UVM_HOME: same fallback as other run scripts
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

# Interface
vlog -sv -work work tb/crc_if.sv

# UVM from source
vlog -sv -work work +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv

# CRC UVM package
vlog -sv -work work +incdir+$UVM_HOME/src +incdir+. pkg/CrcUvmPkg.sv

# CRC-16 top
vlog -sv -work work +incdir+$UVM_HOME/src +incdir+. tb/tb_top_crc16.sv

# Run: use UVM_TESTNAME from env if set, else default CrcWidthTestCrc16
if {[info exists env(UVM_TESTNAME)] && $env(UVM_TESTNAME) != ""} {
  set TEST_NAME $env(UVM_TESTNAME)
} else {
  set TEST_NAME CrcWidthTestCrc16
}
vsim -voptargs=+acc -L mtiUvm work.tb_top_crc16 -sv_seed random +UVM_TESTNAME=$TEST_NAME
run -all
quit -f
