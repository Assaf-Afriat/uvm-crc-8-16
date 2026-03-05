# UVM CRC-8/16

Configurable CRC-8/16 RTL with full UVM verification (SystemVerilog, QuestaSim). Serial and parallel modes; configurable polynomial, init, and final XOR.

---

## Demo

**[View verification demo](demo/index.html)** — Spec → Plan → Results in one page. Open the link in a browser (clone the repo and open `demo/index.html` locally, or enable **GitHub Pages**: Settings → Pages → Deploy from branch `main`, root).

---

## Flow: Spec → Planning → Results

| Stage | Doc | Content |
|-------|-----|---------|
| **Spec** | [REQUIREMENTS.md](docs/REQUIREMENTS.md) | DUT requirements (R1–R7), interface, protocol |
| **Planning** | [VERIFICATION_PLAN.md](docs/VERIFICATION_PLAN.md) | UVM testbench plan, test list, coverage, traceability |
| **Results** | [VERIFICATION_RESULTS_AND_SIGNOFF.md](docs/VERIFICATION_RESULTS_AND_SIGNOFF.md) | 12/12 tests pass, coverage, sign-off |

- **RTL:** [rtl/crc_dut.sv](rtl/crc_dut.sv) · [RTL_NOTES.md](docs/RTL_NOTES.md)  
- **Run:** [verification/README.md](verification/README.md) — QuestaSim, `run_regression.ps1` (12 tests, 3 builds).

---

## Skills used

| Skill / method | Use |
|----------------|-----|
| **dut-architect** | Spec (REQUIREMENTS.md) |
| **rtl-designer** | DUT (crc_dut.sv) |
| **verification-architect** | VERIFICATION_PLAN.md |
| **verification-engineer** | UVM TB, 12 tests, regression |
| **html-demo-dut** | [demo/index.html](demo/index.html) (Spec → Plan → Results) |
| **Reference model** | CrcScoreboard.ref_crc(); TLM, coverage, multi-build |

---

## Layout

```
├── demo/index.html          # Verification demo (spec → plan → results)
├── docs/                    # REQUIREMENTS, VERIFICATION_PLAN, VERIFICATION_RESULTS_AND_SIGNOFF, RTL_NOTES
├── rtl/crc_dut.sv           # DUT
├── tb_zero_order/           # Zero-order test (Vivado)
└── verification/            # UVM TB, run.do, run_regression.ps1, agent/env/sequences/tests
```
