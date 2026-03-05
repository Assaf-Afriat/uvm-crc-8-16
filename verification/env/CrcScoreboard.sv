// FILE: CrcScoreboard.sv
// DESCRIPTION: Reference CRC model + compare DUT result; subscribes to monitor.
// Table format follows round-robin arbiter scoreboard (RrScoreboard.sv): one block with box-drawing and summary.
// AUTHOR: verification-engineer (workflow)
// DATE: 2025-03-05

// CLASS: CrcScoreboard
// DESCRIPTION: uvm_analysis_imp; computes expected CRC; compares to DUT. Stores rows; prints one table + summary in report_phase.
class CrcScoreboard extends uvm_component;
  uvm_analysis_imp #(CrcResultTxn, CrcScoreboard) m_export;
  CrcConfig m_cfg;
  int m_match, m_mismatch;

  // Row storage for report_phase table
  string     m_input_q[$];
  bit [15:0] m_exp_q[$];
  bit [15:0] m_act_q[$];
  bit        m_pass_q[$];  // 1=PASS, 0=FAIL

  `uvm_component_utils(CrcScoreboard)

  function new(string i_name, uvm_component i_parent);
    super.new(i_name, i_parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_export = new("m_export", this);
    if (!uvm_config_db#(CrcConfig)::get(this, "", "m_cfg", m_cfg) || m_cfg == null)
      `uvm_fatal("CFG", "CrcScoreboard: CrcConfig not found")
  endfunction

  // Format data[] as hex string; max 4 bytes then "..." to fit column
  function string format_input(byte data[]);
    string s = "";
    int n = (data.size() > 4) ? 4 : data.size();
    for (int i = 0; i < n; i++)
      s = $sformatf("%s 0x%02X", s, data[i]);
    if (data.size() > 4)
      s = { s, " ..." };
    return (s != "") ? s.substr(1, s.len()-1) : "(none)";
  endfunction

  // Pad string to width (truncate if longer); pad with spaces on right
  function string pad(string s, int width);
    if (s.len() >= width) return s.substr(0, width-1);
    while (s.len() < width) s = { s, " " };
    return s;
  endfunction

  virtual function void write(CrcResultTxn txn);
    bit [15:0] exp;
    string input_str;
    if (txn.m_data.size() == 0) return;
    exp = ref_crc(m_cfg.m_crc_width, m_cfg.m_polynomial, m_cfg.m_init, m_cfg.m_final_xor, txn.m_data);
    input_str = format_input(txn.m_data);
    m_input_q.push_back(input_str);
    m_exp_q.push_back(exp);
    m_act_q.push_back(txn.m_crc_out);
    if (txn.m_crc_out == exp) begin
      m_match++;
      m_pass_q.push_back(1);
    end else begin
      m_mismatch++;
      m_pass_q.push_back(0);
    end
  endfunction

  // Print results table + summary in one block (style of RrScoreboard print_summary_table)
  virtual function void report_phase(uvm_phase phase);
    string table_str;
    string pass_fail;
    int i;
    pass_fail = (m_mismatch == 0) ? "PASS" : "FAIL";

    table_str = "\n";
    table_str = { table_str, "  +============================================================+\n" };
    table_str = { table_str, "  |              CRC SCOREBOARD - RESULTS TABLE                 |\n" };
    table_str = { table_str, "  +============================================================+\n" };
    table_str = { table_str, "  |  Input (hex)       |  Expected   |  Actual    |  Result     |\n" };
    table_str = { table_str, "  +--------------------+-------------+------------+-------------+\n" };
    for (i = 0; i < m_input_q.size(); i++) begin
      table_str = { table_str, $sformatf("  |  %-18s |  0x%04X     |  0x%04X    |  %-11s |\n",
          pad(m_input_q[i], 18), m_exp_q[i], m_act_q[i], m_pass_q[i] ? "PASS" : "FAIL") };
    end
    table_str = { table_str, "  +--------------------+-------------+------------+-------------+\n" };
    table_str = { table_str, "  |                      SCOREBOARD SUMMARY                    |\n" };
    table_str = { table_str, "  +--------------------+----------------------------------------+\n" };
    table_str = { table_str, $sformatf("  |  Total Comparisons  |  %6d                                 |\n", m_match + m_mismatch) };
    table_str = { table_str, $sformatf("  |  Matched             |  %6d                                 |\n", m_match) };
    table_str = { table_str, $sformatf("  |  Mismatched          |  %6d                                 |\n", m_mismatch) };
    table_str = { table_str, "  +============================================================+\n" };
    table_str = { table_str, $sformatf("  |  RESULT: %-52s |\n", pass_fail) };
    table_str = { table_str, "  +============================================================+\n" };

    `uvm_info("SB", table_str, UVM_NONE)
    if (m_mismatch > 0)
      `uvm_error("SB", "TEST FAILED - scoreboard mismatches detected")
  endfunction

  // Reference CRC: Galois LFSR, LSB first within byte, first byte = MSB of message. Same as RTL.
  static function bit [15:0] ref_crc(int w, bit [15:0] poly, bit [15:0] init, bit [15:0] final_xor, byte data[]);
    bit [15:0] crc;
    bit [15:0] poly_mask;
    if (w == 8) begin
      crc = init[7:0];
      poly_mask = {8'h00, poly[7:0]};
    end else begin
      crc = init;
      poly_mask = poly;
    end
    for (int b = 0; b < data.size(); b++)
      for (int i = 0; i < 8; i++) begin
        bit bit_in = data[b][i];
        if (w == 8)
          crc = ((crc << 1) ^ (poly_mask & {16{(crc[7] ^ bit_in)}})) & 16'h00FF;
        else
          crc = (crc << 1) ^ (poly_mask & {16{(crc[15] ^ bit_in)}});
      end
    if (w == 8)
      return (final_xor[7:0] ^ crc[7:0]) & 16'h00FF;
    return crc ^ final_xor;
  endfunction
endclass
