// FILE: crc_dut.sv
// DESCRIPTION: Configurable CRC-8/16 DUT; serial (1 bit/cycle) or parallel (8 bit/cycle). Sync reset, LSB first, optional final XOR.
// AUTHOR: rtl-designer (workflow)
// DATE: 2025-03-05

module crc_dut #(
  parameter int CRC_WIDTH = 8,           // 8 or 16
  parameter logic [15:0] POLYNOMIAL = 16'h0007,  // CRC-8 default 0x07; CRC-16 use e.g. 16'h1021
  parameter logic [15:0] INIT = 16'h0000,
  parameter logic [15:0] FINAL_XOR = 16'h0000
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        mode_serial,  // 1 = serial, 0 = parallel
  input  logic [7:0]  data_in,
  input  logic        data_valid,
  input  logic        start,
  output logic [15:0] crc_out,
  output logic        crc_valid
);

  localparam int W = CRC_WIDTH;

  logic [W-1:0] crc_state;
  logic [W-1:0] next_crc;     // Computed in always_ff from current crc_state
  logic         prev_data_valid;
  logic         crc_valid_r;

  // Serial: one bit per cycle (data_in[0]), LSB first. Galois LFSR update.
  function automatic logic [W-1:0] serial_update(logic [W-1:0] crc, logic bit_in);
    logic [W-1:0] poly;
    poly = (W == 8) ? POLYNOMIAL[7:0] : POLYNOMIAL;
    if (W == 8)
      return ((crc << 1) ^ (poly & {W{(crc[7] ^ bit_in)}})) & 8'hFF;
    else
      return (crc << 1) ^ (poly & {W{(crc[15] ^ bit_in)}});
  endfunction

  // Sync reset, start, and state update. Compute next inside always_ff so current crc_state is used.
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      crc_state       <= (W == 8) ? INIT[7:0] : INIT[15:0];
      prev_data_valid <= 1'b0;
      crc_valid_r     <= 1'b0;
    end else begin
      prev_data_valid <= data_valid;
      crc_valid_r     <= prev_data_valid && !data_valid;
      if (start)
        crc_state <= (W == 8) ? INIT[7:0] : INIT[15:0];
      else if (data_valid) begin
        if (mode_serial)
          next_crc = serial_update(crc_state, data_in[0]);
        else begin
          next_crc = crc_state;
          for (int i = 0; i < 8; i++)
            next_crc = serial_update(next_crc, data_in[i]);
        end
        crc_state <= next_crc;
      end
    end
  end

  // Output: crc_valid 1 cycle after last data_valid (registered so visible for full cycle); crc_out = state XOR FINAL_XOR
  logic [15:0] final_xor_mask;
  assign final_xor_mask = (W == 8) ? {8'h00, FINAL_XOR[7:0]} : FINAL_XOR;
  assign crc_valid = crc_valid_r;
  assign crc_out  = final_xor_mask ^ (W == 8 ? {8'h00, crc_state[7:0]} : crc_state);

endmodule
