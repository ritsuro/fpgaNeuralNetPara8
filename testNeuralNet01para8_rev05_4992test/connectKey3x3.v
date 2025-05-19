module connectKey3x3 (
	input						CLOCK_50,
	input						RST_N,
	output reg	[7:0]		LED = 8'd0,

	input			[2:0]		KEY_X,				// Pull-Up 
	output reg	[2:0]		KEY_Y = 3'bzzz,	// Pull-Up
	
	output reg	[8:0]		flagKey3x3
);
	
reg	[7:0]		countKey = 8'd0;

reg	[8:0]		flagKEY = 9'd0;

reg	[0:0]		flag_on[9];
reg	[0:0]		flag_sw[9];
reg	[11:0]	count_on[9];

reg	[9:0]		flag_check = 9'd0;

integer i;

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		KEY_Y	<= 3'bzzz;
		LED <= 8'd0;
		countKey <= 8'd0;
		flagKEY <= 9'd0;
		flagKey3x3 = 9'd0;
		for (i=0;i<9;i=i+1) begin
			flag_on[i] <= 1'b0;
			flag_sw[i] <= 1'b0;
			count_on[i][11:0] <= 12'd0;
		end
	end else begin
	
		
		flag_check = 9'd1;
		
		for (i=0;i<9;i=i+1) begin
			if ((flagKEY[8:0] & flag_check) == 9'd0) begin
				if (count_on[i] == 12'd4000) begin					// time interval.
					if (flag_sw[i] == 1'b0) begin						// button on flag set.
						flag_sw[i] <= 1'b1;								// button on flag set.
						flag_on[i] <= 1'b1;								// button flag now.
					end else begin
						flag_on[i] <= 1'b0;
					end
				end else begin
					count_on[i] <= count_on[i] + 12'd1;
					flag_on[i] <= 1'b0;
				end
			end else begin
				if (count_on[i] == 12'd0) begin
					flag_sw[i] <= 1'b0;									// button on flag clear.
					flag_on[i] <= 1'b0;
				end else begin
					count_on[i] <= count_on[i] - 12'd1;
				end
			end
			
			flag_check = flag_check << 1;
		end
		
		flagKey3x3[8:0] <= {flag_on[8],flag_on[7],flag_on[6],flag_on[5],flag_on[4],flag_on[3],flag_on[2],flag_on[1],flag_on[0]};
	
	
		if (countKey == 8'd61) begin
			countKey <= 8'd0;
		end else begin
			countKey <= countKey + 8'd1;
		end

		case (countKey)
		0  : KEY_Y <= 3'bzz0;
		20 : begin
				LED[2:0] <= KEY_X[2:0];
				flagKEY[2:0] <= KEY_X[2:0];
			end
			
		21 : KEY_Y <= 3'bz0z;
		40 : begin
				LED[5:3] <= KEY_X[2:0];
				flagKEY[5:3] <= KEY_X[2:0];
			end
			
		41 : KEY_Y <= 3'b0zz;
		60 : begin
				LED[7:6] <= KEY_X[1:0];
				flagKEY[8:6] <= KEY_X[2:0];
			end
		endcase
	end
end
endmodule
