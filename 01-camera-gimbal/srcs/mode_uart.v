`timescale 1ns/1ps
// 115200 8N1, full duplex. All protocol logic runs in the 25 MHz pixel domain.
module mode_uart #(parameter integer DIV=217)(
 input wire clk, input wire rx, output wire tx,
 output reg [7:0] rx_data=0, output reg rx_valid=0,
 input wire [7:0] tx_data, input wire tx_start, output wire tx_busy);
 (* ASYNC_REG="TRUE" *) reg r1=1,r2=1;
 reg [15:0] rc=0,tc=0;
 reg [3:0] rb=0,tb=0;
 reg [7:0] rd=0;
 reg receiving=0;
 reg [9:0] shift=10'h3ff;
 assign tx_busy=tb!=0;
 assign tx=tb!=0 ? shift[0] : 1'b1;
 always @(posedge clk) begin
   r1<=rx; r2<=r1; rx_valid<=0;
   if (!receiving) begin
     if (!r2) begin receiving<=1;rc<=DIV/2;rb<=0;end
   end else if(rc!=0) rc<=rc-1'b1;
   else begin
     rc<=DIV-1;
     if(rb==0) begin
       if(r2) receiving<=0; else rb<=1;
     end else if(rb<=8) begin rd[rb-1]<=r2; rb<=rb+1'b1;end
     else begin
       receiving<=0;
       if(r2) begin rx_data<=rd;rx_valid<=1;end
     end
   end
   if(tb==0) begin
     if(tx_start) begin shift<={1'b1,tx_data,1'b0};tb<=10;tc<=DIV-1;end
   end else if(tc!=0) tc<=tc-1'b1;
   else begin shift<={1'b1,shift[9:1]};tb<=tb-1'b1;tc<=DIV-1;end
 end
endmodule
