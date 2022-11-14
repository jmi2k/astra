# Board parameters
FCLK = 25000000

#
# Synthesis
#

$B/%.bit: $B/%.config
	ecppack \
		--input $< \
		--bit $@

$B/%.config: $B/%.json
	nextpnr-ecp5 \
		--json $< \
		--lpf bsp/$(BOARD)/board.lpf \
		--package CABGA256 \
		--speed 6 \
		--textcfg $@ \
		--25k

$B/%.json: rtl/%.sv
	@mkdir -p $B
	yosys -q \
		-D ECP5 \
		-D 'FCLK=$(FCLK)' \
		-D 'R="$R"' \
		-p 'read_verilog -nooverwrite -sv -I rtl $<' \
		-p 'synth_ecp5' \
		-p 'write_json $@'
