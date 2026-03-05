# CRC-8/16 DUT — UVM Verification Master Plan

**Document:** VERIFICATION_PLAN.md  
**DUT:** crc_dut (configurable CRC-8/16, serial/parallel)  
**Date:** 2025-03-05  
**Status:** Ready for verification-engineer implementation  

---

## 1. Scope and goals

### Verification objectives

- Prove that the DUT computes the correct CRC for any valid input stream (serial or parallel) and any configured polynomial, init, and final XOR.
- Prove that reset and `start` correctly re-initialize state.
- Prove that both CRC-8 and CRC-16 configurations behave correctly (per requirements R1–R7).

### Sign-off criteria

- All requirements R1–R7 have at least one passing test and documented coverage path.
- Functional coverage: polynomial presets (at least CRC-8 0x07 and CRC-16 0x1021), serial vs parallel mode, and representative data patterns covered; coverage targets per section 4.
- No open P1/P2 bugs; any known limitations documented.
- Regression: all tests pass (user runs via simulator/scripts).

### Out of scope

- Gate-level or post-synthesis timing verification.
- Formal property verification (beyond any simple SVA in this plan).

---

## 2. Testbench architecture

### 2.1 Top / testbench

- **Top module:** `tb_top` or equivalent instantiates DUT, generates clock/reset, and instantiates the UVM env. Clock and reset driven from top (e.g. initial block or clocking block); sync reset per RTL.
- **DUT instance:** Single instance of `crc_dut` with parameters set via `uvm_config_db` or fixed in top for a given test (e.g. test selects CRC-8 or CRC-16 and passes POLYNOMIAL, INIT, FINAL_XOR). Recommendation: drive DUT parameters from test via config so one TB can run both CRC-8 and CRC-16 tests by reconfiguring the DUT or by having two top variants (e.g. `tb_top_crc8`, `tb_top_crc16`) if the tool flow requires it; otherwise one parameterized top with config_db for test-specific overrides where possible.

### 2.2 Agents and environment

- **Single agent (e.g. `CrcAgent`):** One agent for the DUT interface.
  - **Driver:** Drives `mode_serial`, `data_in`, `data_valid`, `start` per protocol (serial: 1 bit/cycle on `data_in[0]`; parallel: 8 bits/cycle; LSB first; first byte = MSB of message).
  - **Monitor:** Observes DUT inputs and outputs; emits transactions (input stream + output CRC when `crc_valid` is high). Captures: mode, data bytes/bits, and `crc_out` on `crc_valid`.
  - **Sequencer:** Standard UVM sequencer for sequences to drive stimulus.
- **Environment:** `CrcEnv` contains: CrcAgent, scoreboard (with reference model or reference model as separate component feeding scoreboard), and optional coverage collector. Build in `build_phase`; connect TLM in `connect_phase` per project guidelines.

### 2.3 TLM

- Monitor has **`uvm_analysis_port`** (e.g. `m_ap`) for both input and result transactions (or one transaction type that carries both).
- Scoreboard has **`uvm_analysis_imp`** (e.g. `m_export`) and subscribes to the monitor’s analysis port. Connect in `connect_phase`: `monitor.m_ap.connect(scoreboard.m_export)`.
- If coverage is in a separate subscriber, same pattern: coverage component has `uvm_analysis_imp`, connected to monitor’s analysis port (or a second port if needed).

### 2.4 Reference model

- **Location:** Inside the scoreboard (preferred) or as a separate UVM component that feeds the scoreboard.
- **Inputs:** Same as DUT: polynomial, init, final XOR, mode (serial/parallel), and the stream of data (bytes or bits). Reference model implements the same Galois CRC algorithm (LSB first, first byte = MSB of message) per RTL_NOTES.
- **Output:** Expected CRC when “message end” is indicated (e.g. when monitor reports `crc_valid` and the corresponding input stream). Scoreboard compares DUT `crc_out` (from monitor) with reference CRC; report match/mismatch. Use `crc_valid` timing: compare when monitor reports result one cycle after last `data_valid`.

### 2.5 Configuration

