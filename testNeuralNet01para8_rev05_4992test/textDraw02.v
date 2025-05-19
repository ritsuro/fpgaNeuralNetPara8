module textDraw02(
	input					CLOCK_50,
	input					RST_N,
	input		[19:0]	dot,
	input 	[19:0]	y_count_in,
	
	input					resetMode,
	
	input		[7:0]		print_rec_01,
	input		[24:0]	print_val_01,
	input		[0:0]		print_set_01,

	input		[7:0]		print_rec_02,
	input		[24:0]	print_val_02,
	input		[0:0]		print_set_02,

	input		[7:0]		print_rec_03,
	input		[24:0]	print_val_03,
	input		[0:0]		print_set_03,

	output  	[0:0]		r_val,
	output  	[0:0]		g_val,
	output  	[0:0]		b_val,
	output 	[0:0]		flagOK
);

reg [7:0] 	bufferText00[8];
reg [7:0] 	bufferText01[8];
reg [7:0] 	bufferText02[8];
reg [7:0] 	bufferText03[8];
reg [7:0] 	bufferText04[8];
reg [7:0] 	bufferText05[8];
reg [7:0] 	bufferText06[8];
reg [7:0] 	bufferText07[8];
reg [7:0] 	bufferText08[8];
reg [7:0] 	bufferText09[8];
reg [7:0] 	bufferText0A[8];
reg [7:0] 	bufferText0B[8];
reg [7:0] 	bufferText0C[8];
reg [7:0] 	bufferText0D[8];
reg [7:0] 	bufferText0E[8];
reg [7:0] 	bufferText0F[8];

parameter	TEXT_BLOCK_MAX = 46;//40; //240;
parameter 	SUJI_KETA = 7;

reg	[24:0] 	sujiCount01_table[TEXT_BLOCK_MAX];
reg	[3:0]  	sujiDegi	[SUJI_KETA];

integer i;

initial begin
	$readmemh("txt/number_test_30h.txt",bufferText00);
	$readmemh("txt/number_test_31h.txt",bufferText01);
	$readmemh("txt/number_test_32h.txt",bufferText02);
	$readmemh("txt/number_test_33h.txt",bufferText03);
	$readmemh("txt/number_test_34h.txt",bufferText04);
	$readmemh("txt/number_test_35h.txt",bufferText05);
	$readmemh("txt/number_test_36h.txt",bufferText06);
	$readmemh("txt/number_test_37h.txt",bufferText07);
	$readmemh("txt/number_test_38h.txt",bufferText08);
	$readmemh("txt/number_test_39h.txt",bufferText09);
	$readmemh("txt/number_test_41h.txt",bufferText0A);
	$readmemh("txt/number_test_42h.txt",bufferText0B);
	$readmemh("txt/number_test_43h.txt",bufferText0C);
	$readmemh("txt/number_test_44h.txt",bufferText0D);
	$readmemh("txt/number_test_45h.txt",bufferText0E);
	$readmemh("txt/number_test_46h.txt",bufferText0F);
end

parameter		TEXT_BLOCK_HEIGHT = 9;
parameter		TEXT_BLOCK_COUNT_Y = TEXT_BLOCK_MAX;//53;		// 480 / 9 = 53.3333...
parameter		TEXT_ALL_HEIGHT = TEXT_BLOCK_COUNT_Y * TEXT_BLOCK_HEIGHT;

parameter		WIDTH_VALUE = 11'd112;			// 16 * 7 = 112

//parameter		WIDTH_VALUE_2a = 11'd64;		// 16 * 4
//parameter		WIDTH_VALUE_2b = 11'd112;		// 16 * 7 = 112
//
//parameter		WIDTH_VALUE_3a = 11'd128;		// 16 * 8
//parameter		WIDTH_VALUE_3b = 11'd176;		// 16 * 11 = 176
//
//parameter		WIDTH_VALUE_4a = 11'd192;		// 16 * 12
//parameter		WIDTH_VALUE_4b = 11'd240;		// 16 * 15 = 176

wire	[10:0]	dotX;
wire	[10:0]	dotX_read;
assign			dotX[10:0] = dot[10:0] - 11'd320;
assign			dotX_read[10:0] = dotX[10:0] + 11'd1;

wire	[9:0]		dotY_moji;
assign			dotY_moji[9:0] = y_count_adj[9:0] * 8'd8;

wire	[10:0]	addCountY;
assign			addCountY = dotX[9:7] * TEXT_BLOCK_COUNT_Y;					// [9:7] = column count. ([6:0]=128 -> 64 pixel : value width) 

