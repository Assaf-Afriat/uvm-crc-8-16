# RTL Implementation Notes

**Module:** `rtl/crc_dut.sv`  
**Date:** 2025-03-05  

## Design choices

- **Sync reset:** `rst_n` is synchronous; state and `prev_data_valid` reset on rising edge when `rst_n` is low.
- **Serial algorithm:** Galois LFSR; one bit per cycle from `data_in[0]`, LSB first. Next state = `(crc << 1) ^ (POLYNOMIAL & {W{(crc[W-1] ^ bit_in)}})`.
- **Parallel:** Eight serial steps per cycle (unrolled loop) on `data_in[7:0]`; within the byte, bit 0 then 1 … then 7 (LSB first). First byte supplied = MSB of message.
- **crc_valid:** Registered; high for exactly one cycle after the last cycle where `data_valid` was high (so the testbench can sample it reliably).
- **start:** When high, state is reloaded with `INIT` on the next rising edge; same as starting a new CRC. If `start` and `data_valid` are both high in the same cycle, `start` takes priority and the incoming data byte is silently dropped.
- **start + end-of-packet hazard:** If `start` is asserted in the cycle immediately after the last `data_valid` (i.e., the cycle where `crc_valid` would fire), `crc_state` is reset to `INIT` before the output is sampled, so `crc_out` will reflect `INIT ^ FINAL_XOR` instead of the computed CRC. Testbench must not assert `start` until after sampling `crc_valid`.
- **FINAL_XOR:** Applied to `crc_state` when forming `crc_out`; width matches CRC_WIDTH (upper bits zero for CRC-8).

## Parameters

| Parameter   | Description                          | Example (CRC-8) | Example (CRC-16-CCITT) |
|------------|--------------------------------------|-----------------|-------------------------|
| CRC_WIDTH  | 8 or 16                              | 8               | 16                      |
| POLYNOMIAL | Generator polynomial (no x^W term)   | 8'h07           | 16'h1021                 |
| INIT       | Value after reset / start            | 16'h0000        | 16'hFFFF                |
| FINAL_XOR  | XOR applied to output                | 16'h0000        | 16'h0000                |

## Port usage

- `data_in[7:0]`: In serial mode only `data_in[0]` is used; in parallel mode the full byte is used (LSB of byte = first bit of that byte).
- `crc_out`: Zero-extended to 16 bits for CRC-8 (upper 8 bits zero); full 16 bits for CRC-16.

## Verification alignment

- Reference model must use the same polynomial, INIT, FINAL_XOR, LSB-first serial order, and “first byte = MSB of message” for parallel mode.
- Scoreboard should compare DUT `crc_out` with reference CRC when `crc_valid` is high (one cycle after last `data_valid`).
