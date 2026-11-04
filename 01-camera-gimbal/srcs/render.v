`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:51:55 01/15/2014 
// Design Name: 
// Module Name:    render 
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
module render(
    input               PClk,
    input               yellow_enable,
    input [23:0]        RGB24,
    input               Binary_in,
    input [11:0]        VtcHCnt,
    input [10:0]        VtcVCnt,
    input [11:0]        center_h,  	// 0-319 from BW
    input [10:0]        center_v,		// 0-239 from BW
    output reg [23:0]   RGB_render
    );
	 
reg [23:0]      RGB_render_temp;

always@(posedge PClk) begin
    if(Binary_in==1) begin//labeled by green 
        RGB_render_temp[23:16]  <= 0;
        RGB_render_temp[15:8]	<= 255;
        RGB_render_temp[7:0] 	<= 0;
    end
    else begin
        RGB_render_temp[23:16]  <= RGB24[23:16];
        RGB_render_temp[15:8]	<= RGB24[15:8];
        RGB_render_temp[7:0] 	<= RGB24[7:0];
    end
    
    if (yellow_enable && ((160-16==VtcHCnt||160+16==VtcHCnt) && VtcVCnt>=120-16&&VtcVCnt<=120+16 //show a yellow rectangle
    ||(120-16==VtcVCnt||120+16==VtcVCnt) && VtcHCnt>=160-16&&VtcHCnt<=160+16))begin
        RGB_render <= 24'b11111111_11111111_00000000;
    end
    // S1 disables yellow: draw a compact fixed aim cross, preserving S0's full cross.
    else if ((center_h==VtcHCnt && (yellow_enable ||
              (VtcVCnt+11'd4>=center_v && VtcVCnt<=center_v+11'd4))) ||
             (center_v==VtcVCnt && (yellow_enable ||
              (VtcHCnt+12'd4>=center_h && VtcHCnt<=center_h+12'd4))))
        RGB_render <= 24'b11111111_00000000_00000000;
    else
        RGB_render <= RGB_render_temp;

end


endmodule
