// EP4CE22F17C6N FPGA
module testNeuralNet01 (
	input					CLOCK_50,
	input					RST_N,
	input					KEY,
	input					BUTTON01,			// pull-up
	output  [7:0]		LED,

	input					SPI_MISO,
	output				SPI_MOSI,
	input					SPI_CLOCK,
	input					SPI_ENABLE_N,

	output	[12:0]	DRAM_A,
	inout		[15:0]	DRAM_DQ,
	output	[1:0]		DRAM_BA,
	output	[1:0]		DRAM_DQM,
	output				DRAM_RAS_N,
	output				DRAM_CAS_N,
	output				DRAM_CKE,
	output				DRAM_CLK,
	output				DRAM_WE_N,
	output				DRAM_CS_N,

	input		[2:0]		KEY_X,				// Pull-Up 
	output 	[2:0]		KEY_Y,				// Pull-Up
	
	output	[2:0]		VGA_R,
	output	[2:0]		VGA_G,
	output	[2:0]		VGA_B,
	output				VGA_V_SYNC,
	output				VGA_H_SYNC
);

// SPI I/O reg.
reg	[0:0]		SPI_MISO_reg = 1'b0;
wire	[0:0]		SPI_MOSI_W;
reg	[0:0]		SPI_CLOCK_reg = 1'b0;
reg	[0:0]		SPI_ENABLE_N_reg = 1'b0;

wire	[7:0]		receiveData_spi;
wire	[24:0]	receiveAddress_spi;
wire	[0:0]		receiveResetMode_spi;
wire	[0:0]		receiveDisableNow_spi;

connectSPI01 connectSPI01 (
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.BUTTON_COMM_RESET(KEY),

		.SPI_MISO(SPI_MISO_reg),
		.SPI_MOSI(SPI_MOSI_W),
		.SPI_CLOCK(SPI_CLOCK_reg),
		.SPI_ENABLE_N(SPI_ENABLE_N_reg),
		
		.receiveData(receiveData_spi),				// <====================== SPI data
		.receiveAddress(receiveAddress_spi),		// <====================== address.
		.receiveResetMode(receiveResetMode_spi),
		.receiveDisableNow(receiveDisableNow_spi)
	);

wire	[0:0]		receiveResetMode;
wire	[0:0]		receiveDisableNow;
	
wire	[23:0]	ramWriteAddress;
wire	[15:0]	ramWriteData0;
wire	[15:0]	ramWriteData1;
wire	[15:0]	ramWriteData2;
wire	[15:0]	ramWriteData3;	
wire	[15:0]	checksum;

wire	[0:0]		autoRefreshMode;

receiveDataConv receiveDataConv (
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),

		.receiveData_i(receiveData_spi),
		.receiveAddress_i(receiveAddress_spi),
		.receiveResetMode_i(receiveResetMode_spi),
		.receiveDisableNow_i(receiveDisableNow_spi),
		
		.receiveResetMode(receiveResetMode),
		.receiveDisableNow(receiveDisableNow),

		.receiveAddress(ramWriteAddress),
		.receiveData0(ramWriteData0),
		.receiveData1(ramWriteData1),
		.receiveData2(ramWriteData2),
		.receiveData3(ramWriteData3),
		
		.checksum(checksum),
		
		.flagWriteBusy(flagWriteBusy),
		.flagAutoRefreshBusy(flagAutoRefreshBusy),
		.flagBusy(flagBusySDRAM),									// busy flag(startup, write, read)
		.flagWriteBurst(flagWriteBurst),
		.flagReadBurst(flagReadBurst),
		.flagAutoRefreshCycle(flagAutoRefreshCycle),			// now CBR Auto-Refresh...
		
		.flagCompleteCalc(flagCompleteCalc_v00),

		.autoRefreshMode(autoRefreshMode)						// CBR Auto-Refresh(REF) 
	);
	

wire	[0:0]		ramResetMode;
wire	[0:0]		ramWriteMode;
	
assign	ramResetMode = receiveResetMode;
assign	ramWriteMode = ~receiveDisableNow;

wire	[0:0]		flagWriteBusy;
wire	[0:0]		flagAutoRefreshBusy;
wire	[0:0]		flagBusySDRAM;
wire	[0:0]		flagWriteBurst;
wire	[0:0]		flagReadBurst;
wire	[0:0]		flagAutoRefreshCycle;

wire	[23:0]	ramAddress;			// from procMemory01.
wire	[15:0]	ramData;
wire				flagReadOK;

connectSDRAM connectSDRAM (
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),

		.DRAM_A(DRAM_A),
		.DRAM_DQ(DRAM_DQ),
		.DRAM_BA(DRAM_BA),
		.DRAM_DQM(DRAM_DQM),
		.DRAM_RAS_N(DRAM_RAS_N),
		.DRAM_CAS_N(DRAM_CAS_N),
		.DRAM_CKE(DRAM_CKE),
		.DRAM_CLK(DRAM_CLK),
		.DRAM_WE_N(DRAM_WE_N),
		.DRAM_CS_N(DRAM_CS_N),
		
		.resetMode(ramResetMode),						// resetMode.
		.writeMode(ramWriteMode),						// writeMode.
		.autoRefreshMode(autoRefreshMode),			// CBR Auto-Refresh(REF) 
		
		.ramWriteAddress(ramWriteAddress),
		.ramWriteData0(ramWriteData0),
		.ramWriteData1(ramWriteData1),
		.ramWriteData2(ramWriteData2),
		.ramWriteData3(ramWriteData3),
		
		.flagWriteBusy(flagWriteBusy),
		.flagAutoRefreshBusy(flagAutoRefreshBusy),
		.flagBusy(flagBusySDRAM),
		.flagWriteBurst(flagWriteBurst),
		.flagReadBurst(flagReadBurst),
		.flagAutoRefreshCycle(flagAutoRefreshCycle),
		
		.ramAddress(ramAddress),
		.ramData(ramData),
		.flagReadOK(flagReadOK)
	);

wire	[2:0]		r_val;
wire	[2:0]		g_val;
wire	[2:0]		b_val;

reg	[2:0]		r_val_bg = 3'b110;
reg	[2:0]		g_val_bg = 3'b111;
reg	[2:0]		b_val_bg = 3'b111;

reg	[2:0]		r_val_bg2 = 3'd0;
reg	[2:0]		g_val_bg2 = 3'd0;
reg	[2:0]		b_val_bg2 = 3'd0;

reg	[3:0]		r_val_bg3 = 4'd0;
reg	[3:0]		g_val_bg3 = 4'd0;
reg	[3:0]		b_val_bg3 = 4'd0;

// GPIO VGA.
wire	[19:0]	dot;
wire	[19:0]	y_count;

wire	[2:0]		VGA_R_w;
wire	[2:0]		VGA_G_w;
wire	[2:0]		VGA_B_w;
wire				VGA_V_SYNC_w;
wire				VGA_H_SYNC_w;

connectVGA connectVGA (
		.CLOCK_50(CLOCK_50),
		.r_val(r_val),
		.g_val(g_val),
		.b_val(b_val),
		.dot_out(dot),
		.y_count_out(y_count),
		.VGA_R(VGA_R_w),
		.VGA_G(VGA_G_w),
		.VGA_B(VGA_B_w),
		.VGA_V_SYNC(VGA_V_SYNC_w),
		.VGA_H_SYNC(VGA_H_SYNC_w)
	);

reg	[7:0]		print_rec_01 = 8'd0;
reg	[24:0]	print_val_01 = 25'd0;
reg				print_set_01 = 1'b0;

reg	[7:0]		print_rec_02 = 8'd0;
reg	[24:0]	print_val_02 = 25'd0;
reg				print_set_02 = 1'b0;

wire	[7:0]		print_rec_03;
wire	[24:0]	print_val_03;
wire				print_set_03;

wire				r_val_tx1;
wire				g_val_tx1;
wire				b_val_tx1;
wire				flagOK_tx1;

textDraw02 textDraw02(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.print_rec_01(print_rec_01),
		.print_val_01(print_val_01),
		.print_set_01(print_set_01),

		.print_rec_02(print_rec_02),
		.print_val_02(print_val_02),
		.print_set_02(print_set_02),
		
		.print_rec_03(print_rec_03),
		.print_val_03(print_val_03),
		.print_set_03(print_set_03),
		
		.r_val(r_val_tx1),
		.g_val(g_val_tx1),
		.b_val(b_val_tx1),
		.flagOK(flagOK_tx1)
	);

// -----------------------------------------------------------------------------------------------------------------
parameter	DRAW_X00 = 80*2;
parameter	DRAW_X01 = 192*2;
parameter	DRAW_X02 = 256*2;
parameter	DRAW_X03 = 320*2;
parameter	DRAW_X04 = 384*2;
parameter	DRAW_X05 = 448*2;
parameter	DRAW_X06 = 512*2;
parameter	DRAW_X07 = 576*2;

