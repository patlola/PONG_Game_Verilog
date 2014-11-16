`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:29:56 11/10/2013 
// Design Name: 
// Module Name:    pong_graph_animate 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pong_graph_animate(
    input wire clk,
    input wire reset,
    input wire video_on,
    input wire [1:0] btn,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,
    output reg [2:0] graph_rgb
    );
// constantandsignaldeclaration
//x,y coordinates (0,0) to (639,479)
	localparam MAX_X = 640;
	localparam MAX_Y = 480;
	wire refr_tick;
	//vertical strip easawall
	//wall left, right boundary
	localparam WALL_X_L = 32 ;
	localparam WALL_X_R = 35 ;
	//right vertical bar
	//
	// bar left,right boundary
	localparam BAR_X_L = 600;
	localparam BAR_X_R = 603;
	// bar to p , bottom boundary
	wire [9:0] bar_y_t , bar_y_b;
	localparam BAR_Y_SIZE = 72 ;
	// register totrack to p boundary ( x position is fixed )
	reg [9:0] bar_y_reg, bar_y_next;
	// bar moving velocity when abutton is pressed
	localparam BAR_V = 4 ;
	// square ball
	localparam BALL_SIZE = 8 ;
	// ball left , right boundary
	wire [9:0] ball_x_l , ball_x_r ;
	// b a l l t o p , bottom boundary
	wire [9: 0] ball_y_t , ball_y_b;
	// reg t o t r a c k l e f t , t o p p o s i t i o n
	reg [9:0] ball_x_reg , ball_y_reg ;
	wire [9:0] ball_x_next , ball_y_next ;
	// reg t o t r a c k b a l l speed
	reg [9:0] x_delta_reg , x_delta_next;
	reg [9:0] y_delta_reg, y_delta_next;
	// b a l l v e l o c i t y can be pos or n e g )
	localparam BALL_V_P = 2 ;
	localparam BALL_V_N = -2 ;
	// round b a l l
	wire [2:0] rom_addr , rom_col ;
	reg [7:0] rom_data;
	wire rom_bit;
	// o b j e c t o u t p u t s i g n a l s

	wire wall_on , bar_on , sq_ball_on , rd_ball_on;
	wire [2:0] wall_rgb , bar_rgb , ball_rgb;

	always @*
	case (rom_addr)
		3'h0: rom_data = 8'b00111100; //   ****
		3'h1: rom_data = 8'b01111110; //  ******
		3'h2: rom_data = 8'b11111111; // ********
		3'h3: rom_data = 8'b11111111; // ********
		3'h4: rom_data = 8'b11111111; // ********
		3'h5: rom_data = 8'b11111111; // ********
		3'h6: rom_data = 8'b01111110; //  ******
		3'h7: rom_data = 8'b00111100; //   ****
	endcase

	always @( posedge clk , posedge reset)
		if(reset)
			begin
				bar_y_reg <= 0;
				ball_x_reg <= 0;
				ball_y_reg <= 0;
				x_delta_reg <= 10'h004;
				y_delta_reg <= 10'h004;
			end
		else
			begin
				bar_y_reg <= bar_y_next;
				ball_x_reg <= ball_x_next;
				ball_y_reg <= ball_y_next;
				x_delta_reg <= x_delta_next;
				y_delta_reg <= y_delta_next;
			end

	assign refr_tick = (pix_y == 481) && (pix_x == 0);

	assign wall_on = (WALL_X_L <= pix_x) && ( pix_x <=WALL_X_R);

	assign wall_rgb = 3'b001; // blue

	assign bar_y_t = bar_y_reg;
	assign bar_y_b = bar_y_t + BAR_Y_SIZE - 1 ;
	// pixel with in bar
	assign bar_on = (BAR_X_L <= pix_x) && (pix_x<=BAR_X_R) && ( bar_y_t<=pix_y)&&(pix_y <= bar_y_b);
	// bar rgb output
	assign bar_rgb=3'b010; // green

	always @*
	begin
		bar_y_next = bar_y_reg; // no move
		if (refr_tick)
			if(btn[1] & (bar_y_b < (MAX_Y - 1 - BAR_V)))
				bar_y_next = bar_y_reg + BAR_V; // move down
			else if (btn[0] & (bar_y_t > BAR_V))
				bar_y_next = bar_y_reg - BAR_V;// move up
	end
	assign ball_x_l = ball_x_reg;
	assign ball_y_t = ball_y_reg;
	assign ball_x_r = ball_x_l + BALL_SIZE - 1 ;
	assign ball_y_b = ball_y_t + BALL_SIZE - 1 ;

	assign sq_ball_on =(ball_x_l <= pix_x) && (pix_x <= ball_x_r) && (ball_y_t <= pix_y) && (pix_y <= ball_y_b);
						

	assign rom_addr = pix_y [2:0] - ball_y_t [2:0] ;
	assign rom_col = pix_x [2:0] - ball_x_l [2:0] ;
	assign rom_bit = rom_data[rom_col] ;

	assign rd_ball_on = sq_ball_on & rom_bit;

	assign ball_rgb = 3'b100;

	assign ball_x_next = (refr_tick) ? ball_x_reg + x_delta_reg : ball_x_reg;
	assign ball_y_next = (refr_tick) ? ball_y_reg + y_delta_reg : ball_y_reg;

	always @*
	begin
		x_delta_next = x_delta_reg;
		y_delta_next = y_delta_reg;
		if(ball_y_t < 1) // reach top
			y_delta_next = BALL_V_P;
		else if ( ball_y_b > (MAX_Y - 1)) // reach bottom
			y_delta_next = BALL_V_N;
		else if (ball_x_l <= WALL_X_R) // reach wall
			x_delta_next = BALL_V_P; // bounce back
		else if ((BAR_X_L <=ball_x_r ) && (ball_x_r <=BAR_X_R) &&
			(bar_y_t <= ball_y_b) && (ball_y_t <=bar_y_b))
		// reach x of right bar and hit , ball bounce back
			x_delta_next = BALL_V_N;
	end

	always @*
		if(~video_on)
			graph_rgb = 3'b000; // blank
		else
			if (wall_on)
				graph_rgb = wall_rgb ;
			else if (bar_on)
				graph_rgb = bar_rgb;
			else if (rd_ball_on)
				graph_rgb = ball_rgb;
			else
				graph_rgb = 3'b110;
endmodule
