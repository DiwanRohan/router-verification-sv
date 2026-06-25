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

endinterface
