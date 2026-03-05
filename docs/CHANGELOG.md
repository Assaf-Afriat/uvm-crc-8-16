# Changelog — CRC-8/16 DUT

All notable changes to RTL, testbench, and docs are recorded here. Newest first.

---

## 2025-03-06 — Verification results and sign-off document

**What changed**
- Added docs/VERIFICATION_RESULTS_AND_SIGNOFF.md: full verification results, CRC mechanic and use, plan alignment, test list and requirements traceability, functional coverage (code + bins hit), code coverage note, skills used, highlights, and sign-off with criteria checklist.

**Files touched**
- docs/VERIFICATION_RESULTS_AND_SIGNOFF.md (new)

**Reason**
- Document verification outcome and formal sign-off per verification plan.

---

## 2025-03-06 — Doc sync (dut-doc-keeper): README, REQUIREMENTS, VIVADO_RUN

**What changed**
- README: Pipeline step 5 note clarified with three build names (tb_top.sv, tb_top_init_final_xor.sv, tb_top_crc16.sv) and run_regression.ps1.
- REQUIREMENTS: Next steps updated to mark RTL, zero-order, full verification Done; next = doc/sign-off.
- tb_zero_order/VIVADO_RUN.md: Added pointer to verification/README.md for full UVM runs and regression.

**Files touched**
- README.md, docs/REQUIREMENTS.md, tb_zero_order/VIVADO_RUN.md

**Reason**
- Keep project docs consistent with current RTL and verification state.

---

## 2025-03-05 — Full verification complete; CRC-16 build; regression 12 tests

**What changed**
- UVM TB: agent (driver, monitor, sequencer), env, scoreboard with reference model, coverage. Sequences and tests per VERIFICATION_PLAN (smoke, multi-byte, reset/start, init/final XOR, full coverage, all variations, corner inputs).
- Three DUT builds: main (CRC-8, poly 0x07), init_final_xor (CRC-8, init/final 0xFF), CRC-16 (width 16, poly 0x1021). Run via run.do, run_init_final_xor.do, run_crc16.do.
- Regression: run_regression.ps1 runs 12 tests (10 on main top + CrcInitFinalXorTest + CrcWidthTestCrc16). All pass.
- Scoreboard: table-style results + summary (round-robin style). README and VERIFICATION_PLAN updated.

**Files touched**
- verification/ (agent, env, sequences, tests, tb, pkg), run scripts, run_regression.ps1
- tb/tb_top_crc16.sv, run_crc16.do, CrcWidthTestCrc16
- README.md (pipeline step 5 Done; next = doc/sign-off)

**Reason**
- Verification-engineer implementation per plan; R3/R4 covered by CRC-16 build.

---

## 2025-03-05 — UVM verification master plan (decisions locked)

**What changed**
- VERIFICATION_PLAN.md: Locked simulator = QuestaSim; coverage target = keep (100% / ≥90%); layout = verification under verification/, one folder per major component, agent folder contains monitor + driver + sequencer.
- Earlier: Added full plan (TB architecture, test plan, coverage, requirements traceability, run/regression).

**Files touched**
- docs/VERIFICATION_PLAN.md (new)
- README.md (plan link, pipeline step 4)

**Reason**
- verification-architect step: plan before implementation.

---

## 2025-03-05 — Zero-order test passing; RTL and TB fixes

**What changed**
- RTL: `crc_valid` registered; next state computed inside `always_ff` (XSim fix). DUT init block for clean sim.
- Zero-order TB: sampling at negedge + #1; reference CRC and expected check; PASS requires match to 0x72 for 0xA5.

**Files touched**
- `rtl/crc_dut.sv`
- `tb_zero_order/tb_crc_zero_order.sv`

**Reason**
- Reliable sampling in Vivado/XSim; correct full-byte CRC capture; pass/fail vs reference.

---

*(Add new entries above this line.)*
