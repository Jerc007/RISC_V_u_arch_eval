#!/usr/bin/tclsh

# To use this script open design_vision from command line as design_vision& "for GUI" or dc_shell "for command line"
# in the folder of the script and only: source xxxx.tcl

set GPGPU_GENERIC_ROOT ".."

set NCORES __NCORES__

set gpgpu_vhdls [list \
	"$GPGPU_GENERIC_ROOT/RTL/def_package.vhd" \
	"$GPGPU_GENERIC_ROOT/RTL/fp_leading_zeros_and_shift.vhd" \
	"$GPGPU_GENERIC_ROOT/RTL/right_shifter.vhd" \
	"$GPGPU_GENERIC_ROOT/RTL/prueba.vhd" \
	"$GPGPU_GENERIC_ROOT/RTL/suma_resta.vhd"
]

# 	"$GPGPU_GENERIC_ROOT/SFU/sfu_proc.vhd"  for the complete system including two of them.

# loading the libraries:
set synthetic_library ../../../../../syn_libraries/15nm/CCS/NanGate_15nm_OCL_typical_conditional_ccs.db
set target_library ../../../../../syn_libraries/15nm/CCS/NanGate_15nm_OCL_typical_conditional_ccs.db

# set synthetic_library ../45nm/NangateOpenCellLibrary.db
# set target_library ../45nm/NangateOpenCellLibrary.db

set link_library [list $target_library $synthetic_library]


foreach src $gpgpu_vhdls {
	if [expr {[string first # $src] eq 0}] {puts $src} else {
		#exec >@stdout 2>@stderr
		read_file -format vhdl $src
	}
}


# Create black box for dp_reg to be replaced with behavioral
#set_dont_touch dp_regfile

# elaborate STREAMING_MULTIPROCESSOR -architecture ARCH -library DEFAULT -parameters "STREAMING_MULTIPROCESSOR_ID = 00000000, GMEM_ADDR_SIZE = 18, CMEM_ADDR_SIZE = 13, SYSMEM_ADDR_SIZE = 18" -update


elaborate adder_FP

link

check_design


#Target clock frequency 500MHz. for 45nm tech lib (timeunit in ns)
#create_clock -name clk -period 2 clk 

# Target clock frequency 500MHz. for 15nm tech lib (timeunit in ps)
# create_clock -name clk_i -period 2000 clk_i


		# ###########COMPILE
# ungroup -all -flatten

# ungroup -start_level 3 -all

compile
	
		# compile -map_effort high
		# compile_ultra -inc -retime
		# compile_ultra -retime

write -f verilog -hierarchy -output FP_add_15_polito_cadence.v

report_timing -transition_time -nets -attributes -nosplit > Report_time_transition_15.txt
report_timing -delay max -nosplit > Report_time_delay_max_15.txt
report_timing -path full -nosplit > Report_time_path_full_15.txt

report_area -nosplit -hierarchy > Report_Area_15.txt
report_power -nosplit -hierarchy > Report_Power_15.txt
report_reference -nosplit -hierarchy > Report_References_15.txt
report_resources -nosplit -hierarchy > Report_Resources_15.txt
report_cell > Report_Cells_15.txt

exit
		#quit
