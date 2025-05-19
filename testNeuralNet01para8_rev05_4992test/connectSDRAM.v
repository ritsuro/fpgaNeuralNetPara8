// SDRAM write and read test.
// ISSI IS42S16160G-7TLI   (CAS Latency-2)
//
// write 4 word data at same time. write address is step 4.
// Other write address are not supported.
//

module connectSDRAM (
	input							CLOCK_50,
	input							RST_N,

	// SDRAM
	output	reg	[12:0]	DRAM_A 		= 13'd0,
	inout				[15:0]	DRAM_DQ,
	output	reg	[1:0]		DRAM_BA 		= 2'd0,
	output	reg	[1:0]		DRAM_DQM 	= 2'd0,
	output	reg				DRAM_RAS_N 	= 1'b0,
	output	reg				DRAM_CAS_N 	= 1'b0,
	output	reg				DRAM_CKE 	= 1'b0,
	output						DRAM_CLK,
	output	reg				DRAM_WE_N 	= 1'b0,
	output	reg				DRAM_CS_N 	= 1'b0,

	input				[0:0]		resetMode,
	input				[0:0]		writeMode,
	input				[0:0]		autoRefreshMode,					// CBR Auto-Refresh(REF) 
	
	input				[23:0]	ramWriteAddress,
	input				[15:0]	ramWriteData0,
	input				[15:0]	ramWriteData1,
	input				[15:0]	ramWriteData2,
	input				[15:0]	ramWriteData3,
	
	output	reg	[0:0]		flagWriteBusy	= 1'b0,
	output	reg	[0:0]		flagAutoRefreshBusy = 1'b0,
	output	reg	[0:0]		flagBusy			= 1'b1,			// busy flag(startup, write, read)
	output			[0:0]		flagWriteBurst,
	output			[0:0]		flagReadBurst,
	output			[0:0]		flagAutoRefreshCycle,			// now CBR Auto-Refresh...
	
	input				[23:0]	ramAddress,
	output	reg	[15:0]	ramData		= 16'd0,
	output	reg	[0:0]		flagReadOK	= 1'b0
);

reg	[7:0]		countLastWrite	= 8'b0;

reg	[15:0]	DRAM_DQ_W		= 16'bzzzz_zzzz_zzzz_zzzz;
reg	[15:0]	DRAM_DQ_R		= 16'd0;
wire	[15:0]	DRAM_DQ_R2;

reg	[15:0]	ramData00		= 16'd0;
reg	[15:0]	ramData01		= 16'd0;
reg	[15:0]	ramData02		= 16'd0;
reg	[15:0]	ramData03		= 16'd0;
reg	[15:0]	ramData10		= 16'd0;
reg	[15:0]	ramData11		= 16'd0;
reg	[15:0]	ramData12		= 16'd0;
reg	[15:0]	ramData13		= 16'd0;

reg	[0:0]		flagReadOK00	= 1'b0;
reg	[0:0]		flagReadOK01	= 1'b0;
reg	[0:0]		flagReadOK02	= 1'b0;
reg	[0:0]		flagReadOK03	= 1'b0;
reg	[0:0]		flagReadOK10	= 1'b0;
reg	[0:0]		flagReadOK11	= 1'b0;
reg	[0:0]		flagReadOK12	= 1'b0;
reg	[0:0]		flagReadOK13	= 1'b0;

parameter	SEQ_POWER_ON = 0;
parameter	SEQ_IDLE = 10;

parameter	SEQ_READ_ACT_wait = 21;
parameter	SEQ_READ = 40;
parameter	SEQ_READ_wait = 41;

//parameter	SEQ_WRITE_ACT = 60;
parameter	SEQ_WRITE_ACT_TEST_DATA = 61;
parameter	SEQ_WRITE_ACT_loop = 62;
parameter	SEQ_WRITE_ACT_wait = 63;
parameter	SEQ_WRITE_COLUMN = 64;
parameter	SEQ_WRITE_COLUMN_wait = 65;

parameter	SEQ_PRECHARGE_INIT = 72;
parameter	SEQ_PRECHARGE_INIT_wait = 73;
parameter	SEQ_PRECHARGE_INIT_2 = 74;
parameter	SEQ_PRECHARGE_INIT_2_wait = 75;
parameter	SEQ_PRECHARGE_INIT_3 = 76;
parameter	SEQ_PRECHARGE_INIT_3_wait = 77;

parameter	SEQ_MRS = 80;
parameter	SEQ_MRS_wait = 81;

