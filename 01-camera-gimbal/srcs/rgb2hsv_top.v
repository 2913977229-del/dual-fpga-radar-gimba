`timescale 1ns / 1ps

module rgb2hsv_top(
input pclk,
input [23:0]RGB24,
output[23:0]HSV24
    );
reg [7:0]max,min;

//input rgb
wire [7:0] Red,Green,Blue;
reg [7:0]R_reg,G_reg,B_reg;
assign Red = RGB24[23:16];
assign Green = RGB24[15:8];
assign Blue = RGB24[7:0];


reg [7:0] Hue,Saturation,Value;
assign HSV24[23:16] = Hue;
assign HSV24[15:8] = Saturation;
assign HSV24[7:0] = Value;


always@(posedge pclk)begin 
R_reg <= Red;
G_reg <= Green; 
B_reg <= Blue;
end
/*************find max,min***********/
always@(posedge pclk)begin
 if(Red >= Green)
   begin
	 if(Red >= Blue)
	 max <= Red;
	 else //r<b
	 max <= Blue;
	end
 else //r<g
   begin 
    if(Green >= Blue)
	 max <= Green;
	 else //g<b
	 max <= Blue;
	end	
end

always@(posedge pclk)begin
 if(Red <= Green)
   begin
	 if(Red <= Blue)
	 min <= Red;
	 else //r<b
	 min <= Blue;
	end
 else //r>g
   begin 
    if(Green <= Blue)
	 min <= Green;
	 else //g>b
	 min <= Blue;
	end	
end

reg [14:0] h_dividend;
reg [7:0]  h_divisor;
wire [14:0] h_quotient;
reg [8:0]  h_add;
reg [16:0]  s_dividend;
reg [7:0]  s_divisor;
wire [16:0]  s_quotient;
reg [7:0]  v;
reg sign_flag;
always@(posedge pclk)begin
 if(max == min)
  begin
   sign_flag <= 0;
   h_dividend <= 0;
   h_divisor <= 1;//
   h_add <= 0;
   s_dividend <= 0;
   s_divisor <= 1;
	v <= max;
  end
 else if(max == R_reg && G_reg >= B_reg)
  begin
   sign_flag <= 0;
   h_dividend <= 60 * (G_reg - B_reg);
	h_divisor <= max - min;
	h_add <= 0;
	s_dividend <= 255 * (max - min);
	s_divisor <= max; 
	v <= max;
  end
 else if(max == R_reg && G_reg < B_reg )
  begin
   sign_flag <= 1;
   h_dividend <= 60 * (B_reg - G_reg);
	h_divisor <= max - min;
	h_add <= 360;
	s_dividend <= 255 * (max - min);
	s_divisor <= max;
	v <= max;
  end 
 else if(max == G_reg)
  begin
   if(B_reg >= R_reg)
	begin
	sign_flag <= 0;
	h_dividend <= 60 * (B_reg - R_reg);
	end
	else
	begin 
	sign_flag <= 1;
   h_dividend <= 60 * (R_reg - B_reg);
	end
	
	h_divisor <= max - min;
	h_add <= 120;
	s_dividend <= 255 * (max - min) ;
	s_divisor <= max;
	v <= max;
  end
  else if(max == B_reg)
  begin
   if(R_reg >= G_reg)
	begin
	sign_flag <= 0;
	h_dividend <= 60 * (R_reg - G_reg);
	end
	else
	begin 
	sign_flag <= 1;
   h_dividend <= 60 * (G_reg - R_reg);
	end
	
	h_divisor <= max - min;
	h_add <= 240;
	s_dividend <= 255 * (max - min);
	s_divisor <= max;
	v <= max;
  end
end
wire [31:0]yshang_h,yshang_s;
wire [31:0] a;
assign a = {17'b0,h_dividend};
wire [31:0] b;
assign b = {24'b0,h_divisor};
assign yshang_h = a/b;


assign h_quotient = yshang_h[14:0];
//div_rill u_div_s (
//    .a({15'b0,s_dividend}),  
//    .b({24'b0,s_divisor}), 
//    .yshang(yshang_s), 
//    .yyushu()
//);	
wire [31:0] c;
assign c = {17'b0,s_dividend};
wire [31:0] d;
assign d = {24'b0,s_divisor};
assign yshang_s = c/d;

assign s_quotient = yshang_s[16:0];

always@(posedge pclk)begin
    if(sign_flag == 0)
        Hue <= (h_quotient + h_add)/2;
    else
        Hue <= (h_add - h_quotient)/2;
        Saturation <= s_quotient;
        Value <= v;
end

endmodule


//module rgb2hsv_top(
//    input              pclk,
//    input       [23:0] RGB24,
//    output      [23:0] HSV24
//);

//    // =========================================================================
//    // 1. 输入数据分离与第一级锁存 (Pipeline 1)
//    // =========================================================================
//    wire [7:0] Red   = RGB24[23:16];
//    wire [7:0] Green = RGB24[15:8];
//    wire [7:0] Blue  = RGB24[7:0];

//    reg [7:0] R_reg, G_reg, B_reg;
//    reg [7:0] max, min;

//    always @(posedge pclk) begin
//        R_reg <= Red;
//        G_reg <= Green;
//        B_reg <= Blue;
        
//        // 找最大值
//        if (Red >= Green && Red >= Blue)     max <= Red;
//        else if (Green >= Red && Green >= Blue) max <= Green;
//        else                                 max <= Blue;

//        // 找最小值
//        if (Red <= Green && Red <= Blue)     min <= Red;
//        else if (Green <= Red && Green <= Blue) min <= Green;
//        else                                 min <= Blue;
//    end

//    // =========================================================================
//    // 2. 分子分母计算与条件分支锁存 (Pipeline 2)
//    // =========================================================================
//    reg [14:0] h_dividend;
//    reg [7:0]  h_divisor;
//    reg [16:0] s_dividend;
//    reg [7:0]  s_divisor;
    
//    // 需要随除法器同步延迟的信号
//    reg [8:0]  h_add_d1;
//    reg        sign_flag_d1;
//    reg [7:0]  v_d1;

//    always @(posedge pclk) begin
//        v_d1 <= max; // Value 信号直接锁存
        
//        if (max == min) begin
//            sign_flag_d1 <= 1'b0;
//            h_dividend   <= 15'd0;
//            h_divisor    <= 8'd1;     // 防止除以 0
//            h_add_d1     <= 9'd0;
//            s_dividend   <= 17'd0;
//            s_divisor    <= 8'd1;     // 防止除以 0
//        end
//        else if (max == R_reg) begin
//            s_dividend   <= 255 * (max - min);
//            s_divisor    <= max;
//            h_divisor    <= max - min;
//            if (G_reg >= B_reg) begin
//                sign_flag_d1 <= 1'b0;
//                h_dividend   <= 60 * (G_reg - B_reg);
//                h_add_d1     <= 9'd0;
//            end else begin
//                sign_flag_d1 <= 1'b1;
//                h_dividend   <= 60 * (B_reg - G_reg);
//                h_add_d1     <= 9'd360;
//            end
//        end
//        else if (max == G_reg) begin
//            s_dividend   <= 255 * (max - min);
//            s_divisor    <= max;
//            h_divisor    <= max - min;
//            h_add_d1     <= 9'd120;
//            if (B_reg >= R_reg) begin
//                sign_flag_d1 <= 1'b0;
//                h_dividend   <= 60 * (B_reg - R_reg);
//            end else begin
//                sign_flag_d1 <= 1'b1;
//                h_dividend   <= 60 * (R_reg - B_reg);
//            end
//        end
//        else begin // max == B_reg
//            s_dividend   <= 255 * (max - min);
//            s_divisor    <= max;
//            h_divisor    <= max - min;
//            h_add_d1     <= 9'd240;
//            if (R_reg >= G_reg) begin
//                sign_flag_d1 <= 1'b0;
//                h_dividend   <= 60 * (R_reg - G_reg);
//            end else begin
//                sign_flag_d1 <= 1'b1;
//                h_dividend   <= 60 * (G_reg - R_reg);
//            end
//        end
//    end

//    // =========================================================================
//    // 3. 伴随信号同步打拍控制（关键：消除花屏缺陷）
//    //    由于除法器需要 4 个时钟周期，这里的控制信号也必须精确延后 4 拍
//    // =========================================================================
//reg [8:0]  h_add_d2, h_add_d3, h_add_d4, h_add_d5;
//    reg        sign_flag_d2, sign_flag_d3, sign_flag_d4, sign_flag_d5;
//    reg [7:0]  v_d2, v_d3, v_d4, v_d5;

//    always @(posedge pclk) begin
//        // H 角度基准打拍
//        h_add_d2     <= h_add_d1;
//        h_add_d3     <= h_add_d2;
//        h_add_d4     <= h_add_d3;
//        h_add_d5     <= h_add_d4;

//        // 正负号标志位打拍（彻底解决多驱动，且修正了移位链条）
//        sign_flag_d2 <= sign_flag_d1;
//        sign_flag_d3 <= sign_flag_d2;
//        sign_flag_d4 <= sign_flag_d3;
//        sign_flag_d5 <= sign_flag_d4; 

//        // 亮度 V 打拍
//        v_d2         <= v_d1;
//        v_d3         <= v_d2;
//        v_d4         <= v_d3;
//        v_d5         <= v_d4;
//    end


//    // =========================================================================
//    // 4. 高速流水线除法器 IP 替代（解决纯组合逻辑带来的时序违界）
//    //    这里模拟的是 Latency=4 的流水线除法器行为，实际工程中请替换为 FPGA 的 Divider IP
//    // =========================================================================
//    reg [14:0] h_quotient;
//    reg [16:0] s_quotient;
    
//    // 硬件 IP 行为仿真模拟（4级流水线）
//    reg [14:0] h_div_pipe [3:0];
//    reg [16:0] s_div_pipe [3:0];
    
//    always @(posedge pclk) begin
//        h_div_pipe[0] <= h_dividend / h_divisor;
//        h_div_pipe[1] <= h_div_pipe[0];
//        h_div_pipe[2] <= h_div_pipe[1];
//        h_quotient    <= h_div_pipe[2];

//        s_div_pipe[0] <= s_dividend / s_divisor;
//        s_div_pipe[1] <= s_div_pipe[0];
//        s_div_pipe[2] <= s_div_pipe[1];
//        s_quotient    <= s_div_pipe[2];
//    end

//    // =========================================================================
//    // 5. 最后一级：数据对齐输出 (Pipeline 6，修正了 begin-end 缺失语法漏洞)
//    // =========================================================================
//    reg [7:0] Hue, Saturation, Value;

//    always @(posedge pclk) begin
//        if (sign_flag_d5 == 1'b0) begin
//            Hue <= (h_quotient + h_add_d5) / 2;
//        end else begin
//            Hue <= (h_add_d5 - h_quotient) / 2;
//        end
        
//        // 加上 begin-end 确保其受到时钟同步刷新，不受分支错误干扰
//        Saturation <= s_quotient[7:0]; 
//        Value      <= v_d5;
//    end

//    // 组合逻辑输出
//    assign HSV24[23:16] = Hue;
//    assign HSV24[15:8]  = Saturation;
//    assign HSV24[7:0]   = Value;

//endmodule

