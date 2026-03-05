# QuestaSim run script for CrcInitFinalXorTest (DUT INIT=0x00FF, FINAL_XOR=0x00FF).
# Run from verification/: vsim -do run_init_final_xor.do

# UVM_HOME: same fallback as round-robin-arbiter
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

# Top with INIT/FINAL_XOR params for this test
vlog -sv -work work +incdir+$UVM_HOME/src +incdir+. tb/tb_top_init_final_xor.sv

# Run CrcInitFinalXorTest. -L mtiUvm loads DPI for +UVM_TESTNAME.
vsim -voptargs=+acc -L mtiUvm work.tb_top_init_final_xor -sv_seed random +UVM_TESTNAME=CrcInitFinalXorTest
run -all
quit -f
