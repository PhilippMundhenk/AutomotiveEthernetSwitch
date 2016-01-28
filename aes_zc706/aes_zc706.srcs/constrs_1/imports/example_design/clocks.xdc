############################################################
# TX Clock period Constraints                              #
############################################################
# Transmitter clock period constraints: please do not relax
create_clock -period 5.000 -name clk_in_p -add [get_ports clk_in_p]
set_input_jitter clk_in_p 0.050

set_false_path -from [get_ports glbl_rst]

# mdio has timing implications but slow interface so relaxed
#set axi_clk_name [get_clocks -of [get_pins example_clocks/clock_generator/mmcm_adv_inst/CLKOUT1]]
#set_input_delay -clock $axi_clk_name 5 [get_ports mdio]

#create_clock -period 8 [get_ports gmii_rx_clk]
#create_clock -period 8 [get_ports gmii_rx_clk[0]]
#create_clock -period 8 [get_ports gmii_rx_clk[1]]
#create_clock -period 8 [get_ports gmii_rx_clk[2]]
#create_clock -period 8 [get_ports gmii_rx_clk[3]]

#set rx_clk0 [get_clocks -of [get_ports gmii_rx_clk[0]]]
#set rx_clk1 [get_clocks -of [get_ports gmii_rx_clk[1]]]
#set rx_clk2 [get_clocks -of [get_ports gmii_rx_clk[2]]]
#set rx_clk3 [get_clocks -of [get_ports gmii_rx_clk[3]]]

#set_input_delay -clock $rx_clk0 -max 5.2            [get_ports {gmii_rxd[0] gmii_rxd[1] gmii_rxd[2] gmii_rxd[3] gmii_rxd[4] gmii_rxd[5] gmii_rxd[6] gmii_rxd[7] gmii_rx_er[0] gmii_rx_dv[0]}]
#set_input_delay -clock $rx_clk0 -min 0.5 -add_delay [get_ports {gmii_rxd[0] gmii_rxd[1] gmii_rxd[2] gmii_rxd[3] gmii_rxd[4] gmii_rxd[5] gmii_rxd[6] gmii_rxd[7] gmii_rx_er[0] gmii_rx_dv[0]}]
#set_input_delay -clock $rx_clk1 -max 5.2            [get_ports {gmii_rxd[8] gmii_rxd[9] gmii_rxd[10] gmii_rxd[11] gmii_rxd[12] gmii_rxd[13] gmii_rxd[14] gmii_rxd[15] gmii_rx_er[1] gmii_rx_dv[1]}]
#set_input_delay -clock $rx_clk1 -min 0.5 -add_delay [get_ports {gmii_rxd[8] gmii_rxd[9] gmii_rxd[10] gmii_rxd[11] gmii_rxd[12] gmii_rxd[13] gmii_rxd[14] gmii_rxd[15] gmii_rx_er[1] gmii_rx_dv[1]}]
#set_input_delay -clock $rx_clk2 -max 5.2            [get_ports {gmii_rxd[16] gmii_rxd[17] gmii_rxd[18] gmii_rxd[19] gmii_rxd[20] gmii_rxd[21] gmii_rxd[22] gmii_rxd[23] gmii_rx_er[2] gmii_rx_dv[2]}]
#set_input_delay -clock $rx_clk2 -min 0.5 -add_delay [get_ports {gmii_rxd[16] gmii_rxd[17] gmii_rxd[18] gmii_rxd[19] gmii_rxd[20] gmii_rxd[21] gmii_rxd[22] gmii_rxd[23] gmii_rx_er[2] gmii_rx_dv[2]}]
#set_input_delay -clock $rx_clk3 -max 5.2            [get_ports {gmii_rxd[24] gmii_rxd[25] gmii_rxd[26] gmii_rxd[27] gmii_rxd[28] gmii_rxd[29] gmii_rxd[30] gmii_rxd[31] gmii_rx_er[3] gmii_rx_dv[3]}]
#set_input_delay -clock $rx_clk3 -min 0.5 -add_delay [get_ports {gmii_rxd[24] gmii_rxd[25] gmii_rxd[26] gmii_rxd[27] gmii_rxd[28] gmii_rxd[29] gmii_rxd[30] gmii_rxd[31] gmii_rx_er[3] gmii_rx_dv[3]}]

