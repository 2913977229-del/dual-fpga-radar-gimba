`timescale 1ns/1ps
module uart_rx #(parameter integer CLK_HZ=100_000_000, BAUD=460800)(
 input wire clk, rst, rx, output reg [7:0] data,
 output reg valid, framing_error
);
 localparam integer DIV=(CLK_HZ+BAUD/2)/BAUD;
 (* ASYNC_REG="TRUE" *) reg [1:0] sync_rx=2'b11;
 reg [1:0] state=0;
 integer timer=0;
 reg [2:0] bit_index=0;
 reg [7:0] shift=0;
 always @(posedge clk) begin
   sync_rx <= {sync_rx[0],rx};
   valid<=0; framing_error<=0;
   if(rst) begin state<=0; timer<=0; sync_rx<=3; end
   else case(state)
     0: if(!sync_rx[1]) begin timer<=DIV/2-1; state<=1; end
     1: if(timer!=0) timer<=timer-1;
        else if(sync_rx[1]) state<=0;
        else begin timer<=DIV-1; bit_index<=0; state<=2; end
     2: if(timer!=0) timer<=timer-1;
        else begin
          shift[bit_index]<=sync_rx[1]; timer<=DIV-1;
          if(bit_index==7) state<=3; else bit_index<=bit_index+1'b1;
        end
     3: if(timer!=0) timer<=timer-1;
        else begin
          state<=0;
          if(sync_rx[1]) begin data<=shift; valid<=1; end
          else framing_error<=1;
        end
   endcase
 end
endmodule
