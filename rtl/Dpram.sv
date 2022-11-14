module Dpram #(
	parameter
		Data     = 'x,
		Readonly = 0,
		Bufsz    = 1_024,
		Wordsz   = 32,
		Bytesz   = 8,
		Addrsz   = $clog2(Bufsz),
		Bpw      = Wordsz/Bytesz
) (
	input wire CLK_1, CLK_2,

	input  wire [Addrsz-1:0] ADDR_1,  ADDR_2,
	input  wire    [Bpw-1:0] W_SEL_1, W_SEL_2,
	input  wire [Wordsz-1:0] IN_1,    IN_2,
	output reg  [Wordsz-1:0] OUT_1,   OUT_2
);

	reg [Wordsz-1:0] memory [Bufsz];

	if (Data !== 'x) initial $readmemh(Data, memory);

	always @(posedge CLK_1)
		OUT_1 <= memory[ADDR_1];

	always @(posedge CLK_2)
		OUT_2 <= memory[ADDR_2];

	/*
	 * Write word IN from both ports. Individual bytes can be masked off so each
	 * Bytesz slice must be updated independently.
	 *
	 * This functionality can be turned off by setting Readonly in order to make
	 * the module instantiation simpler.
	 */

	if (!Readonly) for (genvar i = 0; i < Bpw; i++) begin: slice

		always @(posedge CLK_1)
			if (W_SEL_1[i])
				memory[ADDR_1][Bytesz*i +: Bytesz] <= IN_1[Bytesz*i +: Bytesz];

		always @(posedge CLK_2)
			if (W_SEL_2[i])
				memory[ADDR_2][Bytesz*i +: Bytesz] <= IN_2[Bytesz*i +: Bytesz];

	end

endmodule
