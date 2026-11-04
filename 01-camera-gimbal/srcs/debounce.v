`timescale 1ns / 1ps


//module debounce(
//input clk,clr,
//input i,
//output  o
//);
//reg[3:0] delay1;
//reg[3:0] delay2;
//reg[3:0] delay3;
//reg cclk;
//reg[5:0] cnt;
//always@(posedge clk )begin
//    if(cnt >=19)begin
//        cnt <= 0;
//        cclk <= ~cclk;
//    end
//    else
//        cnt <= cnt+1;
//end

//always@(posedge cclk or posedge clr)
// begin
//  if(clr==1)
//   begin
//	 delay1<=4'b0000;
//	 delay2<=4'b0000;
//	 delay3<=4'b0000;

//   end
//  else
//   begin
//	 delay1<=i;
//	 delay2<=delay1;
//	 delay3<=delay2;

//	end
//end
//assign o=delay1&delay2&delay3;

//endmodule


module debounce(
    input  wire clk,      // 系统时钟
    input  wire clr,    // 异步低电平复位
    input  wire i,        // 按键输入
    output wire o         // 消抖后输出
);

    reg [5:0] cnt;
    reg       sample_en;  // 采样使能信号

    // 1. 产生采样使能信号（代替分频时钟，不破坏时钟树）
    always @(posedge clk or negedge clr) begin
        if (!clr) begin
            cnt       <= 6'd0;
            sample_en <= 1'b0;
        end else if (cnt >= 6'd39) begin // 满40个周期产生一个单脉冲使能
            cnt       <= 6'd0;
            sample_en <= 1'b1;
        end else begin
            cnt       <= cnt + 1'b1;
            sample_en <= 1'b0;
        end
    end

    // 2. 三级移位寄存器（改为 1 位宽）
    reg d1, d2, d3;
    always @(posedge clk or negedge clr) begin
        if (!clr) begin
            d1 <= 1'b0;
            d2 <= 1'b0;
            d3 <= 1'b0;
        end else if (sample_en) begin // 仅在采样使能有效时移位
            d1 <= i;
            d2 <= d1;
            d3 <= d2;
        end
    end

    // 3. 输出逻辑
    assign o = d1 & d2 & d3;

endmodule