parameter	SEQ_PRECHARGE_ALL = 90;
parameter	SEQ_PRECHARGE_ALL_02 = 91;
parameter	SEQ_PRECHARGE_ALL_wait = 92;

parameter	SEQ_AUTO_REFRESH_CYCLE = 93;
parameter	SEQ_AUTO_REFRESH_CYCLE_02 = 94;
parameter	SEQ_AUTO_REFRESH_CYCLE_wait = 95;

parameter	CASL = 2;
parameter	tRCD = 2;
parameter	tRC  = 8;
parameter	tRP  = 2;
parameter	tDPL = 2;
parameter	tMRD = 2;

parameter	H = 1'b1;
parameter	L = 1'b0;

reg	[1:0]		ACT_BANK 					= 2'd0;							// BA1-BA0
reg	[12:0]	ACT_ROW 						= 13'd0;							// A12-A0

reg	[15:0]	countTimeInterval			= 16'd5000;
reg	[7:0]		sequenceID						= SEQ_POWER_ON;

reg	[3:0]		count_Dout_CASL_0			= 4'd0;
reg	[3:0]		count_Dout_CASL_1			= 4'd0;


parameter		MAX_TEST_WRITE 			= 16'd6400; //16'd12800; //16'd1280; //16'd51200;					// 16'd1024; //777; //555; // 512;

reg	[23:0]	ramWriteAddressOld		= 24'hffffff;

reg	[23:0]	ramAddressNow	 			= 24'hffffff;
reg	[23:0]	ramAddressOld0 			= 24'hffffff;
reg	[23:0]	ramAddressOld1 			= 24'hffffff;
reg	[23:0]	ramAddressRead 			= 24'hffffff;

reg	[0:0]		flagGetData00				= 1'b0;
reg	[0:0]		flagGetData01				= 1'b0;
reg	[0:0]		flagGetData02				= 1'b0;
reg	[0:0]		flagGetData03				= 1'b0;
reg	[0:0]		flagGetData10				= 1'b0;
reg	[0:0]		flagGetData11				= 1'b0;
reg	[0:0]		flagGetData12				= 1'b0;
reg	[0:0]		flagGetData13				= 1'b0;

reg	[15:0]	TEST_WRITE_DATA_00		= 16'd0;							// bank 0:address 0 data for write.
reg	[15:0]	TEST_WRITE_DATA_01		= 16'd0;							// bank 0:address 1 data for write.
reg	[15:0]	TEST_WRITE_DATA_02		= 16'd0;							// bank 0:address 2 data for write.
reg	[15:0]	TEST_WRITE_DATA_03		= 16'd0;							// bank 0:address 3 data for write.
reg	[15:0]	TEST_WRITE_DATA_10		= 16'd0;							// bank 1:address 0 data for write.
reg	[15:0]	TEST_WRITE_DATA_11		= 16'd0;							// bank 1:address 1 data for write.
reg	[15:0]	TEST_WRITE_DATA_12		= 16'd0;							// bank 1:address 2 data for write.
reg	[15:0]	TEST_WRITE_DATA_13		= 16'd0;							// bank 1:address 3 data for write.

reg	[8:0]		TEST_WRITE_ADDRESS 		= 9'd0;							// address for write.

reg	[15:0]	count_test_write			= 16'd0;
reg	[23:0]	count_test_address		= 24'd0;
reg	[3:0]		count_test_bank0_count	= 4'd0;
reg	[3:0]		count_test_bank1_count	= 4'd0;

reg	[8:0]		TEST_READ_ADDRESS 		= 9'd0;							// address for read.

reg	[15:0]	TEST_WRITE_DATA_A			= 16'd0;							// test data for write.
reg	[15:0]	TEST_WRITE_DATA_B			= 16'd0;							// test data for write.
reg	[15:0]	TEST_WRITE_DATA_C			= 16'd0;							// test data for write.
reg	[15:0]	TEST_WRITE_DATA_D			= 16'd0;							// test data for write.

reg	[15:0]	regWriteData0	= 16'H2222;// 16'h1717;//16'd0;
reg	[15:0]	regWriteData1	= 16'H4444;//16'h1727;//16'd0;
reg	[15:0]	regWriteData2	= 16'H3333;//16'h1717;//16'd0;
reg	[15:0]	regWriteData3	= 16'H5555;//16'h1747;//16'd0;

reg	[0:0]		flagEarlyRead = 1'b0;

reg	[7:0]		countRefreashNop = 8'd0;

reg	[0:0]		flag_IDLE_run_command = 1'b0;

initial begin
end

