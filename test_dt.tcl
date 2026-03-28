puts "testing DT generation"
set jdts_dir /tmp/jdts_test
file mkdir $jdts_dir

hsi::open_hw_design /home/casper/tutorials_devel/rfsoc/tut_spec/rfsoc4x2/rfsoc4x2_tut_spec/myproj/myproj.runs/impl_1/top.xsa
hsi::set_repo_path /home/casper/system-device-tree-xlnx
set processor [hsi::get_cells * -filter {IP_TYPE==PROCESSOR}]
puts "processors = $processor"
set processor [lindex $processor 0]
puts "using processor = $processor"
hsi::create_sw_design device-tree -os device_tree -proc $processor
hsi::set_property CONFIG.dt_overlay true [hsi::get_os]
hsi::generate_target -dir $jdts_dir
hsi::close_hw_design [hsi::current_hw_design]