`timescale 1ns/1ps
module motion_detector(input wire clk,rst,new_scan,point_valid,
 input wire [8:0] bin, input wire [15:0] distance,
 output wire ready, output wire failed, output reg changed, moving);
 reg [15:0] bg[0:359], latest[0:359], prior[0:359];
 reg [4:0] observations[0:359];
 reg [15:0] tag[0:359], bg_tag[0:359];
 reg [8:0] clear_index=0;
 reg clearing=1, synchronized=0, started=0;
 reg [5:0] captured_scans=0;
 reg [8:0] reliable_bins=0;
 reg [15:0] scan=0;
 reg pending=0;
 reg [8:0] p_bin;
 reg [15:0] p_distance,p_scan,p_bg,p_latest,p_prior,p_tag,p_bg_tag;
 reg [4:0] p_observations;
 reg p_started,p_capture,p_ready;
 reg q_pending=0, q_changed=0;
 reg [15:0] q_distance,q_prev;
 wire valid_range=p_distance>=200 && p_distance<=5000;
 wire [15:0] prev = p_tag==p_scan ? p_prior :
                          p_tag==p_scan-16'd1 ? p_latest : 16'hffff;
 wire [16:0] diff=q_distance>=q_prev ? q_distance-q_prev : q_prev-q_distance;
 assign ready=started && captured_scans>=20 && !clearing && reliable_bins!=0;
 assign failed=started && captured_scans>=20 && !clearing && reliable_bins==0;
 always @(posedge clk) begin
   if(rst) begin
     clearing<=1; clear_index<=0; synchronized<=0; started<=0; captured_scans<=0;
     scan<=0; reliable_bins<=0; changed<=0; moving<=0; pending<=0; q_pending<=0;
   end else if(clearing) begin
     bg[clear_index]<=16'hffff; latest[clear_index]<=16'hffff;
     prior[clear_index]<=16'hffff; observations[clear_index]<=0;
     tag[clear_index]<=16'hffff; bg_tag[clear_index]<=16'hffff;
     if(clear_index==359) begin clear_index<=0; clearing<=0; end
     else clear_index<=clear_index+1'b1;
   end else begin
     if(new_scan) begin
       scan<=scan+1'b1;
       if(!synchronized) synchronized<=1;
       else if(!started) started<=1;
       else if(captured_scans<20) captured_scans<=captured_scans+1'b1;
     end
     pending<=point_valid;
     q_pending<=pending;
     if(point_valid) begin
       p_bin<=bin; p_distance<=distance; p_scan<=scan;
       p_bg<=bg[bin]; p_latest<=latest[bin]; p_prior<=prior[bin];
       p_tag<=tag[bin]; p_bg_tag<=bg_tag[bin]; p_observations<=observations[bin];
       p_started<=started; p_capture<=captured_scans<20; p_ready<=ready;
     end
     if(pending) begin
       q_changed<=0; q_distance<=p_distance; q_prev<=prev;
       if(valid_range && p_started) begin
         if(p_capture) begin
           if(p_distance<p_bg) bg[p_bin]<=p_distance;
           if(p_bg_tag!=p_scan) begin
             bg_tag[p_bin]<=p_scan;
             if(p_observations==9) reliable_bins<=reliable_bins+1'b1;
             if(p_observations<31) observations[p_bin]<=p_observations+1'b1;
           end
         end else if(p_ready) begin
           if(p_observations>=10 && {1'b0,p_distance}+17'd180 < {1'b0,p_bg}) begin
             q_changed<=1;
           end
         end
         if(p_tag!=p_scan) begin
           prior[p_bin]<=p_tag==p_scan-16'd1 ? p_latest : 16'hffff;
           latest[p_bin]<=p_distance; tag[p_bin]<=p_scan;
         end else if(p_distance<p_latest) latest[p_bin]<=p_distance;
       end
     end
     if(q_pending) begin
       changed<=q_changed;
       moving<=q_changed && q_prev!=16'hffff && diff>=120;
     end
   end
 end
endmodule
