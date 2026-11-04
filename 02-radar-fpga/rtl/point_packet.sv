`timescale 1ns/1ps
module point_packet #(
 parameter integer CLK_HZ=100_000_000, TX_BAUD=921600,
 parameter integer ECHO_SELECT=0, MIN_MM=50, MAX_MM=25000
)(
 input wire clk,rst,frame_valid,
 input wire [15:0] start_angle,end_angle,
 input wire [767:0] echoes,
 output wire tx, output reg [31:0] dropped_frames,
 output wire busy
);
 reg [7:0] packet[0:99];
 reg [383:0] samples;
 reg [15:0] seq=0, scan_id=0, previous_start=0;
 reg have_previous=0;
 wire new_scan=!have_previous || ({1'b0,start_angle}+17'd18000 < {1'b0,previous_start});
 reg [3:0] state=0;
 reg [3:0] point_index=0;
 reg [15:0] delta=0,a0=0;
 reg [19:0] angle_product=0;
 reg [15:0] angle_step=0;
 reg [19:0] div_shift=0;
 reg [3:0] remainder=0;
 reg [4:0] div_bits=0;
 wire [4:0] trial={remainder,div_shift[19]};
 reg [16:0] angle=0;
 reg [11:0] lut_index=0;
 integer crc_index=0, send_index=0, offset=0,k;
 reg [15:0] distance;
 reg [7:0] intensity;
 reg point_ok;
 wire signed [17:0] sx,sy;
 wire [11:0] sin_addr=lut_index==3600 ? 12'd0 : lut_index;
 wire [11:0] cos_addr=lut_index>=2700 ? lut_index-12'd2700 : lut_index+12'd900;
 (* KEEP_HIERARCHY="yes" *) sine_rom lookup(.clk(clk),.address_a(sin_addr),
   .address_b(cos_addr),.value_a(sy),.value_b(sx));
 reg signed [34:0] product_x,product_y;
 wire bg_ready, bg_failed, bg_changed, bg_moving;
 wire [8:0] degree_bin = lut_index>=3600 ? 9'd0 : lut_index/10;
 motion_detector detector(.clk(clk),.rst(rst),.new_scan(frame_valid && new_scan),
   .point_valid(state==3),.bin(degree_bin),.distance(distance),
   .ready(bg_ready),.failed(bg_failed),.changed(bg_changed),.moving(bg_moving));
 reg [15:0] crc=16'hffff;
 wire tx_ready;
 wire tx_valid=(state==9);
 wire [7:0] tx_data=packet[send_index];
 assign busy=(state!=0);
 uart_tx #(.CLK_HZ(CLK_HZ),.BAUD(TX_BAUD)) sender(
   .clk(clk),.rst(rst),.data(tx_data),.valid(tx_valid),.ready(tx_ready),.tx(tx));
 function automatic [15:0] crc_step(input [15:0] c,input [7:0] d);
   reg [15:0] v; integer b;
   begin v=c^{d,8'h00};
     for(b=0;b<8;b=b+1) v=v[15] ? (v<<1)^16'h1021 : v<<1;
     crc_step=v;
   end
 endfunction
 always @(posedge clk) begin
   if(rst) begin
     state<=0; seq<=0; scan_id<=0; previous_start<=0;
     have_previous<=0; dropped_frames<=0;
   end else begin
     if(frame_valid) begin
       seq<=seq+1'b1; previous_start<=start_angle; have_previous<=1;
       if(new_scan) scan_id<=scan_id+1'b1;
       if(busy) dropped_frames<=dropped_frames+1'b1;
     end
     case(state)
       0: if(frame_valid) begin
         for(k=0;k<16;k=k+1)
           samples[k*24 +: 24]<=echoes[(k*6+ECHO_SELECT*3)*8 +: 24];
         a0<=start_angle;
         delta <= end_angle>=start_angle ? end_angle-start_angle : end_angle+36000-start_angle;
         packet[0]<=8'hc3; packet[1]<=8'h3c; packet[2]<=2;
         packet[3]<={6'b0,(ECHO_SELECT!=0),new_scan};
         packet[4]<=seq[7:0]; packet[5]<=seq[15:8];
         packet[6]<=new_scan ? (scan_id+16'd1)&8'hff : scan_id[7:0];
         packet[7]<=new_scan ? (scan_id+16'd1)>>8 : scan_id[15:8];
         packet[8]<=start_angle[7:0]; packet[9]<=start_angle[15:8];
         packet[10]<=end_angle[7:0]; packet[11]<=end_angle[15:8];
         packet[12]<=16; packet[13]<={6'b0,bg_failed,bg_ready};
         packet[94]<=0; packet[95]<=0; packet[96]<=0; packet[97]<=0;
         point_index<=0; state<=1;
       end
       1: begin
         angle_product<=delta*point_index;
         offset=point_index*3;
         distance<={samples[offset*8 +: 8],samples[(offset+1)*8 +: 8]};
         intensity<=samples[(offset+2)*8 +: 8]; state<=11;
       end
       11: begin div_shift<=angle_product; remainder<=0; div_bits<=20; state<=13; end
       13: begin
         remainder<=trial>=15 ? trial-5'd15 : trial;
         div_shift<={div_shift[18:0],trial>=15}; div_bits<=div_bits-1'b1;
         if(div_bits==1) begin
           angle_step<={div_shift[14:0],trial>=15}; state<=12;
         end
       end
       12: begin angle<={1'b0,a0}+{1'b0,angle_step}; state<=2; end
       2: begin
         lut_index<=((angle>=17'd36000 ? angle-17'd36000 : angle)+17'd5)/17'd10;
         point_ok<=distance>=MIN_MM && distance<=MAX_MM && distance!=16'hffff;
         state<=3;
       end
       3: state<=4;
       4: begin
         product_x<=$signed({1'b0,distance})*sx;
         product_y<=$signed({1'b0,distance})*sy;
         state<=14;
       end
       14: state<=5;
       5: begin
         packet[14+point_index*5]<=point_ok ? (product_x>>>16)&8'hff : 0;
         packet[15+point_index*5]<=point_ok ? (product_x>>>24)&8'hff : 8'h80;
         packet[16+point_index*5]<=point_ok ? (product_y>>>16)&8'hff : 0;
         packet[17+point_index*5]<=point_ok ? (product_y>>>24)&8'hff : 8'h80;
         packet[18+point_index*5]<=point_ok ? intensity : 0;
         packet[94+(point_index>>3)][point_index[2:0]]<=(packet[13]==1) && bg_changed;
         packet[96+(point_index>>3)][point_index[2:0]]<=(packet[13]==1) && bg_moving;
         if(point_index==15) begin crc<=16'hffff; crc_index<=2; state<=6; end
         else begin point_index<=point_index+1; state<=1; end
       end
       6: begin
         crc<=crc_step(crc,packet[crc_index]);
         if(crc_index==97) state<=7; else crc_index<=crc_index+1;
       end
       7: begin packet[98]<=crc[7:0]; packet[99]<=crc[15:8]; send_index<=0; state<=9; end
       9: if(tx_ready) begin
         if(send_index==99) state<=10; else send_index<=send_index+1;
       end
       10: if(tx_ready) state<=0;
       default: state<=0;
     endcase
   end
 end
endmodule
