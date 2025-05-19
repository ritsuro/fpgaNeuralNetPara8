module procMemory01 (
	input						CLOCK_50,
	input						RST_N,
	input			[0:0]		resetMode,								// soft reset mode.
	
	input			[12:0]	numberPicture,							// picuture number.
	
	input			[0:0]		flagRequestRun,						// request run for neuralnetwork.

	input			[0:0]		flagBusySDRAM,							// busy SDRAM flag.

	output reg	[23:0]	ramAddress = 24'hffffff,			// read request address for SDRAM.
	input			[15:0]	ramData,									// read SDRAM data.
	input						flagReadOK,								// read SDRAM flag.
	
	output reg	[7:0]		print_rec_03 = 8'd0,					// debug print for VGA text.
	output reg	[24:0]	print_val_03 = 25'd0,				// debug print for VGA text. (28 -> 25bit)
	output reg	[0:0]		print_set_03 = 1'b0,					// debug print for VGA text.

	output		[3:0]		Answer_out,								// answer 0.
	output		[3:0]		AnswerNear_out,						// answer near 0.
	
	output		[3:0]		Answer_out_to_1,						// answer 1.
	output		[3:0]		AnswerNear_out_to_1,					// answer near 1.
	
	output		[3:0]		Answer_out_to_2,						// answer 1.
	output		[3:0]		AnswerNear_out_to_2,					// answer near 1.
	
	output		[3:0]		Answer_out_to_3,						// answer 1.
	output		[3:0]		AnswerNear_out_to_3,					// answer near 1.
	
	output reg [0:0]		flagCompleteCalc = 1'b0,			// complete flag.

	input			[9:0]		image_address_byte_to_0,			// image table read address for draw.
	output		[7:0]		image_data_byte_to_0,				// image table read data for draw.

	input			[9:0]		image_address_byte_to_1,			// image table read address for draw.
	output		[7:0]		image_data_byte_to_1,				// image table read data for draw.

	input			[9:0]		image_address_byte_to_2,			// image table read address for draw.
	output		[7:0]		image_data_byte_to_2					// image table read data for draw.

//	input			[9:0]		image_address_byte_to_3,			// image table read address for draw.
//	output		[7:0]		image_data_byte_to_3					// image table read data for draw.
);


reg	[0:0]		image_WR_00 = 1'b0;
reg	[8:0]		image_wr_address_word_00 = 9'd0;
reg	[15:0]	image_wr_data_word_00 = 16'd0;

reg	[9:0]		image_address_byte_00 = 10'd0;
wire	[7:0]		image_data_byte_00;

memoryM9Kdual memoryM9Kdual(
	.CLOCK_50(CLOCK_50),
	.WR(image_WR_00),
	.wr_address_word(image_wr_address_word_00),
	.wr_data_word(image_wr_data_word_00),
	
	.address_byte_1(image_address_byte_00),
	.data_byte_1(image_data_byte_00),

	.address_byte_2(image_address_byte_to_0),
	.data_byte_2(image_data_byte_to_0)
);


reg	[0:0]		image_WR_01 = 1'b0;
reg	[8:0]		image_wr_address_word_01 = 9'd0;
reg	[15:0]	image_wr_data_word_01 = 16'd0;

reg	[9:0]		image_address_byte_01 = 10'd0;
wire	[7:0]		image_data_byte_01;

memoryM9Kdual memoryM9Kdual_01(
	.CLOCK_50(CLOCK_50),
	.WR(image_WR_01),
	.wr_address_word(image_wr_address_word_01),
	.wr_data_word(image_wr_data_word_01),
	
	.address_byte_1(image_address_byte_01),
	.data_byte_1(image_data_byte_01),

	.address_byte_2(image_address_byte_to_1),
	.data_byte_2(image_data_byte_to_1)
);


reg	[0:0]		image_WR_02 = 1'b0;
reg	[8:0]		image_wr_address_word_02 = 9'd0;
reg	[15:0]	image_wr_data_word_02 = 16'd0;

reg	[9:0]		image_address_byte_02 = 10'd0;
wire	[7:0]		image_data_byte_02;

memoryM9Kdual memoryM9Kdual_02(
	.CLOCK_50(CLOCK_50),
	.WR(image_WR_02),
	.wr_address_word(image_wr_address_word_02),
	.wr_data_word(image_wr_data_word_02),
	
	.address_byte_1(image_address_byte_02),
	.data_byte_1(image_data_byte_02),

	.address_byte_2(image_address_byte_to_2),
	.data_byte_2(image_data_byte_to_2)
);






reg	[0:0]		W1A_WR = 1'b0;
reg	[5:0]		W1A_wr_address_word = 6'd0;
reg	[16:0]	W1A_wr_data_word = 17'd0;
reg	[5:0]		W1A_address_word = 6'd0;
wire	[16:0]	W1A_data_word;

