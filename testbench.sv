program testbench(router_if vif);

//Section 4.1 : Include test cases
`include "test.sv"

//Section 4.2 : Define test class handles
base_test test;


//Section 6: Verification Flow
initial begin
$display("[Program Block] Simulation Started at time=%0t",$time);
//Section 6.1 : Construct test object and pass required interface handles
test=new(vif.tb_mod_port,vif.tb_mon,vif.tb_mon);

//Section 6.2 : Start the testcase.
test.run();
$display("[Program Block] Simulation Finished at time=%0t",$time);
end

endprogram


`include "top.sv"

