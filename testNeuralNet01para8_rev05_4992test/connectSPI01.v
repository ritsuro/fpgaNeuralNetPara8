module connectSPI01 (
	input					CLOCK_50,
	input					RST_N,
	input					BUTTON_COMM_RESET,	// comm reset button.

	input					SPI_MISO,
	output				SPI_MOSI,
	input					SPI_CLOCK,
	input					SPI_ENABLE_N,
	
	output reg [7:0]	receiveData				= 8'd0,
	output reg [24:0]	receiveAddress			= 25'h1ffffff,		// <============= 16(65,536) -> 25(33,554,432)
	output reg [0:0]	receiveResetMode		= 1'b0,
	output reg [0:0]	receiveDisableNow		= 1'b0
	
);

parameter	MAX_ADDRESS 				= 25'd32000000; //16'd65520; //16'd16384;

reg [0:0]	SPI_MOSI_W					= 1'b0;
reg [0:0]	bitValue	[8];
reg [7:0]	receiveBitCount			= 8'd0;

reg [31:0]	counter2widthOn			= 32'd0;
reg [31:0]	counter2widthOnHold		= 32'd0;
reg [31:0]	counter2widthOff			= 32'd0;
reg [31:0]	counter2widthOffHold		= 32'd0;
reg [0:0]	flagClockOn					= 1'b0;
reg [31:0]	countOvershootWait		= 32'd0;

reg [3:0]	countZeroData				= 4'd0;

reg [0:0]	flagResetMode				= 1'b0;

reg [7:0]	data8							= 8'd0;

reg [31:0]	count_SPI_disable			= 32'd0;

parameter	SPI_DISABLE_TIME			= 32'd5000000;	//25000000;		// 5,000,000 = 0.1sec, 25,000,000 = 0.5sec

reg [7:0]	resetCounter				= 8'd0;

integer	i;

initial begin
	for(i=0;i<8;i=i+1) begin
		bitValue[i] = 1'b0;
	end
end

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		SPI_MOSI_W					<= 1'b0;

		receiveBitCount			<= 8'd0;

		counter2widthOn			<= 32'd0;
		counter2widthOnHold		<= 32'd0;
		counter2widthOff			<= 32'd0;
		counter2widthOffHold		<= 32'd0;
		flagClockOn					<= 1'b0;
		countOvershootWait		<= 32'd0;

		countZeroData				<= 4'd0;
		
		receiveData					<= 8'd0;
		receiveAddress				<= 25'h1ffffff;
		receiveResetMode			<= 1'b0;
		receiveDisableNow 		<= 1'b0;
		
		count_SPI_disable			<= 32'd0;
		
		resetCounter				<= 8'd02;							// <======== 2 = test number....
		
	end else begin
		if (BUTTON_COMM_RESET == 1'b0) begin
			receiveResetMode <= 1'b1;
		end
	
		if (receiveResetMode == 1'b1) begin							// reset mode.
			receiveResetMode <= 1'b0;									// reset mode clear now.
			
			SPI_MOSI_W					<= 1'b0;

			receiveBitCount			<= 8'd0;

			counter2widthOn			<= 32'd0;
			counter2widthOnHold		<= 32'd0;
			counter2widthOff			<= 32'd0;
			counter2widthOffHold		<= 32'd0;
			flagClockOn					<= 1'b0;
			countOvershootWait		<= 32'd0;

			countZeroData				<= 4'd0;
			
			receiveData					<= 8'd0;
			receiveAddress				<= 25'h1ffffff;
			receiveResetMode			<= 1'b0;
			receiveDisableNow 		<= 1'b0;
			
			count_SPI_disable			<= 32'd0;
			
		end else begin

			if (SPI_ENABLE_N == 1'b1) begin										// SPI enable line check.
				if (count_SPI_disable == SPI_DISABLE_TIME) begin			// SPI receive data disable time check.
					receiveDisableNow <= 1'b1;
				end else begin
					count_SPI_disable <= count_SPI_disable + 32'd1;
				end
			end else begin
				count_SPI_disable <= 32'd0;
				receiveDisableNow <= 1'b0;
			end
		
			if (SPI_CLOCK == 1'b1) begin													// SPI_CLOCK == 1

				if (flagClockOn == 1'b0) begin											// clock on start.
					flagClockOn <= 1'b1;
					
					// important of blank gap timing.
					if (counter2widthOffHold > (counter2widthOnHold + 32'd2)) begin // clock blank check.
						bitValue[0] = SPI_MISO;												// bit 0.
						receiveBitCount <= 8'd0;
						bitValue[1] = 0;
						bitValue[2] = 0;
						bitValue[3] = 0;
						bitValue[4] = 0;
						bitValue[5] = 0;
						bitValue[6] = 0;
						bitValue[7] = 0;
					end else begin
						if(receiveBitCount < 8'd8) begin
							bitValue[receiveBitCount] = SPI_MISO;						// bit 1~7.
							
							if(receiveBitCount == 8'd7) begin

								data8 = { bitValue[0],bitValue[1],bitValue[2],bitValue[3],bitValue[4],bitValue[5],bitValue[6],bitValue[7] };
								
								receiveData[7:0] <= data8;
								
								flagResetMode = 1'b0;
								
								if (flagResetMode == 1'b0) begin							//
									if (receiveAddress != MAX_ADDRESS) begin			// stop address.
										receiveAddress <= receiveAddress + 25'd1;		//
									end															//
								end
							end
						end
					end
					
					counter2widthOff <= 0;
				end else begin															// clock on continue.
					if (counter2widthOn < 32'h3fff_ffff) begin				// mask 30bit(0~1,073,741,824)  1sec = 50,000,000
						counter2widthOn     <= counter2widthOn + 32'd1;
						counter2widthOnHold <= counter2widthOn;
					end
				end
			end else begin																// SPI_CLOCK == 0
				if (flagClockOn == 1'b1) begin
					flagClockOn <= 1'b0;
					
					receiveBitCount <= receiveBitCount + 8'd1;
					counter2widthOn <= 0;
					
				end else begin
					if (counter2widthOff < 32'h3fff_ffff) begin				// mask 30bit(0~1,073,741,824)  1sec = 50,000,000
						counter2widthOff     <= counter2widthOff + 32'd1;
						counter2widthOffHold <= counter2widthOff;
					end

					// send port.
					case(receiveBitCount)
					1 : SPI_MOSI_W <= resetCounter[6:6];
					2 : SPI_MOSI_W <= resetCounter[5:5];
					3 : SPI_MOSI_W <= resetCounter[4:4];
					4 : SPI_MOSI_W <= resetCounter[3:3];
					5 : SPI_MOSI_W <= resetCounter[2:2];
					6 : SPI_MOSI_W <= resetCounter[1:1];
					7 : SPI_MOSI_W <= resetCounter[0:0];
					default : SPI_MOSI_W <= resetCounter[7:7];				// 0 or 8
					endcase
				end
			end
		end
	end
end

assign SPI_MOSI = SPI_MOSI_W;

endmodule
