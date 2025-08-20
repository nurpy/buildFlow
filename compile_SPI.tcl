
# Turn argv into a dict
set args [dict create]
foreach {key value} $argv {
    dict set args $key $value
}

# Extract by name
set command [dict get $args -command]

puts "Starting Command:  $command"

## Start Script


set project_name my_project
set VERILOG_VIVADO $::env(VERILOG_VIVADO) 
set working_dir $VERILOG_VIVADO
set project_dir $VERILOG_VIVADO/vivado_project

proc add_fileList {path_to_file mode} {
#mode is compile or sim

puts "path to file : $path_to_file " 

set filelist [open $path_to_file r]
while {[gets $filelist line] >= 0} {
    if {[string match "#*" $line]} { continue }
    if {[string match "" $line]} { continue }
    if {[string match "*.sv" $line]} {
	if {$mode == "sim"} {
		add_files -fileset sim_1 $line
		add_files -fileset sources_1 $line
		continue
	}
	if {$mode == "compile"} {
		read_verilog $line
		continue
	}
    }
    if {[string match "*.v" $line]} {
	if {$mode == "sim"} {
		add_files -fileset sim_1 $line
		add_files -fileset sources_1 $line
		continue
	}
	if {$mode == "compile"} {
		read_verilog $line
		continue
	}
    }
    if {[string match "*.xdc" $line]} {
        add_files -fileset constrs_1 $line 
	continue
    }
    if {[string match "*.f" $line]} {
	add_fileList $line $mode
	continue
    }
    if {[string match "*.vc" $line]} {
	add_fileList $line $mode
	continue
    }
    add_files $line
	
	#error "did not parse $line"
    
}
close $filelist


}



if {$command == "create"} {
##Create New Project
set project_name [dict get $args -project_name]
puts "Creating Project $project_name"
create_project $project_name $project_dir -part xc7a35tcpg236-1

} elseif {$command == "compile"} {
##Compile Project | Synthesis & Implementation
set project_name [dict get $args -project_name]
set top_module [dict get $args -top_module]
set src_dir [dict get $args -src_dir]
puts "Top Module:  $top_module"
puts "Compiling Project $project_name"
puts "Sourcing Directory from $src_dir"
open_project $project_dir/$project_name.xpr


set design_dir "$working_dir/$src_dir"

#set src_dir $working_dir/src/
#set source_files [glob -nocomplain -directory $design_dir *.v *.vh *.sv *.vhd *.vhdl]
#add_files $source_files


#set filelist "$working_dir/src/filelist.vc"
#set filelist "$design_dir/filelist.f"
#puts $filelist
#add_files -fileset sources_1 $filelist
#read_verilog -f $filelist



#set filelist [open "$design_dir/filelist.f" r]
add_fileList "$design_dir/filelist.f" "compile"
#close $filelist




#add_files -fileset constrs_1 $working_dir/constraints/filelist.vc
#add_files -fileset constrs_1 $working_dir/constraints/top.xdc
#add_files -fileset constrs_1 $working_dir/constraints/timing.xdc

# Set the top module
set_property top $top_module [current_fileset]

#resest synth
reset_run synth_1

# Run synthesis
launch_runs synth_1
wait_on_run synth_1

# Optionally, open synthesized design
# open_run synth_1

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1


} elseif {$command == "simulate"} {
##Simulate Project
set project_name [dict get $args -project_name]
set top_module [dict get $args -top_module]
set src_dir [dict get $args -src_dir]
puts "Top Module:  $top_module"
puts "Simulating project $project_name"
puts "Sourcing Directory from $src_dir"
open_project $project_dir/$project_name.xpr

set design_dir "$working_dir/$src_dir"

#add_files -fileset sources_1 [glob $design_dir/*.sv]
#add_files -fileset sim_1     [glob $design_dir/*.sv]
add_fileList "$design_dir/filelist.vc" "sim"


# Set the top module (your testbench)
#set_property top $top_module [current_fileset]
set_property top $top_module [get_filesets sim_1]

# Set simulation language (SystemVerilog if needed)
set_property source_mgmt_mode All [current_project]

# Launch simulation
launch_simulation  -verbose
run all

} elseif {$command == "program"} {
##Program FPGA
set project_name [dict get $args -project_name]
set top_module [dict get $args -top_module]
puts "Top Module:  $top_module"
puts "Simulating project $project_name"
open_project $project_dir/$project_name.xpr

open_hw_manager
connect_hw_server
open_hw_target

# Automatically detect and open the first FPGA device
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [current_hw_device]

# Program the FPGA
#set_property PROGRAM.FILE {./vivado_project/my_project.runs/impl_1/adder.bit} [current_hw_device]
#set_property PROGRAM.FILE ${project_dir}/${project_name}.runs/impl_1/top.bit [current_hw_device]
set_property PROGRAM.FILE ${project_dir}/${project_name}.runs/impl_1/$top_module.bit [current_hw_device]
program_hw_devices [current_hw_device]

}



# Set project name and directory

# Create a new project

#Open a Project


# Set the top module


#add the design files
#set src_dir ./src/
#set source_files [glob -nocomplain -directory $src_dir *.v *.vh *.sv *.vhd *.vhdl]

# Add source files
#add_files $source_files
#set filelist [open "$working_dir/src/filelist.vc" r]
#while {[gets $filelist line] >= 0} {
#    if {[string match "#*" $line]} { continue }
#    if {[string match "" $line]} { continue }
#    read_verilog $line
#}
#close $filelist









# Optionally, add constraint files (comment out if you don't have any)
# add_files ./constraints/top.xdc
#add_files -fileset constrs_1 $working_dir/constraints/top.xdc
#add_files -fileset constrs_1 $working_dir/constraints/timing.xdc



# Or suppress all INFO and STATUS messages globally
#set_msg_config -severity INFO -suppress
#set_msg_config -severity STATUS -suppress



#connect_hw_server
#open_hw_manager
#open_hw_target

# Automatically detect and open the first FPGA device
#current_hw_device [lindex [get_hw_devices] 0]
#refresh_hw_device -update_hw_probes false [current_hw_device]

# Program the FPGA
#set_property PROGRAM.FILE {./vivado_project/${project_name}.runs/impl_1/adder.bit} [current_hw_device]
#program_hw_devices [current_hw_device]




#open_hw_target
#set_property PROGRAM.FILE {/home/nurps/Verilog/vivado_test/vivado_project/my_project.runs/impl_1/adder.bit} [get_hw_devices xc7a35t_0]
#current_hw_device [get_hw_devices xc7a35t_0]
#refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]
#set_property PROBES.FILE {} [get_hw_devices xc7a35t_0]
#set_property FULL_PROBES.FILE {} [get_hw_devices xc7a35t_0]
#set_property PROGRAM.FILE {/home/nurps/Verilog/vivado_test/vivado_project/my_project.runs/impl_1/adder.bit} [get_hw_devices xc7a35t_0]
#program_hw_devices [get_hw_devices xc7a35t_0]
#refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]
