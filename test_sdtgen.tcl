puts "testing SDTGen"
set jdts_dir /tmp/jdts_test
file mkdir $jdts_dir
set xsa /home/casper/tutorials_devel/rfsoc/tut_spec/rfsoc4x2/rfsoc4x2_tut_spec/myproj/myproj.runs/impl_1/top.xsa
set ::env(CUSTOM_SDT_REPO) /home/casper/system-device-tree-xlnx
set_dt_param -xsa $xsa -dir $jdts_dir
generate_sdt