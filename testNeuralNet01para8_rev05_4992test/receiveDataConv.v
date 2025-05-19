//
// input 8 byte data => output 4 word data.
// under 8 byte data is hold internally.
//

module receiveDataConv (
	input						CLOCK_50,
	input						RST_N,

	input 		[7:0]		receiveData_i,
	input 		[24:0]	receiveAddress_i,
	input 		[0:0]		receiveResetMode_i,
	input 		[0:0]		receiveDisableNow_i,
	
	output reg	[0:0]		receiveResetMode		= 1'b0,
	output reg	[0:0]		receiveDisableNow		= 1'b0,
	
	output reg	[24:0]	receiveAddress			= 25'h1ffffff,
	output reg	[15:0]	receiveData0			= 16'd0,
	output reg	[15:0]	receiveData1			= 16'd0,
	output reg	[15:0]	receiveData2			= 16'd0,
	output reg	[15:0]	receiveData3			= 16'd0,
	
	output reg	[15:0]	checksum					= 16'd0,

	input						flagWriteBusy,
	input						flagAutoRefreshBusy,
	input						flagBusy,							// busy flag(startup, write, read)
	input						flagWriteBurst,
	input						flagReadBurst,
	input						flagAutoRefreshCycle,			// now CBR Auto-Refresh...
	
	input						flagCompleteCalc,

	output reg	[0:0]		autoRefreshMode		= 1'b0	// CBR Auto-Refresh(REF) 
);

reg	[7:0]		data8 = 8'd0;
reg	[3:0]		countData = 4'd0;
reg	[24:0]	receiveAddressOld = 25'd0;

parameter		AUTO_REFRESH_INTERVAL   = 26'd20000;//26'd5000;			// (20,000=0.4msec, 10,000=0.2msec, 5,000=0.1msec, 2,500=0.05msec)
parameter		AUTO_REFRESH_INTERVAL_2 = 26'd20000;		// (50,000,000=1sec, 500,000=1sec, 20,000=0.4msec, 10,000=0.2msec)

reg	[25:0]	countAutoRefreshInterval = 26'd0;

reg	[0:0]		flagAutoRefreshRequest = 1'b0;
reg	[3:0]		sequenceAutoRefreshRequest = 4'd0;
reg	[0:0]		flagIdleNow = 1'b0;


initial begin
end

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		receiveData0			<= 16'd0;
		receiveData1			<= 16'd0;
		receiveData2			<= 16'd0;
		receiveData3			<= 16'd0;
		receiveAddress			<= 25'h1ffffff;
		receiveResetMode		<= 1'b0;
		receiveDisableNow		<= 1'b0;
		data8						<= 8'd0;
		countData				<= 4'd0;
		receiveAddressOld		<= 25'd0;
		checksum					<= 16'd0;
		autoRefreshMode		<= 1'b0;
		countAutoRefreshInterval	<= 26'd0;
		flagAutoRefreshRequest		<= 1'b0;
		sequenceAutoRefreshRequest	<= 4'd0;
		flagIdleNow						<= 1'b0;
	end else if (receiveResetMode_i == 1'b1) begin
		receiveData0			<= 16'd0;
		receiveData1			<= 16'd0;
		receiveData2			<= 16'd0;
		receiveData3			<= 16'd0;
		receiveAddress			<= 25'h1ffffff;
		receiveResetMode		<= 1'b1;
		receiveDisableNow		<= 1'b0;
		data8						<= 8'd0;
		countData				<= 4'd0;
		receiveAddressOld		<= 25'd0;
		checksum					<= 16'd0;
		autoRefreshMode		<= 1'b0;
		countAutoRefreshInterval	<= 26'd0;
		flagAutoRefreshRequest		<= 1'b0;
		sequenceAutoRefreshRequest	<= 4'd0;
		flagIdleNow						<= 1'b0;
	end else begin												// data area.
		receiveResetMode		<= 1'b0;
		
		receiveDisableNow <= receiveDisableNow_i;

		if (countAutoRefreshInterval != 26'h3ffffff) begin
			countAutoRefreshInterval <= countAutoRefreshInterval + 26'd1;
		end
		
		if (receiveAddressOld == receiveAddress_i) begin
			receiveAddressOld <= receiveAddressOld + 25'd1;
			
			checksum[15:0] <= checksum[15:0] + {8'd0, receiveData_i[7:0]};

			if (countData[0:0] == 1'b0) begin
				data8[7:0]  <= receiveData_i[7:0];

				if (countData == 4'd0) begin
					receiveData0[15:0] <= 16'd0;
					receiveData1[15:0] <= 16'd0;
					receiveData2[15:0] <= 16'd0;
					receiveData3[15:0] <= 16'd0;
				end
				
				countData <= countData + 4'd1;
				
			end else begin
				case(countData[2:1])
				2'd0 : receiveData0[15:0] <= { receiveData_i[7:0], data8[7:0] };
				2'd1 : receiveData1[15:0] <= { receiveData_i[7:0], data8[7:0] };
				2'd2 : receiveData2[15:0] <= { receiveData_i[7:0], data8[7:0] };
				2'd3 : receiveData3[15:0] <= { receiveData_i[7:0], data8[7:0] };
				endcase
				
				if (countData == 4'd7) begin
					if (flagAutoRefreshRequest == 1'b0) begin
					
						countData <= 4'd0;

						if (countAutoRefreshInterval >= AUTO_REFRESH_INTERVAL) begin	// SDRAM Auto refresh timeinterval clock count.
							countAutoRefreshInterval <= 26'd0;
							flagAutoRefreshRequest <= 1'b1;										// SDRAM Auto refresh cycle request sequence.
							sequenceAutoRefreshRequest <= 4'd0;
						end

						if (receiveAddress == 25'h1fffffc) begin								// address empty!
							receiveAddress <= 25'd0;
						end else begin
							receiveAddress <= receiveAddress + 25'd4;							// raceive address == write address.
						end
					end
				end else begin
					countData <= countData + 4'd1;
				end
			end
			
			flagIdleNow <= 1'b0;
			
		end else begin

			if (receiveDisableNow_i == 1'b1 && receiveAddress != 25'h1ffffff &&  flagCompleteCalc == 1'b1) begin
				if (countAutoRefreshInterval >= AUTO_REFRESH_INTERVAL_2) begin	// SDRAM Auto refresh timeinterval clock count.
					countAutoRefreshInterval <= 26'd0;
					flagAutoRefreshRequest <= 1'b1;										// SDRAM Auto refresh cycle request sequence.
					sequenceAutoRefreshRequest <= 4'd0;
				end
				
				flagIdleNow <= 1'b1;
			end else begin
				flagIdleNow <= 1'b0;
			end
		end

		
		// SDRAM Auto refresh cycle request sequence.
		if (flagAutoRefreshRequest == 1'b1) begin
			case (sequenceAutoRefreshRequest)
			0 : sequenceAutoRefreshRequest <= 4'd1;
			1 : begin
					if (flagWriteBusy | flagBusy | flagWriteBurst | flagReadBurst | flagIdleNow) begin
						autoRefreshMode <= 1'b1;						// request now.
						sequenceAutoRefreshRequest <= 4'd2;
					end
				end
			2 : begin
					if (flagAutoRefreshCycle == 1'b1) begin		// now CBR Auto-Refresh...
						autoRefreshMode <= 1'b0;
						flagAutoRefreshRequest <= 1'b0;				// request complete.
					end
				end
			endcase
		end
	end
end

endmodule
