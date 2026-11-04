`timescale 1ns/1ps
module n10p_parser #(parameter integer CLK_HZ=100_000_000, BAUD=460800)(
 input wire clk,rst, input wire [7:0] data,
 input wire valid,framing_error,
 output reg frame_valid, output reg [15:0] start_angle,end_angle,
 output reg [767:0] echoes,
 output reg [31:0] good_frames,bad_frames
);
 localparam integer TIMEOUT=CLK_HZ/20;
 reg [7:0] frame[0:106];
 reg [7:0] sum=0;
 integer pos=0, idle_count=0;
 integer k;
 always @(posedge clk) begin
   frame_valid<=0;
   if(rst) begin pos<=0; idle_count<=0; sum<=0; good_frames<=0; bad_frames<=0; end
   else if(framing_error || (pos!=0 && idle_count>=TIMEOUT)) begin
     pos<=0; idle_count<=0; bad_frames<=bad_frames+1'b1;
   end else if(valid) begin
     idle_count<=0;
     case(pos)
       0: if(data==8'ha5) begin frame[0]<=data; sum<=data; pos<=1; end
       1: if(data==8'h5a) begin frame[1]<=data; sum<=sum+data; pos<=2; end
          else if(data==8'ha5) begin sum<=data; pos<=1; end
          else pos<=0;
       2: if(data==108) begin frame[2]<=data; sum<=sum+data; pos<=3; end
          else begin
            bad_frames<=bad_frames+1'b1;
            if(data==8'ha5) begin sum<=data; pos<=1; end else pos<=0;
          end
       107: begin
         pos<=0;
         if(data==sum && {frame[5],frame[6]}<36000 &&
            {frame[105],frame[106]}<36000) begin
           start_angle<={frame[5],frame[6]}; end_angle<={frame[105],frame[106]};
           for(k=0;k<96;k=k+1) echoes[k*8 +: 8]<=frame[k+7];
           frame_valid<=1; good_frames<=good_frames+1'b1;
         end else bad_frames<=bad_frames+1'b1;
       end
       default: begin frame[pos]<=data; sum<=sum+data; pos<=pos+1; end
     endcase
   end else if(pos!=0) idle_count<=idle_count+1;
 end
endmodule
