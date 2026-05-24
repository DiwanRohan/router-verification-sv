class coverage;

//Section C1: Define mailbox and packet class handles
packet pkt;
mailbox#(packet) mbx;

//Section C2: Define variable coverage_score to keep track of coverage score.
real coverage_score;
 
//Section C3: Define Embeded coverage group with required coverpoints and cross.
covergroup fcov with function sample(packet pkt);
   
   
   //Section C3.1 : Define coverpoint on sa 
   coverpoint pkt.sa{
   
   //Section C3.1.1 : Define bins for sa1,sa2,sa3 and sa4 ports
	bins sa1 = {1};
	bins sa2 = {2};
	bins sa3 = {3};
	bins sa4 = {4};
   }
   //Section C3.1.2 : Define bins for da1,da2,da3 and da4 ports
	coverpoint pkt.da{
		bins da1 = {1};
		bins da2 = {2};
		bins da3 = {3};
		bins da4 = {4};
   }
   //Section C3.1.3 : Define bins for differnet sizes of packet using len .
	coverpoint pkt.len{
	bins length_small  = {[12:50]};
	bins length_medium = {[51:200]};
	bins length_big    = {[201:999]};
	bins jumbo_pkts    = {[1000:2000]};
	bins short_length  = {[$:11]};
	bins max_length    = {[2001:$]};
	}
   
   //Section C3.1.4 : Define cross to monitor sa,da combinations
	cross pkt.sa,pkt.da;
   
   //Section C3.1.5: Define cross to monitor sa with different packet lengths as combinations	
   cross pkt.sa,pkt.len;
   
   //Section C3.1.6: Define cross to monitor da with different packet lengths as combinations
	cross pkt.da,pkt.len;
   
   endgroup

//Section C4 : Define custom constructor with mailbox as argument
function new (input mailbox #(packet) mbx_arg);
this.mbx=mbx_arg;
//Section C4.1 : Construct cover group
fcov = new;
endfunction

//Section C5: Define run method to start the coverage sampling.
virtual task run();
while(1) begin
//Section C5.1 : Wait on transaction to be available in mailbox
@(mbx.num);
//Section C5.2 : Retrieve copy of transaction object from mailbox using peek method.
mbx.peek(pkt);
//Section C5.3 : Call the sample with with transaction object as argument.
fcov.sample(pkt);
//Section C5.4 : Call get_coverage method on fcov to get the current functional coverage number.
coverage_score = fcov.get_coverage();

$display("[FCOV] Coverage=%0f ",coverage_score);
end
endtask

//Section C6 : Define report method to print the final functional coverage collected.
function void report();
	$display("************ Functional Coverage**********");
	$display("**coverage_score=%0f",coverage_score);
	$display("********************************************");
endfunction
  
endclass

