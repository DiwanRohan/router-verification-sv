`include "router_defines.sv"

interface router_if #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
) (
    input clk
);

  logic reset;
  logic [DATA_WIDTH-1:0] dut_inp;
  logic inp_valid;
  logic [DATA_WIDTH-1:0] dut_outp[NUM_PORTS];
  logic outp_valid[NUM_PORTS];
  logic busy;
  logic [3:0] error;

  // Define the clocking block
  clocking cb @(posedge clk);
    output dut_inp;  // Direction is w.r.t TB
    output inp_valid;
    input dut_outp;
    input outp_valid;
    input busy;
    input error;
  endclocking

  // Define clocking block for monitors
  clocking mcb @(posedge clk);
    input dut_inp;
    input inp_valid;
    input dut_outp;
    input outp_valid;
    input busy;
    input error;
  endclocking

  // Define modport for TB Driver
  modport tb_mod_port(clocking cb, output reset);

  // Define modport for TB Monitors
  modport tb_mon(clocking mcb);

  // ==========================================
  // SystemVerilog Assertions (SVA)
  // ==========================================

  // SVA: Assert that busy rises 1 cycle after inp_valid goes high
  property p_busy_rise;
    @(posedge clk) disable iff (reset)
    inp_valid |=> busy;
  endproperty
  ap_busy_rise: assert property(p_busy_rise)
    else $error("[SVA ERROR] busy failed to rise after inp_valid");

  // SVA: Assert that busy falls eventually (no hang)
  property p_busy_falls;
    @(posedge clk) disable iff (reset)
    busy |-> s_eventually !busy;
  endproperty
  ap_busy_falls: assert property(p_busy_falls)
    else $error("[SVA ERROR] busy hung high");

  // SVA: Assert that when outp_valid is high, output data contains no X or Z
  generate
    for (genvar i = 0; i < NUM_PORTS; i++) begin : gen_sva
      property p_outp_stable;
        @(posedge clk) disable iff (reset)
        outp_valid[i] |-> !$isunknown(dut_outp[i]);
      endproperty
      ap_outp_stable: assert property(p_outp_stable)
        else $error("[SVA ERROR] Invalid output data on port %0d", i);
    end
  endgenerate

endinterface
