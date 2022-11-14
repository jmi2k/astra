`include "Riscv.sv"
`include "device/Prng.sv"
`include "device/Pwm.sv"
`include "device/Video.sv"

module SoC(
	input wire CLK,

	/* Onboard LED */
	output wire [2:0] LED,

	/* Ethernet PMOD */
	output wire
		CLK_SPI,
		SPI_IN,
		SPI_OUT,
		CS_ETH,
		INT_ETH_,

	/* VGA PMOD */
	output wire [11:0] PIXEL,
	output wire        H_SYNC_, V_SYNC_
);

	wire
		core_clk,
		led_pulse;

`ifdef ECP5
	/* Use the internal ECP5 oscillator during synthesis */
	OSCG #(.DIV(3)) oscg(.OSC(core_clk));
`else
	/* Use the onboard clock */
	assign core_clk = CLK;
`endif

	PrngDevice dev_prng(
		.CLK(core_clk),
		.*
	);

	VideoDevice #(
		.Pixmap({`R, "/640x480.pbm.mem"})
	) dev_video(
		.CLK(core_clk),
		.CLK_VGA(CLK),
		.*
	);

	PwmDevice dev_pwm(
		.CLK(core_clk),
		.CLK_PWM(CLK),
		.OUT(LED[0]),
		.*
	);

	Riscv cpu(
		.CLK(core_clk),
		.I_IN(32'h00000013),
		.D_IN(32'h7AC0BE11)
	);

	assign
		LED[2:1] = 'b00,
		CLK_SPI  = CLK;

endmodule
