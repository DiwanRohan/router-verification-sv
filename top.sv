// Define interface with clk as input
interface router_if (
    input clk
);

  logic reset;
  logic [7:0] dut_inp;
  logic inp_valid;
  logic [7:0] dut_outp[4];
  logic outp_valid[4];
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

module top;

  // Clock initialization and Generation
  logic clk;
  initial clk = 0;
  always #5 clk = !clk;

  // Instantiate interface
  router_if router_if_inst (clk);

  // DUT instantiation
  router_dut dut_inst (
      .clk(clk),
      .reset(router_if_inst.reset),
      .dut_inp(router_if_inst.dut_inp),
      .inp_valid(router_if_inst.inp_valid),
      .dut_outp0(router_if_inst.dut_outp[0]),
      .dut_outp1(router_if_inst.dut_outp[1]),
      .dut_outp2(router_if_inst.dut_outp[2]),
      .dut_outp3(router_if_inst.dut_outp[3]),
      .outp_valid0(router_if_inst.outp_valid[0]),
      .outp_valid1(router_if_inst.outp_valid[1]),
      .outp_valid2(router_if_inst.outp_valid[2]),
      .outp_valid3(router_if_inst.outp_valid[3]),
      .busy(router_if_inst.busy),
      .error(router_if_inst.error)
  );

  // Testbench module instantiation
  testbench tb_inst (.vif(router_if_inst));

  // Dumping Waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top.dut_inst);
  end

endmodule
