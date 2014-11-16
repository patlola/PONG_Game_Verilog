`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:13:06 11/06/2013 
// Design Name: 
// Module Name:    pong 
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
module pong(
	input wire clk, reset,
	input wire [1:0] btn,
	output wire hsync , vsync,
	output wire [2:0] rgb
    );
	 
	 // signal declaration
	wire [9:0] pixel_x, pixel_y;
	wire video_on , p_tick;
	reg [2:0] rgb_reg;
	wire [2:0] rgb_next;
	
	// body
	//instantiate vga sync circuit
	vga_sync vsync_unit( .clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(video_on), .p_tick(p_tick), .pixel_x(pixel_x), .pixel_y(pixel_y));
	
	// instantiate graphic generator
	pong_graph_animate pong_graph_an_unit( .clk(clk) , .reset(reset), .btn(btn), .video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_rgb(rgb_next));
	
	//rgb buffer
	always @( posedge clk)
		if(p_tick)
			rgb_reg <= rgb_next;
			
	//output
	assign rgb = rgb_reg;
	

endmodule
