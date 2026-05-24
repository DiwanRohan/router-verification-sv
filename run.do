vlib work
vdel -all
vlib work


vlog router_dut.sv testbench.sv top.sv +acc



vsim work.top
add wave -r *
run -all