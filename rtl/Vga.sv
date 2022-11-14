module Vga #(
	parameter
		Width  = 640,
		Height = 480,
		Hfp    = 16,
		Hsync  = 96,
		Hbp    = 48,
		Vfp    = 10,
		Vsync  = 2,
		Vbp    = 33,
		Wfull  = Width  + Hfp + Hsync + Hbp,
		Hfull  = Height + Vfp + Vsync + Vbp,
		Xsz    = $clog2(Wfull),
		Ysz    = $clog2(Hfull),
		Possz  = $clog2(Width*Height)
) (
	input wire CLK,

	output wire
		H_BLANK, V_BLANK,
		H_SYNC,  V_SYNC,

	output reg   [Xsz-1:0] X   = Wfull-1,
	output reg   [Ysz-1:0] Y   = Hfull-1,
	output reg [Possz-1:0] POS = 0
);

	/*
	 * A VGA video signal is composed of frames. Each frame contains Hfull lines
	 * with Wfull dots each. Part of this frame is dedicated to the Width×Height
	 * visible area, and the rest is the blanking interval. During that interval
	 * no pixel data must be transmitted.
	 *
	 *             ╭──────────── Width ────────────┬─ Hfp ─┬─ Hsync ─┬─ Hbp ─╮
	 *           ╭ ┌───────────────────────────────┬ ─ ─ ─ ┬ ─ ─ ─ ─ ┬ ─ ─ ─ ┐
	 *           │ │ ░░░░░░░░░░░░░▒▒░░▒▓██▒░░░░░░░ ╷       ╷         ╷       ╷
	 *           │ │ ░░░░░░░░░░░░▒▒▒▓▓▓█▓██▓▓▓▒▒░░ ╷       ╷         ╷       ╷
	 *           │ │ ░░░░░░▒▒▒▓▓▓▓▓██▓▒░  ▒▓▓█▓▒▒░ ╷       ╷         ╷       ╷
	 *           │ │ ░░░▒▒▒▒▓▓██████         ▓█▒▒░ ╷       ╷         ╷       ╷
	 *    Height │ │ ░░▒▓▓▓▓██▓   ▒         ░█▓▒▒░ ╷       ╷         ╷       ╷
	 *           │ │ ░░▒▒▒▒▒▓▓██████         ▓█▒▒░ ╷       ╷         ╷       ╷
	 *           │ │ ░░░░░░▒▒▒▓▓▓▓▓██▓▒░  ▒▓▓█▓▒▒░ ╷       ╷         ╷       ╷
	 *           │ │ ░░░░░░░░░░░░▒▒▒▓▓▓█▓██▓▓▓▒▒░░ ╷       ╷         ╷       ╷
	 *           │ │ ░░░░░░░░░░░░░▒▒░░▒▓██▒░░░░░░░ ╷       ╷         ╷       ╷
	 *           ├ ├───────────────────────────────┼ ─ ─ ─ ┬ ─ ─ ─ ─ ┬ ─ ─ ─ ┐
	 *       Vbp │ ╷                               ╷       ╷         ╷       ╷
	 *           ├ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ┬ ─ ─ ─ ─ ┬ ─ ─ ─ ┐
	 *     Vsync │ ╷                               ╷       ╷         ╷       ╷
	 *           ├ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ┬ ─ ─ ─ ─ ┬ ─ ─ ─ ┐
	 *       Vfp │ ╷                               ╷       ╷         ╷       ╷
	 *           ╰ ╶ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ╴
	 *
	 * Values for all those parameters are standardized, although slight changes
	 * might be needed for some setups.
	 */

	wire
		x_maxed = X == Wfull-1,
		y_maxed = Y == Hfull-1;

	always @(posedge CLK)
		if (x_maxed) begin
			X <= 0;
			Y <= y_maxed ? 0 : Y+1;
		end else
			X <= X+1;

	/*
	 * Both blanking and synchronization signals are produced. Keep in mind they
	 * usually (but not always!) must be inverted before transmitting!
	 *
	 *             ╭─────────── Visible ───────────┬─ Xfp ─┬─ Xsync ─┬─ Xbp ─╮
	 *             ╷                               ┌───────┬─────────┬───────┐
	 *    X_BLANK  ╷                               │       ╷         ╷       │
	 *             ┌───────────────────────────────┼ ─ ─ ─ ┬ ─ ─ ─ ─ ┬ ─ ─ ─ ├
	 *             ╷                               ╷       ┌─────────┐       ╷
	 *     X_SYNC  ╷                               ╷       │         │       ╷
	 *             ╶───────────────────────────────────────┴ ─ ─ ─ ─ ┴────────
	 */

	assign
		H_BLANK = X >= Width,
		V_BLANK = Y >= Height,
		H_SYNC  = X >= Width+Hfp  && X < Wfull-Hbp,
		V_SYNC  = Y >= Height+Vfp && Y < Hfull-Vbp;

	/*
	 * POS keeps track of the linear position of the currently visible pixel. It
	 * provides an address suitable for accessing linear buffers.
	 *
	 * This implementation takes advantage of V_SYNC to reset the counter before
	 * the next frame starts.
	 */

	always @(posedge CLK)
		if (V_SYNC) POS <= 0;
		else        POS <= POS + !(H_BLANK|V_BLANK);

endmodule
