`include "Lfsr.sv"
`include "Sipo.sv"

module PrngDevice(
	input wire CLK
);

	wire coin;
	wire [31:0] word;

	Lfsr lfsr(
		.OE(1'b1),
		.OUT(coin),
		.*
	);

	Sipo sipo(
		.WE(1'b1),
		.IN(coin),
		.OUT(word),
		.*
	);

endmodule
