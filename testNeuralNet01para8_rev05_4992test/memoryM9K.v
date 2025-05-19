module memoryM9K(
	input						CLOCK_50,
	input						WR,
	
	input			[8:0]		wr_address_word,	// from SDRAM word address.
	input			[15:0]	wr_data_word,		// from SDRAM 16bit word.
	
	input			[9:0]		address_byte,		// read byte address.(before 1 clock)
	output		[7:0]		data_byte			// byte data.
);

reg [15:0] memory [0:511];						// <---- ok.  (M9K memory block assign of automatic)

always @(posedge CLOCK_50)
begin
	if (WR == 1'b1) begin
		memory[wr_address_word][15:0] <= wr_data_word[15:0];
	end
end

assign data_byte[7:0] = (address_byte[0:0] == 1'b0) ? memory[address_byte[9:1]][7:0] : memory[address_byte[9:1]][15:8];

endmodule
