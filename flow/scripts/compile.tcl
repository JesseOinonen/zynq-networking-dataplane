# Compile and elaborate the simulation
open_project ./dataplane.xpr
set_property top top [get_filesets sim_1]

puts "======================================"
puts "Compiling and Elaborating Design"
puts "======================================"
puts "Project: dataplane"
puts "Fileset: sim_1"
puts "Top module: top"
puts "======================================"

# Include directories for `include resolution in dp_pkg.sv (absolute paths)
set tb_dir [file normalize [file join [get_property DIRECTORY [current_project]] ../../../pl/tb]]
set_property include_dirs [list \
    [file join $tb_dir uvm] \
    [file join $tb_dir cases] \
    [file join $tb_dir top] \
] [get_filesets sim_1]

# UVM library required for xvlog compilation and xelab elaboration
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]

# Launch simulation (compile and elaborate, but don't run)
launch_simulation -step compile
launch_simulation -step elaborate

puts "Compilation and elaboration complete."
quit