// -----------------------------------------------------------------------------------------------------------------

wire	[7:0]		print_rec_03_v01;
wire	[27:0]	print_val_03_v01;
wire				print_set_03_v01;
wire	[7:0]		print_rec_03_v02;
wire	[27:0]	print_val_03_v02;
wire				print_set_03_v02;
wire	[7:0]		print_rec_03_v03;
wire	[27:0]	print_val_03_v03;
wire				print_set_03_v03;
wire	[7:0]		print_rec_03_v04;
wire	[27:0]	print_val_03_v04;
wire				print_set_03_v04;
wire	[7:0]		print_rec_03_v05;
wire	[27:0]	print_val_03_v05;
wire				print_set_03_v05;
wire	[7:0]		print_rec_03_v06;
wire	[27:0]	print_val_03_v06;
wire				print_set_03_v06;

// ----------------------------------------------------------------------------------------------------------------- 00
reg	[12:0]	numberPicture_v00 = 13'd0;

reg	[0:0]		flagRequestRun_v00 = 1'b0;

wire	[3:0]		Answer_v00;
wire	[3:0]		AnswerNear_v00;
wire	[3:0]		Answer_v10;
wire	[3:0]		AnswerNear_v10;
wire	[3:0]		Answer_v20;
wire	[3:0]		AnswerNear_v20;
wire	[3:0]		Answer_v30;
wire	[3:0]		AnswerNear_v30;

wire 	[0:0]		flagCompleteCalc_v00;

wire	[9:0]		image_address_byte_2_v00_0;			// image table read address.
wire	[7:0]		image_data_byte_2_v00_0;				// image table read data.

wire	[9:0]		image_address_byte_2_v00_1;			// image table read address.
wire	[7:0]		image_data_byte_2_v00_1;				// image table read data.

wire	[9:0]		image_address_byte_2_v00_2;			// image table read address.
wire	[7:0]		image_data_byte_2_v00_2;				// image table read data.

wire	[23:0]	ramAddress_v00;
wire				flagReadOK_v00;

procMemory01 procMemory01_v00(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),						// soft reset mode.
		
		.numberPicture(numberPicture_v00),				// picuture number.
		
		.flagRequestRun(flagRequestRun_v00),			// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),					// busy SDRAM flag.
		
		.ramAddress(ramAddress_v00),						// read request address for SDRAM.
		.ramData(ramData),									// read SDRAM data.
		.flagReadOK(flagReadOK_v00),						// read SDRAM flag.
	
		.print_rec_03(print_rec_03),						// debug print for VGA text.
		.print_val_03(print_val_03),						// debug print for VGA text.
		.print_set_03(print_set_03),						// debug print for VGA text.
		
		.Answer_out(Answer_v00),							// answer 0.
		.AnswerNear_out(AnswerNear_v00),					// answer near 0.
		.Answer_out_to_1(Answer_v10),						// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v10),			// answer near 1.
		.Answer_out_to_2(Answer_v20),						// answer 2.
		.AnswerNear_out_to_2(AnswerNear_v20),			// answer near 2.
		.Answer_out_to_3(Answer_v30),						// answer 3.
		.AnswerNear_out_to_3(AnswerNear_v30),			// answer near 3.
		
		.flagCompleteCalc(flagCompleteCalc_v00),		// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v00_0),
		.image_data_byte_to_0(image_data_byte_2_v00_0),
		
		.image_address_byte_to_1(image_address_byte_2_v00_1),
		.image_data_byte_to_1(image_data_byte_2_v00_1),
		
		.image_address_byte_to_2(image_address_byte_2_v00_2),
		.image_data_byte_to_2(image_data_byte_2_v00_2)
	);

// ----------------------------------------------------------------------------------------------------------------- 01
reg	[12:0]	numberPicture_v01 = 13'd1;

wire	[0:0]		flagRequestRun_v01;
assign			flagRequestRun_v01 = flagRequestRun_v00;

wire	[3:0]		Answer_v01;
wire	[3:0]		AnswerNear_v01;
wire	[3:0]		Answer_v11;
wire	[3:0]		AnswerNear_v11;
wire	[3:0]		Answer_v21;
wire	[3:0]		AnswerNear_v21;
wire	[3:0]		Answer_v31;
wire	[3:0]		AnswerNear_v31;

wire 	[0:0]		flagCompleteCalc_v01;

wire	[9:0]		image_address_byte_2_v01_0;					// image table read address.
wire	[7:0]		image_data_byte_2_v01_0;						// image table read data.

wire	[9:0]		image_address_byte_2_v01_1;					// image table read address.
wire	[7:0]		image_data_byte_2_v01_1;						// image table read data.

wire	[9:0]		image_address_byte_2_v01_2;					// image table read address.
wire	[7:0]		image_data_byte_2_v01_2;						// image table read data.

wire	[23:0]	ramAddress_v01;
wire				flagReadOK_v01;

procMemory01 procMemory01_v01(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v01),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v01),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v01),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v01),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v01),						// debug print for VGA text.
		.print_val_03(print_val_03_v01),						// debug print for VGA text.
		.print_set_03(print_set_03_v01),						// debug print for VGA text.
		
		.Answer_out(Answer_v01),								// answer.
		.AnswerNear_out(AnswerNear_v01),						// answer near.
		.Answer_out_to_1(Answer_v11),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v11),				// answer near 1.
		.Answer_out_to_2(Answer_v21),							// answer 2.
		.AnswerNear_out_to_2(AnswerNear_v21),				// answer near 2.
		.Answer_out_to_3(Answer_v31),							// answer 3.
		.AnswerNear_out_to_3(AnswerNear_v31),				// answer near 3.

		.flagCompleteCalc(flagCompleteCalc_v01),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v01_0),
		.image_data_byte_to_0(image_data_byte_2_v01_0),
		
		.image_address_byte_to_1(image_address_byte_2_v01_1),
		.image_data_byte_to_1(image_data_byte_2_v01_1),
		
		.image_address_byte_to_2(image_address_byte_2_v01_2),
		.image_data_byte_to_2(image_data_byte_2_v01_2)
	);

// ----------------------------------------------------------------------------------------------------------------- 02
reg	[12:0]	numberPicture_v02 = 13'd2;

wire	[0:0]		flagRequestRun_v02;
assign			flagRequestRun_v02 = flagRequestRun_v00;

wire	[3:0]		Answer_v02;
wire	[3:0]		AnswerNear_v02;
wire	[3:0]		Answer_v12;
wire	[3:0]		AnswerNear_v12;
wire	[3:0]		Answer_v22;
wire	[3:0]		AnswerNear_v22;
wire	[3:0]		Answer_v32;
wire	[3:0]		AnswerNear_v32;

wire 	[0:0]		flagCompleteCalc_v02;

wire	[9:0]		image_address_byte_2_v02_0;				// image table read address.
wire	[7:0]		image_data_byte_2_v02_0;					// image table read data.

wire	[9:0]		image_address_byte_2_v02_1;				// image table read address.
wire	[7:0]		image_data_byte_2_v02_1;					// image table read data.

wire	[9:0]		image_address_byte_2_v02_2;				// image table read address.
wire	[7:0]		image_data_byte_2_v02_2;					// image table read data.

wire	[23:0]	ramAddress_v02;
wire				flagReadOK_v02;

procMemory01 procMemory01_v02(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v02),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v02),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v02),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v02),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v02),						// debug print for VGA text.
		.print_val_03(print_val_03_v02),						// debug print for VGA text.
		.print_set_03(print_set_03_v02),						// debug print for VGA text.
		
		.Answer_out(Answer_v02),								// answer.
		.AnswerNear_out(AnswerNear_v02),						// answer near.
		.Answer_out_to_1(Answer_v12),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v12),				// answer near 1.
		.Answer_out_to_2(Answer_v22),							// answer 2.
		.AnswerNear_out_to_2(AnswerNear_v22),				// answer near 2.
		.Answer_out_to_3(Answer_v32),							// answer 3.
		.AnswerNear_out_to_3(AnswerNear_v32),				// answer near 3.
		
		.flagCompleteCalc(flagCompleteCalc_v02),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v02_0),
		.image_data_byte_to_0(image_data_byte_2_v02_0),
		
		.image_address_byte_to_1(image_address_byte_2_v02_1),
		.image_data_byte_to_1(image_data_byte_2_v02_1),
		
		.image_address_byte_to_2(image_address_byte_2_v02_2),
		.image_data_byte_to_2(image_data_byte_2_v02_2)
	);



// ----------------------------------------------------------------------------------------------------------------- 03
reg	[12:0]	numberPicture_v03 = 13'd3;

wire	[0:0]		flagRequestRun_v03;
assign			flagRequestRun_v03 = flagRequestRun_v00;

