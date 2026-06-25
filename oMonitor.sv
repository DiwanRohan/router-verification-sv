class oMonitor;
  packet pkt;
  virtual router_if.tb_mon vif;
  mailbox #(packet) mbx;

  bit [31:0] no_of_pkts_recvd;
  int port_id;

  function new(
    input mailbox#(packet) mbx_arg,
    input virtual router_if.tb_mon vif_arg,
    input int port_id_arg
  );
    this.mbx = mbx_arg;
    this.vif = vif_arg;
    this.port_id = port_id_arg;
  endfunction

  task run();
    bit [7:0] outp_q[$];
    $display("[oMon_%0d] run started at time=%0t ", port_id, $time);
    forever begin
      @(posedge vif.mcb.outp_valid[port_id]);
      no_of_pkts_recvd++;
      $display(
        "[oMon_%0d] Started collecting packet %0d at time=%0t ",
        port_id, no_of_pkts_recvd, $time);
      while (1) begin
        if (vif.mcb.outp_valid[port_id] == 0) begin
          pkt = new;
          pkt.unpack(outp_q);
          pkt.outp_stream = outp_q;
          mbx.put(pkt);
          $display(
            "[oMon_%0d] Sent packet %0d to scoreboard at time=%0t ",
            port_id, no_of_pkts_recvd, $time);
          outp_q.delete();
          break;
        end
        outp_q.push_back(vif.mcb.dut_outp[port_id]);
        @(vif.mcb);
      end
    end
    $display("[oMon_%0d] run ended at time=%0t ", port_id, $time);
  endtask

  function void report();
    $display("[oMon_%0d] Report: total_packets_collected=%0d", port_id, no_of_pkts_recvd);
  endfunction
endclass
