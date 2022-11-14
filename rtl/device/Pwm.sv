`include "Pulse.sv"

module PwmDevice(
	input wire
		CLK,
		CLK_PWM,

	output wire OUT
);

	Pulse pulse(
		.CLK(CLK_PWM),
		.WIDTH(32'h00001000),
		.LIMIT(32'h0000FFFF),
		.*
	);

endmodule
