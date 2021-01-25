## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
#Bank = 34, Pin name = ,					Sch name = CLK100MHZ
		set_property PACKAGE_PIN W5 [get_ports Clockin]
		set_property IOSTANDARD LVCMOS33 [get_ports Clockin]
		create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports Clockin]
       ## connect_debug_port dbg_hub/clk [get_nets Clockin]
# Switches

#set_property PACKAGE_PIN V17 [get_ports slide_program[0]]
#set_property IOSTANDARD LVCMOS33 [get_ports slide_program[0]]


#set_property PACKAGE_PIN V16 [get_ports slide_program[1]]
#set_property IOSTANDARD LVCMOS33 [get_ports slide_program[1]]

#set_property PACKAGE_PIN W16 [get_ports slide_program[2]]
#set_property IOSTANDARD LVCMOS33 [get_ports slide_program[2]]


set_property PACKAGE_PIN W17 [get_ports slide_display[0]]
set_property IOSTANDARD LVCMOS33 [get_ports slide_display[0]]

set_property PACKAGE_PIN W15 [get_ports slide_display[1]]
set_property IOSTANDARD LVCMOS33 [get_ports slide_display[1]]

set_property PACKAGE_PIN V15 [get_ports slide_display[2]]
set_property IOSTANDARD LVCMOS33 [get_ports slide_display[2]]

set_property PACKAGE_PIN W14 [get_ports slide_display[3]]
set_property IOSTANDARD LVCMOS33 [get_ports slide_display[3]]

set_property PACKAGE_PIN W13 [get_ports slide_display[4]]
set_property IOSTANDARD LVCMOS33 [get_ports slide_display[4]]

set_property PACKAGE_PIN R2 [get_ports slide_display[5]]
set_property IOSTANDARD LVCMOS33 [get_ports slide_display[5]]

#set_property PACKAGE_PIN T1 [get_ports go]
#set_property IOSTANDARD LVCMOS33 [get_ports go]

#set_property PACKAGE_PIN U1 [get_ports step]
#set_property IOSTANDARD LVCMOS33 [get_ports step]

## Buttons

set_property PACKAGE_PIN W19 [get_ports Resetin]
set_property IOSTANDARD LVCMOS33 [get_ports Resetin]

set_property PACKAGE_PIN U18 [get_ports Onestepin]
set_property IOSTANDARD LVCMOS33 [get_ports Onestepin]

set_property PACKAGE_PIN T17 [get_ports Goin]
set_property IOSTANDARD LVCMOS33 [get_ports Goin]

set_property PACKAGE_PIN T18 [get_ports Oneinstrin]
set_property IOSTANDARD LVCMOS33 [get_ports Oneinstrin]

set_property PACKAGE_PIN U17 [get_ports IRQin]
set_property IOSTANDARD LVCMOS33 [get_ports IRQin]



##LEDs

set_property PACKAGE_PIN L1 [get_ports ledOut[15]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[15]]

set_property PACKAGE_PIN P1 [get_ports ledOut[14]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[14]]

set_property PACKAGE_PIN N3 [get_ports ledOut[13]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[13]]

set_property PACKAGE_PIN P3 [get_ports ledOut[12]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[12]]

set_property PACKAGE_PIN U3 [get_ports ledOut[11]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[11]]

set_property PACKAGE_PIN W3 [get_ports ledOut[10]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[10]]

set_property PACKAGE_PIN V3 [get_ports ledOut[9]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[9]]

set_property PACKAGE_PIN V13 [get_ports ledOut[8]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[8]]

set_property PACKAGE_PIN V14 [get_ports ledOut[7]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[7]]

set_property PACKAGE_PIN U14 [get_ports ledOut[6]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[6]]

set_property PACKAGE_PIN U15 [get_ports ledOut[5]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[5]]

set_property PACKAGE_PIN W18 [get_ports ledOut[4]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[4]]

set_property PACKAGE_PIN V19 [get_ports ledOut[3]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[3]]

set_property PACKAGE_PIN U19 [get_ports ledOut[2]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[2]]

set_property PACKAGE_PIN E19 [get_ports ledOut[1]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[1]]

set_property PACKAGE_PIN U16 [get_ports ledOut[0]]					
	set_property IOSTANDARD LVCMOS33 [get_ports ledOut[0]]

#set_property PACKAGE_PIN V7 [get_ports dp]							
#	set_property IOSTANDARD LVCMOS33 [get_ports dp]




# Others (BITSTREAM, CONFIG)
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]



