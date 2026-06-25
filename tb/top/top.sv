`include "router_defines.sv"

module top;
  import router_pkg::*;

  // Clock initialization and Generation
  logic clk;
  initial clk = 0;
  always #5 clk = !clk;

  router_if #(
      .DATA_WIDTH(`DEFAULT_DATA_WIDTH),
      .NUM_PORTS(`DEFAULT_NUM_PORTS)
  ) router_if_inst (clk);

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

  // Testbench instantiation & run
  base_test #(
      .DATA_WIDTH(`DEFAULT_DATA_WIDTH),
      .NUM_PORTS(`DEFAULT_NUM_PORTS)
  ) test;

  initial begin
    $display("[Testbench] Simulation Started at time=%0t", $time);
    test = new(router_if_inst.tb_mod_port, router_if_inst.tb_mon, router_if_inst.tb_mon);
    test.run();
    $display("[Testbench] Simulation Finished at time=%0t", $time);
    $finish;
  end

  // Dumping Waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top.dut_inst);
  end

endmodule
