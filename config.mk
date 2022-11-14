# RTL parameters
BOARD = icesugar_pro
TOP   = SoC
TEST  = SoC

#
# Depedencies
#

test/SoC.sv: \
	rtl/SoC.sv \

rtl/SoC.sv: \
	$R/640x480.pbm.mem \
	rtl/Riscv.sv \
	rtl/device/Prng.sv \
	rtl/device/Pwm.sv \
	rtl/device/Video.sv \

rtl/device/Prng.sv: \
	rtl/Lfsr.sv \
	rtl/Sipo.sv \

rtl/device/Pwm.sv: \
	rtl/Pulse.sv \

rtl/device/Video.sv: \
	rtl/Delay.sv \
	rtl/Dpram.sv \
	rtl/Vga.sv \
	rtl/style/Beam.sv \
