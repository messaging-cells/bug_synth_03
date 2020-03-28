# verilog_defaults -add -I./cell_src_snk/
yosys -import
read_verilog bin_to_disp.v; 
read_verilog debouncer.v; 
read_verilog tree_nand.v; 
read_verilog calc_redun.v; 
read_verilog nd_bug_03.v; # tested module
read_verilog io_bug_03.v; # tester module
read_verilog bug_03.v;  # top module
synth_ice40 -top test_top -json ../$::env(BUILD_DIR)/bug_03.json;
write_ilang ../$::env(BUILD_DIR)/bug_03.ilang;
# write_verilog ../$::env(BUILD_DIR)/bug_03.verilog;
