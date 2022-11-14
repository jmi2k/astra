module Riscv #(
	parameter
		Addrsz    = 32,
		Resetaddr = 32'h00000000
) (
	input wire
		CLK,
		IRQ,

	output wire [Addrsz-1:0] D_ADDR,   I_ADDR
	input  wire       [31:0] D_IN,     I_IN,
	output wire       [31:0] D_OUT,
	output wire        [3:0] D_SEL,
	input  wire              D_ACK,    I_ACK,
	output wire              D_STROBE, I_STROBE,
	output wire              D_WE
);

	localparam
		Access  = 1<<0,
		Execute = 1<<1,
		Nop     = 32'h00000013;

	reg  [1:0] stage = Access;
	reg [31:2] instr = Nop;

	reg [31:0]
		registers [32],
		vd, vs1, vs2,
		pc = Resetaddr;

	wire [9:0] rs;
	wire [6:0] funct7;
	wire [4:0] opcode, rd, rs1, rs2;
	wire [2:0] funct3;

	assign
		{funct7, rs, funct3, rd, opcode} = instr,
		{rs2, rs1} = I_IN[24:15];

	wire
		is_store  = opcode == 5'b01000,  // [vs₁+Simm] ← vs₂
		is_load   = opcode == 5'b00000,  // vd ← [vs₁+Iimm]
		is_lui    = opcode == 5'b01101,  // vd ← Uimm
		is_alui   = opcode == 5'b00100,  // vd ← vs₁◇Iimm
		is_alur   = opcode == 5'b01100,  // vd ← vs₁◇vs2
		is_auipc  = opcode == 5'b00101,  // vd ← PC+Uimm
		is_jal    = opcode == 5'b11011,  // vd ← PC+4,  PC ←  PC+Jimm
		is_jalr   = opcode == 5'b11001,  // vd ← PC+4,  PC ← vs1+Iimm
		is_branch = opcode == 5'b11000;  // if(vs₁◇vs₂) PC ←  PC+Bimm

	reg write_back;

	always @(posedge CLK) case (stage)

	/*
	 * Perform write-back and memory I/O for the last instruction while fetching
	 * the next one alongside its operands.
	 */

	Access: begin
		if (write_back)
			registers[rd] <= vd;

		instr <= I_IN[31:2];
		vs1   <= registers[rs1];
		vs2   <= registers[rs2];
	end

	/*
	 * Calculate operation result and next PC.
	 */

	Execute: begin
		write_back <=
			!is_load   &
			!is_branch &
			|rd;
	end

	endcase

endmodule
