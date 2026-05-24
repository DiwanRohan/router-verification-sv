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
- Driver.sv        : Stimulus driver
- Generator.sv     : Packet generator
- iMonitor.sv      : Input monitor
- oMonitor.sv      : Output monitor
- scoreboard.sv    : Data checking
- coverage.sv      : Functional coverage
- environment.sv   : Environment integration
- router_dut.sv    : DUT
- run.do           : Simulation script

## Tools Used
- SystemVerilog
- ModelSim / QuestaSim

## Run Simulation

```bash
vsim -do run.do
```