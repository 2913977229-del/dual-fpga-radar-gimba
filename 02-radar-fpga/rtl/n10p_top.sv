`timescale 1ns/1ps
module n10p_top(
 input wire clk,btnC,lidar_rx,
 output wire pi_tx, output wire [3:0] led
);
 (* ASYNC_REG="TRUE" *) reg [1:0] reset_sync=2'b11;
 always @(posedge clk) reset_sync<={reset_sync[0],btnC};
 wire rst=reset_sync[1];
 wire [7:0] data;
 wire valid,error,frame_valid,busy;
 wire [15:0] a0,a1;
 wire [767:0] echoes;
 wire [31:0] good,bad,dropped;
 reg [26:0] heartbeat=0;
 always @(posedge clk) if(rst) heartbeat<=0; else heartbeat<=heartbeat+1'b1;
 uart_rx #(.BAUD(921600)) rx(.clk(clk),.rst(rst),.rx(lidar_rx),.data(data),.valid(valid),.framing_error(error));
 n10p_parser parser(.clk(clk),.rst(rst),.data(data),.valid(valid),.framing_error(error),
   .frame_valid(frame_valid),.start_angle(a0),.end_angle(a1),.echoes(echoes),
   .good_frames(good),.bad_frames(bad));
 point_packet converter(.clk(clk),.rst(rst),.frame_valid(frame_valid),
   .start_angle(a0),.end_angle(a1),.echoes(echoes),.tx(pi_tx),.dropped_frames(dropped),.busy(busy));
 assign led={dropped!=0,bad!=0,good!=0,heartbeat[26]};
endmodule
