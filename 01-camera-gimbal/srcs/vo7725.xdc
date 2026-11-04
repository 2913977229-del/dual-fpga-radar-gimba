# Main Clock				
set_property PACKAGE_PIN W5 [get_ports clk100]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]				
create_clock -period 10.000 -name sys_clk [get_ports clk100]

# BTN    rst = BTND;  btn_ColorExtract=BTNC;
set_property PACKAGE_PIN U17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN U18 [get_ports btn_ColorExrtract]
set_property IOSTANDARD LVCMOS33 [get_ports btn_ColorExrtract]

#pwm pwm_h pwm_v
#Sch name = JA1  pwm_h
set_property PACKAGE_PIN J1 [get_ports pwm_h]					
	set_property IOSTANDARD LVCMOS33 [get_ports pwm_h]
#Sch name = JA2  pwm_v
set_property PACKAGE_PIN L2 [get_ports pwm_v]					
	set_property IOSTANDARD LVCMOS33 [get_ports pwm_v]

# SW sw_ColorClear SW0
set_property PACKAGE_PIN V17 [get_ports sw_ColorClear]
set_property IOSTANDARD LVCMOS33 [get_ports sw_ColorClear]

#RST_OUT JB4   ; SGM_OUT JB10
#set_property PACKAGE_PIN B16 [get_ports RST_OUT]
#set_property IOSTANDARD LVCMOS33 [get_ports RST_OUT]
#set_property PACKAGE_PIN C16 [get_ports SGM_OUT]
#set_property IOSTANDARD LVCMOS33 [get_ports SGM_OUT]


#led  counter_v[10:0]
# LEDs
set_property PACKAGE_PIN U16 [get_ports {counter_v[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[0]}]
set_property PACKAGE_PIN E19 [get_ports {counter_v[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[1]}]
set_property PACKAGE_PIN U19 [get_ports {counter_v[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[2]}]
set_property PACKAGE_PIN V19 [get_ports {counter_v[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[3]}]
set_property PACKAGE_PIN W18 [get_ports {counter_v[4]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[4]}]
set_property PACKAGE_PIN U15 [get_ports {counter_v[5]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[5]}]
set_property PACKAGE_PIN U14 [get_ports {counter_v[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[6]}]
set_property PACKAGE_PIN V14 [get_ports {counter_v[7]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[7]}]
set_property PACKAGE_PIN V13 [get_ports {counter_v[8]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[8]}]
set_property PACKAGE_PIN V3 [get_ports {counter_v[9]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[9]}]
set_property PACKAGE_PIN W3 [get_ports {counter_v[10]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {counter_v[10]}]

# State display replaces the old horizontal-coordinate debug outputs.
#OV7725 Data signals 
set_property PACKAGE_PIN P18 [get_ports {OV7725_D[7]}]
set_property PACKAGE_PIN R18 [get_ports {OV7725_D[6]}]
set_property PACKAGE_PIN N17 [get_ports {OV7725_D[5]}]
set_property PACKAGE_PIN P17 [get_ports {OV7725_D[4]}]
set_property PACKAGE_PIN M18 [get_ports {OV7725_D[3]}]
set_property PACKAGE_PIN M19 [get_ports {OV7725_D[2]}]
set_property PACKAGE_PIN K17 [get_ports {OV7725_D[1]}]
set_property PACKAGE_PIN L17 [get_ports {OV7725_D[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7725_D[0]}]
#OV7725 Control signals 
set_property PACKAGE_PIN A17 [get_ports OV7725_HREF]
set_property PACKAGE_PIN A14 [get_ports OV7725_PCLK]
set_property PACKAGE_PIN B15 [get_ports OV7725_SIOC]
set_property PACKAGE_PIN C15 [get_ports OV7725_SIOD]
set_property PACKAGE_PIN A16 [get_ports OV7725_VSYNC]
set_property PACKAGE_PIN A15 [get_ports OV7725_XCLK]
set_property IOSTANDARD LVCMOS33 [get_ports OV7725_HREF]
set_property IOSTANDARD LVCMOS33 [get_ports OV7725_PCLK]
set_property IOSTANDARD LVCMOS33 [get_ports OV7725_SIOC]
set_property IOSTANDARD LVCMOS33 [get_ports OV7725_SIOD]
set_property IOSTANDARD LVCMOS33 [get_ports OV7725_VSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports OV7725_XCLK]
#IIC port"OV7725_SIOD" must be pulled up
set_property PULLUP true [get_ports OV7725_SIOD]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets OV7725_PCLK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets OV7725_VSYNC]


# VGA signals
set_property PACKAGE_PIN J18 [get_ports {vga_blue[3]}]
set_property PACKAGE_PIN K18 [get_ports {vga_blue[2]}]
set_property PACKAGE_PIN L18 [get_ports {vga_blue[1]}]
set_property PACKAGE_PIN N18 [get_ports {vga_blue[0]}]
set_property PACKAGE_PIN D17 [get_ports {vga_green[3]}]
set_property PACKAGE_PIN G17 [get_ports {vga_green[2]}]
set_property PACKAGE_PIN H17 [get_ports {vga_green[1]}]
set_property PACKAGE_PIN J17 [get_ports {vga_green[0]}]
set_property PACKAGE_PIN N19 [get_ports {vga_red[3]}]
set_property PACKAGE_PIN J19 [get_ports {vga_red[2]}]
set_property PACKAGE_PIN H19 [get_ports {vga_red[1]}]
set_property PACKAGE_PIN G19 [get_ports {vga_red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[0]}]
set_property PACKAGE_PIN P19 [get_ports vga_hsync]
set_property PACKAGE_PIN R19 [get_ports vga_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]


set_property PACKAGE_PIN W19 [get_ports {btn_mode_minus}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_mode_minus}]

set_property PACKAGE_PIN T17 [get_ports {btn_mode_plus}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_mode_plus}]
set_property PACKAGE_PIN T18 [get_ports {btn_mode_enter}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_mode_enter}]

# Direct 3.3V UART5: Pi TX GPIO3_C2 -> JA3/J2 (photo lower red pin).
set_property PACKAGE_PIN J2 [get_ports {mode_rx}]
set_property IOSTANDARD LVCMOS33 [get_ports {mode_rx}]

# JA4/G2 (photo upper red pin) -> Pi RX GPIO3_C3, physical pin 36.
set_property PACKAGE_PIN G2 [get_ports {mode_tx}]
set_property IOSTANDARD LVCMOS33 [get_ports {mode_tx}]

set_property PACKAGE_PIN V7 [get_ports {dp}]
set_property IOSTANDARD LVCMOS33 [get_ports {dp}]

set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
