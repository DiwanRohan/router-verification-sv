class iMonitor #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
);
  packet #(DATA_WIDTH, NUM_PORTS) pkt;
  virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx;      // Connected to scoreboard
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx_cov;  // Connected to coverage

  bit [15:0] no_of_pkts_recvd;

  function new(
    input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_arg,
    input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_cov_arg,
    input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif_arg
  );
    this.mbx = mbx_arg;
    this.mbx_cov = mbx_cov_arg;
    this.vif = vif_arg;
  endfunction

  task run();
    bit [DATA_WIDTH-1:0] inp_q[$];
    $display("[iMon] run started at time=%0t ", $time);
    forever begin
      @(posedge vif.mcb.inp_valid);
      no_of_pkts_recvd++;
      $display("[iMon] Started collecting packet %0d at time=%0t ", no_of_pkts_recvd, $time);
      while (1) begin
        if (vif.mcb.inp_valid == 0) begin
          pkt = new;
          pkt.unpack(inp_q);
          pkt.inp_stream = inp_q;

          mbx.put(pkt);
          mbx_cov.put(pkt);

          $display(
            "[iMon] Sent packet %0d to scoreboard and coverage at time=%0t ",
            no_of_pkts_recvd, $time);
          inp_q.delete();
          break;
        end
        inp_q.push_back(vif.mcb.dut_inp);
        @(vif.mcb);
      end
    end
    $display("[iMon] run ended at time=%0t ", $time);
  endtask

  function void report();
    $display("[iMon] Report: total_packets_collected=%0d ", no_of_pkts_recvd);
  endfunction
endclass