wire	[3:0]		Answer_v03;
wire	[3:0]		AnswerNear_v03;
wire	[3:0]		Answer_v13;
wire	[3:0]		AnswerNear_v13;
wire	[3:0]		Answer_v23;
wire	[3:0]		AnswerNear_v23;
wire	[3:0]		Answer_v33;
wire	[3:0]		AnswerNear_v33;

wire 	[0:0]		flagCompleteCalc_v03;

wire	[9:0]		image_address_byte_2_v03_0;					// image table read address.
wire	[7:0]		image_data_byte_2_v03_0;						// image table read data.

wire	[9:0]		image_address_byte_2_v03_1;					// image table read address.
wire	[7:0]		image_data_byte_2_v03_1;						// image table read data.

wire	[9:0]		image_address_byte_2_v03_2;					// image table read address.
wire	[7:0]		image_data_byte_2_v03_2;						// image table read data.

wire	[23:0]	ramAddress_v03;
wire				flagReadOK_v03;

procMemory01 procMemory01_v03(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v03),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v03),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v03),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v03),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v03),						// debug print for VGA text.
		.print_val_03(print_val_03_v03),						// debug print for VGA text.
		.print_set_03(print_set_03_v03),						// debug print for VGA text.
		
		.Answer_out(Answer_v03),								// answer.
		.AnswerNear_out(AnswerNear_v03),						// answer near.
		.Answer_out_to_1(Answer_v13),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v13),				// answer near 1.
		.Answer_out_to_2(Answer_v23),							// answer 2.
		.AnswerNear_out_to_2(AnswerNear_v23),				// answer near 2.
		.Answer_out_to_3(Answer_v33),							// answer 3.
		.AnswerNear_out_to_3(AnswerNear_v33),				// answer near 3.
		
		.flagCompleteCalc(flagCompleteCalc_v03),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v03_0),
		.image_data_byte_to_0(image_data_byte_2_v03_0),
		
		.image_address_byte_to_1(image_address_byte_2_v03_1),
		.image_data_byte_to_1(image_data_byte_2_v03_1),
		
		.image_address_byte_to_2(image_address_byte_2_v03_2),
		.image_data_byte_to_2(image_data_byte_2_v03_2)
	);
	
// ----------------------------------------------------------------------------------------------------------------- 04
reg	[12:0]	numberPicture_v04 = 13'd4;

wire	[0:0]		flagRequestRun_v04;
assign			flagRequestRun_v04 = flagRequestRun_v00;

wire	[3:0]		Answer_v04;
wire	[3:0]		AnswerNear_v04;
wire	[3:0]		Answer_v14;
wire	[3:0]		AnswerNear_v14;
wire	[3:0]		Answer_v24;
wire	[3:0]		AnswerNear_v24;
wire	[3:0]		Answer_v34;
wire	[3:0]		AnswerNear_v34;

wire 	[0:0]		flagCompleteCalc_v04;

wire	[9:0]		image_address_byte_2_v04_0;				// image table read address.
wire	[7:0]		image_data_byte_2_v04_0;					// image table read data.

wire	[9:0]		image_address_byte_2_v04_1;				// image table read address.
wire	[7:0]		image_data_byte_2_v04_1;					// image table read data.

wire	[9:0]		image_address_byte_2_v04_2;				// image table read address.
wire	[7:0]		image_data_byte_2_v04_2;					// image table read data.

wire	[23:0]	ramAddress_v04;
wire				flagReadOK_v04;

procMemory01 procMemory01_v04(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v04),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v04),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v04),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v04),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v04),						// debug print for VGA text.
		.print_val_03(print_val_03_v04),						// debug print for VGA text.
		.print_set_03(print_set_03_v04),						// debug print for VGA text.
		
		.Answer_out(Answer_v04),								// answer.
		.AnswerNear_out(AnswerNear_v04),						// answer near.
		.Answer_out_to_1(Answer_v14),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v14),				// answer near 1.
		.Answer_out_to_2(Answer_v24),							// answer 1.
		.AnswerNear_out_to_2(AnswerNear_v24),				// answer near 1.
		.Answer_out_to_3(Answer_v34),							// answer 1.
		.AnswerNear_out_to_3(AnswerNear_v34),				// answer near 1.
		
		.flagCompleteCalc(flagCompleteCalc_v04),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v04_0),
		.image_data_byte_to_0(image_data_byte_2_v04_0),
		
		.image_address_byte_to_1(image_address_byte_2_v04_1),
		.image_data_byte_to_1(image_data_byte_2_v04_1),
		
		.image_address_byte_to_2(image_address_byte_2_v04_2),
		.image_data_byte_to_2(image_data_byte_2_v04_2)
	);
	
// ----------------------------------------------------------------------------------------------------------------- 05
reg	[12:0]	numberPicture_v05 = 13'd5;

wire	[0:0]		flagRequestRun_v05;
assign			flagRequestRun_v05 = flagRequestRun_v00;

wire	[3:0]		Answer_v05;
wire	[3:0]		AnswerNear_v05;
wire	[3:0]		Answer_v15;
wire	[3:0]		AnswerNear_v15;
wire	[3:0]		Answer_v25;
wire	[3:0]		AnswerNear_v25;
wire	[3:0]		Answer_v35;
wire	[3:0]		AnswerNear_v35;

wire 	[0:0]		flagCompleteCalc_v05;

wire	[9:0]		image_address_byte_2_v05_0;					// image table read address.
wire	[7:0]		image_data_byte_2_v05_0;						// image table read data.

wire	[9:0]		image_address_byte_2_v05_1;					// image table read address.
wire	[7:0]		image_data_byte_2_v05_1;						// image table read data.

wire	[9:0]		image_address_byte_2_v05_2;					// image table read address.
wire	[7:0]		image_data_byte_2_v05_2;						// image table read data.

wire	[23:0]	ramAddress_v05;
wire				flagReadOK_v05;

procMemory01 procMemory01_v05(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v05),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v05),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v05),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v05),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v05),						// debug print for VGA text.
		.print_val_03(print_val_03_v05),						// debug print for VGA text.
		.print_set_03(print_set_03_v05),						// debug print for VGA text.
		
		.Answer_out(Answer_v05),								// answer 0.
		.AnswerNear_out(AnswerNear_v05),						// answer near 0.
		.Answer_out_to_1(Answer_v15),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v15),				// answer near 1.
		.Answer_out_to_2(Answer_v25),							// answer 2.
		.AnswerNear_out_to_2(AnswerNear_v25),				// answer near 2.
		.Answer_out_to_3(Answer_v35),							// answer 3.
		.AnswerNear_out_to_3(AnswerNear_v35),				// answer near 3.
		
		.flagCompleteCalc(flagCompleteCalc_v05),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v05_0),
		.image_data_byte_to_0(image_data_byte_2_v05_0),
		
		.image_address_byte_to_1(image_address_byte_2_v05_1),
		.image_data_byte_to_1(image_data_byte_2_v05_1),
		
		.image_address_byte_to_2(image_address_byte_2_v05_2),
		.image_data_byte_to_2(image_data_byte_2_v05_2)
	);

// ----------------------------------------------------------------------------------------------------------------- 06
reg	[12:0]	numberPicture_v06 = 13'd6;

wire	[0:0]		flagRequestRun_v06;
assign			flagRequestRun_v06 = flagRequestRun_v00;

wire	[3:0]		Answer_v06;
wire	[3:0]		AnswerNear_v06;
wire	[3:0]		Answer_v16;
wire	[3:0]		AnswerNear_v16;
wire	[3:0]		Answer_v26;
wire	[3:0]		AnswerNear_v26;
wire	[3:0]		Answer_v36;
wire	[3:0]		AnswerNear_v36;

wire 	[0:0]		flagCompleteCalc_v06;

wire	[9:0]		image_address_byte_2_v06_0;				// image table read address.
wire	[7:0]		image_data_byte_2_v06_0;					// image table read data.

wire	[9:0]		image_address_byte_2_v06_1;				// image table read address.
wire	[7:0]		image_data_byte_2_v06_1;					// image table read data.

wire	[9:0]		image_address_byte_2_v06_2;				// image table read address.
wire	[7:0]		image_data_byte_2_v06_2;					// image table read data.

wire	[23:0]	ramAddress_v06;
wire				flagReadOK_v06;

