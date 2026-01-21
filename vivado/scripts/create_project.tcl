set proj_name dataplane
set build_dir .

create_project $proj_name $build_dir -part xc7z010clg400-1 -force

add_files [glob ../../fpga/rtl/axi/*.sv]
add_files [glob ../../fpga/rtl/common/*.sv]
add_files [glob ../../fpga/rtl/match_action/*.sv]
add_files [glob ../../fpga/rtl/observability/*.sv]
add_files [glob ../../fpga/rtl/parser/*.sv]
add_files [glob ../../fpga/rtl/top/*.sv]
add_files [glob ../../fpga/rtl/*.sv]

add_files -fileset sim_1 [glob ../../fpga/tb/cases/*.sv]
add_files -fileset sim_1 [glob ../../fpga/tb/top/*.sv]

add_files -fileset constrs_1 ../../../vivado/constraints.xdc

set_property top dataplane_top [current_fileset]; # Synthesis top
set_property top top [get_fileset sim_1];         # Simulation top

puts "Vivado project created in build/dataplane"
