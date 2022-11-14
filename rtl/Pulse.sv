module Pulse #(
	parameter
		Cntsz = 32
) (
	input wire CLK,

	input  wire [Cntsz-1:0] WIDTH,
	input  wire [Cntsz-1:0] LIMIT
	output wire             OUT,
);

	reg [Cntsz-1:0] counter = 0;
	reg [Cntsz-1:0] width   = 0;
	reg [Cntsz-1:0] limit   = 0;

	always @(posedge CLK)
		if (counter == limit) begin
			counter <= 0;
			width   <= WIDTH;
			limit   <= LIMIT;
		end else
			counter <= counter+1;

	assign OUT = counter < width;

endmodule