- Use **`uvm_config_db`** with wildcard path `"*"` when setting config for child components (per project UVM guidelines).
- Configurable items (set by test via config_db): at minimum **polynomial** (or preset: CRC-8 0x07, CRC-16 0x1021), **init**, **final_xor**, **crc_width** (8 or 16). Sequences retrieve config via `uvm_config_db` with `m_sequencer` and path `"*"` so they can drive the correct mode and data for the chosen config.
- DUT is RTL with parameters; TB cannot change RTL parameters at run time. So either: (1) one simulation build per configuration (e.g. CRC-8 build and CRC-16 build) and tests select config for that build, or (2) parameterized top with plusargs to select preset. Plan assumes (1) for simplicity: CRC-8 and CRC-16 are separate builds or separate test runs; tests in each build use the matching reference config.

### 2.6 Interfaces

- **Virtual interface or hierarchy:** Connect driver and monitor to DUT signals (clock, rst_n, mode_serial, data_in, data_valid, start, crc_out, crc_valid). Use a single DUT interface struct or individual signals; pass to agent via config_db. Clocking blocks optional; if used, align with 1-cycle-after timing for `crc_valid`.

---

## 3. Test plan

### 3.1 Test list

| Test name | Purpose | Req focus |
|-----------|---------|-----------|
| **CrcSerialSmokeTest** | Single-byte serial, CRC-8 poly 0x07, init 0. Sanity. | R1, R5 |
| **CrcParallelSmokeTest** | Single-byte parallel, CRC-8 poly 0x07, init 0. Sanity. | R2, R5 |
| **CrcSerialMultiByteTest** | Multiple bytes serial; constrained random length and data. | R1 |
| **CrcParallelMultiByteTest** | Multiple bytes parallel; constrained random length and data. | R2 |
| **CrcResetStartTest** | Reset and `start` during stream; verify re-init. | R5 |
| **CrcPolyPresetTest** | At least two polynomials (e.g. 0x07 and 0x1021 for CRC-16 build). | R4 |
| **CrcInitFinalXorTest** | Non-zero init and/or non-zero final XOR. | R6, R7 |
| **CrcWidthTest** | If both CRC-8 and CRC-16 builds exist, run width-specific tests. | R3 |

### 3.2 Base test

- **Base test** (`CrcBaseTest`): In `build_phase` set config (polynomial, init, final_xor, width) for the chosen preset; create env; set default sequence (e.g. a simple smoke sequence). Derived tests override default sequence and/or config to specialize.

### 3.3 Directed vs random

- **Directed:** Smoke tests use fixed vectors (e.g. 0xA5 as in zero-order). Reset/start test directs specific sequence of start/reset.
- **Random:** Multi-byte tests use constrained random length (e.g. 1–16 bytes) and data; reference model and scoreboard must match. Cover multiple polynomials and init/final XOR via directed or constrained random config.

### 3.4 Requirements mapping (high level)

- R1: CrcSerialSmokeTest, CrcSerialMultiByteTest.
- R2: CrcParallelSmokeTest, CrcParallelMultiByteTest.
- R3: CrcWidthTest / build selection.
- R4: CrcPolyPresetTest (and coverage on polynomial).
- R5: CrcResetStartTest, smoke tests.
- R6: CrcInitFinalXorTest (and coverage on init).
- R7: CrcInitFinalXorTest (and coverage on final XOR).

---

## 4. Coverage plan

### 4.1 Functional coverage

- **Where:** Coverage subscriber or component with `uvm_analysis_imp` connected to monitor’s analysis port (or in monitor if preferred; project guidelines apply).
- **Items:**
  - **Mode:** Serial vs parallel (at least two bins).
  - **Polynomial preset:** At least CRC-8 0x07; if CRC-16 build, 0x1021 (and any other presets).
  - **Init value:** Representative bins (e.g. 0, 0xFFFF, or 0/1 for CRC-8).
  - **Final XOR:** 0 vs non-zero (e.g. 0xFF for CRC-8).
  - **Data / length:** Byte count bins (e.g. 1, 2–4, 5–8, 9+); optional data value bins for corner cases (all 0, all 1, single bit set).
- **Requirements vs coverage:** R1/R2 closed by mode × data coverage; R4 by polynomial coverage; R5 by reset/start test; R6/R7 by init/final XOR coverage.

### 4.2 Coverage targets

- **Target:** 100% of defined bins hit for mode, polynomial preset, init, and final XOR; at least 90% of data/length bins or document waiver. (Adjust in open points if needed.)

### 4.3 Requirements traceability (coverage)

