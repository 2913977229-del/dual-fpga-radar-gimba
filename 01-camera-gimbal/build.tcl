set root [file dirname [file normalize [info script]]]
create_project state_s0_s1 [file join $root build] -part xc7a35tcpg236-1 -force
add_files [glob [file join $root srcs *.v]]
add_files -fileset constrs_1 [file join $root srcs vo7725.xdc]
foreach ip {clk_wiz_0 blk_mem_gen_0} {
    import_ip [file join $root ip $ip ${ip}.xci]
}
set_property CONFIG.PRIM_SOURCE {No_buffer} [get_ips clk_wiz_0]
set_property top top [current_fileset]
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property STATUS [get_runs impl_1]] ne "write_bitstream Complete!"} {
    error "Build failed: [get_property STATUS [get_runs impl_1]]"
}
open_run impl_1
report_timing_summary -file [file join $root build timing.rpt]
report_drc -file [file join $root build drc.rpt]
if {[get_property SLACK [get_timing_paths -max_paths 1]] < 0} {error "Setup timing failed"}
if {[get_property SLACK [get_timing_paths -delay_type min -max_paths 1]] < 0} {error "Hold timing failed"}
puts STATE_BUILD_OK
close_project
