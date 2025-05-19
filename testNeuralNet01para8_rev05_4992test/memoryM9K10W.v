module memoryM9K10W(
	input						CLOCK_50,
	input						WR,
	
	input			[3:0]		wr_address_word,	// from data to word address.
	input			[34:0]	wr_data_word,		// from data 32bit word. (35bit)
	
	input			[3:0]		address_word_1,	// read word address 1.(before 1 clock)
	output 		[34:0]	data_word_1,		// word data 1. (35bit)

	input			[3:0]		address_word_2,	// read word address 2.(before 1 clock)
	output 		[34:0]	data_word_2			// word data 2. (35bit)
);

reg [34:0] memory [0:9];						// <---- ok.  (M9K memory block assign of automatic)

always @(posedge CLOCK_50)
begin
	if (WR == 1'b1) begin
		memory[wr_address_word][34:0] <= wr_data_word[34:0];
	end
end

assign data_word_1[34:0] = memory[address_word_1][34:0];
assign data_word_2[34:0] = memory[address_word_2][34:0];

endmodule
