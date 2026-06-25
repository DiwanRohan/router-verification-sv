module testbench(router_if vif);
  import router_pkg::*;

  base_test test;

  initial begin
    $display("[Testbench] Simulation Started at time=%0t", $time);
    test = new(vif.tb_mod_port, vif.tb_mon, vif.tb_mon);
    test.run();
    $display("[Testbench] Simulation Finished at time=%0t", $time);
  end
endmodule
