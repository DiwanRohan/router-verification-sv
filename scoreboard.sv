class scoreboard;

  //Section S1: Define virtual interface, mailbox and packet class handles
  packet ref_pkt;
  packet got_pkt;
  mailbox #(packet) mbx_in;  //will be connected to input monitor
  mailbox #(packet) mbx_out;  //will be connected to output monitor


  //Section S2: Define variable total_pkts_recvd to keep track of packets received from monitors
  bit [15:0] total_pkts_recvd;

  //Section S3: Define variable to keep track of matched/mis_matched packets
  bit [15:0] m_matched;
  bit [15:0] m_mismatched;

  //Section S4: Define custom constructor with mailbox handles as arguments
  function new(input mailbox#(packet) mbx_in, input mailbox#(packet) mbx_out);

    this.mbx_in  = mbx_in;
    this.mbx_out = mbx_out;
  endfunction

  //Section S5: Define run method to start the scoreboard operations
  task run;
    $display("[Scoreboard] run started at time=%0t", $time);
    while (1) begin
      //Section S6: Wait on mailbox and get a copy of transaction object from mailbox using peek method.
      mbx_in.peek(ref_pkt);

      //Section S7: Wait for packet from Outnput Monitor
      mbx_out.get(got_pkt);

      //Section S8: Increment pkt count once packet received from both the monitors
      total_pkts_recvd++;
      $display("[Scoreboard] Packet %0d received at time=%0t", total_pkts_recvd, $time);

      //Section S9: Compare expected packet with received packet from DUT
      if (ref_pkt.compare(got_pkt)) begin
        //Section S10: Increment m_matches count if packet Matches
        m_matched++;
        $display("[Scoreboard] Packet %0d Matched ", total_pkts_recvd);
      end else begin
        //Section S11: Increment m_mismatches count if packet does NOT Match
        m_mismatched++;

        //Section S12: Print enough information (for debug) when packet does NOT Match
        $display("[Scoreboard] ERROR :: Packet %0d Not_Matched at time=%0t", total_pkts_recvd,
                 $time);
        $display("[Scoreboard] *** Expected Packet to DUT****");
        ref_pkt.print();
        $display("[Scoreboard] *** Received Packet From DUT****");
        got_pkt.print();
      end
    end
    $display("[Scoreboard] run ended at time=%0t", $time);
  endtask

  //Section S13: Define report method to print scoreboard summary
  function void report();
    $display("[Scoreboard] Report: total_packets_received=%0d", total_pkts_recvd);
    $display("[Scoreboard] Report: Matched=%0d Mis_Matched=%0d", m_matched, m_mismatched);
  endfunction

endclass
