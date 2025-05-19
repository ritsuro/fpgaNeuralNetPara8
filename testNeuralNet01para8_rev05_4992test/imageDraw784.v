module imageDraw784(
	input						CLOCK_50,
	input						RST_N,
	input			[19:0]	dot,
	input 		[19:0]	y_count_in,

	input			[19:0]	OFFSET_BASE_X,
	input			[19:0]	OFFSET_BASE_Y,
	
	output reg	[9:0]		image_address_byte = 10'd0,
	input			[7:0]		image_data_byte,
	
	output reg	[9:0]		image_address_byte_01 = 10'd0,
	input			[7:0]		image_data_byte_01,
	
	output reg	[9:0]		image_address_byte_02 = 10'd0,
	input			[7:0]		image_data_byte_02,
	
//	output reg	[9:0]		image_address_byte_03 = 10'd0,
//	input			[7:0]		image_data_byte_03,
	
	output reg 	[2:0]		r_val,
	output reg 	[2:0]		g_val,
	output reg 	[2:0]		b_val,
	output 		[0:0]		flagOK
);

parameter	IMAGE_WIDTH  = 56*2;
parameter	IMAGE_HEIGHT = 56;

parameter	OFFSET_Y_0 = 0;
parameter	OFFSET_Y_1 = 108;
parameter	OFFSET_Y_2 = 108*2;
parameter	OFFSET_Y_3 = 108*3;

wire	[10:0]	dotX;
wire	[10:0]	dotX_read;
assign			dotX[10:0] = dot[10:0] - 11'd320;
assign			dotX_read[10:0] = dotX[10:0] + 11'd1;

wire	[19:0]	y_count_45;
assign			y_count_45[19:0] = y_count_in[19:0] - 20'd45;

assign			conditionImageX = (dotX >= OFFSET_BASE_X && dotX < OFFSET_BASE_X + IMAGE_WIDTH);

assign			conditionImageY_0 = (y_count_45 >= OFFSET_BASE_Y + OFFSET_Y_0 && y_count_45 < OFFSET_BASE_Y + OFFSET_Y_0 + IMAGE_HEIGHT);
assign			conditionImageY_1 = (y_count_45 >= OFFSET_BASE_Y + OFFSET_Y_1 && y_count_45 < OFFSET_BASE_Y + OFFSET_Y_1 + IMAGE_HEIGHT);
assign			conditionImageY_2 = (y_count_45 >= OFFSET_BASE_Y + OFFSET_Y_2 && y_count_45 < OFFSET_BASE_Y + OFFSET_Y_2 + IMAGE_HEIGHT);
//assign			conditionImageY_3 = (y_count_45 >= OFFSET_BASE_Y + OFFSET_Y_3 && y_count_45 < OFFSET_BASE_Y + OFFSET_Y_3 + IMAGE_HEIGHT);

assign			conditionImageY = (conditionImageY_0|conditionImageY_1|conditionImageY_2);//|conditionImageY_3);

assign			conditionImageX_read = (dotX_read >= OFFSET_BASE_X && dotX_read < OFFSET_BASE_X + IMAGE_WIDTH);

always @(posedge CLOCK_50, negedge RST_N)
begin
	if (RST_N == 1'b0) begin
	end else begin
		if (conditionImageX_read) begin
			if (conditionImageY_0) begin
				image_address_byte <= ((dotX_read - OFFSET_BASE_X)>>2) + (((y_count_45 - OFFSET_BASE_Y - OFFSET_Y_0)>>1) * 28);
			end else if (conditionImageY_1) begin
				image_address_byte_01 <= ((dotX_read - OFFSET_BASE_X)>>2) + (((y_count_45 - OFFSET_BASE_Y - OFFSET_Y_1)>>1) * 28);
			end else if (conditionImageY_2) begin
				image_address_byte_02 <= ((dotX_read - OFFSET_BASE_X)>>2) + (((y_count_45 - OFFSET_BASE_Y - OFFSET_Y_2)>>1) * 28);
//			end else if (conditionImageY_3) begin
//				image_address_byte_03 <= ((dotX_read - OFFSET_BASE_X)>>2) + (((y_count_45 - OFFSET_BASE_Y - OFFSET_Y_3)>>1) * 28);
			end
		end
		
		if (conditionImageX & conditionImageY) begin
			if (conditionImageY_0) begin
				r_val[2:0] <= image_data_byte[7:5];
				g_val[2:0] <= image_data_byte[7:5];
				b_val[2:0] <= image_data_byte[7:5];
			end else if (conditionImageY_1) begin
				r_val[2:0] <= image_data_byte_01[7:5];
				g_val[2:0] <= image_data_byte_01[7:5];
				b_val[2:0] <= image_data_byte_01[7:5];
			end else if (conditionImageY_2) begin
			
//				r_val[2:0] <= image_data_byte_02[7:5];
//				g_val[2:0] <= image_data_byte_02[7:5];
//				b_val[2:0] <= image_data_byte_02[7:5];

				r_val[2:0] <= 3'b001; //image_data_byte_02[7:5];
				g_val[2:0] <= 3'b011; //image_data_byte_02[7:5];
				b_val[2:0] <= 3'b001; //image_data_byte_02[7:5];
				
//			end else if (conditionImageY_3) begin
//				r_val[2:0] <= image_data_byte_03[7:5];
//				g_val[2:0] <= image_data_byte_03[7:5];
//				b_val[2:0] <= image_data_byte_03[7:5];
			end
		end
	end
end

assign	flagOK = (conditionImageX & conditionImageY);

endmodule
