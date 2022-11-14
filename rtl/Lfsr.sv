module Lfsr #(
	parameter
		Length = 48,
		Taps   = 'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0101_1100,
		Seed   = 'hA1EA_1AC7A_E57
) (
	input wire
		CLK,
		OE,

	output wire OUT
);

	/*
	 * This register holds Length bits, with the first one exposed as OUT. It is
	 * initialized to Seed.
	 *
	 * On each cycle, the bits set on Taps are selected from the register, XORed
	 * together and then shifted into the front of the register.
	 *
	 *        ┌ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ─ ─ ┐
	 *  Taps  ╷     0     ╷     1     ╷     0     ╷     1     ╷     1     ╷
	 *        ╶ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ╴
	 *        ╭───────────────────────────────────────────────────────────╮
	 *        │                            XOR                            ├───┐
	 *        ╰─────────────────▲───────────────────────▲───────────▲─────╯   │
	 *        ┌───────────┬─────┴─────┬───────────┬─────┴─────┬─────┴─────┐   │
	 *        │ Length-1  │◀    …     │◀    2     │◀    1     │◀    0     │◀──┘
	 *        └───────────┴───────────┴───────────┴───────────┴───────────┘
	 *        └───────────┘                                   ╰── Width ──╯
	 *             OUT
	 */

	reg  [Length-1:0] bits = Seed;
	wire [Length-1:0] taps = bits&Taps;

	assign
		OUT = bits[Length-1];

	always @(posedge CLK) if (OE)
		bits <= {bits, ^taps};

endmodule
