create_clock -name I_clk -period 20 [get_ports {I_clk}] -add
create_generated_clock -name clk -source [get_ports {I_clk}] -master_clock I_clk -multiply_by 60 -divide_by 50 [get_nets {clk}]
set_clock_groups -asynchronous
	-group [get_clocks {clk}] 
	-group [get_clocks {I_clk}]
