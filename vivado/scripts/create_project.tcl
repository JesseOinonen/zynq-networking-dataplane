set proj_name dataplane
set build_dir .

create_project $proj_name $build_dir -part xc7z010clg400-1 -force

add_files [glob ../../../pl/rtl/axi/*.sv]
add_files [glob ../../../pl/rtl/csr.sv]
add_files [glob ../../../pl/rtl/top/dataplane_top.sv]
#add_files [glob ../../../pl/rtl/match_action/*.sv]
#add_files [glob ../../../pl/rtl/observability/*.sv]
#add_files [glob ../../../pl/rtl/parser/*.sv]
#add_files [glob ../../../pl/rtl/*.sv]

add_files -fileset sim_1 [glob ../../../fpga/tb/cases/*.sv]
add_files -fileset sim_1 [glob ../../../fpga/tb/top/*.sv]

add_files -fileset constrs_1 ../../../vivado/constraints.xdc

set_property top dataplane_top [current_fileset]; # Synthesis top
set_property top top [get_fileset sim_1];         # Simulation top

puts "Vivado project created in build/dataplane"
