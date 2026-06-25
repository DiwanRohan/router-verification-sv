class scoreboard;
  packet ref_pkt;
  packet got_pkt;
  mailbox #(packet) mbx_in;
  mailbox #(packet) mbx_out[4];

  bit [15:0] total_pkts_recvd;
  bit [15:0] m_matched;
  bit [15:0] m_mismatched;

  function new(input mailbox#(packet) mbx_in, input mailbox#(packet) mbx_out[4]);
    this.mbx_in  = mbx_in;
    this.mbx_out = mbx_out;
  endfunction

  task run;
    $display("[Scoreboard] run started at time=%0t", $time);
    while (1) begin
      mbx_in.get(ref_pkt);

      // Check if the packet is expected to be dropped by the DUT due to length or routing errors
      if (ref_pkt.len < 12 || ref_pkt.len > 2000 || ref_pkt.da > 3) begin
        $display(
          "[Scoreboard] Packet %0d expected to be dropped by DUT (len=%0d, da=%0d) at time=%0t",
          total_pkts_recvd + 1, ref_pkt.len, ref_pkt.da, $time);
        total_pkts_recvd++;
        m_matched++;
      end else begin
        mbx_out[ref_pkt.da].get(got_pkt);
        total_pkts_recvd++;
        $display(
          "[Scoreboard] Packet %0d received (dest=%0d) at time=%0t",
          total_pkts_recvd, ref_pkt.da, $time);

        if (ref_pkt.compare(got_pkt)) begin
          m_matched++;
          $display("[Scoreboard] Packet %0d Matched ", total_pkts_recvd);
        end else begin
          m_mismatched++;
          $display(
            "[Scoreboard] ERROR :: Packet %0d Not_Matched at time=%0t",
            total_pkts_recvd, $time);
          $display("[Scoreboard] *** Expected Packet to DUT****");
          ref_pkt.print();
          $display("[Scoreboard] *** Received Packet From DUT****");
          got_pkt.print();
        end
      end
    end
    $display("[Scoreboard] run ended at time=%0t", $time);
  endtask

  function void report();
    $display("[Scoreboard] Report: total_packets_received=%0d", total_pkts_recvd);
    $display("[Scoreboard] Report: Matched=%0d Mis_Matched=%0d", m_matched, m_mismatched);
  endfunction
endclass