procMemory01 procMemory01_v06(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v06),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v06),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v06),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v06),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v06),						// debug print for VGA text.
		.print_val_03(print_val_03_v06),						// debug print for VGA text.
		.print_set_03(print_set_03_v06),						// debug print for VGA text.
		
		.Answer_out(Answer_v06),								// answer.
		.AnswerNear_out(AnswerNear_v06),						// answer near.
		.Answer_out_to_1(Answer_v16),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v16),				// answer near 1.
		.Answer_out_to_2(Answer_v26),							// answer 2.
		.AnswerNear_out_to_2(AnswerNear_v26),				// answer near 2.
		.Answer_out_to_3(Answer_v36),							// answer 3.
		.AnswerNear_out_to_3(AnswerNear_v36),				// answer near 3.
		
		.flagCompleteCalc(flagCompleteCalc_v06),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v06_0),
		.image_data_byte_to_0(image_data_byte_2_v06_0),
		
		.image_address_byte_to_1(image_address_byte_2_v06_1),
		.image_data_byte_to_1(image_data_byte_2_v06_1),
		
		.image_address_byte_to_2(image_address_byte_2_v06_2),
		.image_data_byte_to_2(image_data_byte_2_v06_2)
	);

// ----------------------------------------------------------------------------------------------------------------- 07
reg	[12:0]	numberPicture_v07 = 13'd7;

wire	[0:0]		flagRequestRun_v07;
assign			flagRequestRun_v07 = flagRequestRun_v00;

wire	[3:0]		Answer_v07;
wire	[3:0]		AnswerNear_v07;
wire	[3:0]		Answer_v17;
wire	[3:0]		AnswerNear_v17;
wire	[3:0]		Answer_v27;
wire	[3:0]		AnswerNear_v27;
wire	[3:0]		Answer_v37;
wire	[3:0]		AnswerNear_v37;

wire 	[0:0]		flagCompleteCalc_v07;

wire	[9:0]		image_address_byte_2_v07_0;					// image table read address.
wire	[7:0]		image_data_byte_2_v07_0;						// image table read data.

wire	[9:0]		image_address_byte_2_v07_1;					// image table read address.
wire	[7:0]		image_data_byte_2_v07_1;						// image table read data.

wire	[9:0]		image_address_byte_2_v07_2;					// image table read address.
wire	[7:0]		image_data_byte_2_v07_2;						// image table read data.

wire	[23:0]	ramAddress_v07;
wire				flagReadOK_v07;

procMemory01 procMemory01_v07(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.resetMode(receiveResetMode),							// soft reset mode.
		
		.numberPicture(numberPicture_v07),					// picuture number.
		
		.flagRequestRun(flagRequestRun_v07),				// request run for neuralnetwork.
		
		.flagBusySDRAM(flagBusySDRAM),						// busy SDRAM flag.
		
		.ramAddress(ramAddress_v07),							// read request address for SDRAM.
		.ramData(ramData),										// read SDRAM data.
		.flagReadOK(flagReadOK_v07),							// read SDRAM flag.
	
		.print_rec_03(print_rec_03_v07),						// debug print for VGA text.
		.print_val_03(print_val_03_v07),						// debug print for VGA text.
		.print_set_03(print_set_03_v07),						// debug print for VGA text.
		
		.Answer_out(Answer_v07),								// answer.
		.AnswerNear_out(AnswerNear_v07),						// answer near.
		.Answer_out_to_1(Answer_v17),							// answer 1.
		.AnswerNear_out_to_1(AnswerNear_v17),				// answer near 1.
		.Answer_out_to_2(Answer_v27),							// answer 1.
		.AnswerNear_out_to_2(AnswerNear_v27),				// answer near 1.
		.Answer_out_to_3(Answer_v37),							// answer 1.
		.AnswerNear_out_to_3(AnswerNear_v37),				// answer near 1.
		
		.flagCompleteCalc(flagCompleteCalc_v07),			// complete flag.
		
		.image_address_byte_to_0(image_address_byte_2_v07_0),
		.image_data_byte_to_0(image_data_byte_2_v07_0),
		
		.image_address_byte_to_1(image_address_byte_2_v07_1),
		.image_data_byte_to_1(image_data_byte_2_v07_1),
		
		.image_address_byte_to_2(image_address_byte_2_v07_2),
		.image_data_byte_to_2(image_data_byte_2_v07_2)
	);

// ----------------------------------------------------------------------------------------------------------------- task switch.
parameter	OFFSET_W1      = 24'h1de840;	// W1.

wire	[3:0]	case_procMemory_rec;

assign	case_procMemory_rec  = (ramAddress_v00 < OFFSET_W1) ? 4'd0 
										: (ramAddress_v01 < OFFSET_W1) ? 4'd1 
										: (ramAddress_v02 < OFFSET_W1) ? 4'd2 
										: (ramAddress_v03 < OFFSET_W1) ? 4'd3 
										: (ramAddress_v04 < OFFSET_W1) ? 4'd4 
										: (ramAddress_v05 < OFFSET_W1) ? 4'd5 
										: (ramAddress_v06 < OFFSET_W1) ? 4'd6 
										: (ramAddress_v07 < OFFSET_W1) ? 4'd7 
										: 4'd9;

function [31:0] CASE_mem_ramAddress;
	input [3:0] rec;
	case (rec)
		0 : CASE_mem_ramAddress = ramAddress_v00;
		1 : CASE_mem_ramAddress = ramAddress_v01;
		2 : CASE_mem_ramAddress = ramAddress_v02;
		3 : CASE_mem_ramAddress = ramAddress_v03;
		4 : CASE_mem_ramAddress = ramAddress_v04;
		5 : CASE_mem_ramAddress = ramAddress_v05;
		6 : CASE_mem_ramAddress = ramAddress_v06;
		7 : CASE_mem_ramAddress = ramAddress_v07;
		9 : CASE_mem_ramAddress = ramAddress_v00;
	endcase
endfunction

assign	ramAddress = CASE_mem_ramAddress(case_procMemory_rec);

assign	flagReadOK_v00 = (case_procMemory_rec == 4'd0 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v01 = (case_procMemory_rec == 4'd1 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v02 = (case_procMemory_rec == 4'd2 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v03 = (case_procMemory_rec == 4'd3 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v04 = (case_procMemory_rec == 4'd4 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v05 = (case_procMemory_rec == 4'd5 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v06 = (case_procMemory_rec == 4'd6 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;
assign	flagReadOK_v07 = (case_procMemory_rec == 4'd7 || case_procMemory_rec == 4'd9) ? flagReadOK : 1'b0;

// -----------------------------------------------------------------------------------------------------------------

parameter	DRAW_IMAGE_BASE_Y = 52;

wire	[2:0]		r_val_img00;
wire	[2:0]		g_val_img00;
wire	[2:0]		b_val_img00;
wire				flagOK_img00;
	
imageDraw784 imageDraw784v00(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X00),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v00_0),
		.image_data_byte(image_data_byte_2_v00_0),
		
		.image_address_byte_01(image_address_byte_2_v00_1),
		.image_data_byte_01(image_data_byte_2_v00_1),
		
		.image_address_byte_02(image_address_byte_2_v00_2),
		.image_data_byte_02(image_data_byte_2_v00_2),
		
		.r_val(r_val_img00),
		.g_val(g_val_img00),
		.b_val(b_val_img00),
		.flagOK(flagOK_img00)
	);
	
wire	[2:0]		r_val_img01;
wire	[2:0]		g_val_img01;
wire	[2:0]		b_val_img01;
wire				flagOK_img01;
	
imageDraw784 imageDraw784v01(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X01),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v01_0),
		.image_data_byte(image_data_byte_2_v01_0),
		
		.image_address_byte_01(image_address_byte_2_v01_1),
		.image_data_byte_01(image_data_byte_2_v01_1),
		
		.image_address_byte_02(image_address_byte_2_v01_2),
		.image_data_byte_02(image_data_byte_2_v01_2),
		
		.r_val(r_val_img01),
		.g_val(g_val_img01),
		.b_val(b_val_img01),
		.flagOK(flagOK_img01)
	);
	
wire	[2:0]		r_val_img02;
wire	[2:0]		g_val_img02;
wire	[2:0]		b_val_img02;
wire				flagOK_img02;
	
imageDraw784 imageDraw784v02(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X02),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v02_0),
		.image_data_byte(image_data_byte_2_v02_0),
		
		.image_address_byte_01(image_address_byte_2_v02_1),
		.image_data_byte_01(image_data_byte_2_v02_1),
		
		.image_address_byte_02(image_address_byte_2_v02_2),
		.image_data_byte_02(image_data_byte_2_v02_2),
		
		.r_val(r_val_img02),
		.g_val(g_val_img02),
		.b_val(b_val_img02),
		.flagOK(flagOK_img02)
	);
	
wire	[2:0]		r_val_img03;
wire	[2:0]		g_val_img03;
wire	[2:0]		b_val_img03;
wire				flagOK_img03;
	
