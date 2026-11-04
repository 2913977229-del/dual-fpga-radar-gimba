# vivado -mode batch -source scripts/build.tcl (from package root)
set root [file normalize [file join [file dirname [info script]] ..]]
cd [file join $root rtl]
create_project -in_memory -part xc7a35tcpg236-1
read_verilog -sv [glob *.sv]
read_xdc basys3.xdc
synth_design -top n10p_top -part xc7a35tcpg236-1
file mkdir [file join $root build]
report_utilization -file [file join $root build utilization_synth.txt]
opt_design
place_design
phys_opt_design
route_design
report_timing_summary -file [file join $root build timing.txt]
report_utilization -file [file join $root build utilization.txt]
report_drc -file [file join $root build drc.txt]
write_checkpoint -force [file join $root build routed.dcp]
if {[get_property SLACK [get_timing_paths -delay_type max -max_paths 1]] < 0} {
  error "Timing failed; bitstream not generated"
}
if {[get_property SLACK [get_timing_paths -delay_type min -max_paths 1]] < 0} {
  error "Hold timing failed; bitstream not generated"
}
write_bitstream -force [file join $root build n10p_top.bit]
