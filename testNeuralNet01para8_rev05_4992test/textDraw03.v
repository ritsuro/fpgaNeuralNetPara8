module textDraw03(
	input					CLOCK_50,
	input					RST_N,
	input		[19:0]	dot,
	input 	[19:0]	y_count_in,
	
	input					resetMode,
	
	input		[19:0]	OFFSET_BASE_X,
	
	input		[12:0]	print_val_01,
	input		[7:0]		print_val_02,
	input		[7:0]		print_val_03,

	input		[12:0]	print_val_11,
	input		[7:0]		print_val_12,
	input		[7:0]		print_val_13,

	input		[12:0]	print_val_21,
	input		[7:0]		print_val_22,
	input		[7:0]		print_val_23,

	output  	[0:0]		r_val,
	output  	[0:0]		g_val,
	output  	[0:0]		b_val,
	output 	[0:0]		flagOK
);

parameter	print_rec_01 = 8'd0;
parameter	print_set_01 = 1'b1;
parameter	print_rec_02 = 8'd1;
parameter	print_set_02 = 1'b1;
parameter	print_rec_03 = 8'd2;
parameter	print_set_03 = 1'b1;

parameter	print_rec_11 = 8'd6;
parameter	print_set_11 = 1'b1;
parameter	print_rec_12 = 8'd7;
parameter	print_set_12 = 1'b1;
parameter	print_rec_13 = 8'd8;
parameter	print_set_13 = 1'b1;

parameter	print_rec_21 = 8'd12;
parameter	print_set_21 = 1'b1;
parameter	print_rec_22 = 8'd13;
parameter	print_set_22 = 1'b1;
parameter	print_rec_23 = 8'd14;
parameter	print_set_23 = 1'b1;

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

parameter	TEXT_BLOCK_MAX = 15;//21;
parameter 	SUJI_KETA = 4;

reg	[12:0] 	sujiCount01_table[TEXT_BLOCK_MAX];
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
end

parameter		TEXT_BLOCK_HEIGHT = 18;
parameter		TEXT_BLOCK_COUNT_Y = TEXT_BLOCK_MAX;

parameter		TEXT_HS1 = 0;
parameter		TEXT_HE1 = TEXT_BLOCK_HEIGHT * 3;

parameter		TEXT_HS2 = TEXT_BLOCK_HEIGHT * 6;
parameter		TEXT_HE2 = TEXT_BLOCK_HEIGHT * 9;

parameter		TEXT_HS3 = TEXT_BLOCK_HEIGHT * 12;
parameter		TEXT_HE3 = TEXT_BLOCK_HEIGHT * 15;

parameter		TEXT_ALL_HEIGHT = TEXT_BLOCK_COUNT_Y * TEXT_BLOCK_HEIGHT;

//parameter		OFFSET_BASE_X  = 11'd160;				// 16 * 10
parameter		WIDTH_VALUE_2a = 11'd0;					// 0
parameter		WIDTH_VALUE_2b = 11'd32*SUJI_KETA;	// 16 * keta

wire	[10:0]	dotX;
wire	[10:0]	dotX_read;
assign			dotX[10:0] = dot[10:0] - 11'd320 - OFFSET_BASE_X;
assign			dotX_read[10:0] = dotX[10:0] + 11'd1;

wire	[9:0]		dotY_moji;
assign			dotY_moji[9:0] = y_count_adj[9:0] * 8'd16;