wire	[10:0]	address_number;
assign			address_number = { 4'd0, dotY_moji[8:3] } + addCountY;	// [8:3] = row count.

assign			conditionImageX = (dotX < WIDTH_VALUE);
//assign			conditionImageX = ((dotX < WIDTH_VALUE) || (dotX>=WIDTH_VALUE_2a && dotX<WIDTH_VALUE_2b)
//																		 || (dotX>=WIDTH_VALUE_3a && dotX<WIDTH_VALUE_3b)
//																		 || (dotX>=WIDTH_VALUE_4a && dotX<WIDTH_VALUE_4b));
assign			conditionImageY = (y_count_45 < TEXT_ALL_HEIGHT);

reg [7:0]		x_image_moji = 8'd0;
wire 				x_image_moji_w;
assign 			x_image_moji_w = (x_image_moji >> (3'd7 - dot[3:1])) & 1'b1;

reg	[24:0]	sujiNow = 25'd1234567;

reg	[19:0]	y_count_45;
reg	[9:0]		y_count_adj;
reg	[9:0]		y_count_adj2;
reg	[9:0]		dotYY;

wire	[0:0]		checkGapLine;
assign			checkGapLine = (y_count_in[19:0] < 20'd45) ? 1'b1 : (dotYY[3:0] >= 4'd8) ? 1'b1 : 1'b0;

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		for (i=0;i < TEXT_BLOCK_MAX;i=i+1) begin
			sujiCount01_table[i][24:0] <= 25'd0;
		end
	end else begin
		if (resetMode == 1'b1) begin
			for (i=0;i < TEXT_BLOCK_MAX;i=i+1) begin
				sujiCount01_table[i][24:0] <= 25'd0;
			end
		end else begin
			if (print_set_01 == 1'b1) begin
				sujiCount01_table[print_rec_01[7:0]][24:0] <= print_val_01[24:0];
			end

			if (print_set_02 == 1'b1) begin
				sujiCount01_table[print_rec_02[7:0]][24:0] <= print_val_02[24:0];
			end

			if (print_set_03 == 1'b1) begin
				sujiCount01_table[print_rec_03[7:0]][24:0] <= print_val_03[24:0];
			end

			if (dot[10:0] == 11'd0) begin									// x = H-Blank.
				y_count_45[19:0] <= y_count_in[19:0] - 20'd45;		//
			end else if (dot[10:0] == 11'd1) begin						// x = H-Blank.
				y_count_adj[9:0] <= y_count_45[9:0]  / 9;				// 1 clock division calc.
			end else if (dot[10:0] == 11'd2) begin						// x = H-Blank.
				y_count_adj2[9:0] <= y_count_adj[9:0] * 9;			// 1 clock multiply calc.
			end else if (dot[10:0] == 11'd3) begin						// x = H-Blank.
				dotYY <= y_count_45[9:0] - y_count_adj2[9:0];		//
			end else if (checkGapLine == 1'b0) begin
			
				for (i=0;i < SUJI_KETA;i=i+1) begin
					sujiDegi[SUJI_KETA - 1 - i][3:0] = sujiNow[3:0];
					sujiNow = sujiNow >> 4;
				end
			
				sujiNow <= sujiCount01_table[address_number];

				if (conditionImageX & conditionImageY == 1'b1) begin
					case (sujiDegi[dotX_read[6:4]])
						0 : x_image_moji <= bufferText00[dotYY[2:0]];
						1 : x_image_moji <= bufferText01[dotYY[2:0]];
						2 : x_image_moji <= bufferText02[dotYY[2:0]];
						3 : x_image_moji <= bufferText03[dotYY[2:0]];
						4 : x_image_moji <= bufferText04[dotYY[2:0]];
						5 : x_image_moji <= bufferText05[dotYY[2:0]];
						6 : x_image_moji <= bufferText06[dotYY[2:0]];
						7 : x_image_moji <= bufferText07[dotYY[2:0]];
						8 : x_image_moji <= bufferText08[dotYY[2:0]];
						9 : x_image_moji <= bufferText09[dotYY[2:0]];
						10 : x_image_moji <= bufferText0A[dotYY[2:0]];
						11 : x_image_moji <= bufferText0B[dotYY[2:0]];
						12 : x_image_moji <= bufferText0C[dotYY[2:0]];
						13 : x_image_moji <= bufferText0D[dotYY[2:0]];
						14 : x_image_moji <= bufferText0E[dotYY[2:0]];
						15 : x_image_moji <= bufferText0F[dotYY[2:0]];
						default : x_image_moji <= bufferText00[dotYY[2:0]];
					endcase
				end else begin
					x_image_moji <= 8'd0;
				end
			end
		end
	end
end

assign	flagOK = (conditionImageX & conditionImageY) & ~checkGapLine;
assign	r_val = x_image_moji_w;
assign	g_val = x_image_moji_w;
assign	b_val = x_image_moji_w;

endmodule