#create_generated_clock -name gmii_ext_clk0 -divide_by 1 -invert -source [get_pins {Xports[0].switch_port/trimac_block/tri_mode_ethernet_mac_i/U0/gmii_interface/gmii_tx_clk_ddr_iob/C}] [get_ports gmii_tx_clk[0]]
#create_generated_clock -name gmii_ext_clk0 -divide_by 1 -invert -source [get_pins {Xports[0].switch_port/trimac_block/tri_mode_ethernet_mac_i/gtx_clk}] [get_ports gmii_tx_clk[0]]
#create_generated_clock -name gmii_ext_clk1 -divide_by 1 -invert -source [get_pins {Xports[1].switch_port/trimac_block/tri_mode_ethernet_mac_i/gtx_clk}] [get_ports gmii_tx_clk[1]]
#create_generated_clock -name gmii_ext_clk2 -divide_by 1 -invert -source [get_pins {Xports[2].switch_port/trimac_block/tri_mode_ethernet_mac_i/gtx_clk}] [get_ports gmii_tx_clk[2]]
#create_generated_clock -name gmii_ext_clk3 -divide_by 1 -invert -source [get_pins {Xports[3].switch_port/trimac_block/tri_mode_ethernet_mac_i/gtx_clk}] [get_ports gmii_tx_clk[3]]

#set_output_delay 2 -max -clock [get_clocks gmii_ext_clk0]  [get_ports {gmii_txd[0] gmii_txd[1] gmii_txd[2] gmii_txd[3] gmii_txd[4] gmii_txd[5] gmii_txd[6] gmii_txd[7] gmii_tx_er[0] gmii_tx_en[0]}]
#set_output_delay -2 -min -clock [get_clocks gmii_ext_clk0] [get_ports {gmii_txd[0] gmii_txd[1] gmii_txd[2] gmii_txd[3] gmii_txd[4] gmii_txd[5] gmii_txd[6] gmii_txd[7] gmii_tx_er[0] gmii_tx_en[0]}]
#set_output_delay 2 -max -clock [get_clocks gmii_ext_clk1]  [get_ports {gmii_txd[8] gmii_txd[9] gmii_txd[10] gmii_txd[11] gmii_txd[12] gmii_txd[13] gmii_txd[14] gmii_txd[15] gmii_tx_er[1] gmii_tx_en[1]}]
#set_output_delay -2 -min -clock [get_clocks gmii_ext_clk1] [get_ports {gmii_txd[8] gmii_txd[9] gmii_txd[10] gmii_txd[11] gmii_txd[12] gmii_txd[13] gmii_txd[14] gmii_txd[15] gmii_tx_er[1] gmii_tx_en[1]}]
#set_output_delay 2 -max -clock [get_clocks gmii_ext_clk2]  [get_ports {gmii_txd[16] gmii_txd[17] gmii_txd[18] gmii_txd[19] gmii_txd[20] gmii_txd[21] gmii_txd[22] gmii_txd[23] gmii_tx_er[2] gmii_tx_en[2]}]
#set_output_delay -2 -min -clock [get_clocks gmii_ext_clk2] [get_ports {gmii_txd[16] gmii_txd[17] gmii_txd[18] gmii_txd[19] gmii_txd[20] gmii_txd[21] gmii_txd[22] gmii_txd[23] gmii_tx_er[2] gmii_tx_en[2]}]
#set_output_delay 2 -max -clock [get_clocks gmii_ext_clk3]  [get_ports {gmii_txd[24] gmii_txd[25] gmii_txd[26] gmii_txd[27] gmii_txd[28] gmii_txd[29] gmii_txd[30] gmii_txd[31] gmii_tx_er[3] gmii_tx_en[3]}]
#set_output_delay -2 -min -clock [get_clocks gmii_ext_clk3] [get_ports {gmii_txd[24] gmii_txd[25] gmii_txd[26] gmii_txd[27] gmii_txd[28] gmii_txd[29] gmii_txd[30] gmii_txd[31] gmii_tx_er[3] gmii_tx_en[3]}]

#set_false_path -to [get_ports {phy_resetn[0] phy_resetn[1] phy_resetn[2] phy_resetn[3]}]

