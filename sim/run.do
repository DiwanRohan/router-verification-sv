vlib work
vdel -all
vlib work

vlog -cover sbcef +incdir+../tb/env +incdir+../tb/tests ../tb/env/router_if.sv ../tb/env/router_pkg.sv ../tb/tests/test_pkg.sv ../rtl/router_dut.sv ../tb/top/top.sv +acc

vsim -coverage work.top
add wave -r *
run -all
coverage report -detail -cvg
quit -f
