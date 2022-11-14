𝕒𝕤𝕥𝕣𝕒
=====

Venture into the realms of hardware design and computer architecture.

Quick start
-----------

Install dependencies
   GNU make, awk, yosys, nextpnr and Icarus Verilog.

Edit *config.mk*
   Specify your board, top module, testbench and dependencies to drive the build
   process.

Edit constraint file
   Set pin assignments for external, relocatable peripherals like PMODs.

Run ``make``
   By default, perform both simulation and synthesis.

Inspect waveform
   Simulation produces a waveform that can be opened with a suitable viewer like
   *GTKWave* or *Pulseview*.

Flash bitstream
   Synthesis produces a bitstream that can be flashed to the selected board.
