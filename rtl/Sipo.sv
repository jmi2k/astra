module Sipo #(
    parameter
        Insz  = 1,
        Outsz = 32
) (
    input wire
        CLK,
        WE,

    input  wire  [Insz-1:0] IN,
    output reg  [Outsz-1:0] OUT
);

	/*
     *
	 *       ┌───────────┬───────────┬───────────┬───────────┬───────────┐
	 *  OUT  │  Depth-1  ╷◀    …     ╷◀    2     ╷◀    1     ╷◀    0     │◀  IN
	 *       └───────────────────────────────────────────────────────────┘
	 *       ╰────────────────────────── Outsz ──────────────────────────╯
	 */

    always @(posedge CLK) if (WE)
        OUT <= {OUT, IN};

endmodule
