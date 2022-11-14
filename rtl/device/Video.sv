`include "Delay.sv"
`include "Dpram.sv"
`include "Vga.sv"

module VideoDevice #(
    parameter
        Pixmap = 'x
) (
    input wire
        CLK,
        CLK_VGA,

    output wire [11:0] PIXEL,
    output wire        H_SYNC_, V_SYNC_
);

`include "style/Beam.sv"

	wire
		blank,
		h_blank, v_blank,
		h_sync,  v_sync;

	wire [31:0] word;
	wire [18:0] pos;
	wire  [4:0] subpos;

	Dpram #(
		.Data(Pixmap),
		.Bufsz(640*480 / 32)
	) ram_video(
		.CLK_1(CLK),
		.W_SEL_1(4'b0000),
		.CLK_2(CLK_VGA),
		.ADDR_2(pos[18:5]),
		.OUT_2(word),
		.W_SEL_2(4'b0000)
	);

	Vga vga(
		.CLK(CLK_VGA),
		.POS(pos),
		.H_BLANK(h_blank),
		.V_BLANK(v_blank),
		.H_SYNC(h_sync),
		.V_SYNC(v_sync)
	);

	/*
	 * Video RAM takes 1 clock cycle to retrieve the value, so every signal used
	 * alongside it must be delayed accordingly.
	 */

	Delay #(
        .Depth(1),
		.Width(5+1+1+1)
	) delay_1(
		.CLK(CLK_VGA),
		.IN( {pos[4:0], !h_sync, !v_sync, h_blank|v_blank}),
		.OUT({subpos,   H_SYNC_, V_SYNC_, blank})
	);

	assign PIXEL = blank ? 0 : word[subpos] ? Fgcolor : Bgcolor;


endmodule