memoryM9K50W memoryM9K50W(
	.CLOCK_50(CLOCK_50),
	.WR(W1A_WR),
	.wr_address_word(W1A_wr_address_word),
	.wr_data_word(W1A_wr_data_word),
	.address_word(W1A_address_word),
	.data_word(W1A_data_word)
);

reg	[0:0]		W2A_WR = 1'b0;
reg	[6:0]		W2A_wr_address_word = 7'd0;
reg	[29:0]	W2A_wr_data_word = 30'd0;
reg	[6:0]		W2A_address_word = 7'd0;
wire	[29:0]	W2A_data_word;

memoryM9K100W memoryM9K100W(
	.CLOCK_50(CLOCK_50),
	.WR(W2A_WR),
	.wr_address_word(W2A_wr_address_word),
	.wr_data_word(W2A_wr_data_word),
	.address_word(W2A_address_word),
	.data_word(W2A_data_word)
);

reg	[0:0]		W3A_WR = 1'b0;
reg	[3:0]		W3A_wr_address_word = 4'd0;
reg	[34:0]	W3A_wr_data_word = 35'd0;
reg	[3:0]		W3A_address_word = 4'd0;
wire	[34:0]	W3A_data_word;
reg	[3:0]		W3A_address_word_2 = 4'd0;
wire	[34:0]	W3A_data_word_2;

memoryM9K10W memoryM9K10W(
	.CLOCK_50(CLOCK_50),
	.WR(W3A_WR),
	.wr_address_word(W3A_wr_address_word),
	.wr_data_word(W3A_wr_data_word),

	.address_word_1(W3A_address_word),
	.data_word_1(W3A_data_word),

	.address_word_2(W3A_address_word_2),
	.data_word_2(W3A_data_word_2)
);

parameter		SEQUENCE_ID_IDLE = 8'd0;
parameter		SEQUENCE_ID_SETUP = 8'd1;
parameter		SEQUENCE_ID_SETUP_LOOP = 8'd2;
parameter		SEQUENCE_ID_READ_START_WAIT = 8'd3;
parameter		SEQUENCE_ID_READ_LOOP = 8'd4;
parameter		SEQUENCE_ID_READ_COMPLETE = 8'd5;

reg	[7:0]		sequenceID = SEQUENCE_ID_SETUP;

parameter		NEURALNET_ID_IDLE = 8'd0;

parameter		NEURALNET_ID_X00_LOOP = 8'd1;
parameter		NEURALNET_ID_X01_LOOP = 8'd2;
parameter		NEURALNET_ID_X02_LOOP = 8'd3;

parameter		NEURALNET_ID_W1_LOOP = 8'd4;
parameter		NEURALNET_ID_B1_LOOP = 8'd5;
parameter		NEURALNET_ID_W2_LOOP = 8'd6;
parameter		NEURALNET_ID_B2_LOOP = 8'd7;
parameter		NEURALNET_ID_W3_LOOP = 8'd8;
parameter		NEURALNET_ID_B3_LOOP = 8'd9;
parameter		NEURALNET_ID_Y_LOOP = 8'd10;

reg	[7:0]		neuralnetID = NEURALNET_ID_IDLE;

parameter		SIZE_IMAGE		 = 10'd784;
parameter		SIZE_IMAGE_WORD = 24'd392;

//parameter		OFFSET_IMAGE   = 392*56;//392*3;//392*59;//392*56;//392*16;//392*4;									// image.
parameter		OFFSET_W1      = 24'h1de840;																						// W1.
parameter		OFFSET_B1      = 24'h1de840 + 24'h9920;																		// b1.
parameter		OFFSET_W2      = 24'h1de840 + 24'h9920 + 24'h0032;															// W2.
parameter		OFFSET_B2      = 24'h1de840 + 24'h9920 + 24'h0032 + 24'h1388;											// b2.
parameter		OFFSET_W3      = 24'h1de840 + 24'h9920 + 24'h0032 + 24'h1388 + 24'h0064;							// W3.
parameter		OFFSET_B3      = 24'h1de840 + 24'h9920 + 24'h0032 + 24'h1388 + 24'h0064 + 24'h03e8;				// b3.
parameter		OFFSET_END     = 24'h1de840 + 24'h9920 + 24'h0032 + 24'h1388 + 24'h0064 + 24'h03e8 + 24'ha;	// end.

reg	[0:0]		flag_NEURALNET_SETUP_run = 1'b0;
reg	[0:0]		flag_NEURALNET_SETUP_OK = 1'b0;

reg	[0:0]		flagRequestRun_keep = 1'b0;			// keep of request run for neuralnetwork.

reg	[23:0]	offset_picture_image_00 = 24'd0;		// picture image offset address.
reg	[23:0]	offset_picture_image_01 = 24'd0;		// picture image offset address.
reg	[23:0]	offset_picture_image_02 = 24'd0;		// picture image offset address.
reg	[23:0]	offset_picture_image_03 = 24'd0;		// picture image offset address.
reg	[23:0]	ww = 24'd0;

