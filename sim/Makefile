# Makefile for Router Verification

# Tool variables
VLIB = vlib
VMAP = vmap
VLOG = vlog
VSIM = vsim
VCOVER = vcover

# Directories
RTL_DIR = ../rtl
TB_DIR  = ../tb
SIM_DIR = .

# Include directories
INC_DIRS = +incdir+$(TB_DIR)/env +incdir+$(TB_DIR)/tests

# Source files
RTL_SRC = $(RTL_DIR)/router_dut.sv
TB_IF   = $(TB_DIR)/env/router_if.sv
TB_PKG  = $(TB_DIR)/env/router_pkg.sv
TB_TOP  = $(TB_DIR)/top/top.sv

# Simulation options
VSIM_OPTS = -coverage -voptargs="+acc"

.PHONY: all lib compile sim cov merge_cov clean

all: lib compile sim cov

lib:
	$(VLIB) work

compile:
	$(VLOG) -cover sbcef $(INC_DIRS) $(TB_IF) $(TB_PKG) $(RTL_SRC) $(TB_TOP)

sim:
	$(VSIM) -c $(VSIM_OPTS) -do "coverage save -onexit sim_cov.ucdb; run -all; quit -f" work.top


cov:
	$(VCOVER) report -html -output cov_html sim_cov.ucdb

merge_cov:
	$(VCOVER) merge merged_cov.ucdb *.ucdb
	$(VCOVER) report -html -output cov_html merged_cov.ucdb


clean:
	-rm -rf work transcript vsim.wlf dump.vcd *.log *.jou *.str *.ucdb cov_html
	-rmdir /s /q work cov_html 2>nul
	-del /f /q transcript vsim.wlf dump.vcd *.log *.jou *.str *.ucdb 2>nul

