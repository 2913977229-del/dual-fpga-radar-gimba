`timescale 1ns/1ps
// Active-low segments {g,f,e,d,c,b,a}; upright Basys3, S left of digit.
module mode_display(input wire clk,input wire [1:0] mode,
 input wire running,
 output reg [6:0] seg,output reg [3:0] an,output wire dp);
 reg [15:0] scan=0;
 reg [6:0] glyph;
 assign dp=1;
 always @(posedge clk) scan<=scan+1'b1;
 always @* begin
   an=4'b1111;glyph=7'b1111111;
   if(scan[15:14]==0) begin an=4'b0111;glyph=7'b0010010;end
   else if(scan[15:14]==1) begin
     an=4'b1011;
     case(mode)
       0:glyph=7'b1000000;
       1:glyph=7'b1111001;
       2:glyph=7'b0100100;
       3:glyph=7'b0110000;
     endcase
   end else if(scan[15:14]==3) begin
     an=4'b1110;glyph=running ? 7'b1111001 : 7'b1000000;
   end
   seg=glyph;
 end
endmodule
