module Delay #(
	parameter
		Depth = 1,
		Width = 1
) (
	input wire CLK,

	input  wire [Width-1:0] IN,
	output wire [Width-1:0] OUT
);

	localparam
		Size = Depth*Width;

	/*
	 * This register is large enough for Depth groups, each one Width bits wide.
	 * The highest group is exposed through OUT.
	 *
	 * On each clock cycle, the entire register is shifted left Width positions,
	 * pulling IN onto the front.
	 *
	 *    ┌───────────┬───────────┬───────────┬───────────┬───────────┐
	 *    │  Depth-1  │◀    …     │◀    2     │◀    1     │◀    0     │◀  IN
	 *    └───────────┴───────────┴───────────┴───────────┴───────────┘
	 *    └───────────┘                                   ╰── Width ──╯
	 *         OUT
	 */

	reg [Size-1:0] buffer;

	assign
		OUT = buffer[Size-1:Size-Width];

	always @(posedge CLK)
		buffer <= {buffer, IN};

endmodule
