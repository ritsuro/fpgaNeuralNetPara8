module memoryM9K50W(
	input						CLOCK_50,
	input						WR,
	
	input			[5:0]		wr_address_word,	// from data to word address.
	input			[16:0]	wr_data_word,		// from data 32bit word. (17bit)
	
	input			[5:0]		address_word,		// read word address.(before 1 clock)
	output 		[16:0]	data_word			// word data. (17bit)
);

reg [16:0] memory [0:63];						// <---- ok.  (M9K memory block assign of automatic)

always @(posedge CLOCK_50)
begin
	if (WR == 1'b1) begin
		memory[wr_address_word][16:0] <= wr_data_word[16:0];
	end
end

assign data_word[16:0] = memory[address_word][16:0];

endmodule
