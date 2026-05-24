class oMonitor ;

//Section M2.1:Define virtual interface, mailbox and packet class handles
packet pkt;
virtual router_if.tb_mon vif;
mailbox#(packet) mbx;


//Section M2.2: Define variable no_of_pkts_recvd to keep track of packets sent to scoreboard
bit [31:0] no_of_pkts_recvd;

//Section M2.3: Define custom constructor with mailbox and virtual interface handles as arguments
function new(input mailbox#(packet) mbx_arg, input virtual router_if.tb_mon vif_arg);
	this.mbx=mbx_arg;
	this.vif=vif_arg;
endfunction

//Section M2.4: Define run method to start the monitor operations
task run();
bit [7:0] outp_q[$];
$display("[oMon] run started at time=%0t ",$time); 
forever begin //Monitor runs forever
//Section M2.4.1 : Start of Packet into DUT :Wait on outp_valid to become high
@(posedge vif.mcb.outp_valid);
  no_of_pkts_recvd++;
  $display("[oMon] Started collecting packet %0d at time=%0t ",no_of_pkts_recvd,$time); 
  //Section M2.5 : Capture complete packet driven into DUT
  while (1) begin
  
  //Section M2.6: End of packet into DUT: Collect untill outp_valid becomes 0
  if(vif.mcb.outp_valid==0) begin
   //Section M2.7: Convert Pin level activity to Transaction Level
    pkt=new;
    //Section M2.8: Unpack collected outp_q stream into pkt fields
	pkt.unpack(outp_q);
	pkt.outp_stream=outp_q;
	//Section M2.9: Send collected to scoreboard
	mbx.put(pkt);
	$display("[oMon] Sent packet %0d to scoreboard at time=%0t ",no_of_pkts_recvd,$time);
	//pkt.print();
	//Section M2.10: Delete local outp_q.
	outp_q.delete();
    //Section M2.11: Break out of while loop as collection of packet completed.
	break;
  end//end_of_if
  
  //Section M2.12: Wait for posedge of clk to collect all the dut inputs
  outp_q.push_back(vif.mcb.dut_outp);
	@(vif.mcb);
  end//end_of_while
  
end//end_of_forever

$display("[oMon] run ended at time=%0t ",$time);//monitor will never end 
endtask

//Section M2.13: Define report method to print how many packets collected by oMonitor
function void report();
	$display("[oMon] Report: total_packets_collected=%0d",no_of_pkts_recvd);
endfunction



endclass
