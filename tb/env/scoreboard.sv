class scoreboard #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
);
  packet #(DATA_WIDTH, NUM_PORTS) ref_pkt;
  packet #(DATA_WIDTH, NUM_PORTS) got_pkt;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx_in;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx_out[NUM_PORTS];

  bit [15:0] total_pkts_recvd;
  bit [15:0] m_matched;
  bit [15:0] m_mismatched;

  localparam int WordSize = (32 + DATA_WIDTH - 1) / DATA_WIDTH;

  function new(
      input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_in,
      input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_out[NUM_PORTS]
  );
    this.mbx_in  = mbx_in;
    this.mbx_out = mbx_out;
  endfunction

  task run;
    $display("[Scoreboard] run started at time=%0t", $time);
    while (1) begin
      mbx_in.get(ref_pkt);

      // min valid length is 2 (sa, da) + 2*WordSize (len, crc) + 2 (min payload elements to not be < 12 in DATA_WIDTH=8)
      if (ref_pkt.len < (2 + 2 * WordSize + 2) || ref_pkt.len > 2000 ||
          ref_pkt.da >= NUM_PORTS) begin
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
