#### Clock and reset
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_in_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_in_n]
set_property PACKAGE_PIN G9 [get_ports clk_in_n]

set_property IOSTANDARD LVCMOS15 [get_ports glbl_rst]
set_property PACKAGE_PIN A8 [get_ports glbl_rst]

#### Module Push_Buttons_4Bit constraints
# left button
#set_property IOSTANDARD LVCMOS25 [get_ports pin_name]
#set_property PACKAGE_PIN AK25 [get_ports pin_name]
# center button
#set_property IOSTANDARD LVCMOS15 [get_ports pin_name]
#set_property PACKAGE_PIN K15 [get_ports pin_name]
# right button
#set_property IOSTANDARD LVCMOS25 [get_ports pin_name]
#set_property PACKAGE_PIN R27 [get_ports pin_name]

#### Module DIP_Switches_4Bit constraints
# dip switch 4
#set_property IOSTANDARD LVCMOS25 [get_ports port12_speed]
#set_property PACKAGE_PIN AJ13 [get_ports port12_speed]
# dip switch 3
#set_property IOSTANDARD LVCMOS25 [get_ports port34_speed]
#set_property PACKAGE_PIN AC17 [get_ports port34_speed]
# dip switch 2
# set_property IOSTANDARD LVCMOS25 [get_ports pin_name]
# set_property PACKAGE_PIN AC16 [get_ports pin_name]
# dip switch 1
#set_property IOSTANDARD LVCMOS25 [get_ports pin_name]
#set_property PACKAGE_PIN AB17 [get_ports pin_name]

#### Module GPIO LED constraints
# led left
set_property IOSTANDARD LVCMOS25 [get_ports debug0]
set_property PACKAGE_PIN Y21 [get_ports debug0]
# led center
set_property IOSTANDARD LVCMOS15 [get_ports debug1]
set_property PACKAGE_PIN G2 [get_ports debug1]
# led right
set_property IOSTANDARD LVCMOS25 [get_ports debug2]
set_property PACKAGE_PIN W21 [get_ports debug2]
# led 0
set_property IOSTANDARD LVCMOS15 [get_ports debug3]
set_property PACKAGE_PIN A17 [get_ports debug3]

######################################################
### to FMC PHY board
####################
### LPC 1
#D14
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[0]}]
set_property PACKAGE_PIN AH14 [get_ports {phy_resetn[0]}]
#D12
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[0]}]
set_property PACKAGE_PIN AE15 [get_ports {mdc[0]}]
#C11 
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[0]}]
set_property PACKAGE_PIN AC12 [get_ports {mdio[0]}]
#D11
set_property IOSTANDARD LVCMOS25 [get_ports {intn[0]}]
set_property PACKAGE_PIN AE16 [get_ports {intn[0]}]

#H17
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[7]}]
set_property PACKAGE_PIN AK16 [get_ports {gmii_rxd[7]}]
#H16
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[6]}]
set_property PACKAGE_PIN AJ16 [get_ports {gmii_rxd[6]}]
#H14
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[5]}]
set_property PACKAGE_PIN AA14 [get_ports {gmii_rxd[5]}]
#H13
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[4]}]
set_property PACKAGE_PIN AA15 [get_ports {gmii_rxd[4]}]
#H11
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[3]}]
set_property PACKAGE_PIN AK15 [get_ports {gmii_rxd[3]}]
#H10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[2]}]
set_property PACKAGE_PIN AJ15 [get_ports {gmii_rxd[2]}]
#H8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[1]}]
set_property PACKAGE_PIN AF12 [get_ports {gmii_rxd[1]}]
#H7
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[0]}]
set_property PACKAGE_PIN AE12 [get_ports {gmii_rxd[0]}]

#G9
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[7]}]
set_property PACKAGE_PIN AG12 [get_ports {gmii_txd[7]}]
#G10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[6]}]
set_property PACKAGE_PIN AH12 [get_ports {gmii_txd[6]}]
#C10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[5]}]
set_property PACKAGE_PIN AB12 [get_ports {gmii_txd[5]}]
#G13
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[4]}]
set_property PACKAGE_PIN AD13 [get_ports {gmii_txd[4]}]
#G12
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[3]}]
set_property PACKAGE_PIN AD14 [get_ports {gmii_txd[3]}]
#G16
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[2]}]
set_property PACKAGE_PIN AD15 [get_ports {gmii_txd[2]}]
#G15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[1]}]
set_property PACKAGE_PIN AD16 [get_ports {gmii_txd[1]}]
#D15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[0]}]
set_property PACKAGE_PIN AH13 [get_ports {gmii_txd[0]}]

#D17
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[0]}]
set_property PACKAGE_PIN AH17 [get_ports {gmii_tx_en[0]}]
#C15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[0]}]
set_property PACKAGE_PIN AC13 [get_ports {gmii_tx_er[0]}]
#C14
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[0]}]
set_property PACKAGE_PIN AC14 [get_ports {gmii_tx_clk[0]}]

