open_project ./dataplane.xpr
set_property top top [get_filesets sim_1]

# Accept test name as first argument, default to axi4_lite_test
if {[llength $argv] > 0} {
    set test_name [lindex $argv 0]
} else {
    set test_name "axi4_lite_test"
}

set_property -name {xsim.compile.xvlog.more_options}   -value {-L uvm}                               -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm}                               -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options}   -value "-testplusarg UVM_TESTNAME=$test_name" -objects [get_filesets sim_1]

puts "======================================"
puts "Test configured: $test_name"
puts "Click 'Run Simulation' or type:"
puts "  launch_simulation"
puts "in the Tcl console to start."
puts "======================================"
