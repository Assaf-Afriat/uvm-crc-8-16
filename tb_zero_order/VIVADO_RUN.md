# Zero-Order Test — Run in Vivado

**Purpose:** Confirm the CRC DUT operates: one serial and one parallel run; pass = same CRC for the same byte and `crc_valid` timing correct.

---

## Pass/fail criterion

- **PASS:** Console prints `[PASS] Zero-order: serial and parallel CRC match for byte 0xA5 -> CRC-8 = 0xXX`.
- **FAIL:** Console prints `[FAIL] ...` or simulation errors. Fix RTL or TB and re-run.

You approve the zero-order test when you see **PASS** in Vivado and are satisfied with the run.

---

## Files to add in Vivado

| Order | Path (relative to project) | Type |
|-------|----------------------------|------|
| 1 | `../rtl/crc_dut.sv` | Design source |
| 2 | `tb_crc_zero_order.sv` | Simulation source (testbench) |

---

## Steps in Vivado

1. **Create project** (if new)
   - Project type: RTL Project; do not specify sources yet.
   - Part: choose your FPGA (e.g. xc7a35t for Artix-7) or “Don’t specify” for sim-only.
   - Add design source: `rtl/crc_dut.sv`.
   - Add simulation source: `tb_zero_order/tb_crc_zero_order.sv`.

2. **Set top for simulation**
   - In Sources, right-click `tb_crc_zero_order` → **Set as Top** (for simulation).
   - Or: Flow Navigator → Simulation → Simulation Settings → set Simulation top to `tb_crc_zero_order`.

3. **Run simulation**
   - Flow Navigator → **Simulation** → **Run Simulation** → **Run Behavioral Simulation**.
   - Wait for run to finish (testbench calls `$finish`).

4. **Check result**
   - In Tcl Console or transcript, look for:
     - `[PASS] Zero-order: serial and parallel CRC match for byte 0xA5 -> CRC-8 = 0xXX`
   - If you see `[PASS]`, the zero-order test is **approved**; you can proceed to full verification.

---

## If using a project under `crc-8-16` on disk

- Add design source: `DUTs/crc-8-16/rtl/crc_dut.sv`.
- Add simulation source: `DUTs/crc-8-16/tb_zero_order/tb_crc_zero_order.sv`.
- Simulation top: `tb_crc_zero_order`.

---

## What was exercised

- Sync reset; then serial mode: 8 bits (one byte `0xA5` LSB first), `crc_valid` one cycle after last bit.
- New CRC via `start`; then parallel mode: one byte `0xA5`, `crc_valid` one cycle after.
- Pass = same CRC-8 value for both runs (serial and parallel produce the same result for the same byte).

Full verification (UVM, coverage, all requirements) runs under **`../verification/`** — see `../verification/README.md` for run commands and regression (12 tests, three builds: main CRC-8, init/final XOR, CRC-16).