#H19
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[0]}]
set_property PACKAGE_PIN AB15 [get_ports {gmii_rx_dv[0]}]
#H20
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[0]}]
set_property PACKAGE_PIN AB14 [get_ports {gmii_rx_er[0]}]
#D8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[0]}]
set_property PACKAGE_PIN AF15 [get_ports {gmii_rx_clk[0]}]
#G6
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[0]}]
set_property PACKAGE_PIN AE13 [get_ports {mii_tx_clk[0]}]


####################
### LPC 2
#D26
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[1]}]
set_property PACKAGE_PIN AJ30 [get_ports {phy_resetn[1]}]
#C26
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[1]}]
set_property PACKAGE_PIN AJ28 [get_ports {mdc[1]}]
#D24 
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[1]}]
set_property PACKAGE_PIN AK26 [get_ports {mdio[1]}]
#C23
set_property IOSTANDARD LVCMOS25 [get_ports {intn[1]}]
set_property PACKAGE_PIN AF27 [get_ports {intn[1]}]

#H32
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[15]}]
set_property PACKAGE_PIN AE26 [get_ports {gmii_rxd[15]}]
#H31
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[14]}]
set_property PACKAGE_PIN AD25 [get_ports {gmii_rxd[14]}]
#H29
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[13]}]
set_property PACKAGE_PIN AG30 [get_ports {gmii_rxd[13]}]
#H28
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[12]}]
set_property PACKAGE_PIN AF30 [get_ports {gmii_rxd[12]}]
#H26
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[11]}]
set_property PACKAGE_PIN AH29 [get_ports {gmii_rxd[11]}]
#H25
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[10]}]
set_property PACKAGE_PIN AH28 [get_ports {gmii_rxd[10]}]
#H23
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[9]}]
set_property PACKAGE_PIN AH27 [get_ports {gmii_rxd[9]}]
#H22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[8]}]
set_property PACKAGE_PIN AH26 [get_ports {gmii_rxd[8]}]

#G21
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[15]}]
set_property PACKAGE_PIN AG26 [get_ports {gmii_txd[15]}]
#G22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[14]}]
set_property PACKAGE_PIN AG27 [get_ports {gmii_txd[14]}]
#D23
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[13]}]
set_property PACKAGE_PIN AJ26 [get_ports {gmii_txd[13]}]
#G24
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[12]}]
set_property PACKAGE_PIN AK27 [get_ports {gmii_txd[12]}]
#G25
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[11]}]
set_property PACKAGE_PIN AK28 [get_ports {gmii_txd[11]}]
#G28
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[10]}]
set_property PACKAGE_PIN AG29 [get_ports {gmii_txd[10]}]
#G27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[9]}]
set_property PACKAGE_PIN AF29 [get_ports {gmii_txd[9]}]
#G30
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[8]}]
set_property PACKAGE_PIN AE25 [get_ports {gmii_txd[8]}]

#D27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[1]}]
set_property PACKAGE_PIN AK30 [get_ports {gmii_tx_en[1]}]
#C27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[1]}]
set_property PACKAGE_PIN AJ29 [get_ports {gmii_tx_er[1]}]
#G36
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[1]}]
set_property PACKAGE_PIN Y30 [get_ports {gmii_tx_clk[1]}]

#H34
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[1]}]
set_property PACKAGE_PIN AB29 [get_ports {gmii_rx_dv[1]}]
#H35
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[1]}]
set_property PACKAGE_PIN AB30 [get_ports {gmii_rx_er[1]}]
#C22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[1]}]
set_property PACKAGE_PIN AE27 [get_ports {gmii_rx_clk[1]}]
#D20
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[1]}]
set_property PACKAGE_PIN AB27 [get_ports {mii_tx_clk[1]}]

####################
### HPC 1
#D14
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[2]}]
set_property PACKAGE_PIN AD21 [get_ports {phy_resetn[2]}]
#D12
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[2]}]
set_property PACKAGE_PIN AH24 [get_ports {mdc[2]}]
#C11 
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[2]}]
set_property PACKAGE_PIN AH22 [get_ports {mdio[2]}]
#D11
set_property IOSTANDARD LVCMOS25 [get_ports {intn[2]}]
set_property PACKAGE_PIN AH23 [get_ports {intn[2]}]

#H17
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[23]}]
set_property PACKAGE_PIN AE23 [get_ports {gmii_rxd[23]}]
#H16
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[22]}]
set_property PACKAGE_PIN AD23 [get_ports {gmii_rxd[22]}]
#H14
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[21]}]
set_property PACKAGE_PIN AJ24 [get_ports {gmii_rxd[21]}]
#H13
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[20]}]
set_property PACKAGE_PIN AJ23 [get_ports {gmii_rxd[20]}]
#H11
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[19]}]
set_property PACKAGE_PIN AK20 [get_ports {gmii_rxd[19]}]
#H10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[18]}]
set_property PACKAGE_PIN AJ20 [get_ports {gmii_rxd[18]}]
#H8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[17]}]
set_property PACKAGE_PIN AK18 [get_ports {gmii_rxd[17]}]
#H7
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[16]}]
set_property PACKAGE_PIN AK17 [get_ports {gmii_rxd[16]}]

