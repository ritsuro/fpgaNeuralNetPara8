module memoryM9K100W(
	input						CLOCK_50,
	input						WR,
	
	input			[6:0]		wr_address_word,	// from data to word address.
	input			[29:0]	wr_data_word,		// from data 32bit word. (30bit)
	
	input			[6:0]		address_word,		// read word address.(before 1 clock)
	output 		[29:0]	data_word			// word data. (30bit)
);

reg [29:0] memory [0:127];						// <---- ok.  (M9K memory block assign of automatic)

always @(posedge CLOCK_50)
begin
	if (WR == 1'b1) begin
		memory[wr_address_word][29:0] <= wr_data_word[29:0];
	end
end

assign data_word[29:0] = memory[address_word][29:0];

endmodule
