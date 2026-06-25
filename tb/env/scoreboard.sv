class scoreboard #(
    parameter int DATA_WIDTH = `DEFAULT_DATA_WIDTH,
    parameter int NUM_PORTS  = `DEFAULT_NUM_PORTS
);
  packet #(DATA_WIDTH, NUM_PORTS) ref_pkt;
  packet #(DATA_WIDTH, NUM_PORTS) got_pkt;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx_in;
  mailbox #(packet #(DATA_WIDTH, NUM_PORTS)) mbx_out[NUM_PORTS];
  virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif;

  bit [15:0] total_pkts_recvd;
  bit [15:0] m_matched;
  bit [15:0] m_mismatched;

  localparam int WordSize = (32 + DATA_WIDTH - 1) / DATA_WIDTH;

  function new(
      input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_in,
      input mailbox#(packet #(DATA_WIDTH, NUM_PORTS)) mbx_out[NUM_PORTS],
      input virtual router_if #(DATA_WIDTH, NUM_PORTS).tb_mon vif
  );
    this.mbx_in  = mbx_in;
    this.mbx_out = mbx_out;
    this.vif     = vif;
  endfunction

  task run;
    $display("[Scoreboard] run started at time=%0t", $time);
    while (1) begin
      mbx_in.get(ref_pkt);

      // check if packet is expected to be dropped by DUT
      if (ref_pkt.inp_stream.size() < (2 + 2 * WordSize + 2) ||
          ref_pkt.inp_stream.size() > 2000 ||
          ref_pkt.da >= NUM_PORTS || ref_pkt.corrupt_crc ||
          ref_pkt.corrupt_len || ref_pkt.corrupt_da) begin
        $write("[Scoreboard] Packet %0d drop expected (len=%0d, da=%0d, ",
            total_pkts_recvd + 1, ref_pkt.len, ref_pkt.da);
        $display("err_crc=%0b, err_len=%0b, err_da=%0b) at time=%0t",
            ref_pkt.corrupt_crc, ref_pkt.corrupt_len, ref_pkt.corrupt_da,
            $time);
        total_pkts_recvd++;
        m_matched++;

        // Wait a short time to verify no packet is output incorrectly
        #50;
        for (int i = 0; i < NUM_PORTS; i++) begin
          if (mbx_out[i].try_get(got_pkt)) begin
            $display(
                "[Scoreboard] ERROR :: Packet %0d expected to be dropped was emitted on port %0d!",
                total_pkts_recvd, i);
            m_matched--;
            m_mismatched++;
          end
        end
      end else begin
        got_pkt = null;
        fork
          begin
            mbx_out[ref_pkt.da].get(got_pkt);
          end
          begin
            repeat (2000) @(vif.mcb);
          end
        join_any
        disable fork;

        total_pkts_recvd++;
        if (got_pkt == null) begin
          m_mismatched++;
          $display(
              "[Scoreboard] ERROR :: Timeout waiting for packet %0d on port %0d",
              total_pkts_recvd, ref_pkt.da);
        end else begin
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
    end
    $display("[Scoreboard] run ended at time=%0t", $time);
  endtask

  function void report();
    $display("[Scoreboard] Report: total_packets_received=%0d", total_pkts_recvd);
    $display("[Scoreboard] Report: Matched=%0d Mis_Matched=%0d", m_matched, m_mismatched);
  endfunction
endclass