#G9
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[23]}]
set_property PACKAGE_PIN AH19 [get_ports {gmii_txd[23]}]
#G10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[22]}]
set_property PACKAGE_PIN AJ19 [get_ports {gmii_txd[22]}]
#C10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[21]}]
set_property PACKAGE_PIN AG22 [get_ports {gmii_txd[21]}]
#G13
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[20]}]
set_property PACKAGE_PIN AG19 [get_ports {gmii_txd[20]}]
#G12
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[19]}]
set_property PACKAGE_PIN AF19 [get_ports {gmii_txd[19]}]
#G16
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[18]}]
set_property PACKAGE_PIN AF24 [get_ports {gmii_txd[18]}]
#G15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[17]}]
set_property PACKAGE_PIN AF23 [get_ports {gmii_txd[17]}]
#D15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[16]}]
set_property PACKAGE_PIN AE21 [get_ports {gmii_txd[16]}]

#D17
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[2]}]
set_property PACKAGE_PIN AA22 [get_ports {gmii_tx_en[2]}]
#C15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[2]}]
set_property PACKAGE_PIN AG25 [get_ports {gmii_tx_er[2]}]
#C14
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[2]}]
set_property PACKAGE_PIN AG24 [get_ports {gmii_tx_clk[2]}]

#H19
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[2]}]
set_property PACKAGE_PIN Y22 [get_ports {gmii_rx_dv[2]}]
#H20
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[2]}]
set_property PACKAGE_PIN Y23 [get_ports {gmii_rx_er[2]}]
#D8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[2]}]
set_property PACKAGE_PIN AG21 [get_ports {gmii_rx_clk[2]}]
#G6
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[2]}]
set_property PACKAGE_PIN AF20 [get_ports {mii_tx_clk[2]}]


####################
### HPC 2
#D26
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[3]}]
set_property PACKAGE_PIN R28 [get_ports {phy_resetn[3]}]
#C26
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[3]}]
set_property PACKAGE_PIN V28 [get_ports {mdc[3]}]
#D24 
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[3]}]
set_property PACKAGE_PIN P26 [get_ports {mdio[3]}]
#C23
set_property IOSTANDARD LVCMOS25 [get_ports {intn[3]}]
set_property PACKAGE_PIN W26 [get_ports {intn[3]}]

#H32
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[31]}]
set_property PACKAGE_PIN R30 [get_ports {gmii_rxd[31]}]
#H31
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[30]}]
set_property PACKAGE_PIN P30 [get_ports {gmii_rxd[30]}]
#H29
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[29]}]
set_property PACKAGE_PIN U30 [get_ports {gmii_rxd[29]}]
#H28
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[28]}]
set_property PACKAGE_PIN T30 [get_ports {gmii_rxd[28]}]
#H26
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[27]}]
set_property PACKAGE_PIN W30 [get_ports {gmii_rxd[27]}]
#H25
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[26]}]
set_property PACKAGE_PIN W29 [get_ports {gmii_rxd[26]}]
#H23
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[25]}]
set_property PACKAGE_PIN T25 [get_ports {gmii_rxd[25]}]
#H22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[24]}]
set_property PACKAGE_PIN T24 [get_ports {gmii_rxd[24]}]

#G21
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[31]}]
set_property PACKAGE_PIN U25 [get_ports {gmii_txd[31]}]
#G22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[30]}]
set_property PACKAGE_PIN V26 [get_ports {gmii_txd[30]}]
#D23
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[29]}]
set_property PACKAGE_PIN P25 [get_ports {gmii_txd[29]}]
#G24
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[28]}]
set_property PACKAGE_PIN V27 [get_ports {gmii_txd[28]}]
#G25
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[27]}]
set_property PACKAGE_PIN W28 [get_ports {gmii_txd[27]}]
#G28
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[26]}]
set_property PACKAGE_PIN U29 [get_ports {gmii_txd[26]}]
#G27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[25]}]
set_property PACKAGE_PIN T29 [get_ports {gmii_txd[25]}]
#G30
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[24]}]
set_property PACKAGE_PIN R25 [get_ports {gmii_txd[24]}]

#D27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[3]}]
set_property PACKAGE_PIN T28 [get_ports {gmii_tx_en[3]}]
#C27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[3]}]
set_property PACKAGE_PIN V29 [get_ports {gmii_tx_er[3]}]
#G36
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[3]}]
set_property PACKAGE_PIN N26 [get_ports {gmii_tx_clk[3]}]

#H34
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[3]}]
set_property PACKAGE_PIN P23 [get_ports {gmii_rx_dv[3]}]
#H35
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[3]}]
set_property PACKAGE_PIN P24 [get_ports {gmii_rx_er[3]}]
#C22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[3]}]
set_property PACKAGE_PIN U26 [get_ports {gmii_rx_clk[3]}]
#D20
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[3]}]
set_property PACKAGE_PIN V23 [get_ports {mii_tx_clk[3]}]

