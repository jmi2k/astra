#!/bin/awk -f

# Let any blank delimit records
BEGIN {
	RS = "[[:blank:]\n]+"
}

# Tweak, accumulate and process bitmap data after the PBM header
NR > 3 {
	# Make 0 black and 1 white, as opposed to PBM specification
	gsub("0", "I")
	gsub("1", "0")
	gsub("I", "1")

	buffer = buffer $0

	# Retrieve words from the buffer while there are enough bits
	for (; length(buffer) >= 32; addr++) {
		bits   = substr(buffer, 1, 32)
		buffer = substr(buffer, 33)
		word   = 0

		# Parse LSB-first bit string into word
		for (i = length(bits); i; i--)
			word = 2*word + substr(bits, i, 1)

		# Output hexadecimal word
		printf "%X\n", word
	}
}
