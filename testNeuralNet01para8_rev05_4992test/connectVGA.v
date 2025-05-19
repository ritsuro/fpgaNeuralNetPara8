module connectVGA (
	input					CLOCK_50,
	input	[2:0]			r_val,
	input	[2:0]			g_val,
	input	[2:0]			b_val,
	output [19:0]		dot_out,
	output [19:0]		y_count_out,
	output [2:0]		VGA_R,
	output [2:0]		VGA_G,
	output [2:0]		VGA_B,
	output				VGA_V_SYNC,
	output				VGA_H_SYNC
);

// GPIO VGA.
reg [19:0]	dot = 0;
reg [19:0]	y_count = 20'd45;
wire			dot_clear;

wire			v_area;

wire [2:0]	r_area;
wire [2:0]	g_area;
wire [2:0]	b_area;

reg [19:0]	h,v;
reg [19:0]	h_count,v_count;
wire			h_sync,h_on;
wire			v_sync,v_on;

always @(posedge CLOCK_50)
begin
	//-------------------------------------------------------------
	// VGA logic.
	//-------------------------------------------------------------
	if (dot_clear == 1'b1) begin
		dot <= 0;
	end else begin
		dot <= dot + 20'd1;
	end

	if (h_sync == 1'b1) begin
		y_count <= y_count + 20'd1;
		h_count <= 20'd96;
		h <= 0;
	end else begin
		h <= h + 20'd1;

		if (h_on == 1'b1) begin
			h_count <= h_count - 20'd1;
		end

		if (v_sync == 1'b1) begin
			y_count <= 20'd0;
			v_count <= 20'd3200;
			v <= 20'd0;
		end else begin
			if (v_on == 1'b1) begin
				v_count <= v_count - 20'd1;
			end
		end
	end
end

//-------------------------------------------------------------
//	VGA assign.
//-------------------------------------------------------------
assign v_sync  = (y_count >= 20'd525) ? 1'b1 : 1'b0;
assign v_on    = (v_count >= 20'd1) ? 1'b1 : 1'b0;
assign VGA_V_SYNC = !v_on;

assign h_sync  = (h >= 20'd1600) ? 1'b1 : 1'b0;
assign h_on    = (h_count >= 20'd1) ? 1'b1 : 1'b0;
assign VGA_H_SYNC = !h_on;

assign v_area	= (y_count >= 20'd45 && y_count < 20'd45 + 20'd480) ? 1'b1 : 1'b0;

assign r_area[2:0]  = (r_val[2:0] != 3'b000) ? ((v_area) ? r_val[2:0] : 3'b000) : 3'b000;
assign g_area[2:0]  = (g_val[2:0] != 3'b000) ? ((v_area) ? g_val[2:0] : 3'b000) : 3'b000;
assign b_area[2:0]  = (b_val[2:0] != 3'b000) ? ((v_area) ? b_val[2:0] : 3'b000) : 3'b000;

assign dot_clear = (dot >= 20'd1600) ? 1'b1 : 1'b0;

assign VGA_R[2:0] = (dot >=  20'd320 && dot < 20'd320+20'd1280) ? r_area[2:0] : 3'b000;
assign VGA_G[2:0] = (dot >=  20'd320 && dot < 20'd320+20'd1280) ? g_area[2:0] : 3'b000;
assign VGA_B[2:0] = (dot >=  20'd320 && dot < 20'd320+20'd1280) ? b_area[2:0] : 3'b000;

assign dot_out = dot;
assign y_count_out = y_count;

endmodule