imageDraw784 imageDraw784v03(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X03),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v03_0),
		.image_data_byte(image_data_byte_2_v03_0),

		.image_address_byte_01(image_address_byte_2_v03_1),
		.image_data_byte_01(image_data_byte_2_v03_1),
		
		.image_address_byte_02(image_address_byte_2_v03_2),
		.image_data_byte_02(image_data_byte_2_v03_2),
		
		.r_val(r_val_img03),
		.g_val(g_val_img03),
		.b_val(b_val_img03),
		.flagOK(flagOK_img03)
	);
	
wire	[2:0]		r_val_img04;
wire	[2:0]		g_val_img04;
wire	[2:0]		b_val_img04;
wire				flagOK_img04;
	
imageDraw784 imageDraw784v04(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X04),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v04_0),
		.image_data_byte(image_data_byte_2_v04_0),

		.image_address_byte_01(image_address_byte_2_v04_1),
		.image_data_byte_01(image_data_byte_2_v04_1),
		
		.image_address_byte_02(image_address_byte_2_v04_2),
		.image_data_byte_02(image_data_byte_2_v04_2),
		
		.r_val(r_val_img04),
		.g_val(g_val_img04),
		.b_val(b_val_img04),
		.flagOK(flagOK_img04)
	);
	
wire	[2:0]		r_val_img05;
wire	[2:0]		g_val_img05;
wire	[2:0]		b_val_img05;
wire				flagOK_img05;
	
imageDraw784 imageDraw784v05(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X05),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v05_0),
		.image_data_byte(image_data_byte_2_v05_0),

		.image_address_byte_01(image_address_byte_2_v05_1),
		.image_data_byte_01(image_data_byte_2_v05_1),

		.image_address_byte_02(image_address_byte_2_v05_2),
		.image_data_byte_02(image_data_byte_2_v05_2),
		
		.r_val(r_val_img05),
		.g_val(g_val_img05),
		.b_val(b_val_img05),
		.flagOK(flagOK_img05)
	);
	
wire	[2:0]		r_val_img06;
wire	[2:0]		g_val_img06;
wire	[2:0]		b_val_img06;
wire				flagOK_img06;
	
imageDraw784 imageDraw784v06(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X06),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v06_0),
		.image_data_byte(image_data_byte_2_v06_0),

		.image_address_byte_01(image_address_byte_2_v06_1),
		.image_data_byte_01(image_data_byte_2_v06_1),

		.image_address_byte_02(image_address_byte_2_v06_2),
		.image_data_byte_02(image_data_byte_2_v06_2),
		
		.r_val(r_val_img06),
		.g_val(g_val_img06),
		.b_val(b_val_img06),
		.flagOK(flagOK_img06)
	);
	
wire	[2:0]		r_val_img07;
wire	[2:0]		g_val_img07;
wire	[2:0]		b_val_img07;
wire				flagOK_img07;
	
imageDraw784 imageDraw784v07(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.OFFSET_BASE_X(DRAW_X07),
		.OFFSET_BASE_Y(DRAW_IMAGE_BASE_Y),

		.image_address_byte(image_address_byte_2_v07_0),
		.image_data_byte(image_data_byte_2_v07_0),

		.image_address_byte_01(image_address_byte_2_v07_1),
		.image_data_byte_01(image_data_byte_2_v07_1),

		.image_address_byte_02(image_address_byte_2_v07_2),
		.image_data_byte_02(image_data_byte_2_v07_2),
		
		.r_val(r_val_img07),
		.g_val(g_val_img07),
		.b_val(b_val_img07),
		.flagOK(flagOK_img07)
	);
	
// -----------------------------------------------------------------------------------------------------------------

reg	[12:0]		printB_v001 = 13'd0;
reg	[7:0]			printB_v002 = 8'd0;
reg	[7:0]			printB_v003 = 8'd0;
reg	[12:0]		printB_v101 = 13'd0;
reg	[7:0]			printB_v102 = 8'd0;
reg	[7:0]			printB_v103 = 8'd0;
reg	[12:0]		printB_v201 = 13'd0;
reg	[7:0]			printB_v202 = 8'd0;
reg	[7:0]			printB_v203 = 8'd0;

wire				r_val_v00;
wire				g_val_v00;
wire				b_val_v00;
wire				flagOK_v00;

textDraw03 textDraw03v00(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X00),
		
		.print_val_01(printB_v001),
		.print_val_02(printB_v002),
		.print_val_03(printB_v003),
		.print_val_11(printB_v101),
		.print_val_12(printB_v102),
		.print_val_13(printB_v103),
		.print_val_21(printB_v201),
		.print_val_22(printB_v202),
		.print_val_23(printB_v203),
		
		.r_val(r_val_v00),
		.g_val(g_val_v00),
		.b_val(b_val_v00),
		.flagOK(flagOK_v00)
	);

reg	[12:0]		printB_v011 = 13'd0;
reg	[7:0]			printB_v012 = 8'd0;
reg	[7:0]			printB_v013 = 8'd0;
reg	[12:0]		printB_v111 = 13'd0;
reg	[7:0]			printB_v112 = 8'd0;
reg	[7:0]			printB_v113 = 8'd0;
reg	[12:0]		printB_v211 = 13'd0;
reg	[7:0]			printB_v212 = 8'd0;
reg	[7:0]			printB_v213 = 8'd0;

wire				r_val_v01;
wire				g_val_v01;
wire				b_val_v01;
wire				flagOK_v01;

textDraw03 textDraw03v01(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X01),
		
		.print_val_01(printB_v011),
		.print_val_02(printB_v012),
		.print_val_03(printB_v013),
		.print_val_11(printB_v111),
		.print_val_12(printB_v112),
		.print_val_13(printB_v113),
		.print_val_21(printB_v211),
		.print_val_22(printB_v212),
		.print_val_23(printB_v213),
		
		.r_val(r_val_v01),
		.g_val(g_val_v01),
		.b_val(b_val_v01),
		.flagOK(flagOK_v01)
	);
	
reg	[12:0]		printB_v021 = 13'd0;
reg	[7:0]			printB_v022 = 8'd0;
reg	[7:0]			printB_v023 = 8'd0;
reg	[12:0]		printB_v121 = 13'd0;
reg	[7:0]			printB_v122 = 8'd0;
reg	[7:0]			printB_v123 = 8'd0;
reg	[12:0]		printB_v221 = 13'd0;
reg	[7:0]			printB_v222 = 8'd0;
reg	[7:0]			printB_v223 = 8'd0;

wire				r_val_v02;
wire				g_val_v02;
wire				b_val_v02;
wire				flagOK_v02;

textDraw03 textDraw03v02(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X02),
		
		.print_val_01(printB_v021),
		.print_val_02(printB_v022),
		.print_val_03(printB_v023),
		.print_val_11(printB_v121),
		.print_val_12(printB_v122),
		.print_val_13(printB_v123),
		.print_val_21(printB_v221),
		.print_val_22(printB_v222),
		.print_val_23(printB_v223),
		
		.r_val(r_val_v02),
		.g_val(g_val_v02),
		.b_val(b_val_v02),
		.flagOK(flagOK_v02)
	);

reg	[12:0]		printB_v031 = 13'd0;
reg	[7:0]			printB_v032 = 8'd0;
reg	[7:0]			printB_v033 = 8'd0;
reg	[12:0]		printB_v131 = 13'd0;
reg	[7:0]			printB_v132 = 8'd0;
reg	[7:0]			printB_v133 = 8'd0;
reg	[12:0]		printB_v231 = 13'd0;
reg	[7:0]			printB_v232 = 8'd0;
reg	[7:0]			printB_v233 = 8'd0;

wire				r_val_v03;
wire				g_val_v03;
wire				b_val_v03;
wire				flagOK_v03;

textDraw03 textDraw03v03(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X03),
		
		.print_val_01(printB_v031),
		.print_val_02(printB_v032),
		.print_val_03(printB_v033),
		.print_val_11(printB_v131),
		.print_val_12(printB_v132),
		.print_val_13(printB_v133),
		.print_val_21(printB_v231),
		.print_val_22(printB_v232),
		.print_val_23(printB_v233),
		
		.r_val(r_val_v03),
		.g_val(g_val_v03),
		.b_val(b_val_v03),
		.flagOK(flagOK_v03)
	);

reg	[12:0]		printB_v041 = 13'd0;
reg	[7:0]			printB_v042 = 8'd0;
reg	[7:0]			printB_v043 = 8'd0;
reg	[12:0]		printB_v141 = 13'd0;
reg	[7:0]			printB_v142 = 8'd0;
reg	[7:0]			printB_v143 = 8'd0;
reg	[12:0]		printB_v241 = 13'd0;
reg	[7:0]			printB_v242 = 8'd0;
reg	[7:0]			printB_v243 = 8'd0;

wire				r_val_v04;
wire				g_val_v04;
wire				b_val_v04;
wire				flagOK_v04;