- R1: Coverage on serial mode + data.
- R2: Coverage on parallel mode + data.
- R3: Coverage on width (build or parameter).
- R4: Coverage on polynomial.
- R5: Test + coverage on reset/start.
- R6: Coverage on init.
- R7: Coverage on final XOR.

---

## 5. Requirements traceability

| Req | Test(s) | Coverage | Sign-off check |
|-----|--------|----------|-----------------|
| R1 | CrcSerialSmokeTest, CrcSerialMultiByteTest | Serial mode + data bins | Pass + bins hit |
| R2 | CrcParallelSmokeTest, CrcParallelMultiByteTest | Parallel mode + data bins | Pass + bins hit |
| R3 | CrcWidthTest / build | Width (8/16) | Pass for each width |
| R4 | CrcPolyPresetTest | Polynomial bins | Pass + poly bins hit |
| R5 | CrcResetStartTest, smoke tests | Reset/start scenario | Pass |
| R6 | CrcInitFinalXorTest | Init bins | Pass + bins hit |
| R7 | CrcInitFinalXorTest | Final XOR bins | Pass + bins hit |

---

## 6. Assertions

- **Optional:** In monitor or a small assertion block: (1) When `crc_valid` is high, `crc_out` is not X. (2) No combinational glitch requirements beyond what RTL guarantees.
- **Protocol:** If desired, simple SVA for “`crc_valid` high for exactly one cycle after last `data_valid`” (per design); can be waived if TB focuses on scoreboard comparison only. Plan leaves SVA as optional; verification-engineer can add minimal assertions if useful.

---

## 7. Run and regression

- **Simulator:** **QuestaSim.** Run scripts and instructions must target QuestaSim.
- **Test selection:** By test name (e.g. `+UVM_TESTNAME=CrcSerialSmokeTest`) or equivalent. Base test and default sequence set in base test; each test overrides as needed.
- **Regression:** Run all tests in the test list; user runs via `verification/run_regression.ps1` or individual `vsim -c -do run.do +UVM_TESTNAME=...`. See **verification/README.md** for copy-paste test commands.
- **Virtual sequence for coverage:** **CrcFullCoverageSeq** runs all main-top scenarios in one body (serial smoke, parallel smoke, multi-byte serial, multi-byte parallel, reset/start). Use **CrcFullCoverageTest** to run it; one simulation hits most functional coverage. **CrcInitFinalXorTest** still requires the separate top (`run_init_final_xor.do`) and is not included in that sequence.
- **CRC-16 build (R3, R4):** **tb_top_crc16.sv** instantiates DUT with `CRC_WIDTH=16`, `POLYNOMIAL=16'h1021`. Run via **run_crc16.do**; default test **CrcWidthTestCrc16** sets config (width 16, poly 0x1021) to match. Regression includes this run.
- **Directory layout (confirmed):**
  - All verification under **`verification/`**; one folder per major component.
  - `verification/agent/` — **Driver, monitor, and sequencer** (all three in this folder).
  - `verification/pkg/` — Package(s) for UVM components.
  - `verification/sequences/` — Base and concrete sequences.
  - `verification/tests/` — Base test and test classes.
  - `verification/tb/` or `verification/env/` etc. as needed for top, env, scoreboard, coverage — one folder per major component.

---

## 8. Open points / assumptions

### Assumptions

- DUT parameters (CRC_WIDTH, POLYNOMIAL, INIT, FINAL_XOR) are fixed per simulation build; tests in that build use the same DUT config. CRC-8 and CRC-16 are covered by separate builds or two top configurations.
- Single clock; sync reset; no backpressure (DUT always accepts when `data_valid` is high).
- Reference model algorithm matches RTL: Galois LFSR, LSB first, first byte = MSB of message, same polynomial/init/final XOR.

### Decisions (resolved)

| # | Question | Decision |
|---|----------|----------|
| 1 | Simulator | **QuestaSim** |
| 2 | Coverage target | **Keep:** 100% bins for mode/poly/init/final XOR; ≥90% for data/length (or document waiver). |
| 3 | Layout | **Verification under `verification/`;** one folder per major component; **agent folder contains monitor, driver, and sequencer.** |

---

**Plan complete.** Hand off to **verification-engineer** to implement the TB, sequences, tests, reference model, scoreboard, and coverage per this plan. After implementation, invoke **dut-doc-keeper** to update README and CHANGELOG.
