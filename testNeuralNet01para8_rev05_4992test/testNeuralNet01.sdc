# Clock
create_clock -name clock_in_50mhz -period 20.000 [get_ports {CLOCK_50}]
create_generated_clock -name reverse_clock_50mhz -source [get_ports {CLOCK_50}] -invert [get_ports {DRAM_CLK}]
#create_generated_clock -name clock_in_25mhz -source [get_ports {CLOCK_50}] -divide_by 2 [get_registers {clock_count[1]}]
create_clock -name CLOCK_VGA -period 40.000

derive_clock_uncertainty
# I/O
set_input_delay -clock { clock_in_50mhz } -max 4 [get_ports {RST_N}]
set_input_delay -clock { clock_in_50mhz } -min 1 [get_ports {RST_N}]

set_input_delay -clock { clock_in_50mhz } -max 4 [get_ports {KEY}]
set_input_delay -clock { clock_in_50mhz } -min 1 [get_ports {KEY}]

set_input_delay -clock { clock_in_50mhz } -max 4 [get_ports {BUTTON01}]
set_input_delay -clock { clock_in_50mhz } -min 1 [get_ports {BUTTON01}]

set_input_delay -clock { reverse_clock_50mhz } -max 6 [get_ports {DRAM_DQ[*]}]
set_input_delay -clock { reverse_clock_50mhz } -min 1 [get_ports {DRAM_DQ[*]}]
set_output_delay -clock { reverse_clock_50mhz } -max 6 [get_ports {DRAM_DQ[*]}]
set_output_delay -clock { reverse_clock_50mhz } -min 1 [get_ports {DRAM_DQ[*]}]
set_output_delay -clock { reverse_clock_50mhz } -max 6 [get_ports {DRAM_A[*]}]
set_output_delay -clock { reverse_clock_50mhz } -min 1 [get_ports {DRAM_A[*]}]
set_output_delay -clock { reverse_clock_50mhz } -max 6 [get_ports {DRAM_BA[*]}]
set_output_delay -clock { reverse_clock_50mhz } -min 1 [get_ports {DRAM_BA[*]}]
set_output_delay -clock { reverse_clock_50mhz } -max 6 [get_ports {DRAM_DQM[*]}]
set_output_delay -clock { reverse_clock_50mhz } -min 1 [get_ports {DRAM_DQM[*]}]
set_output_delay -clock { reverse_clock_50mhz } -max 6 [get_ports {DRAM_CKE DRAM_CAS_N DRAM_RAS_N DRAM_WE_N DRAM_CS_N}]
set_output_delay -clock { reverse_clock_50mhz } -min 1 [get_ports {DRAM_CKE DRAM_CAS_N DRAM_RAS_N DRAM_WE_N DRAM_CS_N}]

set_output_delay -clock { CLOCK_VGA } -max 2 [get_ports {VGA_R[*] VGA_G[*] VGA_B[*] VGA_H_SYNC VGA_V_SYNC}]
set_output_delay -clock { CLOCK_VGA } -min 1 [get_ports {VGA_R[*] VGA_G[*] VGA_B[*] VGA_H_SYNC VGA_V_SYNC}]

set_output_delay -clock { clock_in_50mhz } -max 4  [get_ports {LED[*]}]
set_output_delay -clock { clock_in_50mhz } -min 0  [get_ports {LED[*]}]
set_input_delay -clock { clock_in_50mhz } -max 4  [get_ports {SPI_MISO SPI_CLOCK SPI_ENABLE_N}]
set_input_delay -clock { clock_in_50mhz } -min 0  [get_ports {SPI_MISO SPI_CLOCK SPI_ENABLE_N}]
set_output_delay -clock { clock_in_50mhz } -max 4  [get_ports {SPI_MOSI}]
set_output_delay -clock { clock_in_50mhz } -min 0  [get_ports {SPI_MOSI}]

set_input_delay -clock { clock_in_50mhz } -max 4 [get_ports {KEY_X[*]}]
set_input_delay -clock { clock_in_50mhz } -min 1 [get_ports {KEY_X[*]}]
set_output_delay -clock { clock_in_50mhz } -max 4 [get_ports {KEY_Y[*]}]
set_output_delay -clock { clock_in_50mhz } -min 1 [get_ports {KEY_Y[*]}]

# False Path
set_false_path -from [get_clocks {clock_in_50mhz}] -to [get_clocks {reverse_clock_50mhz}]
#set_false_path -from [get_clocks {clock_in_25mhz}] -to [get_clocks {reverse_clock_50mhz}]
set_clock_groups -logically_exclusive -group [get_clocks {clock_in_50mhz}] -group [get_clocks {reverse_clock_50mhz}]