textDraw03 textDraw03v04(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X04),
		
		.print_val_01(printB_v041),
		.print_val_02(printB_v042),
		.print_val_03(printB_v043),
		.print_val_11(printB_v141),
		.print_val_12(printB_v142),
		.print_val_13(printB_v143),
		.print_val_21(printB_v241),
		.print_val_22(printB_v242),
		.print_val_23(printB_v243),
		
		.r_val(r_val_v04),
		.g_val(g_val_v04),
		.b_val(b_val_v04),
		.flagOK(flagOK_v04)
	);
	
reg	[12:0]		printB_v051 = 13'd0;
reg	[7:0]			printB_v052 = 8'd0;
reg	[7:0]			printB_v053 = 8'd0;
reg	[12:0]		printB_v151 = 13'd0;
reg	[7:0]			printB_v152 = 8'd0;
reg	[7:0]			printB_v153 = 8'd0;
reg	[12:0]		printB_v251 = 13'd0;
reg	[7:0]			printB_v252 = 8'd0;
reg	[7:0]			printB_v253 = 8'd0;

wire				r_val_v05;
wire				g_val_v05;
wire				b_val_v05;
wire				flagOK_v05;

textDraw03 textDraw03v05(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X05),
		
		.print_val_01(printB_v051),
		.print_val_02(printB_v052),
		.print_val_03(printB_v053),
		.print_val_11(printB_v151),
		.print_val_12(printB_v152),
		.print_val_13(printB_v153),
		.print_val_21(printB_v251),
		.print_val_22(printB_v252),
		.print_val_23(printB_v253),
		
		.r_val(r_val_v05),
		.g_val(g_val_v05),
		.b_val(b_val_v05),
		.flagOK(flagOK_v05)
	);
	
reg	[12:0]		printB_v061 = 13'd0;
reg	[7:0]			printB_v062 = 8'd0;
reg	[7:0]			printB_v063 = 8'd0;
reg	[12:0]		printB_v161 = 13'd0;
reg	[7:0]			printB_v162 = 8'd0;
reg	[7:0]			printB_v163 = 8'd0;
reg	[12:0]		printB_v261 = 13'd0;
reg	[7:0]			printB_v262 = 8'd0;
reg	[7:0]			printB_v263 = 8'd0;

wire				r_val_v06;
wire				g_val_v06;
wire				b_val_v06;
wire				flagOK_v06;

textDraw03 textDraw03v06(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X06),
		
		.print_val_01(printB_v061),
		.print_val_02(printB_v062),
		.print_val_03(printB_v063),
		.print_val_11(printB_v161),
		.print_val_12(printB_v162),
		.print_val_13(printB_v163),
		.print_val_21(printB_v261),
		.print_val_22(printB_v262),
		.print_val_23(printB_v263),
		
		.r_val(r_val_v06),
		.g_val(g_val_v06),
		.b_val(b_val_v06),
		.flagOK(flagOK_v06)
	);
	
reg	[12:0]		printB_v071 = 13'd0;
reg	[7:0]			printB_v072 = 8'd0;
reg	[7:0]			printB_v073 = 8'd0;
reg	[12:0]		printB_v171 = 13'd0;
reg	[7:0]			printB_v172 = 8'd0;
reg	[7:0]			printB_v173 = 8'd0;
reg	[12:0]		printB_v271 = 13'd0;
reg	[7:0]			printB_v272 = 8'd0;
reg	[7:0]			printB_v273 = 8'd0;
	
wire				r_val_v07;
wire				g_val_v07;
wire				b_val_v07;
wire				flagOK_v07;

textDraw03 textDraw03v07(
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.dot(dot),
		.y_count_in(y_count),
		
		.resetMode(receiveResetMode),
		
		.OFFSET_BASE_X(DRAW_X07),
		
		.print_val_01(printB_v071),
		.print_val_02(printB_v072),
		.print_val_03(printB_v073),
		.print_val_11(printB_v171),
		.print_val_12(printB_v172),
		.print_val_13(printB_v173),
		.print_val_21(printB_v271),
		.print_val_22(printB_v272),
		.print_val_23(printB_v273),
		
		.r_val(r_val_v07),
		.g_val(g_val_v07),
		.b_val(b_val_v07),
		.flagOK(flagOK_v07)
	);

// -----------------------------------------------------------------------------------------------------------------
	
wire	[8:0]		flagKey3x3;

connectKey3x3 connectKey3x3 (
		.CLOCK_50(CLOCK_50),
		.RST_N(RST_N),
		.LED(LED),
		.KEY_X(KEY_X),
		.KEY_Y(KEY_Y),
		.flagKey3x3(flagKey3x3)
	);
	
parameter		SEQUENCE_ID_SPI_RECEIVE = 8'd0;
parameter		SEQUENCE_ID_WRITE_COMPLETE_WAIT = 8'd1;
parameter		SEQUENCE_ID_READ_START_WAIT = 8'd2;
parameter		SEQUENCE_ID_READ_LOOP = 8'd3;
parameter		SEQUENCE_ID_READ_COMPLETE = 8'd4;

reg	[7:0]		sequenceID = SEQUENCE_ID_SPI_RECEIVE;

reg	[0:0]		flagCompleteNeuralNetCalcAll = 1'b0;

reg	[0:0]		flag_BUTTON_00_on = 1'b0;
reg	[0:0]		flag_BUTTON_01_on = 1'b0;
reg	[0:0]		flag_BUTTON_02_on_auto = 1'b0;
	
reg	[3:0]		debug_count_01 = 4'b0;
reg	[0:0]		debug_spi_receive_RUN_now = 1'b0;
reg	[0:0]		debug_sdram_checksum = 1'b0;
reg	[3:0]		debug_clock01 = 4'd0;
reg	[0:0]		debug_refreash_old_flag = 1'b0;
reg	[15:0]	debug_refreash_counter = 16'd0;

reg	[31:0]	debug_TIME_COUNTER_01 = 32'b0;


