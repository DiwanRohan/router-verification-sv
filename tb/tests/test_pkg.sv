package test_pkg;
  import router_pkg::*;
  `include "router_defines.sv"

  class base_test #(
      parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
      parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
  );

    bit                           [31:0] no_of_pkts;

    virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mod_port        vif;
    virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon             vif_mon_in;
    virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon             vif_mon_out;

    environment #(DATA_WIDTH, NUM_PORTS)                          env;

    function new(input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mod_port vif_in,
                 input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif_mon_in,
                 input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif_mon_out);
      this.vif = vif_in;
      this.vif_mon_in = vif_mon_in;
      this.vif_mon_out = vif_mon_out;
    endfunction

    function void build();
      env = new(vif, vif_mon_in, vif_mon_out, no_of_pkts);
      env.build();
    endfunction

    task run();
      $display("[Testcase] run started at time=%0t", $time);
      no_of_pkts = 2000;
      build();
      env.run();
      $display("[Testcase] run ended at time=%0t", $time);
    endtask

  endclass
endpackage