// SDRAM control.
always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		DRAM_DQ_W 				<= 16'bzzzz_zzzz_zzzz_zzzz;
		sequenceID 				<= SEQ_POWER_ON;
		countTimeInterval 	<= 16'd5000;		// 100usec (20nsec*5000=100000nsec)
		flagWriteBusy			<= 1'b0;
		flagAutoRefreshBusy	<= 1'b0;
		flagBusy					<= 1'b1;
		flagReadOK				<= 1'b0;
		flagReadOK00 			= 1'b0;
		flagReadOK01 			= 1'b0;
		flagReadOK02 			= 1'b0;
		flagReadOK03 			= 1'b0;
		flagReadOK10 			= 1'b0;
		flagReadOK11 			= 1'b0;
		flagReadOK12 			= 1'b0;
		flagReadOK13 			= 1'b0;
		flagGetData00			= 1'b0;
		flagGetData01			= 1'b0;
		flagGetData02			= 1'b0;
		flagGetData03			= 1'b0;
		flagGetData10			= 1'b0;
		flagGetData11			= 1'b0;
		flagGetData12			= 1'b0;
		flagGetData13			= 1'b0;
		ramData					<= 16'd0;
		ramWriteAddressOld	<= 24'hffffff;
		ramAddressNow			<= 24'hffffff;
		ramAddressOld0 		<= 24'hffffff;
		ramAddressOld1 		<= 24'hffffff;
		countRefreashNop		<= 8'd0;
		
	end else begin
	
		if(sequenceID == SEQ_POWER_ON) begin
			flagBusy <= 1'b1;
			
			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_PRECHARGE_INIT;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end
		
		end else if(sequenceID == SEQ_IDLE) begin							// from SEQ_WRITE->SEQ_PRECHARGE, SEQ_READA.
			
			if (resetMode == 1'b1) begin
				flagWriteBusy	<= 1'b0;
				flagAutoRefreshBusy <= 1'b0;
				flagBusy			<= 1'b1;
				flagReadOK		<= 1'b0;
				flagReadOK00 	= 1'b0;
				flagReadOK01 	= 1'b0;
				flagReadOK02 	= 1'b0;
				flagReadOK03 	= 1'b0;
				flagReadOK10 	= 1'b0;
				flagReadOK11 	= 1'b0;
				flagReadOK12 	= 1'b0;
				flagReadOK13 	= 1'b0;
				flagGetData00	= 1'b0;
				flagGetData01	= 1'b0;
				flagGetData02	= 1'b0;
				flagGetData03	= 1'b0;
				flagGetData10	= 1'b0;
				flagGetData11	= 1'b0;
				flagGetData12	= 1'b0;
				flagGetData13	= 1'b0;
				ramData					<= 16'd0;
				ramWriteAddressOld	<= 24'hffffff;
				ramAddressNow			<= 24'hffffff;
				ramAddressOld0 		<= 24'hffffff;
				ramAddressOld1 		<= 24'hffffff;
				countRefreashNop		<= 8'd0;

			end else begin
			
				flag_IDLE_run_command = 1'b0;		// (non block)
			
				if (autoRefreshMode == 1'b1) begin
				
					if (flagWriteBurst == 1'b0 && flagReadBurst == 1'b0) begin
						// NOP
						DRAM_CKE <= H;
						DRAM_CS_N <= L;
						DRAM_RAS_N <= H;
						DRAM_CAS_N <= H;
						DRAM_WE_N <= H;

						countTimeInterval <= tDPL[15:0] + tRP[15:0] - 16'd1;

						sequenceID <= SEQ_PRECHARGE_ALL;

						flag_IDLE_run_command = 1'b1;		// (non block)
							
						flagBusy <= 1'b1;
						
						flagAutoRefreshBusy <= 1'b1;
					end else begin
						flagBusy <= 1'b0;
						
						flagAutoRefreshBusy <= 1'b0;
					end
					
					flagWriteBusy <= 1'b0;
	
				end else if (writeMode == 1'b1) begin
					
					if (ramWriteAddressOld[23:0] != ramWriteAddress[23:0]) begin
						ramWriteAddressOld[23:0] <= ramWriteAddress[23:0];
						
						count_test_write = 16'd0;
						
						regWriteData0 <= ramWriteData0;
						regWriteData1 <= ramWriteData1;
						regWriteData2 <= ramWriteData2;
						regWriteData3 <= ramWriteData3;
						
						if (flagWriteBurst == 1'b0) begin
							DRAM_DQM[1:0] <= {H,H};
						end

						ACT_BANK[1:1] = ramWriteAddress[23:23];					// (23:23) -> BANK(1:1)  0 ~ 1 or 2 ~ 3

						ACT_ROW[12:0] = ramWriteAddress[22:10];					// (22:10) -> ROW(12:0)  0 ~ 8192

						TEST_WRITE_ADDRESS[8:2] <= ramWriteAddress[9:3];		// (9:3) -> COLUMN 0 ~ 508

						ACT_BANK[0:0] = ramWriteAddress[2:2];						// (2:2) -> BANK(0:0)  0 or 1

						TEST_WRITE_ADDRESS[1:0] <= 2'd0;								// (1:0) -> COLUMN 0,1,2,3 (burst length=4)

						// ACT
						DRAM_CKE <= H;
						DRAM_CS_N <= L;
						DRAM_RAS_N <= L;
						DRAM_CAS_N <= H;
						DRAM_WE_N <= H;
						DRAM_BA[1:0] <= ACT_BANK[1:0];
						DRAM_A[12:0] <= ACT_ROW[12:0];

						sequenceID <= SEQ_WRITE_ACT_wait;
							
						flag_IDLE_run_command = 1'b1;		// (non block)
							
						flagBusy <= 1'b1;
						
						flagWriteBusy <= 1'b1;
						
					end else begin
						flagBusy <= 1'b0;
						
						flagWriteBusy <= 1'b0;
					end

					flagAutoRefreshBusy <= 1'b0;
						
				end else begin  // read mode or idle mode.
				
					if (ramAddressNow[23:0] != ramAddress[23:0]) begin		// read mode.
						ramAddressNow[23:0] <= ramAddress[23:0];
					
						flagReadOK	= 1'b0;

						flagGetData00 = 1'b0;
						flagGetData01 = 1'b0;
						flagGetData02 = 1'b0;
						flagGetData03 = 1'b0;
						flagGetData10 = 1'b0;
						flagGetData11 = 1'b0;
						flagGetData12 = 1'b0;
						flagGetData13 = 1'b0;
						
						if (ramAddress[2:2] == 1'b0) begin					// BANK(0:0)  0 or 1
							case (ramAddress[1:0])
								2'd0 : flagGetData00	= 1'b1;
								2'd1 : flagGetData01	= 1'b1;
								2'd2 : flagGetData02	= 1'b1;
								2'd3 : flagGetData03	= 1'b1;
							endcase
						end else begin
							case (ramAddress[1:0])
								2'd0 : flagGetData10	= 1'b1;
								2'd1 : flagGetData11	= 1'b1;
								2'd2 : flagGetData12	= 1'b1;
								2'd3 : flagGetData13	= 1'b1;
							endcase
						end
						
						flagEarlyRead = 1'b0;
					
						if (ramAddressOld0[23:2] == ramAddress[23:2]) begin

							ramAddressOld0[1:0] <= ramAddress[1:0];

							// anather bank 1 sequenceID read check.
							if (ramAddress[1:0] == 2'd2) begin
								if (ramAddressOld1[23:2] != ramAddress[23:2] + 22'd1) begin
									flagEarlyRead = 1'b1;
									ramAddressRead[23:0] = ramAddress + 24'd4;
								end
							end
						end else if (ramAddressOld1[23:2] == ramAddress[23:2]) begin

							ramAddressOld1[1:0] <= ramAddress[1:0];
							
							// anather bank 0 sequenceID read check.
							if (ramAddress[1:0] == 2'd2) begin
								if (ramAddressOld0[23:2] != ramAddress[23:2] + 22'd1) begin
									flagEarlyRead = 1'b1;
									ramAddressRead[23:0] = ramAddress + 24'd2;
								end
							end
						end else begin
							flagEarlyRead = 1'b1;
							ramAddressRead = ramAddress;
						end
							
						if (flagEarlyRead == 1'b1) begin
							if (ramAddressRead[2:2] == 1'b0) begin					// BANK(0:0)  0 or 1
								ramAddressOld0[23:0] <= ramAddressRead[23:0];
								flagReadOK00 = 1'b0;
								flagReadOK01 = 1'b0;
								flagReadOK02 = 1'b0;
								flagReadOK03 = 1'b0;
							end else begin
								ramAddressOld1[23:0] <= ramAddressRead[23:0];
								flagReadOK10 = 1'b0;
								flagReadOK11 = 1'b0;
								flagReadOK12 = 1'b0;
								flagReadOK13 = 1'b0;
							end
							
							DRAM_DQM[1:0] <= {H,H};
							
							// address decord.
							ACT_BANK[1:1] = ramAddressRead[23:23];					// (23:23) -> BANK(1:1)  0 ~ 1 or 2 ~ 3

							ACT_ROW[12:0] = ramAddressRead[22:10];					// (22:10) -> ROW(12:0)  0 ~ 8192

							TEST_READ_ADDRESS[8:2] <= ramAddressRead[9:3];		// (9:3) -> COLUMN 0 ~ 508

							ACT_BANK[0:0] = ramAddressRead[2:2];						// (2:2) -> BANK(0:0)  0 or 1

							TEST_READ_ADDRESS[1:0] <= 2'd0;						// (1:0) -> COLUMN 0,1,2,3 (burst length=4)
							
							// ACT
							DRAM_CKE <= H;
							DRAM_CS_N <= L;
							DRAM_RAS_N <= L;
							DRAM_CAS_N <= H;
							DRAM_WE_N <= H;
							DRAM_BA[1:0] <= ACT_BANK[1:0];
							DRAM_A[12:0] <= ACT_ROW[12:0];

							sequenceID <= SEQ_READ_ACT_wait;

							flag_IDLE_run_command = 1'b1;		// (non block)
							
							flagBusy <= 1'b1;
						end else begin
							flagBusy <= 1'b0;
						end
					end else begin
						flagBusy <= 1'b0;
					end

					flagWriteBusy <= 1'b0;

					flagAutoRefreshBusy <= 1'b0;
				end
				
				if (flag_IDLE_run_command == 1'b0) begin
				
					if (countRefreashNop == 8'd0 && flagWriteBurst == 1'b0 && flagReadBurst == 1'b0) begin

						sequenceID <= SEQ_AUTO_REFRESH_CYCLE_02;
						
						flagBusy <= 1'b1;
						
					end else if (countRefreashNop != 8'd0) begin
						countRefreashNop <= countRefreashNop - 8'd1;

						flagBusy <= 1'b0;
					end
					
					flagWriteBusy <= 1'b0;

					flagAutoRefreshBusy <= 1'b0;
				end
			end
		end else if(sequenceID == SEQ_READ_ACT_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			sequenceID <= SEQ_READ;
			
		end else if(sequenceID == SEQ_READ) begin
			if (ACT_BANK[0:0] == 1'b0) begin
				count_Dout_CASL_0 <= CASL[3:0] + 4'd4;					// Bank 0,2 : CAS Latency + Burst data count.
			end else begin
				count_Dout_CASL_1 <= CASL[3:0] + 4'd4;					// Bank 1,3 : CAS Latency + Burst data count.
			end
			
			DRAM_DQ_W[15:0] = 16'bzzzz_zzzz_zzzz_zzzz;
			// READA
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= L;
			DRAM_WE_N <= H;
			DRAM_BA[1:0] <= ACT_BANK[1:0];
			DRAM_A[12:11] <= 2'd0;
			DRAM_A[10:10] <= H;											// auto precharge. 
			DRAM_A[8:0] <= TEST_READ_ADDRESS[8:0];
			DRAM_DQM[1:0] <= {L,L};

			sequenceID <= SEQ_READ_wait;
			
		end else if(sequenceID == SEQ_READ_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			countRefreashNop <= tRC[15:0];						// next refreash start.
			
			sequenceID <= SEQ_IDLE;
		
		end else if(sequenceID == SEQ_PRECHARGE_INIT) begin
			// PALL
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= L;
			DRAM_A[10:10] <= H; 
			
			countTimeInterval <= tRP[15:0] - 16'd2;
			sequenceID <= SEQ_PRECHARGE_INIT_wait;
				
		end else if(sequenceID == SEQ_PRECHARGE_INIT_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_PRECHARGE_INIT_2;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end
				
		end else if(sequenceID == SEQ_PRECHARGE_INIT_2) begin
			// REF
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= L;
			DRAM_WE_N <= H;
			
			countTimeInterval <= tRC[15:0] - 16'd2;
			sequenceID <= SEQ_PRECHARGE_INIT_2_wait;
			
		end else if(sequenceID == SEQ_PRECHARGE_INIT_2_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_PRECHARGE_INIT_3;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end
			
		end else if(sequenceID == SEQ_PRECHARGE_INIT_3) begin
			// REF
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= L;
			DRAM_WE_N <= H;
			
			countTimeInterval <= tRC[15:0] - 16'd2;
			sequenceID <= SEQ_PRECHARGE_INIT_3_wait;
			
		end else if(sequenceID == SEQ_PRECHARGE_INIT_3_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_MRS;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end
			
		end else if(sequenceID == SEQ_MRS) begin
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= L;
			DRAM_WE_N <= L;
			DRAM_BA[1:0] <= {L,L};
			DRAM_A[10:10] <= L;
			DRAM_A[9:0] <= 10'b0_00_010_0_010;			// Mode Register.(CL=2,BL=4)

			countTimeInterval <= tMRD[15:0] - 16'd2;
			sequenceID <= SEQ_MRS_wait;
			
		end else if(sequenceID == SEQ_MRS_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_WRITE_ACT_TEST_DATA;					// test mode. ****
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end

		end else if(sequenceID == SEQ_PRECHARGE_ALL) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_PRECHARGE_ALL_02;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end

		end else if(sequenceID == SEQ_PRECHARGE_ALL_02) begin
			// PALL
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= L;
			DRAM_A[10:10] <= H; 
			DRAM_A[12:11] <= 2'bzz;
			DRAM_A[9:0] <= 10'bzz_zzzz_zzzz;
			DRAM_BA[1:0] <= 2'bzz;
			
			countTimeInterval <= tRP[15:0] - 16'd2;
			sequenceID <= SEQ_PRECHARGE_ALL_wait;

		end else if(sequenceID == SEQ_PRECHARGE_ALL_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				sequenceID <= SEQ_AUTO_REFRESH_CYCLE_02;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end
			
//		end else if(sequenceID == SEQ_AUTO_REFRESH_CYCLE) begin
//			// NOP
//			DRAM_CKE <= H;
//			DRAM_CS_N <= L;
//			DRAM_RAS_N <= H;
//			DRAM_CAS_N <= H;
//			DRAM_WE_N <= H;
//
//			if (countTimeInterval == 16'd0) begin
//				sequenceID <= SEQ_AUTO_REFRESH_CYCLE_02;
//			end else begin
//				countTimeInterval <= countTimeInterval - 16'd1;
//			end
		
		end else if(sequenceID == SEQ_AUTO_REFRESH_CYCLE_02) begin
			// CBR Auto-Refresh(REF) 
			DRAM_CKE <= H;								// CKE timing {H,H}
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= L;
			DRAM_WE_N <= H;
			DRAM_BA[1:0] <= 2'bzz;
			DRAM_A[12:0] <= 13'bz_zzzz_zzzz_zzzz;

			countTimeInterval <= tRC[15:0];		// next clock start.

			sequenceID <= SEQ_AUTO_REFRESH_CYCLE_wait;
				
			flagBusy <= 1'b1;
			
		end else if(sequenceID == SEQ_AUTO_REFRESH_CYCLE_wait) begin
				// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			if (countTimeInterval == 16'd0) begin
				countRefreashNop <= tRC[15:0];				// next refreash start.

				sequenceID <= SEQ_IDLE;
			end else begin
				countTimeInterval <= countTimeInterval - 16'd1;
			end

	
		end else if(sequenceID == SEQ_WRITE_ACT_TEST_DATA || sequenceID == SEQ_WRITE_ACT_loop) begin
		
			if(sequenceID == SEQ_WRITE_ACT_TEST_DATA) begin
				count_test_address = 24'd0;
				count_test_write = MAX_TEST_WRITE;
				TEST_WRITE_DATA_A <= 8'd0;						// test data for write.
				TEST_WRITE_DATA_B <= 8'd1;						// test data for write.
				TEST_WRITE_DATA_C <= 8'd2;						// test data for write.
				TEST_WRITE_DATA_D <= 8'd3;						// test data for write.
			end

			ACT_BANK[1:1] = count_test_address[23:23];				// (23:23) -> BANK(1:1)  0 ~ 1 or 2 ~ 3

			ACT_ROW[12:0] = count_test_address[22:10];				// (22:10) -> ROW(12:0)  0 ~ 8192

			TEST_WRITE_ADDRESS[8:2] <= count_test_address[9:3];	// (9:3) -> COLUMN 0 ~ 508

			ACT_BANK[0:0] = count_test_address[2:2];					// (2:2) -> BANK(0:0)  0 or 1

			TEST_WRITE_ADDRESS[1:0] <= 2'd0;								// (1:0) -> COLUMN 0,1,2,3 (burst length=4)

			// ACT
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= L;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;
			DRAM_BA[1:0] <= ACT_BANK[1:0];
			DRAM_A[12:0] <= ACT_ROW[12:0];

			sequenceID <= SEQ_WRITE_ACT_wait;
		
		end else if(sequenceID == SEQ_WRITE_ACT_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			sequenceID <= SEQ_WRITE_COLUMN;

			if (count_test_write == 16'd0) begin
				if (ACT_BANK[0:0] == 1'b0) begin
					TEST_WRITE_DATA_00 <= regWriteData0;
				end else begin
					TEST_WRITE_DATA_10 <= regWriteData0;
				end
			end else begin
				if (ACT_BANK[0:0] == 1'b0) begin
					TEST_WRITE_DATA_00 <= TEST_WRITE_DATA_A;
				end else begin
					TEST_WRITE_DATA_10 <= TEST_WRITE_DATA_A;
				end
			end

		end else if(sequenceID == SEQ_WRITE_COLUMN) begin
			if (count_test_write == 16'd0) begin
				if (ACT_BANK[0:0] == 1'b0) begin
					count_test_bank0_count = 4'd4;
					TEST_WRITE_DATA_01 <= regWriteData1;
					TEST_WRITE_DATA_02 <= regWriteData2;
					TEST_WRITE_DATA_03 <= regWriteData3;
				end else begin
					count_test_bank1_count = 4'd4;
					TEST_WRITE_DATA_11 <= regWriteData1;
					TEST_WRITE_DATA_12 <= regWriteData2;
					TEST_WRITE_DATA_13 <= regWriteData3;
				end
			end else begin
				if (ACT_BANK[0:0] == 1'b0) begin
					count_test_bank0_count = 4'd4;
					TEST_WRITE_DATA_01 <= TEST_WRITE_DATA_B;
					TEST_WRITE_DATA_02 <= TEST_WRITE_DATA_C;
					TEST_WRITE_DATA_03 <= TEST_WRITE_DATA_D;
				end else begin
					count_test_bank1_count = 4'd4;
					TEST_WRITE_DATA_11 <= TEST_WRITE_DATA_B;
					TEST_WRITE_DATA_12 <= TEST_WRITE_DATA_C;
					TEST_WRITE_DATA_13 <= TEST_WRITE_DATA_D;
				end
			end
		
			// WRITE
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= L;
			DRAM_WE_N <= L;
			DRAM_BA[1:0] <= ACT_BANK[1:0];
			DRAM_A[12:11] <= 2'd0;
			DRAM_A[10:10] <= H;									// auto precharge.
			DRAM_A[8:0] <= TEST_WRITE_ADDRESS[8:0];
			DRAM_DQM[1:0] <= {L,L};

			sequenceID <= SEQ_WRITE_COLUMN_wait;

		end else if(sequenceID == SEQ_WRITE_COLUMN_wait) begin
			// NOP
			DRAM_CKE <= H;
			DRAM_CS_N <= L;
			DRAM_RAS_N <= H;
			DRAM_CAS_N <= H;
			DRAM_WE_N <= H;

			flagWriteBusy <= 1'b0;								// clear.
			
			if (count_test_write >= 16'd2) begin			// test data write count (startup only)

				count_test_write <= count_test_write - 16'd1;
				
				count_test_address <= count_test_address + 24'd4;
				
				TEST_WRITE_DATA_A <= TEST_WRITE_DATA_A + 16'd4;						// test data for write.
				TEST_WRITE_DATA_B <= TEST_WRITE_DATA_B + 16'd4;						// test data for write.
				TEST_WRITE_DATA_C <= TEST_WRITE_DATA_C + 16'd4;						// test data for write.
				TEST_WRITE_DATA_D <= TEST_WRITE_DATA_D + 16'd4;						// test data for write.
				
				sequenceID <= SEQ_WRITE_ACT_loop;
			end else begin
				count_test_write <= 16'd0;
				sequenceID <= SEQ_IDLE;

				countRefreashNop <= tRC[15:0];						// next refreash start.
			end
		end

		countLastWrite <= count_test_bank0_count + count_test_bank1_count;			// clock now + (always n_CLOCK_50 after)
		
		// WRITE burst 4 data.
		case (count_test_bank0_count) 
			4'd4 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_00;
			4'd3 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_01;
			4'd2 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_02;
			4'd1 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_03;
		endcase
		
		if (count_test_bank0_count != 4'd0) begin
			count_test_bank0_count <= count_test_bank0_count - 4'd1;
		end else begin
			case (count_test_bank1_count)
				4'd4 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_10;
				4'd3 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_11;
				4'd2 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_12;
				4'd1 : DRAM_DQ_W[15:0] <= TEST_WRITE_DATA_13;
			endcase
			
			if (count_test_bank1_count != 4'd0) begin
				count_test_bank1_count <= count_test_bank1_count - 4'd1;
			end
		end

		// READ burst 4 data.
		case (count_Dout_CASL_0)
			4'd4 :
				begin
					ramData00[15:0] = DRAM_DQ_R2[15:0];
					flagReadOK00 = 1'b1;
				end
			4'd3 :
				begin
					ramData01[15:0] = DRAM_DQ_R2[15:0];
					flagReadOK01 = 1'b1;
				end
			4'd2 :
				begin
					ramData02[15:0] = DRAM_DQ_R2[15:0];
					flagReadOK02 = 1'b1;
				end
			4'd1 :
				begin
					ramData03[15:0] = DRAM_DQ_R2[15:0];
					flagReadOK03 = 1'b1;
				end
		endcase
		
		if (count_Dout_CASL_0 != 4'd0) begin
			count_Dout_CASL_0 <= count_Dout_CASL_0 - 4'd1;
		end else begin
			case (count_Dout_CASL_1)
				4'd4 :
					begin
						ramData10[15:0] = DRAM_DQ_R2[15:0];
						flagReadOK10 = 1'b1;
					end
				4'd3 :
					begin
						ramData11[15:0] = DRAM_DQ_R2[15:0];
						flagReadOK11 = 1'b1;
					end
				4'd2 :
					begin
						ramData12[15:0] = DRAM_DQ_R2[15:0];
						flagReadOK12 = 1'b1;
					end
				4'd1 :
					begin
						ramData13[15:0] = DRAM_DQ_R2[15:0];
						flagReadOK13 = 1'b1;
					end
			endcase
			
			if (count_Dout_CASL_1 != 4'd0) begin
				count_Dout_CASL_1 <= count_Dout_CASL_1 - 4'd1;
			end
		end
		
		// get user address one data.
		if (flagGetData00 == 1'b1) begin
			if (flagReadOK00 == 1'b1) begin
				ramData[15:0] <= ramData00[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData01 == 1'b1) begin
			if (flagReadOK01 == 1'b1) begin
				ramData[15:0] <= ramData01[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData02 == 1'b1) begin
			if (flagReadOK02 == 1'b1) begin
				ramData[15:0] <= ramData02[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData03 == 1'b1) begin
			if (flagReadOK03 == 1'b1) begin
				ramData[15:0] <= ramData03[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData10 == 1'b1) begin
			if (flagReadOK10 == 1'b1) begin
				ramData[15:0] <= ramData10[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData11 == 1'b1) begin
			if (flagReadOK11 == 1'b1) begin
				ramData[15:0] <= ramData11[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData12 == 1'b1) begin
			if (flagReadOK12 == 1'b1) begin
				ramData[15:0] <= ramData12[15:0];
				flagReadOK <= 1'b1;
			end
		end else if (flagGetData13 == 1'b1) begin
			if (flagReadOK13 == 1'b1) begin
				ramData[15:0] <= ramData13[15:0];
				flagReadOK <= 1'b1;
			end
		end
	end
end

wire n_CLOCK_50 = ~CLOCK_50;			// reverse clock for SDRAM.

// SDRAM DQ Access.
always @(posedge n_CLOCK_50)
begin
	DRAM_DQ_R[15:0] <= DRAM_DQ[15:0];
end

assign DRAM_CLK = n_CLOCK_50;

assign DRAM_DQ[15:0] = DRAM_DQ_W[15:0];

assign DRAM_DQ_R2[15:0] = DRAM_DQ_R[15:0];

assign flagWriteBurst = (countLastWrite!=8'd0) ? 1'b1 : 1'b0;

assign flagReadBurst = (count_Dout_CASL_0 != 4'd0 || count_Dout_CASL_1 != 4'd0) ? 1'b1 : 1'b0;

assign flagAutoRefreshCycle = (	sequenceID == SEQ_AUTO_REFRESH_CYCLE_wait ||
											sequenceID == SEQ_PRECHARGE_ALL ||
											sequenceID == SEQ_PRECHARGE_ALL_02 ||
											sequenceID == SEQ_PRECHARGE_ALL_wait ||
											sequenceID == SEQ_AUTO_REFRESH_CYCLE ||
											sequenceID == SEQ_AUTO_REFRESH_CYCLE_02 ||
											sequenceID == SEQ_AUTO_REFRESH_CYCLE_wait) ? 1'b1 : 1'b0;			// now CBR Auto-Refresh...
	
endmodule
