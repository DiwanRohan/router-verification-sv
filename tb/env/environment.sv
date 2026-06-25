class environment #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
);

  generator #(DATA_WIDTH, NUM_PORTS)            gen;
  driver #(DATA_WIDTH, NUM_PORTS)               drvr;
  iMonitor #(DATA_WIDTH, NUM_PORTS)             mon_in;
  oMonitor #(DATA_WIDTH, NUM_PORTS)             mon_out[NUM_PORTS];
  scoreboard #(DATA_WIDTH, NUM_PORTS)           scb;
  coverage #(DATA_WIDTH, NUM_PORTS)             cov;

  bit                           [31:0] no_of_pkts;

  mailbox #(packet #(DATA_WIDTH, NUM_PORTS))                    gen_drv_mbox;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS))                    mbx_iMon_scb;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS))                    mbx_iMon_cov;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS))                    mbx_oMon_scb[NUM_PORTS];

  virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mod_port        vif;
  virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon             vif_mon_in;
  virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon             vif_mon_out;

  function new(
      input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mod_port vif_in,
      input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif_mon_in,
      input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif_mon_out,
      input bit [31:0] no_of_pkts
  );
    this.vif = vif_in;
    this.vif_mon_in = vif_mon_in;
    this.vif_mon_out = vif_mon_out;
    this.no_of_pkts = no_of_pkts;
  endfunction

  function void build();
    $display("[Environment] build started at time=%0t", $time);
    gen_drv_mbox = new(1);
    mbx_iMon_scb = new;
    mbx_iMon_cov = new;

    gen          = new(gen_drv_mbox, no_of_pkts);
    drvr         = new(gen_drv_mbox, vif);
    mon_in       = new(mbx_iMon_scb, mbx_iMon_cov, vif_mon_in);
    cov          = new(mbx_iMon_cov);

    for (int i = 0; i < NUM_PORTS; i++) begin
      mbx_oMon_scb[i] = new;
      mon_out[i] = new(mbx_oMon_scb[i], vif_mon_out, i);
    end

    scb          = new(mbx_iMon_scb, mbx_oMon_scb);
    $display("[Environment] build ended at time=%0t", $time);
  endfunction

  task run;
    $display("[Environment] run started at time=%0t", $time);

    for (int i = 0; i < NUM_PORTS; i++) begin
      automatic int j = i;
      fork
        mon_out[j].run();
      join_none
    end

    fork
      gen.run();
      drvr.run();
      mon_in.run();
      scb.run();
      cov.run();
    join_any

    wait (scb.total_pkts_recvd == no_of_pkts);
    repeat (5) @(vif.cb);  // drain time

    report();
    $display("[Environment] run ended at time=%0t", $time);
  endtask

  function void report();
    $display("\n[Environment] ****** Report Started ********** ");
    mon_in.report();
    for (int i = 0; i < NUM_PORTS; i++) begin
      mon_out[i].report();
    end
    scb.report();
    cov.report();
    $display("\n*******************************");
    if (scb.m_mismatched == 0 && (no_of_pkts == scb.total_pkts_recvd)) begin
      $display("***********TEST PASSED ************ ");
      $display("*****Functional Coverage=%0f%% matched=%0d mis_matched=%0d****", cov.coverage_score,
               scb.m_matched, scb.m_mismatched);
    end else begin
      $display("*********TEST FAILED ************ ");
      $display("*******Matched=%0d Mis_matched=%0d *********", scb.m_matched, scb.m_mismatched);
    end
    $display("*************************\n ");
    $display("[Environment] ******** Report ended******** \n");
  endfunction

endclass
