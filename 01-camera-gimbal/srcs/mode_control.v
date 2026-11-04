`timescale 1ns/1ps
module mode_control #(
 parameter integer DEBOUNCE=500000, HEARTBEAT=6250000,
 parameter integer TARGET_TIMEOUT=7500000, UART_DIV=217
)(input wire clk, input wire reset, input wire minus, input wire plus,
 input wire uart_rx, output wire uart_tx,
 output reg [1:0] mode=0, output reg [7:0] epoch=0,
 output reg [11:0] target_x=0, output reg [10:0] target_y=0,
 output wire target_valid, output reg [7:0] target_generation=0,
 input wire enter_mode, input wire leave_mode, output reg running=0,
 input wire [17:0] reported_h, reported_v,
 output reg [11:0] s2_h_us=1500, s2_v_us=1500,
 output wire s2_valid);
 reg [1:0] u=0,d=0;
 reg ud=0,dd=0;
 reg [19:0] uc=0,dc=0;
 wire up=(u[1]!=ud && uc==DEBOUNCE-1 && u[1]);
 wire down=(d[1]!=dd && dc==DEBOUNCE-1 && d[1]);
 (* ASYNC_REG="TRUE" *) reg [1:0] m=0,p=0;
 reg md=0,pd=0;
 reg [19:0] mc=0,pc=0;
 wire mp=(m[1]!=md && mc==DEBOUNCE-1 && m[1]);
 wire pp=(p[1]!=pd && pc==DEBOUNCE-1 && p[1]);
 wire [7:0] data;
 wire valid,busy;
 reg [7:0] txdata=0;
 reg start=0;
 mode_uart #(.DIV(UART_DIV)) serial(clk,uart_rx,uart_tx,data,valid,txdata,start,busy);
 reg [7:0] packet[0:10];
 reg [3:0] index=0;
 reg [7:0] checksum=0;
 reg [23:0] gap=0,age=TARGET_TIMEOUT;
 reg tv=0;
 reg [23:0] s2_age=TARGET_TIMEOUT;
 reg s2_command=0, pose_pending=0;
 wire [15:0] pose_h_us=reported_h/100, pose_v_us=reported_v/100;
 wire [15:0] requested_h={packet[6],packet[5]}, requested_v={packet[8],packet[7]};
 assign s2_valid=running && (mode==2 || mode==3) && s2_command && s2_age<TARGET_TIMEOUT;
 assign target_valid=(running && (mode==1 || mode==2) && tv && age<TARGET_TIMEOUT);
 reg [23:0] heartbeat=0;
 reg pending=1;
 reg [7:0] reply_seq=255;
 reg [7:0] report[0:11];
 reg [3:0] out_index=0;
 reg sending=0;
 wire frame_ok=valid && index==11 && checksum==data;
 wire set_mode=frame_ok && packet[2]==2 && packet[4]<4;
 wire query=frame_ok && packet[2]==1;
 wire [1:0] next_mode=mp&&!pp ? mode-2'd1 :
                         pp&&!mp ? mode+2'd1 : packet[4][1:0];
 wire physical=mp||pp||up||down;
 always @(posedge clk) begin
   m<={m[0],minus};p<={p[0],plus};
   u<={u[0],enter_mode};d<={d[0],leave_mode};
   if(u[1]==ud) uc<=0;
   else if(uc==DEBOUNCE-1) begin ud<=u[1];uc<=0;end else uc<=uc+1'b1;
   if(d[1]==dd) dc<=0;
   else if(dc==DEBOUNCE-1) begin dd<=d[1];dc<=0;end else dc<=dc+1'b1;
   if(m[1]==md) mc<=0;
   else if(mc==DEBOUNCE-1) begin md<=m[1];mc<=0;end else mc<=mc+1'b1;
   if(p[1]==pd) pc<=0;
   else if(pc==DEBOUNCE-1) begin pd<=p[1];pc<=0;end else pc<=pc+1'b1;
   start<=0;
   if(age<TARGET_TIMEOUT) age<=age+1'b1;
   if(s2_age<TARGET_TIMEOUT) s2_age<=s2_age+1'b1;
   if(frame_ok && packet[2]==4 && running && (mode==2 || mode==3) && packet[4]==epoch &&
      packet[9]==0 && packet[10]==0 && requested_h>=500 && requested_h<=2500 &&
      requested_v>=1250 && requested_v<=2500) begin
     s2_h_us<=requested_h[11:0];s2_v_us<=requested_v[11:0];
     s2_command<=1;s2_age<=0;tv<=0;age<=TARGET_TIMEOUT;
   end
   if(heartbeat==HEARTBEAT-1) begin heartbeat<=0;pending<=1;end
   else heartbeat<=heartbeat+1'b1;
   if(index!=0) begin
     if(gap==250000-1) begin index<=0;gap<=0;end else gap<=gap+1'b1;
   end
   if(valid) begin
     gap<=0;
     if(index==0) begin
       if(data==8'ha5) begin packet[0]<=data;checksum<=data;index<=1;end
     end else if(index==1 && data!=8'h5a) begin
       index<=data==8'ha5 ? 1 : 0;checksum<=data;
     end else if(index==11) index<=0;
     else begin packet[index]<=data;checksum<=checksum+data;index<=index+1'b1;end
   end
   if(frame_ok && packet[2]==3 && running && (mode==1 || mode==2) && packet[4]==epoch) begin
     if(mode==2) begin s2_command<=0;s2_age<=TARGET_TIMEOUT;end
     target_generation<=target_generation+1'b1;
     tv<=packet[5]==1 && {packet[7],packet[6]}>0 && {packet[7],packet[6]}<320 &&
                       {packet[9],packet[8]}>0 && {packet[9],packet[8]}<240;
     target_x<={packet[7][3:0],packet[6]};
     target_y<={packet[9][2:0],packet[8]};age<=0;
   end
   if(query) begin pending<=1;reply_seq<=packet[3];end
   if(physical || set_mode) begin
     s2_command<=0;s2_age<=TARGET_TIMEOUT;
     pending<=1;reply_seq<=physical ? 8'hff : packet[3];
     if(down) begin
       running<=0;epoch<=epoch+1'b1;tv<=0;age<=TARGET_TIMEOUT;
     end else if(mp != pp) begin
       mode<=next_mode;running<=0;epoch<=epoch+1'b1;tv<=0;age<=TARGET_TIMEOUT;
     end else if(up || (set_mode && !physical)) begin
       if(set_mode && !physical) mode<=packet[4][1:0];
       running<=1;epoch<=epoch+1'b1;tv<=0;age<=TARGET_TIMEOUT;
     end
   end
   if(reset) begin
     s2_command<=0;s2_age<=TARGET_TIMEOUT;
     if(mode!=0) epoch<=epoch+1'b1;
     mode<=0;running<=0;tv<=0;age<=TARGET_TIMEOUT;pending<=1;reply_seq<=255;index<=0;
   end
   if(!sending && pending && !physical && !set_mode && !query && !reset) begin
     report[0]<=8'ha5;report[1]<=8'h5a;report[2]<=8'h81;report[3]<=reply_seq;
     report[4]<={6'b0,mode};report[5]<=epoch;
     report[6]<={7'b0,running};report[7]<=1;report[8]<=0;report[9]<=0;report[10]<=0;
     report[11]<=8'ha5+8'h5a+8'h81+reply_seq+{6'b0,mode}+epoch+{7'b0,running}+8'd1;
     out_index<=0;sending<=1;pending<=0;reply_seq<=255;pose_pending<=1;
   end else if(!sending && pose_pending && !physical && !set_mode && !query && !reset) begin
     report[0]<=8'ha5;report[1]<=8'h5a;report[2]<=8'h82;report[3]<=8'hff;
     report[4]<=epoch;report[5]<=pose_h_us[7:0];report[6]<=pose_h_us[15:8];
     report[7]<=pose_v_us[7:0];report[8]<=pose_v_us[15:8];report[9]<=1;
     report[10]<={5'b0,running,mode};
     report[11]<=8'ha5+8'h5a+8'h82+8'hff+epoch+pose_h_us[7:0]+pose_h_us[15:8]+
                 pose_v_us[7:0]+pose_v_us[15:8]+8'd1+{5'b0,running,mode};
     out_index<=0;sending<=1;pose_pending<=0;
   end else if(sending && !busy && !start) begin
     txdata<=report[out_index];start<=1;
     if(out_index==11) sending<=0;else out_index<=out_index+1'b1;
   end
 end
endmodule
