set SCRIPT_DIR [file dirname [info script]]

if {[file exists ./dataplane.xpr]} {
    open_project ./dataplane.xpr
} else {
    source $SCRIPT_DIR/create_project.tcl
}

source $SCRIPT_DIR/add_files.tcl