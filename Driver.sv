class driver;
  packet pkt;
  virtual router_if.tb_mod_port vif;
  mailbox #(packet) mbx;

  bit [31:0] no_of_pkts_recvd;

  function new(input mailbox#(packet) mbx_arg, input virtual router_if.tb_mod_port vif_arg);
    mbx = mbx_arg;
    vif = vif_arg;
  endfunction

  extern task run();
  extern task drive(packet pkt);
  extern task drive_reset(packet pkt);
  extern task drive_stimulus(packet pkt);
endclass

task driver::run();
  $display("[Driver] run started at time=%0t", $time);
  while (1) begin
    mbx.get(pkt);
    no_of_pkts_recvd++;
    $display("[Driver] Received  %0s packet %0d from generator at time=%0t", pkt.kind.name(),
             no_of_pkts_recvd, $time);
    drive(pkt);
    $display("[Driver] Done with %0s packet %0d from generator at time=%0t", pkt.kind.name(),
             no_of_pkts_recvd, $time);
  end
endtask

task driver::drive(packet pkt);
  case (pkt.kind)
    RESET:    drive_reset(pkt);
    STIMULUS: drive_stimulus(pkt);
    default:  $display("[Driver] Unknown packet received");
  endcase
endtask

task driver::drive_reset(packet pkt);
  $display("[Driver] Driving Reset transaction at %0t", $time);
  vif.reset <= 1'b1;
  repeat (pkt.reset_cycles) @(vif.cb);
  vif.reset <= 1'b0;
  $display("[Driver] Reset completed at %0t", $time);
endtask

task driver::drive_stimulus(packet pkt);
  wait (vif.cb.busy == 0);
  @(vif.cb);
  $display("[Driver] Driving packet %0d (size=%0d) at %0t", no_of_pkts_recvd, pkt.len, $time);

  vif.cb.inp_valid <= 1;
  foreach (pkt.inp_stream[i]) begin
    vif.cb.dut_inp <= pkt.inp_stream[i];
    @(vif.cb);
  end
  vif.cb.inp_valid <= 0;
  vif.cb.dut_inp   <= 'z;

  $display("[Driver] Done packet %0d (size=%0d) at %0t\n", no_of_pkts_recvd, pkt.len, $time);
endtask