wire	[10:0]	address_number;
assign			address_number = { 4'd0, dotY_moji[9:4] };		// [9:4] = row count.

assign			conditionImageX = (dotX >= WIDTH_VALUE_2a && dotX < WIDTH_VALUE_2b);

//assign			conditionImageY = (y_count_45 < TEXT_ALL_HEIGHT);
assign			conditionImageY = (y_count_45 < TEXT_HE1)
										|| (y_count_45 >= TEXT_HS2 && y_count_45 < TEXT_HE2)
										|| (y_count_45 >= TEXT_HS3 && y_count_45 < TEXT_HE3);

reg [7:0]		x_image_moji = 8'd0;
wire 				x_image_moji_w;
assign 			x_image_moji_w = (x_image_moji >> (3'd7 - dot[4:2])) & 1'b1;

reg	[12:0]		sujiNow = 12'd0;
reg	[12:0]		sujiWork10 = 12'd0;

reg	[19:0]	y_count_45;
reg	[9:0]		y_count_adj;
reg	[9:0]		y_count_adj2;
reg	[9:0]		dotYY;

wire	[0:0]		checkGapLine;
assign			checkGapLine = (y_count_in[19:0] < 20'd45) ? 1'b1 : (dotYY[4:0] >= 5'd16) ? 1'b1 : 1'b0;

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		for (i=0;i < TEXT_BLOCK_MAX;i=i+1) begin
			sujiCount01_table[i][9:0] <= 10'd0;
		end
	end else begin
		if (resetMode == 1'b1) begin
			for (i=0;i < TEXT_BLOCK_MAX;i=i+1) begin
				sujiCount01_table[i][9:0] <= 13'd0;
			end
		end else begin
			if (print_set_01 == 1'b1) sujiCount01_table[print_rec_01[7:0]][12:0] <= print_val_01[12:0];
			if (print_set_02 == 1'b1) sujiCount01_table[print_rec_02[7:0]][7:0] <= print_val_02[7:0];
			if (print_set_03 == 1'b1) sujiCount01_table[print_rec_03[7:0]][7:0] <= print_val_03[7:0];

			if (print_set_11 == 1'b1) sujiCount01_table[print_rec_11[7:0]][12:0] <= print_val_11[12:0];
			if (print_set_12 == 1'b1) sujiCount01_table[print_rec_12[7:0]][7:0] <= print_val_12[7:0];
			if (print_set_13 == 1'b1) sujiCount01_table[print_rec_13[7:0]][7:0] <= print_val_13[7:0];

			if (print_set_21 == 1'b1) sujiCount01_table[print_rec_21[7:0]][12:0] <= print_val_21[12:0];
			if (print_set_22 == 1'b1) sujiCount01_table[print_rec_22[7:0]][7:0] <= print_val_22[7:0];
			if (print_set_23 == 1'b1) sujiCount01_table[print_rec_23[7:0]][7:0] <= print_val_23[7:0];

			if (dot[10:0] == 11'd0) begin											// x = H-Blank.
				y_count_45[19:0] <= y_count_in[19:0] - 20'd45;				//
			end else if (dot[10:0] == 11'd1) begin								// x = H-Blank.
				y_count_adj[9:0] <= y_count_45[9:0]  / 10'd18;				// 1 clock division calc.
			end else if (dot[10:0] == 11'd2) begin								// x = H-Blank.
				y_count_adj2[9:0] <= y_count_adj[9:0] * 10'd18;				// 1 clock multiply calc.
			end else if (dot[10:0] == 11'd3) begin								// x = H-Blank.
				dotYY[9:0] <= y_count_45[9:0] - y_count_adj2[9:0];			//

			
			end else if (dot[10:0] == 11'd4) begin							// x = H-Blank.
				sujiNow <= sujiCount01_table[address_number];			//
			end else if (dot[10:0] == 11'd5) begin							// x = H-Blank. suji keta : 0 (SUJI_KETA=4)
				sujiWork10 <= sujiNow / 10'd10;								//
			end else if (dot[10:0] == 11'd6) begin							// x = H-Blank.
				sujiWork10 <= sujiWork10 * 10'd10;							//
			end else if (dot[10:0] == 11'd7) begin							// x = H-Blank.
				sujiDegi[3][3:0] <= sujiNow - sujiWork10;					//
			
			end else if (dot[10:0] == 11'd8) begin							// x = H-Blank.
				sujiNow <= sujiNow / 10'd10;									//
			end else if (dot[10:0] == 11'd9) begin							// x = H-Blank. suji keta : 0 (SUJI_KETA=3)
				sujiWork10 <= sujiNow / 10'd10;								//
			end else if (dot[10:0] == 11'd10) begin						// x = H-Blank.
				sujiWork10 <= sujiWork10 * 10'd10;							//
			end else if (dot[10:0] == 11'd11) begin						// x = H-Blank.
				sujiDegi[2][3:0] <= sujiNow - sujiWork10;					//
				
			end else if (dot[10:0] == 11'd12) begin						// x = H-Blank.
				sujiNow <= sujiNow / 10'd10;									//
			end else if (dot[10:0] == 11'd13) begin						// x = H-Blank. suji keta : 1 (SUJI_KETA=3)
				sujiWork10 <= sujiNow / 10'd10;								//
			end else if (dot[10:0] == 11'd14) begin						// x = H-Blank.
				sujiWork10 <= sujiWork10 * 10'd10;							//
			end else if (dot[10:0] == 11'd15) begin						// x = H-Blank.
				sujiDegi[1][3:0] <= sujiNow - sujiWork10;					//
				
			end else if (dot[10:0] == 11'd16) begin						// x = H-Blank.
				sujiNow <= sujiNow / 10'd10;									//
			end else if (dot[10:0] == 11'd17) begin						// x = H-Blank. suji keta : 2 (SUJI_KETA=3)
				sujiWork10 <= sujiNow / 10'd10;								//
			end else if (dot[10:0] == 11'd18) begin						// x = H-Blank.
				sujiWork10 <= sujiWork10 * 10'd10;							//
			end else if (dot[10:0] == 11'd19) begin						// x = H-Blank.
				sujiDegi[0][3:0] <= sujiNow - sujiWork10;					//
				

			end else if (checkGapLine == 1'b0) begin
			
				if (conditionImageX & conditionImageY == 1'b1) begin
					case (sujiDegi[dotX_read[7:5]])
						0 : x_image_moji <= bufferText00[dotYY[3:1]];
						1 : x_image_moji <= bufferText01[dotYY[3:1]];
						2 : x_image_moji <= bufferText02[dotYY[3:1]];
						3 : x_image_moji <= bufferText03[dotYY[3:1]];
						4 : x_image_moji <= bufferText04[dotYY[3:1]];
						5 : x_image_moji <= bufferText05[dotYY[3:1]];
						6 : x_image_moji <= bufferText06[dotYY[3:1]];
						7 : x_image_moji <= bufferText07[dotYY[3:1]];
						8 : x_image_moji <= bufferText08[dotYY[3:1]];
						9 : x_image_moji <= bufferText09[dotYY[3:1]];
						default : x_image_moji <= bufferText00[dotYY[3:1]];
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