reg	[15:0]	debug_checksum_value = 16'd0;
reg	[3:0]		debug_clock01 = 4'd0;
reg	[7:0]		debug_answer_sequence = 4'd0;

reg	[15:0]	debug_checksum_table[6];

reg	[31:0]	debug_TIME_COUNTER_01 = 32'b0;


integer i;

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
	
		ramAddress <= 24'hffffff;
		flagCompleteCalc <= 1'b0;

		sequenceID <= SEQUENCE_ID_SETUP;
		
		debug_checksum_value <= 16'd0;
		debug_clock01 <= 25'd0;
		debug_answer_sequence <= 8'd0;
		
		W3A_address_word_2 <= 4'd0;

		flag_NEURALNET_SETUP_run <= 1'b0;
		flag_NEURALNET_SETUP_OK <= 1'b0;
		flagRequestRun_keep <= 1'b0;
		
		offset_picture_image_00 <= 24'd0;
		offset_picture_image_01 <= 24'd0;
		offset_picture_image_02 <= 24'd0;
		offset_picture_image_03 <= 24'd0;
		
		Answer <= 4'd0;
		flagAnswerComplete <= 1'b0;
		flagNextLoopContinue <= 1'b0;

		for (i=0;i<4;i=i+1) begin
			table_Answer[i] <= 4'd0;
			table_AnswerNear[i] <= 4'd0;
		end
		
		for (i=0;i<6;i=i+1) begin
			debug_checksum_table[i] <= 16'd0;
		end
		
		debug_TIME_COUNTER_01 <= 32'b0;
		
	end else begin
		if (resetMode == 1'b1) begin
		
			ramAddress = 24'hffffff;
			flagCompleteCalc = 1'b0;

			sequenceID <= SEQUENCE_ID_SETUP;
			
			flag_NEURALNET_SETUP_run <= 1'b0;
			flag_NEURALNET_SETUP_OK <= 1'b0;
			flagRequestRun_keep <= 1'b0;

			offset_picture_image_00 <= 24'd0;
			offset_picture_image_01 <= 24'd0;
			offset_picture_image_02 <= 24'd0;
			offset_picture_image_03 <= 24'd0;
			
			Answer <= 4'd0;
			flagAnswerComplete <= 1'b0;
			flagNextLoopContinue <= 1'b0;
			
			for (i=0;i<6;i=i+1) begin
				debug_checksum_table[i] <= 16'd0;
			end
			
		end else if (sequenceID == SEQUENCE_ID_SETUP) begin
			for (i=0;i<6;i=i+1) begin
				debug_checksum_table[i] <= 16'd0;
			end
					
			debug_checksum_value <= 16'd0;
			
			NEURALNET_SETUP;
			
			sequenceID <= SEQUENCE_ID_SETUP_LOOP;
		
		end else if (sequenceID == SEQUENCE_ID_SETUP_LOOP) begin
			if(flag_NEURALNET_SETUP_run == 1'b1) begin
				NEURALNET_SETUP;
			end else begin
				sequenceID <= SEQUENCE_ID_IDLE;
			end

		end else if (sequenceID == SEQUENCE_ID_IDLE) begin							// to be ramAddress == hffffff when IDLE phase  ...
			debug_clock01 <= 4'd0;
			
			if (flagRequestRun == 1'b1 || flagRequestRun_keep == 1'b1) begin	// request run for neuralnetwork.
				if (flag_NEURALNET_SETUP_OK == 1'd1) begin
					flag_NEURALNET_SETUP_OK <= 1'b0;
					
					flagRequestRun_keep <= 1'b0;
					
					if (flagNextLoopContinue == 1'b0) begin
					
						ww = {11'd0, numberPicture} * SIZE_IMAGE_WORD;					// picture image offset address.	(392 word = 784 byte)

						offset_picture_image_00 <= ww;
						offset_picture_image_01 <= ww + (SIZE_IMAGE_WORD * 8);		// <========================================================
						offset_picture_image_02 <= ww + (SIZE_IMAGE_WORD * 16);		// <========================================================
						offset_picture_image_03 <= ww + (SIZE_IMAGE_WORD * 24);		// <========================================================

						ramAddress <= ww;
						
						sequenceID <= SEQUENCE_ID_READ_LOOP;
						
						neuralnetID <= NEURALNET_ID_IDLE;
						
					end else begin
					
						ramAddress <= OFFSET_W1;
						
						sequenceID <= SEQUENCE_ID_READ_LOOP;
						
						neuralnetID <= NEURALNET_ID_IDLE;
						
					end
					
					flagCompleteCalc <= 1'b0;
					flagAnswerComplete <= 1'b0;

					debug_checksum_value <= 16'd0;
					
				end else begin
					flagRequestRun_keep <= 1'b1;											// keep of request run for neuralnetwork.
					
					flagCompleteCalc <= 1'b0;
					flagAnswerComplete <= 1'b0;
					
					sequenceID <= SEQUENCE_ID_SETUP;
				end
			end else begin
				flagCompleteCalc <= flagAnswerComplete;
			end

		end else if (sequenceID == SEQUENCE_ID_READ_LOOP) begin
			if (debug_clock01[0:0] == 0) begin											// address -(1 clock)-> sdram controler -(1 clock)-> return data
				debug_clock01 <= debug_clock01 + 4'd1;
			end else begin
				debug_clock01 <= 4'd0;
				
				if (flagReadOK == 1'b1 &&  flagBusySDRAM == 1'b0) begin			// SDRAM ready check.
				
					NEURALNET_TASK;															// neural network.

					if (ramAddress == OFFSET_END) begin									// SDRAM last address + 1 check.
						sequenceID <= SEQUENCE_ID_READ_COMPLETE;
					end

					//if (neuralnetID == NEURALNET_ID_X00_LOOP && ImageOffset_00 == SIZE_IMAGE - 2) begin	// X (Image)
					if (neuralnetID == NEURALNET_ID_X02_LOOP && ImageOffset_00 == SIZE_IMAGE - 2) begin	// X (Image) <================================
						ramAddress <= OFFSET_W1;											// next address.
					end else begin
						ramAddress <= ramAddress + 24'd1;								// next address.
					end
				
					debug_checksum_value[15:0] <= debug_checksum_value[15:0] + {8'd0, ramData[7:0]} + {8'd0, ramData[15:8]};	// checksum calc.
				end
			end
			
		end else if (sequenceID == SEQUENCE_ID_READ_COMPLETE) begin

			if (flagNextLoopContinue == 1'b1) begin
			
				flagRequestRun_keep <= 1'b1;												// keep of request run for neuralnetwork.
				sequenceID <= SEQUENCE_ID_IDLE;
				
			end else if (flagAnswerComplete == 1'b1) begin
			
				sequenceID <= SEQUENCE_ID_IDLE;

			end else begin
			
				NEURALNET_TASK;																// neural network.
				
			end 
		end
		
		if (flagRequestRun == 1'b1) begin
			debug_TIME_COUNTER_01 <= 32'd0;
		end else if (sequenceID != SEQUENCE_ID_IDLE || flagRequestRun_keep == 1'b1) begin
			debug_TIME_COUNTER_01 <= debug_TIME_COUNTER_01 + 32'd1;
		end
		
		
		// debug dump.
		print_rec_03[7:0] <= 8'd20 + debug_answer_sequence;
		print_set_03 <= 1'b1;

		if (debug_answer_sequence < 8'd10) begin
			if (flag_NEURALNET_SETUP_run == 1'b1) begin
				print_val_03[24:0] <= {19'd0, W1A_wr_address_word[5:0]};
			end else begin
				if (W3A_data_word_2[34:25] != 10'd0) begin
					print_val_03[24:0] <= 25'h1ffffff;		// 28bit -> 25bit
				end else begin
					print_val_03[24:0] <= W3A_data_word_2[24:0];		// 28bit -> 25bit
				end
			end
			
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
			
			if (W3A_address_word_2 != 4'd9)
				W3A_address_word_2 <= W3A_address_word_2 + 4'd1;
			else 
				W3A_address_word_2 <= 4'd0;

		end else if (debug_answer_sequence == 8'd10) begin
			print_val_03[24:0] <= {17'd0, neuralnetID[7:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd11) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_value[15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd12) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_table[0][15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd13) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_table[1][15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd14) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_table[2][15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd15) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_table[3][15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd16) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_table[4][15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
		end else if (debug_answer_sequence == 8'd17) begin
			print_val_03[24:0] <= {9'd0, debug_checksum_table[5][15:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
			
		end else if (debug_answer_sequence == 8'd18) begin
			print_val_03[24:0] <= {21'd0, Answer[3:0]};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
			
		end else if (debug_answer_sequence == 8'd19) begin
			print_val_03[24:0] <= AnswerValueMax[24:0];
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
			
		end else if (debug_answer_sequence == 8'd20) begin
			print_val_03[24:0] <= {21'd0, AnswerNear};
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
			
		end else if (debug_answer_sequence == 8'd21) begin
			if (AnswerValueMax2[34:25] != 10'd0) begin
				print_val_03[24:0] <= 25'h1ffffff;		// 28bit -> 25bit
			end else begin
				print_val_03[24:0] <= AnswerValueMax2[24:0];
			end
			debug_answer_sequence <= debug_answer_sequence + 8'd1;
			
		end else if (debug_answer_sequence == 8'd22) begin
			print_val_03[24:0] <= debug_TIME_COUNTER_01[31:7];
			debug_answer_sequence <= 8'd0;
		end
	end
end


task NEURALNET_SETUP;
begin
	if (flag_NEURALNET_SETUP_run == 1'b0) begin
		flag_NEURALNET_SETUP_run <= 1'b1;
		
		W1A_WR <= 1'b1;
		W1A_wr_address_word <= 6'd0;
		W1A_wr_data_word <= 17'd0;

		W2A_WR <= 1'b1;
		W2A_wr_address_word <= 7'd0;
		W2A_wr_data_word <= 30'd0;
		
		W3A_WR <= 1'b1;
		W3A_wr_address_word = 4'd0;
		W3A_wr_data_word = 35'd0;
		
	end else begin
		if (W1A_wr_address_word != 6'd50) begin
			W1A_WR <= 1'b1;
			W1A_wr_address_word <= W1A_wr_address_word + 6'd1;
		end
		
		if (W2A_wr_address_word != 7'd100) begin
			W2A_WR <= 1'b1;
			W2A_wr_address_word <= W2A_wr_address_word + 7'd1;
		end

		if (W3A_wr_address_word != 4'd10) begin
			W3A_WR <= 1'b1;
			W3A_wr_address_word <= W3A_wr_address_word + 4'd1;
		end
		
		if (W2A_wr_address_word == 7'd100) begin
			flag_NEURALNET_SETUP_run <= 1'b0;
			flag_NEURALNET_SETUP_OK <= 1'd1;
			
			W1A_WR <= 1'b0;
			W1A_wr_address_word <= 6'd0;
			W2A_WR <= 1'b0;
			W2A_wr_address_word <= 7'd0;
			W3A_WR <= 1'b0;
			W3A_wr_address_word <= 4'd0;
		end
	end
end
endtask

reg	[3:0]		current_image_record = 4'd0;

reg	[9:0]		ImageOffset_00 = 10'd0;

reg	[7:0]		W1AOffset = 8'd0;
reg	[7:0]		W2AOffset = 8'd0;
reg	[7:0]		W3AOffset = 8'd0;

reg	[3:0]		Answer = 4'd0;
reg	[3:0]		AnswerNear = 4'd0;
reg	[15:0]	AnswerCounter = 4'd0;
reg	[34:0]	AnswerValueMax = 35'd0;
reg	[34:0]	AnswerValueMax2 = 35'd0;
reg	[15:0]	AnswerSum = 16'd0;

reg	[3:0]		table_Answer[4];
reg	[3:0]		table_AnswerNear[4];

reg	[0:0]		flagAnswerComplete = 1'b0;
reg	[0:0]		flagNextLoopContinue = 1'b0;

function [16:0] FIXPOINT_W1;
	input [15:0] d;
	FIXPOINT_W1 = (d[15:15] == 1'b1) ? {1'b1, d[15:0]} : {1'b0, d[15:0]};
endfunction

function [29:0] FIXPOINT_W2;
	input [15:0] d;
	FIXPOINT_W2 = (d[15:15] == 1'b1) ? {14'b11_1111_1111_1111, d[15:0]} : {14'd0, d[15:0]};
endfunction

function [34:0] FIXPOINT_W3;
	input [15:0] d;
	FIXPOINT_W3 = (d[15:15] == 1'b1) ? {19'b111_1111_1111_1111_1111, d[15:0]} : {19'd0, d[15:0]};
endfunction

function [16:0] ReLU_W1;
	input [16:0] d;
	ReLU_W1 = (d[16:16] == 1'b0) ? d[16:0] : 17'd0;
endfunction

function [29:0] ReLU_W2;
	input [29:0] d;
	ReLU_W2 = (d[29:29] == 1'b0) ? d[29:0] : 30'd0;
endfunction

function [34:0] ReLU_W3;
	input [34:0] d;
	ReLU_W3 = (d[34:34] == 1'b0) ? d[34:0] : 35'd0;
endfunction

task NEURALNET_TASK;
begin

	if (ramAddress == offset_picture_image_00) begin
		image_wr_data_word_00[15:0] <= ramData[15:0];
		image_wr_address_word_00 <= 9'd0;
		image_WR_00 <= 1'b1;

		ImageOffset_00 <= 10'd2;
		
		debug_checksum_table[0] <= ramData;

		neuralnetID <= NEURALNET_ID_X00_LOOP;
		
		// memory read/write parameter setup.
		current_image_record <= 4'd0;
		
		image_address_byte_00 <= 10'd0;
		image_address_byte_01 <= 10'd0;
		image_address_byte_02 <= 10'd0;
		
		W1A_WR <= 1'b0;
		W1A_wr_address_word <= 6'd0;
		W1A_wr_data_word <= 17'd0;
		W2A_WR <= 1'b0;
		W2A_wr_address_word <= 7'd0;
		W2A_wr_data_word <= 30'd0;
		
	end else if (ramAddress == offset_picture_image_01) begin
		image_wr_data_word_01[15:0] <= ramData[15:0];
		image_wr_address_word_01 <= 9'd0;
		image_WR_01 <= 1'b1;

		ImageOffset_00 <= 10'd2;
		
		debug_checksum_table[0] <= ramData;

		neuralnetID <= NEURALNET_ID_X01_LOOP;
		
		
	end else if (ramAddress == offset_picture_image_02) begin
		image_wr_data_word_02[15:0] <= ramData[15:0];
		image_wr_address_word_02 <= 9'd0;
		image_WR_02 <= 1'b1;

		ImageOffset_00 <= 10'd2;
		
		debug_checksum_table[0] <= ramData;

		neuralnetID <= NEURALNET_ID_X02_LOOP;
		
	end else begin
		
		case (ramAddress)
		OFFSET_W1 : begin
				image_WR_00 <= 1'b0;			// image memory write disable.

				if (current_image_record == 4'd0) begin
					W1A_wr_data_word[16:0] <= {9'd0, image_data_byte_00[7:0]} * FIXPOINT_W1(ramData);
				end else if (current_image_record == 4'd1) begin
					W1A_wr_data_word[16:0] <= {9'd0, image_data_byte_01[7:0]} * FIXPOINT_W1(ramData);
				end else begin
					W1A_wr_data_word[16:0] <= {9'd0, image_data_byte_02[7:0]} * FIXPOINT_W1(ramData);
				end

				ImageOffset_00 <= 10'd0;
					
				W1A_WR <= 1'b1;
				W1A_wr_address_word <= 6'd0;
				W1A_address_word <= 6'd1;
				
				W1AOffset <= 8'd1;

				neuralnetID <= NEURALNET_ID_W1_LOOP;
			end
			
		OFFSET_B1 : begin
				debug_checksum_table[1] <= {15'd0, W1A_data_word[16:16]} + W1A_data_word[15:0];
		
				W1A_wr_data_word[16:0] <= ReLU_W1(W1A_data_word[16:0] + FIXPOINT_W1(ramData));
				W1A_WR <= 1'b1;
				W1A_wr_address_word <= 6'd0;
				W1A_address_word <= 6'd1;

				W1AOffset <= 8'd1;
				
				neuralnetID <= NEURALNET_ID_B1_LOOP;
			end
		
		OFFSET_W2 : begin
				W1A_WR <= 1'b0;
				W1A_address_word <= 6'd0;

				W2A_wr_data_word[29:0] <= {13'd0, W1A_data_word[16:0]} * FIXPOINT_W2(ramData);
				W2A_WR <= 1'b1;
				W2A_wr_address_word <= 7'd0;
				W2A_address_word <= 7'd1;
				
				W2AOffset <= 8'd1;
				W1AOffset <= 8'd0;
				neuralnetID <= NEURALNET_ID_W2_LOOP;
			end
		
		OFFSET_B2 : begin
				debug_checksum_table[2] <= {2'd0, W2A_data_word[29:16]} + W2A_data_word[15:0];

				W2A_wr_data_word[29:0] <= ReLU_W2(W2A_data_word[29:0] + FIXPOINT_W2(ramData));
				W2A_WR <= 1'b1;
				W2A_wr_address_word <= 7'd0;
				W2A_address_word <= 7'd1;
				
				W2AOffset <= 8'd1;
				neuralnetID <= NEURALNET_ID_B2_LOOP;
			end
		
		OFFSET_W3 : begin
				W2A_WR <= 1'b0;
				W2A_address_word <= 7'd0;

				W3A_wr_data_word[34:0] <= {5'd0, W2A_data_word[29:0]} * FIXPOINT_W3(ramData);
				W3A_WR <= 1'b1;
				W3A_wr_address_word <= 4'd0;
				W3A_address_word <= 4'd1;
		
				W3AOffset <= 8'd1;
				W2AOffset <= 8'd0;
				neuralnetID <= NEURALNET_ID_W3_LOOP;
			end

		OFFSET_B3 : begin
				debug_checksum_table[3] <= {13'd0, W3A_data_word[34:32]} + W3A_data_word[31:16] + W3A_data_word[15:0];

				W3A_wr_data_word[34:0] <= ReLU_W3(W3A_data_word[34:0] + FIXPOINT_W3(ramData));
				W3A_WR <= 1'b1;
				W3A_wr_address_word <= 4'd0;
				W3A_address_word <= 4'd1;

				W3AOffset <= 8'd1;
				neuralnetID <= NEURALNET_ID_B3_LOOP;
			end

		OFFSET_END: begin
				if (neuralnetID != NEURALNET_ID_Y_LOOP) begin
					W3A_WR <= 1'b0;
					W3A_address_word <= 4'd0;
				
					Answer <= 4'd0;
					AnswerNear <= 4'd0;
					AnswerCounter <= 4'd0;
					AnswerValueMax <= 35'd0;
					AnswerValueMax2<= 35'd0;
					AnswerSum <= 16'd0;
					flagAnswerComplete <= 1'b0;
					flagNextLoopContinue <= 1'b0;
					
					neuralnetID <= NEURALNET_ID_Y_LOOP;
				end
			end
		
		default :	NEURALNET_TASK_LOOP;
		endcase
	end
end
endtask


task NEURALNET_TASK_LOOP;
begin


	if (neuralnetID == NEURALNET_ID_X00_LOOP) begin						// X (Image)
		if (ImageOffset_00 != SIZE_IMAGE) begin

			ImageOffset_00 <= ImageOffset_00 + 10'd2;

			image_wr_data_word_00[15:0] <= ramData[15:0];
			image_wr_address_word_00 <= image_wr_address_word_00 + 9'd1;
			image_WR_00 <= 1'b1;
			
			debug_checksum_table[0] <= debug_checksum_table[0] + ramData;
		end else begin
			image_WR_00 <= 1'b0;
		end

		
	end else if (neuralnetID == NEURALNET_ID_X01_LOOP) begin			// X (Image)
		if (ImageOffset_00 != SIZE_IMAGE) begin

			ImageOffset_00 <= ImageOffset_00 + 10'd2;

			image_wr_data_word_01[15:0] <= ramData[15:0];
			image_wr_address_word_01 <= image_wr_address_word_01 + 9'd1;
			image_WR_01 <= 1'b1;
			
			debug_checksum_table[0] <= debug_checksum_table[0] + ramData;
		end else begin
			image_WR_01 <= 1'b0;
		end

		
	end else if (neuralnetID == NEURALNET_ID_X02_LOOP) begin			// X (Image)
		if (ImageOffset_00 != SIZE_IMAGE) begin

			ImageOffset_00 <= ImageOffset_00 + 10'd2;

			image_wr_data_word_02[15:0] <= ramData[15:0];
			image_wr_address_word_02 <= image_wr_address_word_02 + 9'd1;
			image_WR_02 <= 1'b1;
			
			debug_checksum_table[0] <= debug_checksum_table[0] + ramData;
		end else begin
			image_WR_02 <= 1'b0;
		end

		
	end else if (neuralnetID == NEURALNET_ID_W1_LOOP) begin			// W1 (784 x 50)
	
		if (ImageOffset_00 != SIZE_IMAGE) begin
		
			W1A_wr_data_word[16:0] <= W1A_data_word[16:0] + ({9'd0, ((current_image_record == 4'd0) ? image_data_byte_00[7:0] :
																						(current_image_record == 4'd1) ? image_data_byte_01[7:0] : 
																																	image_data_byte_02[7:0])} * FIXPOINT_W1(ramData));
			W1A_WR <= 1'b1;
			W1A_wr_address_word <= W1A_address_word;
			
			if (W1AOffset != 8'd49) begin
				W1AOffset <= W1AOffset + 8'd1;
				
				W1A_address_word <= W1A_address_word + 6'd1;
				
			end else begin
				W1AOffset <= 8'd0;
				
				W1A_address_word <= 6'd0;
				
				if (current_image_record == 4'd0) begin
					image_address_byte_00 <= image_address_byte_00 + 10'd1;
				end else if (current_image_record == 4'd1)  begin 
					image_address_byte_01 <= image_address_byte_01 + 10'd1;
				end else begin 
					image_address_byte_02 <= image_address_byte_02 + 10'd1;
				end

				ImageOffset_00 <= ImageOffset_00 + 10'd1;
			end
		end
	
	end else if (neuralnetID == NEURALNET_ID_B1_LOOP) begin			// b1 (50)
		if (W1AOffset != 8'd50) begin
		
			debug_checksum_table[1] <= debug_checksum_table[1] + {15'd0, W1A_data_word[16:16]} + W1A_data_word[15:0];
			
			W1AOffset <= W1AOffset + 8'd1;

			W1A_wr_data_word[16:0] <= ReLU_W1(W1A_data_word[16:0] + FIXPOINT_W1(ramData));
			W1A_WR <= 1'b1;
			W1A_wr_address_word <= W1AOffset;
			
			if (W1AOffset != 8'd49) begin
				W1A_address_word <= W1A_address_word + 6'd1;
			end else begin
				W1A_address_word <= 6'd0;
			end
		end
	
	end else if (neuralnetID == NEURALNET_ID_W2_LOOP) begin			// W2 (50 x 100)
		if (W1AOffset != 8'd50) begin
		
			W2A_wr_data_word[29:0] <= W2A_data_word[29:0] + ({13'd0, W1A_data_word[16:0]} * FIXPOINT_W2(ramData));
			W2A_WR <= 1'b1;
			W2A_wr_address_word <= W2A_address_word;
		
			if (W2AOffset != 8'd99) begin
				W2AOffset <= W2AOffset + 8'd1;
				
				W2A_address_word <= W2A_address_word + 7'd1;

			end else begin
				W2AOffset <= 8'd0;
				
				W2A_address_word <= 7'd0;

				W1A_address_word <= W1AOffset + 6'd1;

				W1AOffset <= W1AOffset + 8'd1;
			end
		end
	
	end else if (neuralnetID == NEURALNET_ID_B2_LOOP) begin			// b2 (100)
		if (W2AOffset != 8'd100) begin
		
			debug_checksum_table[2] <= debug_checksum_table[2] + {2'd0, W2A_data_word[29:16]} + W2A_data_word[15:0];
		
			W2AOffset <= W2AOffset + 8'd1;

			W2A_wr_data_word[29:0] <= ReLU_W2(W2A_data_word[29:0] + FIXPOINT_W2(ramData));
			W2A_WR <= 1'b1;
			W2A_wr_address_word <= W2A_address_word;

			if (W2AOffset != 8'd99) begin
				W2A_address_word <= W2A_address_word + 7'd1;
			end else begin
				W2A_address_word <= 7'd0;
			end
		end
	
	end else if (neuralnetID == NEURALNET_ID_W3_LOOP) begin			// W3 (100 x 10)
		if (W2AOffset != 8'd100) begin

			W3A_wr_data_word[34:0] <= W3A_data_word[34:0] + ({5'd0, W2A_data_word[29:0]} * FIXPOINT_W3(ramData));
			W3A_WR <= 1'b1;
			W3A_wr_address_word <= W3A_address_word;
		
			if (W3AOffset != 8'd9) begin
				W3AOffset <= W3AOffset + 8'd1;

				W3A_address_word <= W3A_address_word + 4'd1;
							
			end else begin
				W3AOffset <= 8'd0;
				
				W3A_address_word <= 4'd0;
				
				W2A_address_word <= W2A_address_word + 7'd1;

				W2AOffset <= W2AOffset + 8'd1;
			end
		end
	
	end else if (neuralnetID == NEURALNET_ID_B3_LOOP) begin			// b3 (10)
		if (W3AOffset != 8'd10) begin

			debug_checksum_table[3] <= debug_checksum_table[3] + {13'd0, W3A_data_word[34:32]} + W3A_data_word[31:16] + W3A_data_word[15:0];

			W3AOffset <= W3AOffset + 8'd1;

			W3A_wr_data_word[34:0] <= ReLU_W3(W3A_data_word[34:0] + FIXPOINT_W3(ramData));
			W3A_WR <= 1'b1;
			W3A_wr_address_word <= W3A_address_word;

			if (W3AOffset != 8'd9) begin
				W3A_address_word <= W3A_address_word + 4'd1;
			end else begin
				W3AOffset <= 8'd0;
			end
		end
	
	end else if (neuralnetID == NEURALNET_ID_Y_LOOP) begin
	
		if (AnswerCounter != 4'd10) begin
		
			if (AnswerValueMax < W3A_data_word[34:0]) begin

				AnswerValueMax2 <= AnswerValueMax;
				AnswerNear <= Answer;

				AnswerValueMax <= W3A_data_word[34:0];
				Answer <= AnswerCounter;
				
			end else if (AnswerValueMax2 < W3A_data_word[34:0]) begin
				AnswerValueMax2 <= W3A_data_word[34:0];
				AnswerNear <= AnswerCounter;
			end
			
			AnswerSum <= AnswerSum + {13'd0, W3A_data_word[34:32]} + W3A_data_word[31:16] + W3A_data_word[15:0];

			AnswerCounter <= AnswerCounter + 4'd1;
			
			W3A_address_word <= W3A_address_word + 4'd1;

		end else begin
			debug_checksum_table[4] <= AnswerSum;
			debug_checksum_table[5] <= debug_checksum_table[0] + debug_checksum_table[1] + debug_checksum_table[2] + debug_checksum_table[3] + AnswerSum;

			table_Answer[current_image_record] <= Answer;
			table_AnswerNear[current_image_record] <= AnswerNear;
			
			if (current_image_record ==  4'd2) begin
				flagAnswerComplete <= 1'b1;
			end else begin
				current_image_record <= current_image_record + 4'd1;			// <==================================================================
				flagNextLoopContinue <= 1'b1;
			end
		end
	end
end
endtask

assign Answer_out				= table_Answer[0];
assign AnswerNear_out		= table_AnswerNear[0];

assign Answer_out_to_1		= table_Answer[1];
assign AnswerNear_out_to_1 = table_AnswerNear[1];

assign Answer_out_to_2		= table_Answer[2];
assign AnswerNear_out_to_2 = table_AnswerNear[2];

assign Answer_out_to_3		= table_Answer[3];
assign AnswerNear_out_to_3 = table_AnswerNear[3];

endmodule
