# Router Verification Environment

SystemVerilog-based verification environment for a packet router DUT featuring constrained-random stimulus generation, input/output monitoring, scoreboard checking, and functional coverage.

## Features
- Packet-based transaction verification
- Driver and generator architecture
- Input and output monitors
- Scoreboard-based checking
- Functional coverage
- Randomized packet generation

## Project Structure
- `rtl/router_dut.sv`         : Parameterized DUT (with FSM recovery, zero idle state)
- `tb/env/router_if.sv`       : Parameterized interface with clocking blocks and SVAs
- `tb/env/router_pkg.sv`      : Environment Package
- `tb/env/packet.sv`          : Packet transaction model with error injection controls
- `tb/env/Generator.sv`       : Packet generator
- `tb/env/Driver.sv`          : Stimulus driver
- `tb/env/iMonitor.sv`        : Input monitor
- `tb/env/oMonitor.sv`        : Output monitor
- `tb/env/scoreboard.sv`      : Scoreboard with non-blocking timeout & drop verification
- `tb/env/coverage.sv`        : Functional coverage with transition and error bins
- `tb/env/environment.sv`     : Verification environment integration
- `tb/tests/test.sv`          : Simulation test cases
- `tb/top/top.sv`             : Top-level testbench module
- `sim/run.do`                : ModelSim/QuestaSim macro run script
- `sim/Makefile`              : Makefile for clean compile/simulation runs

## Tools Used
- SystemVerilog
- ModelSim / QuestaSim

## Run Simulation

Navigate to the `sim` directory and run:

```bash
vsim -c -do run.do
```
or
```bash
make
```