function	[12:0] PICTURE_INC;
	input [12:0] number;
	//PICTURE_INC = (number <= 13'd4991) ? number + 13'd8 : (number - 13'd4992);
	PICTURE_INC = (number <= 13'd4967) ? number + 13'd24 : (number - 13'd4968);
endfunction
		
function	[12:0] PICTURE_DEC;
	input [12:0] number;
	//PICTURE_DEC = (number >= 13'd8) ? number - 13'd8 : 13'd4999 - (13'd7 - number);
	PICTURE_DEC = (number >= 13'd24) ? number - 13'd24 : 13'd4991 - (13'd23 - number);		// 24 * 208 = 4992
endfunction

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin

		print_rec_01 <= 8'd0;
		print_val_01 <= 28'd0;
		print_set_01 <= 1'b0;
		
		print_rec_02 <= 8'd0;
		print_val_02 <= 28'd0;
		print_set_02 <= 1'b0;

		flag_BUTTON_00_on <= 1'b0;
		flag_BUTTON_01_on <= 1'b0;
		flag_BUTTON_02_on_auto <= 1'b0;
		
		debug_count_01 <= 4'b0;
		
		sequenceID <= SEQUENCE_ID_SPI_RECEIVE;
		
		flagCompleteNeuralNetCalcAll <= 1'b0;

		debug_spi_receive_RUN_now <= 1'b0;
		debug_sdram_checksum <= 1'b0;
		debug_clock01 <= 25'd0;
		debug_refreash_old_flag <= 1'b0;
		debug_refreash_counter <= 16'd0;
		debug_TIME_COUNTER_01 <= 32'd0;

		numberPicture_v00 <= 13'd0;		// picture number. <=======================================
		numberPicture_v01 <= 13'd1;		// picture number. <=======================================
		numberPicture_v02 <= 13'd2;		// picture number. <=======================================
		numberPicture_v03 <= 13'd3;		// picture number. <=======================================
		numberPicture_v04 <= 13'd4;		// picture number. <=======================================
		numberPicture_v05 <= 13'd5;		// picture number. <=======================================
		numberPicture_v06 <= 13'd6;		// picture number. <=======================================
		numberPicture_v07 <= 13'd7;		// picture number. <=======================================
		
		flagRequestRun_v00 <= 1'b0;		// request run calc for checksum.

	end else begin

		if (debug_refreash_old_flag != flagAutoRefreshBusy) begin
			debug_refreash_old_flag <= flagAutoRefreshBusy;
			if (flagAutoRefreshBusy)
				debug_refreash_counter <= debug_refreash_counter + 16'd1;
		end
		
		printB_v001[12:0] <= numberPicture_v00[12:0];
		printB_v002[7:0] <= {4'd0, AnswerNear_v00[3:0]};
		printB_v003[7:0] <= {4'd0, Answer_v00[3:0]};
		printB_v101[12:0] <= numberPicture_v00[12:0] + 13'd8;
		printB_v102[7:0] <= {4'd0, AnswerNear_v10[3:0]};
		printB_v103[7:0] <= {4'd0, Answer_v10[3:0]};
		printB_v201[12:0] <= numberPicture_v00[12:0] + 13'd16;
		printB_v202[7:0] <= {4'd0, AnswerNear_v20[3:0]};
		printB_v203[7:0] <= {4'd0, Answer_v20[3:0]};

		printB_v011[12:0] <= numberPicture_v01[12:0];
		printB_v012[7:0] <= {4'd0, AnswerNear_v01[3:0]};
		printB_v013[7:0] <= {4'd0, Answer_v01[3:0]};
		printB_v111[12:0] <= numberPicture_v01[12:0] + 13'd8;
		printB_v112[7:0] <= {4'd0, AnswerNear_v11[3:0]};
		printB_v113[7:0] <= {4'd0, Answer_v11[3:0]};
		printB_v211[12:0] <= numberPicture_v01[12:0] + 13'd16;
		printB_v212[7:0] <= {4'd0, AnswerNear_v21[3:0]};
		printB_v213[7:0] <= {4'd0, Answer_v21[3:0]};
		
		printB_v021[12:0] <= numberPicture_v02[12:0];
		printB_v022[7:0] <= {4'd0, AnswerNear_v02[3:0]};
		printB_v023[7:0] <= {4'd0, Answer_v02[3:0]};
		printB_v121[12:0] <= numberPicture_v02[12:0] + 13'd8;
		printB_v122[7:0] <= {4'd0, AnswerNear_v12[3:0]};
		printB_v123[7:0] <= {4'd0, Answer_v12[3:0]};
		printB_v221[12:0] <= numberPicture_v02[12:0] + 13'd16;
		printB_v222[7:0] <= {4'd0, AnswerNear_v22[3:0]};
		printB_v223[7:0] <= {4'd0, Answer_v22[3:0]};

		printB_v031[12:0] <= numberPicture_v03[12:0];
		printB_v032[7:0] <= {4'd0, AnswerNear_v03[3:0]};
		printB_v033[7:0] <= {4'd0, Answer_v03[3:0]};
		printB_v131[12:0] <= numberPicture_v03[12:0] + 13'd8;
		printB_v132[7:0] <= {4'd0, AnswerNear_v13[3:0]};
		printB_v133[7:0] <= {4'd0, Answer_v13[3:0]};
		printB_v231[12:0] <= numberPicture_v03[12:0] + 13'd16;
		printB_v232[7:0] <= {4'd0, AnswerNear_v23[3:0]};
		printB_v233[7:0] <= {4'd0, Answer_v23[3:0]};
		
		printB_v041[12:0] <= numberPicture_v04[12:0];
		printB_v042[7:0] <= {4'd0, AnswerNear_v04[3:0]};
		printB_v043[7:0] <= {4'd0, Answer_v04[3:0]};
		printB_v141[12:0] <= numberPicture_v04[12:0] + 13'd8;
		printB_v142[7:0] <= {4'd0, AnswerNear_v14[3:0]};
		printB_v143[7:0] <= {4'd0, Answer_v14[3:0]};
		printB_v241[12:0] <= numberPicture_v04[12:0] + 13'd16;
		printB_v242[7:0] <= {4'd0, AnswerNear_v24[3:0]};
		printB_v243[7:0] <= {4'd0, Answer_v24[3:0]};
		
		printB_v051[12:0] <= numberPicture_v05[12:0];
		printB_v052[7:0] <= {4'd0, AnswerNear_v05[3:0]};
		printB_v053[7:0] <= {4'd0, Answer_v05[3:0]};
		printB_v151[12:0] <= numberPicture_v05[12:0] + 13'd8;
		printB_v152[7:0] <= {4'd0, AnswerNear_v15[3:0]};
		printB_v153[7:0] <= {4'd0, Answer_v15[3:0]};
		printB_v251[12:0] <= numberPicture_v05[12:0] + 13'd16;
		printB_v252[7:0] <= {4'd0, AnswerNear_v25[3:0]};
		printB_v253[7:0] <= {4'd0, Answer_v25[3:0]};
		
		printB_v061[12:0] <= numberPicture_v06[12:0];
		printB_v062[7:0] <= {4'd0, AnswerNear_v06[3:0]};
		printB_v063[7:0] <= {4'd0, Answer_v06[3:0]};
		printB_v161[12:0] <= numberPicture_v06[12:0] + 13'd8;
		printB_v162[7:0] <= {4'd0, AnswerNear_v16[3:0]};
		printB_v163[7:0] <= {4'd0, Answer_v16[3:0]};
		printB_v261[12:0] <= numberPicture_v06[12:0] + 13'd16;
		printB_v262[7:0] <= {4'd0, AnswerNear_v26[3:0]};
		printB_v263[7:0] <= {4'd0, Answer_v26[3:0]};
		
		printB_v071[12:0] <= numberPicture_v07[12:0];
		printB_v072[7:0] <= {4'd0, AnswerNear_v07[3:0]};
		printB_v073[7:0] <= {4'd0, Answer_v07[3:0]};
		printB_v171[12:0] <= numberPicture_v07[12:0] + 13'd8;
		printB_v172[7:0] <= {4'd0, AnswerNear_v17[3:0]};
		printB_v173[7:0] <= {4'd0, Answer_v17[3:0]};
		printB_v271[12:0] <= numberPicture_v07[12:0] + 13'd16;
		printB_v272[7:0] <= {4'd0, AnswerNear_v27[3:0]};
		printB_v273[7:0] <= {4'd0, Answer_v27[3:0]};
		
		if (flagKey3x3[0:0] == 1'b1) begin
			flag_BUTTON_00_on <= 1'b1;								// button flag now.
		end
	
		if (flagKey3x3[1:1] == 1'b1) begin
			flag_BUTTON_01_on <= 1'b1;								// button flag now.
		end

		if (flagKey3x3[2:2] == 1'b1) begin
			flag_BUTTON_02_on_auto <= 1'b1;						// button flag now.
		end
	
		if (receiveResetMode_spi == 1'b1) begin
		
			flagCompleteNeuralNetCalcAll <= 1'b0;
			
		// -----------------------------------------------------------------------------------------------------------------
		// button control.
		// -----------------------------------------------------------------------------------------------------------------
		end else if (sequenceID == SEQUENCE_ID_SPI_RECEIVE 
					&& (flag_BUTTON_00_on == 1'b1 || flag_BUTTON_01_on == 1'b1 || flag_BUTTON_02_on_auto == 1'b1)
					&& flagCompleteNeuralNetCalcAll == 1'b1) begin

			if (flag_BUTTON_00_on || flag_BUTTON_02_on_auto) begin
				if (flag_BUTTON_00_on == 1'b1)
					debug_TIME_COUNTER_01 <= 32'd0;

				flag_BUTTON_00_on <= 1'b0;
				
				if (flag_BUTTON_02_on_auto && numberPicture_v00 == 13'd4944) begin
					flag_BUTTON_02_on_auto <= 1'b0;
				end

				numberPicture_v00 <= PICTURE_INC(numberPicture_v00);
				numberPicture_v01 <= PICTURE_INC(numberPicture_v01);
				numberPicture_v02 <= PICTURE_INC(numberPicture_v02);
				numberPicture_v03 <= PICTURE_INC(numberPicture_v03);
				numberPicture_v04 <= PICTURE_INC(numberPicture_v04);
				numberPicture_v05 <= PICTURE_INC(numberPicture_v05);
				numberPicture_v06 <= PICTURE_INC(numberPicture_v06);
				numberPicture_v07 <= PICTURE_INC(numberPicture_v07);
			end

			if (flag_BUTTON_01_on) begin
				flag_BUTTON_01_on <= 1'b0;
				
				numberPicture_v00 <= PICTURE_DEC(numberPicture_v00);
				numberPicture_v01 <= PICTURE_DEC(numberPicture_v01);
				numberPicture_v02 <= PICTURE_DEC(numberPicture_v02);
				numberPicture_v03 <= PICTURE_DEC(numberPicture_v03);
				numberPicture_v04 <= PICTURE_DEC(numberPicture_v04);
				numberPicture_v05 <= PICTURE_DEC(numberPicture_v05);
				numberPicture_v06 <= PICTURE_DEC(numberPicture_v06);
				numberPicture_v07 <= PICTURE_DEC(numberPicture_v07);
			end
			
			debug_sdram_checksum <= 1'b1;
			debug_clock01 <= 4'd0;

			sequenceID <= SEQUENCE_ID_READ_START_WAIT;
			
		// -----------------------------------------------------------------------------------------------------------------
		//	SPI communication receive data.
		// -----------------------------------------------------------------------------------------------------------------
		end else if (sequenceID == SEQUENCE_ID_SPI_RECEIVE) begin
			// input -> reg.
			SPI_MISO_reg = SPI_MISO;
			SPI_CLOCK_reg = SPI_CLOCK;
			SPI_ENABLE_N_reg = SPI_ENABLE_N;

			// debug dump.
			print_rec_01[7:0] <= debug_count_01;
			case (debug_count_01)
			0 : print_val_01[24:0] <= receiveAddress_spi[24:0];						// SPI comm data debug dump.
			1 : print_val_01[24:0] <= {10'd0, ramWriteData0[15:0]};					// SPI comm data debug dump.
			2 : print_val_01[24:0] <= {10'd0, ramWriteData1[15:0]};					// SPI comm data debug dump.
			3 : print_val_01[24:0] <= {10'd0, ramWriteData2[15:0]};					// SPI comm data debug dump.
			4 : print_val_01[24:0] <= {10'd0, ramWriteData3[15:0]};					// SPI comm data debug dump.
			5 : print_val_01[24:0] <= {10'd0, debug_refreash_counter};
			endcase
			debug_count_01 <= (debug_count_01 == 4'd5) ? 4'd0 : debug_count_01 + 4'd1;
			print_set_01 <= 1'b1;

			print_rec_02[7:0] <= 8'd7;															// debug dump.
			print_val_02[15:0] <= checksum[15:0];											// receive data check sum.
			print_set_02 <= 1'b1;																//
		
			// spi receive start address == 0 is spi receive start.
			if (debug_spi_receive_RUN_now == 1'b0 && receiveAddress_spi == 25'd0 && flagCompleteNeuralNetCalcAll == 1'b0) begin
			
				debug_spi_receive_RUN_now <= 1'b1;																			// flag set.
			
			end else if (debug_spi_receive_RUN_now == 1'b1 && receiveDisableNow_spi == 1'b1) begin			// spi receive end check.
			
				sequenceID <= SEQUENCE_ID_WRITE_COMPLETE_WAIT;
		
			end

		end else if (sequenceID == SEQUENCE_ID_WRITE_COMPLETE_WAIT) begin
			if (debug_clock01[3:3] == 0) begin														// write wait for SDRAM.
				debug_clock01 <= debug_clock01 + 4'd1;
			end else begin
				if ((flagWriteBusy | flagBusySDRAM | flagWriteBurst) == 1'b0) begin		// SDRAM write complete check.
					debug_sdram_checksum <= 1'b1;
					debug_clock01 <= 4'd0;

					sequenceID <= SEQUENCE_ID_READ_START_WAIT;
				end
			end
			
		// -----------------------------------------------------------------------------------------------------------------
		//	neural network.
		// -----------------------------------------------------------------------------------------------------------------
		end else if (sequenceID == SEQUENCE_ID_READ_START_WAIT) begin
			print_rec_01[7:0] <= 8'd8;															// debug dump.
			print_val_01[24:0] <= {1'b0, ramWriteAddress[23:0]};						// last address now.
			print_set_01 <= 1'b1;																//
			
			if (debug_clock01[2:2] == 0) begin
				debug_clock01 <= debug_clock01 + 4'd1;
			end else begin
				debug_clock01 <= 4'd0;
				sequenceID <= SEQUENCE_ID_READ_LOOP;

				flagRequestRun_v00 <= 1'b1;													// request run calc for checksum.
			end

		end else if (sequenceID == SEQUENCE_ID_READ_LOOP) begin
		
			flagRequestRun_v00 <= 1'b0;														// request run calc for checksum clear.(once)

			if (flagCompleteCalc_v00 == 1'b1) begin
				sequenceID <= SEQUENCE_ID_READ_COMPLETE;
			end
			
		end else if (sequenceID == SEQUENCE_ID_READ_COMPLETE) begin
			// next receive.
			debug_spi_receive_RUN_now <= 1'b0;
			debug_sdram_checksum <= 1'b0;

			flagCompleteNeuralNetCalcAll <= 1'b1;
			
			sequenceID <= SEQUENCE_ID_SPI_RECEIVE;
		end
		
		//if (sequenceID != SEQUENCE_ID_SPI_RECEIVE && sequenceID != SEQUENCE_ID_WRITE_COMPLETE_WAIT && sequenceID != SEQUENCE_ID_READ_COMPLETE) begin
		
		if (sequenceID == SEQUENCE_ID_READ_START_WAIT || sequenceID == SEQUENCE_ID_READ_LOOP) begin

			debug_TIME_COUNTER_01 <= debug_TIME_COUNTER_01 + 32'd1;
			print_rec_02 <= 8'd10;
			print_val_02[24:0] <= debug_TIME_COUNTER_01[31:7];//[31:7];
			print_set_02 <= 1'b1;
		end
		
	end
end

assign	SPI_MOSI = SPI_MOSI_W;			// reg -> output.

assign	VGA_R[2:0] = VGA_R_w[2:0];
assign	VGA_G[2:0] = VGA_G_w[2:0];
assign	VGA_B[2:0] = VGA_B_w[2:0];
assign	VGA_V_SYNC = VGA_V_SYNC_w;
assign	VGA_H_SYNC = VGA_H_SYNC_w;

assign	r_val = (flagOK_img00) ? r_val_img00
					: (flagOK_img01) ? r_val_img01
					: (flagOK_img02) ? r_val_img02
					: (flagOK_img03) ? r_val_img03
					: (flagOK_img04) ? r_val_img04
					: (flagOK_img05) ? r_val_img05
					: (flagOK_img06) ? r_val_img06
					: (flagOK_img07) ? r_val_img07
					: (flagOK_tx1) ? {r_val_tx1,r_val_tx1,r_val_tx1}
					: (flagOK_v00) ? {r_val_v00,r_val_v00,r_val_v00}
					: (flagOK_v01) ? {r_val_v01,r_val_v01,r_val_v01}
					: (flagOK_v02) ? {r_val_v02,r_val_v02,r_val_v02}
					: (flagOK_v03) ? {r_val_v03,r_val_v03,r_val_v03}
					: (flagOK_v04) ? {r_val_v04,r_val_v04,r_val_v04}
					: (flagOK_v05) ? {r_val_v05,r_val_v05,r_val_v05}
					: (flagOK_v06) ? {r_val_v06,r_val_v06,r_val_v06}
					: (flagOK_v07) ? {r_val_v07,r_val_v07,r_val_v07}
					: r_val_bg;

assign	g_val = (flagOK_img00) ? g_val_img00
					: (flagOK_img01) ? g_val_img01
					: (flagOK_img02) ? g_val_img02
					: (flagOK_img03) ? g_val_img03
					: (flagOK_img04) ? g_val_img04
					: (flagOK_img05) ? g_val_img05
					: (flagOK_img06) ? g_val_img06
					: (flagOK_img07) ? g_val_img07
					: (flagOK_tx1) ? {g_val_tx1,g_val_tx1,g_val_tx1}
					: (flagOK_v00) ? {g_val_v00,g_val_v00,g_val_v00}
					: (flagOK_v01) ? {g_val_v01,g_val_v01,g_val_v01}
					: (flagOK_v02) ? {g_val_v02,g_val_v02,g_val_v02}
					: (flagOK_v03) ? {g_val_v03,g_val_v03,g_val_v03}
					: (flagOK_v04) ? {g_val_v04,g_val_v04,g_val_v04}
					: (flagOK_v05) ? {g_val_v05,g_val_v05,g_val_v05}
					: (flagOK_v06) ? {g_val_v06,g_val_v06,g_val_v06}
					: (flagOK_v07) ? {g_val_v07,g_val_v07,g_val_v07}
					: g_val_bg;

assign	b_val = (flagOK_img00) ? b_val_img00
					: (flagOK_img01) ? b_val_img01
					: (flagOK_img02) ? b_val_img02
					: (flagOK_img03) ? b_val_img03
					: (flagOK_img04) ? b_val_img04
					: (flagOK_img05) ? b_val_img05
					: (flagOK_img06) ? b_val_img06
					: (flagOK_img07) ? b_val_img07
					: (flagOK_tx1) ? {b_val_tx1,b_val_tx1,b_val_tx1}
					: (flagOK_v00) ? {b_val_v00,b_val_v00,b_val_v00}
					: (flagOK_v01) ? {b_val_v01,b_val_v01,b_val_v01}
					: (flagOK_v02) ? {b_val_v02,b_val_v02,b_val_v02}
					: (flagOK_v03) ? {b_val_v03,b_val_v03,b_val_v03}
					: (flagOK_v04) ? {b_val_v04,b_val_v04,b_val_v04}
					: (flagOK_v05) ? {b_val_v05,b_val_v05,b_val_v05}
					: (flagOK_v06) ? {b_val_v06,b_val_v06,b_val_v06}
					: (flagOK_v07) ? {b_val_v07,b_val_v07,b_val_v07}
					: b_val_bg;

endmodule
