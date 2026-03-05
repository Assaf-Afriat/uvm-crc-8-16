# CRC-8/16 UVM Verification

QuestaSim flow for the CRC DUT. See `../docs/VERIFICATION_PLAN.md` for architecture and test plan.

## Prerequisites

- QuestaSim (or ModelSim with UVM)
- **UVM:** If `UVM_HOME` is not set, the run scripts use the same fallback as **round-robin-arbiter**: `QUESTASIM_DIR` or `MTI_HOME`, then default `C:/questasim64_2025.1_2/verilog_src/uvm-1.1d`. UVM is compiled from source (no separate DPI lib).

## Test commands (copy-paste)

Run from the **verification** directory.

**Single test (default = CrcFullCoverageTest):**
```bash
cd verification
vsim -c -do run.do
```

**Single test by name (main top):**
```bash
cd verification
vsim -c -do run.do +UVM_TESTNAME=CrcSerialSmokeTest
vsim -c -do run.do +UVM_TESTNAME=CrcParallelSmokeTest
vsim -c -do run.do +UVM_TESTNAME=CrcSerialMultiByteTest
vsim -c -do run.do +UVM_TESTNAME=CrcParallelMultiByteTest
vsim -c -do run.do +UVM_TESTNAME=CrcResetStartTest
vsim -c -do run.do +UVM_TESTNAME=CrcPolyPresetTest
vsim -c -do run.do +UVM_TESTNAME=CrcWidthTest
vsim -c -do run.do +UVM_TESTNAME=CrcFullCoverageTest
vsim -c -do run.do +UVM_TESTNAME=CrcAllVariationsTest
vsim -c -do run.do +UVM_TESTNAME=CrcCornerInputsTest
```

**All variations (serial/parallel, lengths, data patterns):** `CrcAllVariationsTest` — uses **start=1** between variation groups to re-init the CRC (no hardware reset needed).

**Corner inputs (maximize data coverage):** `CrcCornerInputsTest` — directed corner cases (0x00, 0xFF, all-zero/all-one buffers, etc.); start=1 before each.

**Init/final XOR test (separate DUT build):**
```bash
cd verification
vsim -c -do run_init_final_xor.do
```
(Test name is fixed: `CrcInitFinalXorTest`.)

**CRC-16 build (R3/R4: width 16, poly 0x1021):**
```bash
cd verification
vsim -c -do run_crc16.do
```
Default test: `CrcWidthTestCrc16`. Override with `+UVM_TESTNAME=...` if needed.

**Full regression (main top + init_final_xor + CRC-16):**
```powershell
cd verification
.\run_regression.ps1
```

**Note:** Use `-c` for batch (no GUI). When running from scripts, use a **~15 s timeout** per run so the process doesn’t hang on errors.

**Scoreboard table (input / expected / actual / result):** The scoreboard prints a table for each comparison. To ensure it is visible, run with **`+UVM_VERBOSITY=UVM_LOW`** (e.g. `vsim -c -do run.do +UVM_VERBOSITY=UVM_LOW`). Many runs already show it at default verbosity.

## Run from verification directory (legacy)

```bash
cd verification
vsim -do run.do
```

Default test: `CrcFullCoverageTest`. To run another test, set `+UVM_TESTNAME=...` as above.

## Layout

- `tb/` — `crc_if.sv`, `tb_top.sv`, `tb_top_init_final_xor.sv`, `tb_top_crc16.sv` (CRC-16 build)
- `agent/` — driver, monitor, sequencer, agent, sequence item
- `env/` — config, scoreboard (with ref model), coverage, env
- `sequences/` — base and concrete sequences
- `tests/` — base test and test list from the plan
- `pkg/CrcUvmPkg.sv` — package that includes all UVM components
