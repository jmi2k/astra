.PHONY: all default nuke

all: default

# Shorthands for the build subdirectories
B = build/$(BOARD)
R = $B/res

# User-defined parameters
include config.mk

# Board-specific parameters
include bsp/$(BOARD)/board.mk

# Simulation-specific parameters
include verilator.mk

# Create bitstream and run simulation by default
default: \
	$B/$(TEST).vcd \
	$B/$(TOP).bit \

# Remove all generated files
nuke:
	rm -rf build

# NetPBM images
$R/%.pbm.mem: res/%.pbm
	@mkdir -p $R
	sed '/\s*#/d' $< | util/pbm2mem.awk > $@
