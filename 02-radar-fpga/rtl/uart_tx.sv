`timescale 1ns/1ps
module uart_tx #(parameter integer CLK_HZ=100_000_000, BAUD=921600)(
 input wire clk,rst, input wire [7:0] data, input wire valid,
 output wire ready, output wire tx
);
 localparam integer DIV=(CLK_HZ+BAUD/2)/BAUD;
 reg [9:0] shift=10'h3ff;
 reg [3:0] bits_left=0;
 integer timer=0;
 assign ready=(bits_left==0);
 assign tx=shift[0];
 always @(posedge clk) begin
   if(rst) begin shift<=10'h3ff; bits_left<=0; timer<=0; end
   else if(ready) begin
     if(valid) begin shift<={1'b1,data,1'b0}; bits_left<=10; timer<=DIV-1; end
   end else if(timer!=0) timer<=timer-1;
   else begin
     shift<={1'b1,shift[9:1]}; timer<=DIV-1; bits_left<=bits_left-1'b1;
   end
 end
endmodule
