class iMonitor;

  //Section M1.1:Define virtual interface, mailbox and packet class handles
  packet pkt;
  virtual router_if.tb_mon vif;
  mailbox #(packet) mbx;  //will be connected to input of scoreboard

  //Section M1.2: Define variable no_of_pkts_recvd to keep track of packets sent to scoreboard
  bit [15:0] no_of_pkts_recvd;

  //Section M1.3: Define custom constructor with mailbox and virtual interface handles as arguments
  function new(input mailbox#(packet) mbx_arg, input virtual router_if.tb_mon vif_arg);
    this.mbx = mbx_arg;
    this.vif = vif_arg;

  endfunction

  //Section M1.3: Define run method to start the monitor operations
  task run();
    bit [7:0] inp_q[$];
    $display("[iMon] run started at time=%0t ", $time);
    forever begin  //Monitor runs forever
      //Section M1.4 : Start of Packet into DUT :Wait on inp_valid to become high
      @(posedge vif.mcb.inp_valid);
      no_of_pkts_recvd++;
      $display("[iMon] Started collecting packet %0d at time=%0t ", no_of_pkts_recvd, $time);
      //Section M1.5 : Capture complete packet driven into DUT
      while (1) begin

        //Section M1.6: End of packet into DUT: Collect until inp_valid becomes 0
        if (vif.mcb.inp_valid == 0) begin
          //Section M1.7: Convert Pin level activity to Transaction Level
          pkt = new;
          //Section M1.8: Unpack collected inp_q stream into pkt fields
          pkt.unpack(inp_q);
          pkt.inp_stream = inp_q;


          //Section M1.9: Send collected transaction to scoreboard and coverage components.
          mbx.put(pkt);

          //Section M1.9.1 : Wait until scoreboard and coverage components gets a copy of transactions and then Delete entries in the mailbox .
          begin
            packet temp;
            #0 while (mbx.num >= 1) void'(mbx.try_get(temp));
          end
          $display("[iMon] Sent packet %0d to scoreboard at time=%0t ", no_of_pkts_recvd, $time);
          //pkt.print();
          //Section M1.10: Delete local inp_q.
          inp_q.delete();
          //Section M1.11: Break out of while loop as collection of packet completed.
          break;
        end  //end_of_if
        //Section M1.12: Wait for posedge of clk to collect all the dut inputs
        inp_q.push_back(vif.mcb.dut_inp);
        @(vif.mcb);
      end  //end_of_while
    end  //end_of_forever

    $display("[iMon] run ended at time=%0t ", $time);  //monitor will never end
  endtask

  //Section M1.13: Define report method to print how many packets collected by iMonitor
  function void report();
    $display("[iMon] Report: total_packets_collected=%0d ", no_of_pkts_recvd);
  endfunction



endclass
