`include "SoC.sv"
`timescale 1ns/100ps

module Test;

	localparam
		T = 1_000_000_000/`FCLK;

	bit CLK = 0;

	SoC soc(
		.CLK
	);

	initial begin
		$dumpfile(`DUMP);
		$dumpvars;

		#(700_000*T) $finish;
	end

	always
		#(T/2) CLK <= !CLK;

endmodule
