# CRC-8 / CRC-16 DUT — Requirements & Interface Spec

**Document:** REQUIREMENTS.md  
**DUT idea:** Configurable polynomial; serial or parallel. Reference model, polynomial coverage.  
**Complexity:** Low–Med  
**Date:** 2025-03-05  

---

## Summary

The DUT is a configurable CRC (Cyclic Redundancy Check) block that supports **CRC-8** or **CRC-16** with a **configurable polynomial**. It can operate in **serial** mode (1 bit per cycle) or **parallel** mode (e.g. 8 bits per cycle). For any given polynomial, init value, and input stream, the DUT computes the CRC remainder. A reference model (e.g. in the scoreboard) will compute the expected CRC for the same inputs; verification compares DUT output to the reference. Coverage will include multiple polynomials and serial vs parallel modes.

---

## Requirements (testable)

| ID | Requirement |
|----|-------------|
| R1 | For a given polynomial and init value, **serial mode** produces the same CRC as the reference algorithm for any input bit sequence. |
| R2 | For a given polynomial and init value, **parallel mode** (e.g. 8-bit data per cycle) produces the same CRC as the reference for any input byte/word sequence. |
| R3 | **CRC width** is 8 or 16 bits (parameter or mode). |
| R4 | **Polynomial** is configurable (e.g. parameter or register); at least two presets supported (e.g. CRC-8 polynomial, CRC-16-CCITT). |
| R5 | **Reset** clears internal state; after reset, the next computation uses the configured init value. |
| R6 | **Init value** is configurable (e.g. 0 for CRC-8, 0xFFFF for some CRC-16). |
| R7 | Optional: **Final XOR** (e.g. 0 or 0xFF/0xFFFF) configurable for standard compliance. |

---

## Interface

### Clock and reset

| Signal | Dir | Width | Description |
|--------|-----|-------|-------------|
| `clk` | in | 1 | System clock. |
| `rst_n` | in | 1 | Active-low **synchronous** reset. |

### Configuration (design-time or runtime)

- **CRC_WIDTH**: 8 or 16 (parameter).
- **POLYNOMIAL**: configurable (parameter or register), e.g. CRC-8 = 0x07, CRC-16-CCITT = 0x1021.
- **INIT**: init value (e.g. 0 or 0xFFFF).
- **FINAL_XOR**: optional; 0 or 0xFF/0xFFFF.

### Data path (conceptual; exact names TBD in RTL)

| Signal | Dir | Width | Description |
|--------|-----|-------|-------------|
| `mode_serial` | in | 1 | 1 = serial (1 bit/cycle), 0 = parallel (e.g. 8 bits/cycle). |
| `data_in` | in | 1 (serial) or 8 (parallel) | Input data; meaning per mode. |
| `data_valid` | in | 1 | Input valid; DUT consumes data this cycle. |
| `start` | in | 1 | Start new CRC (reload init, clear state); also new CRC on reset. |
| `crc_out` | out | 8 or 16 | CRC result. |
| `crc_valid` | out | 1 | CRC result valid **1 cycle after** last `data_valid` (reasonable DUT timing). |

### Protocol notes

- **Serial**: One bit per cycle on `data_in[0]` when `data_valid=1`. **LSB first** (industry common: e.g. USB CRC, many serial CRC standards).
- **Parallel**: One byte per cycle when `data_valid=1`. **First byte = MSB of message** (industry common for packet/network-style CRC).
- **Backpressure**: DUT always accepts when `data_valid=1` (no ready signal).

---

## Block diagram / data flow

```
                    +------------------+
  clk, rst_n        |                  |
  mode_serial  ---->|   CRC-8/16       |----> crc_out
  data_in      ---->|   (configurable  |----> crc_valid
  data_valid   ---->|    polynomial)   |
  start        ---->|                  |
  [POLY, INIT] ---->|  Serial or       |
                    |  Parallel        |
                    +------------------+
```

- Internal: LFSR (or equivalent) driven by polynomial; width 8 or 16; init loaded on reset or on `start`; final XOR applied before output when specified.
- Serial: 1 bit per cycle into LFSR.
- Parallel: N bits (e.g. 8) per cycle; parallel CRC update (standard algorithm).

---

## Design decisions (resolved)

| # | Question | Decision |
|---|----------|----------|
| 1 | Reset | **Sync** with `rst_n`. |
| 2 | crc_valid timing | **1 cycle after** last `data_valid`. |
| 3 | Serial bit order | **LSB first** (industry common). |
| 4 | Parallel byte order | **First byte = MSB of message** (industry common). |
| 5 | start | **Reset + optional start** pulse to begin new CRC. |
| 6 | FINAL_XOR | **Include** in RTL. |
---

## Next steps (pipeline)

1. ~~**RTL**~~ — Done. `rtl/crc_dut.sv`; see `docs/RTL_NOTES.md`.
2. ~~**Zero-order test**~~ — Done. `tb_zero_order/` + `tb_zero_order/VIVADO_RUN.md`; approved.
3. ~~**Full verification**~~ — Done. UVM TB in `verification/`; 12 tests across three builds (main CRC-8, init/final XOR, CRC-16); regression passes.
4. **Doc / sign-off** — Update docs as needed; optional coverage report or sign-off document.
