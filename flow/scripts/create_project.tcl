set proj_name dataplane
set build_dir .

create_project $proj_name $build_dir -part xc7z010clg400-1 -force

puts "Vivado project created in build/dataplane"
