`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/15 10:37:22
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top
   (OV7725_D,
    OV7725_HREF,
    OV7725_PCLK,
    OV7725_SIOC,
    OV7725_SIOD,
    OV7725_VSYNC,
    OV7725_XCLK,
    btn_ColorExrtract,
    clk100,
    btn_mode_minus, btn_mode_plus, btn_mode_enter, mode_rx, mode_tx, seg, an, dp,
    counter_v,
    pwm_h,
    pwm_v,
    rst,
    sw_ColorClear,
    vga_blue,
    vga_green,
    vga_hsync,
    vga_red,
    vga_vsync);
  input [7:0]OV7725_D;
  input OV7725_HREF;
  input OV7725_PCLK;
  output OV7725_SIOC;
  inout OV7725_SIOD;
  input OV7725_VSYNC;
  output OV7725_XCLK;
  input btn_ColorExrtract;
  input clk100;
  input btn_mode_minus, btn_mode_plus, btn_mode_enter, mode_rx;
  output mode_tx, dp;
  output [6:0] seg;
  output [3:0] an;
  output [10:0]counter_v;
  output pwm_h;
  output pwm_v;
  input rst;
  input sw_ColorClear;
  output [3:0]vga_blue;
  output [3:0]vga_green;
  output vga_hsync;
  output [3:0]vga_red;
  output vga_vsync;

  wire IICctrl_0_I2C_SCLK;
  wire [7:0]IICctrl_0_LUT_INDEX;
  wire Net;
  wire [7:0]OV7725_D_1;
  wire OV7725_HREF_1;
  wire OV7725_PCLK_1;
  wire OV7725_VSYNC_1;
  wire [15:0]blk_mem_gen_0_doutb;
  wire btn_ColorExrtract_1;
  wire [16:0]cam_ov7670_ov7725_0_addr;
  wire [15:0]cam_ov7670_ov7725_0_dout;
  wire cam_ov7670_ov7725_0_wclk;
  wire cam_ov7670_ov7725_0_we;
  wire clk100_1;
  wire clk_wiz_0_clk_out1;
  wire colorDetect_0_Binary_PreProcess;
  wire [23:0]colorDetect_0_RGB24_dis;
  wire [11:0]colorDetect_0_center_h;
  wire [10:0]colorDetect_0_center_v;
  wire debounce_0_o;
  wire dilate_0_pix_o;
  wire erode_0_pix_o;
  wire [15:0]ov7725_regData_0_LUT_DATA;
  wire [7:0]ov7725_regData_0_Slave_Addr;
  wire pwm_0_pwm_h;
  wire pwm_0_pwm_v;
  wire tracking_enabled;
  wire sample_color;
  wire [16:0]ram_read_0_address;
  wire [3:0]ram_read_0_vga_blue;
  wire [3:0]ram_read_0_vga_green;
  wire [3:0]ram_read_0_vga_red;
  wire [11:0]region_cut_0_valid_h_cnt;
  wire [10:0]region_cut_0_valid_v_cnt;
  wire [23:0]rgb2hsv_top_0_HSV24;
  wire [23:0]rgb565_rgb888_0_rgb888;
  wire [15:0]rgb888_rgb565_0_rgb565;
  wire rst_1;
  wire sw_ColorClear_1;
  wire [11:0]vga_0_vga_h_cnt;
  wire vga_0_vga_hsync;
  wire [10:0]vga_0_vga_v_cnt;
  wire vga_0_vga_valid;
  wire vga_0_vga_vsync;
  //wire [0:0]xlconstant_0_dout;

  assign OV7725_D_1 = OV7725_D[7:0];
  assign OV7725_HREF_1 = OV7725_HREF;
  assign OV7725_PCLK_1 = OV7725_PCLK;
  assign OV7725_SIOC = IICctrl_0_I2C_SCLK;
  assign OV7725_VSYNC_1 = OV7725_VSYNC;
  assign OV7725_XCLK = clk_wiz_0_clk_out1;
  assign btn_ColorExrtract_1 = btn_ColorExrtract;
  assign clk100_1 = clk100;

  assign counter_v[10:0] = colorDetect_0_center_v;
  assign pwm_h = pwm_0_pwm_h;
  assign pwm_v = pwm_0_pwm_v;
  assign rst_1 = 1'b0;
  assign sw_ColorClear_1 = sw_ColorClear;
  assign vga_blue[3:0] = ram_read_0_vga_blue;
  assign vga_green[3:0] = ram_read_0_vga_green;
  assign vga_hsync = vga_0_vga_hsync;
  assign vga_red[3:0] = ram_read_0_vga_red;
  assign vga_vsync = vga_0_vga_vsync;
  wire [1:0] active_mode;
  wire [1:0] selected_mode;
  wire mode_running;
  wire [17:0] reported_pulse_h, reported_pulse_v;
  wire [11:0] s2_h_us, s2_v_us;
  wire s2_valid;
  assign active_mode = mode_running ? selected_mode : 2'd2;
  wire [7:0] mode_epoch;
  wire [11:0] external_x;
  wire [10:0] external_y;
  wire external_valid;
  wire [7:0] external_generation;
  wire selected_enable = active_mode == 0 ? tracking_enabled :
                         (active_mode == 1 || active_mode == 2) ? external_valid : 1'b0;
  wire [11:0] selected_x = active_mode == 0 ? colorDetect_0_center_h : external_x;
  wire [10:0] selected_y = active_mode == 0 ? colorDetect_0_center_v : external_y;
  mode_control modes(.clk(clk_wiz_0_clk_out1), .reset(debounce_0_o),
    .minus(btn_mode_minus), .plus(btn_mode_plus), .uart_rx(mode_rx), .uart_tx(mode_tx),
    .enter_mode(btn_mode_enter), .leave_mode(rst), .running(mode_running),
    .mode(selected_mode), .epoch(mode_epoch), .target_x(external_x),
    .target_y(external_y), .target_valid(external_valid), .target_generation(external_generation),
    .reported_h(reported_pulse_h), .reported_v(reported_pulse_v),
    .s2_h_us(s2_h_us), .s2_v_us(s2_v_us), .s2_valid(s2_valid));
  mode_display display(.clk(clk_wiz_0_clk_out1), .mode(selected_mode), .running(mode_running), .seg(seg), .an(an), .dp(dp));
  track_select selection_control (
    .clk(clk_wiz_0_clk_out1), .button(btn_ColorExrtract_1),
    .clear(sw_ColorClear_1),
    .frame_tick(region_cut_0_valid_h_cnt == 319 && region_cut_0_valid_v_cnt == 239),
    .sample_color(sample_color), .tracking_enabled(tracking_enabled));
  IICctrl  IICctrl_0
       (.I2C_SCLK(IICctrl_0_I2C_SCLK),
        .I2C_SDAT(OV7725_SIOD),
        .LUT_DATA(ov7725_regData_0_LUT_DATA),
        .LUT_INDEX(IICctrl_0_LUT_INDEX),
        .Slave_Addr(ov7725_regData_0_Slave_Addr),
        .iCLK(clk_wiz_0_clk_out1),
        .rst(debounce_0_o));
  blk_mem_gen_0 blk_mem_gen_0_i
       (.addra(cam_ov7670_ov7725_0_addr),
        .addrb(ram_read_0_address),
        .clka(cam_ov7670_ov7725_0_wclk),
        .clkb(clk_wiz_0_clk_out1),
        .dina(cam_ov7670_ov7725_0_dout),
        .doutb(blk_mem_gen_0_doutb),
        .wea(cam_ov7670_ov7725_0_we));
  cam_ov7670_ov7725 cam_ov7670_ov7725_0_i
       (.addr(cam_ov7670_ov7725_0_addr),
        .d(OV7725_D_1),
        .dout(cam_ov7670_ov7725_0_dout),
        .href(OV7725_HREF_1),
        .pclk(OV7725_PCLK_1),
        .vsync(OV7725_VSYNC_1),
        .wclk(cam_ov7670_ov7725_0_wclk),
        .we(cam_ov7670_ov7725_0_we));
  clk_wiz_0 clk_wiz_0_i
       (.clk_in1(clk100_1),
        .clk_out1(clk_wiz_0_clk_out1));
  wire visual_aim_display = mode_running && (selected_mode == 1 || selected_mode == 2 || selected_mode == 3);
  colorDetect colorDetect_0
       (.native_overlay(active_mode == 0),
        .yellow_enable(!visual_aim_display),
        .display_x(visual_aim_display ? (selected_mode == 3 ? 12'd132 : 12'd122) : selected_enable ? selected_x : 12'd0),
        .display_y(visual_aim_display ? (selected_mode == 3 ? 11'd135 : 11'd126) : selected_enable ? selected_y : 11'd0),
        .Binary_PostProcess(dilate_0_pix_o),
        .Binary_PreProcess(colorDetect_0_Binary_PreProcess),
        .HSV24(rgb2hsv_top_0_HSV24),
        .PClk(clk_wiz_0_clk_out1),
        .RGB24(rgb565_rgb888_0_rgb888),
        .RGB24_dis(colorDetect_0_RGB24_dis),
        .VtcHCnt(region_cut_0_valid_h_cnt),
        .VtcVCnt(region_cut_0_valid_v_cnt),
        .btn_ColorExtract(sample_color && active_mode == 0),
        .center_h(colorDetect_0_center_h),
        .center_v(colorDetect_0_center_v),
        .sw_ColorClear(sw_ColorClear_1));
  debounce debounce_0
       (.clk(clk_wiz_0_clk_out1),
        .clr(1'b0),
        .i(rst_1),
        .o(debounce_0_o));
  dilate dilate_0
       (.PCLK(clk_wiz_0_clk_out1),
        .VtcHCnt(region_cut_0_valid_h_cnt),
        .VtcVCnt(region_cut_0_valid_v_cnt),
        .pix_i(erode_0_pix_o),
        .pix_o(dilate_0_pix_o));
  erode erode_0
       (.PCLK(clk_wiz_0_clk_out1),
        .VtcHCnt(region_cut_0_valid_h_cnt),
        .VtcVCnt(region_cut_0_valid_v_cnt),
        .pix_i(colorDetect_0_Binary_PreProcess),
        .pix_o(erode_0_pix_o));
  ov7725_regData ov7725_regData_0
       (.LUT_DATA(ov7725_regData_0_LUT_DATA),
        .LUT_INDEX(IICctrl_0_LUT_INDEX),
        .Slave_Addr(ov7725_regData_0_Slave_Addr));
  pwm pwm_0
       (.clk(clk100_1),
        .pixel_clk(clk_wiz_0_clk_out1),
        .track_enable(selected_enable),
        .counter_h(selected_x),
        .counter_v(selected_y),
        .external_mode(active_mode == 1 || (active_mode == 2 && !s2_valid)), .target_generation(external_generation),
        .direct_enable(s2_valid && mode_running && (selected_mode == 2 || selected_mode == 3)),
        .direct_h_us(s2_h_us), .direct_v_us(s2_v_us),
        .reported_h(reported_pulse_h), .reported_v(reported_pulse_v),
        .pwm_h(pwm_0_pwm_h),
        .pwm_v(pwm_0_pwm_v));
  ram_read ram_read_0
       (.address(ram_read_0_address),
        .clk(clk_wiz_0_clk_out1),
        .din(rgb888_rgb565_0_rgb565),
        .valid(vga_0_vga_valid),
        .vga_blue(ram_read_0_vga_blue),
        .vga_green(ram_read_0_vga_green),
        .vga_h_cnt(vga_0_vga_h_cnt),
        .vga_red(ram_read_0_vga_red),
        .vga_v_cnt(vga_0_vga_v_cnt));
  region_cut region_cut_0
       (.valid_h_cnt(region_cut_0_valid_h_cnt),
        .valid_v_cnt(region_cut_0_valid_v_cnt),
        .vga_h_cnt(vga_0_vga_h_cnt),
        .vga_v_cnt(vga_0_vga_v_cnt));
  rgb2hsv_top rgb2hsv_top_0
       (.HSV24(rgb2hsv_top_0_HSV24),
        .RGB24(rgb565_rgb888_0_rgb888),
        .pclk(clk_wiz_0_clk_out1));
  rgb565_rgb888 rgb565_rgb888_0
       (.rgb565(blk_mem_gen_0_doutb),
        .rgb888(rgb565_rgb888_0_rgb888));
  rgb888_rgb565 rgb888_rgb565_0
       (.rgb565(rgb888_rgb565_0_rgb565),
        .rgb888(colorDetect_0_RGB24_dis));
  vga vga_0
       (.vga_h_cnt(vga_0_vga_h_cnt),
        .vga_hsync(vga_0_vga_hsync),
        .vga_pclk(clk_wiz_0_clk_out1),
        .vga_rst(debounce_0_o),
        .vga_v_cnt(vga_0_vga_v_cnt),
        .vga_valid(vga_0_vga_valid),
        .vga_vsync(vga_0_vga_vsync));

    
endmodule
