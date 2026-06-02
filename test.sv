//Section T1 : Include environment classes
`include "environment.sv"

//Section T2 : Define test class
class base_test;

  //Section T3 : Define Stimulus packet count
  bit                           [31:0] no_of_pkts;

  //Section T4 : : Define virtual interface handles required for Driver,iMonitor and oMonitor
  virtual router_if.tb_mod_port        vif;
  virtual router_if.tb_mon             vif_mon_in;
  virtual router_if.tb_mon             vif_mon_out;

  //Section T5 : : Define enviroment class handle
  environment                          env;

  //Section T6: Define custom constructor with virtual interface handles as arguments.
  function new(input virtual router_if.tb_mod_port vif_in,
               input virtual router_if.tb_mon vif_mon_in,
               input virtual router_if.tb_mon vif_mon_out);

    this.vif = vif_in;
    this.vif_mon_in = vif_mon_in;
    this.vif_mon_out = vif_mon_out;

  endfunction

  //Section T7: Build Verification environment and connect them.
  function void build();
    //Section T7.1: Decide number of packets to generate in generator
    env = new(vif, vif_mon_in, vif_mon_out, no_of_pkts);
    //Section T7.2: Construct object for environment and connect interfaces
    env.build();
  endfunction

  //Section T8: Define run method to start Verification environment.
  task run();
    $display("[Testcase] run started at time=%0t", $time);
    //Section T8.1: Construct objects for environment and connects intefaces.
    no_of_pkts = 10;
    //Section T8.2: Start the Verification Environment
    build();
    env.run();
    $display("[Testcase] run ended at time=%0t", $time);
  endtask


endclass
