`timescale 1ns/1ps
module sine_rom(
 input wire clk, input wire [11:0] address_a,address_b,
 output reg signed [17:0] value_a,value_b
);
 (* rom_style="block" *) reg signed [17:0] values[0:4095];
 integer i;
 initial begin
   for(i=0;i<4096;i=i+1) values[i]=0;
   $readmemh("sin_q16.mem",values,0,3599);
 end
 always @(posedge clk) value_a<=values[address_a];
 always @(posedge clk) value_b<=values[address_b];
endmodule
