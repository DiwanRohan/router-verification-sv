vlib work
vdel -all
vlib work

vlog -cover sbcef router_pkg.sv router_dut.sv testbench.sv top.sv +acc

vsim -coverage work.top
add wave -r *
run -all
coverage report -detail -cvg