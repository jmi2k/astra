#
# Simulation
#

$B/%.vcd: $B/%.vvp
	vvp $<

$B/%.vvp: test/%.sv
	@mkdir -p $B
	iverilog \
		-D 'DUMP="$B/$*.vcd"' \
		-D 'FCLK=$(FCLK)' \
		-D 'R="$R"' \
		-I rtl \
		-g2009 \
		-o $@ \
		$<
