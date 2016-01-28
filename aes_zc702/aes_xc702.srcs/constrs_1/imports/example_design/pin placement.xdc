#### Clock and reset
set_property IOSTANDARD LVDS_25 [get_ports clk_in_p]
set_property IOSTANDARD LVDS_25 [get_ports clk_in_n]
set_property PACKAGE_PIN C19 [get_ports clk_in_n]
set_property PACKAGE_PIN D18 [get_ports clk_in_p]

set_property IOSTANDARD LVCMOS25 [get_ports glbl_rst]
set_property PACKAGE_PIN G19 [get_ports glbl_rst]

#### Module Push_Buttons_4Bit constraints
# left button
#set_property IOSTANDARD LVCMOS25 [get_ports pin_name]
#set_property PACKAGE_PIN AK25 [get_ports pin_name]
# center button
#set_property IOSTANDARD LVCMOS25 [get_ports pin_name]
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
# led 0
set_property IOSTANDARD LVCMOS25 [get_ports debug0]
set_property PACKAGE_PIN E15 [get_ports debug0]
# led 1
set_property IOSTANDARD LVCMOS25 [get_ports debug1]
set_property PACKAGE_PIN D15 [get_ports debug1]
# led 2
set_property IOSTANDARD LVCMOS25 [get_ports debug2]
set_property PACKAGE_PIN W17 [get_ports debug2]
# led 3
set_property IOSTANDARD LVCMOS25 [get_ports debug3]
set_property PACKAGE_PIN W5 [get_ports debug3]

######################################################
### to FMC PHY board
####################
### LPC 1 PHY 1
#D14
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[0]}]
set_property PACKAGE_PIN M15 [get_ports {phy_resetn[0]}]                                                                   
#D12                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[0]}]                                                                      
set_property PACKAGE_PIN N18 [get_ports {mdc[0]}]                                                                         
#C11                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[0]}]                                                                     
set_property PACKAGE_PIN K18 [get_ports {mdio[0]}]                                                                        
#D11                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {intn[0]}]                                                                     
set_property PACKAGE_PIN N17 [get_ports {intn[0]}]                                                                        

#H17                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[7]}]                                                                 
set_property PACKAGE_PIN R21 [get_ports {gmii_rxd[7]}]                                                                    
#H16                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[6]}]                                                                 
set_property PACKAGE_PIN R20 [get_ports {gmii_rxd[6]}]                                                                    
#H14                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[5]}]                                                                 
set_property PACKAGE_PIN K15 [get_ports {gmii_rxd[5]}]                                                                    
#H13                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[4]}]                                                                 
set_property PACKAGE_PIN J15 [get_ports {gmii_rxd[4]}]                                                                    
#H11                                                                                                                       
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[3]}]                                                                 
set_property PACKAGE_PIN M22 [get_ports {gmii_rxd[3]}]                                                                    
#H10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[2]}]
set_property PACKAGE_PIN M21 [get_ports {gmii_rxd[2]}]
#H8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[1]}]
set_property PACKAGE_PIN L22 [get_ports {gmii_rxd[1]}]
#H7
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[0]}]
set_property PACKAGE_PIN L21 [get_ports {gmii_rxd[0]}]

#G9
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[7]}]
set_property PACKAGE_PIN J20 [get_ports {gmii_txd[7]}]
#G10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[6]}]
set_property PACKAGE_PIN K21 [get_ports {gmii_txd[6]}]
#C10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[5]}]
set_property PACKAGE_PIN J18 [get_ports {gmii_txd[5]}]
#G13
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[4]}]
set_property PACKAGE_PIN J22 [get_ports {gmii_txd[4]}]
#G12
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[3]}]
set_property PACKAGE_PIN J21 [get_ports {gmii_txd[3]}]
#G16
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[2]}]
set_property PACKAGE_PIN P22 [get_ports {gmii_txd[2]}]
#G15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[1]}]
set_property PACKAGE_PIN N22 [get_ports {gmii_txd[1]}]
#D15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[0]}]
set_property PACKAGE_PIN M16 [get_ports {gmii_txd[0]}]

#D17
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[0]}]
set_property PACKAGE_PIN P16 [get_ports {gmii_tx_en[0]}]
#C15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[0]}]
set_property PACKAGE_PIN M17 [get_ports {gmii_tx_er[0]}]
#C14
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[0]}]
set_property PACKAGE_PIN L17 [get_ports {gmii_tx_clk[0]}]

#H19
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[0]}]
set_property PACKAGE_PIN P20 [get_ports {gmii_rx_dv[0]}]
#H20
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[0]}]
set_property PACKAGE_PIN P21 [get_ports {gmii_rx_er[0]}]
#D8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[0]}]
set_property PACKAGE_PIN N19 [get_ports {gmii_rx_clk[0]}]
#G6
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[0]}]
set_property PACKAGE_PIN K19 [get_ports {mii_tx_clk[0]}]


####################
### LPC 1 PHY 2
#D26
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[1]}]
set_property PACKAGE_PIN F18 [get_ports {phy_resetn[1]}]
#C26
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[1]}]
set_property PACKAGE_PIN C17 [get_ports {mdc[1]}]
#D24                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[1]}]                                                                               
set_property PACKAGE_PIN G16 [get_ports {mdio[1]}]                                                                                  
#C23                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {intn[1]}]                                                                               
set_property PACKAGE_PIN C20 [get_ports {intn[1]}]                                                                                  

#H32                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[15]}]                                                                          
set_property PACKAGE_PIN C22 [get_ports {gmii_rxd[15]}]                                                                             
#H31                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[14]}]                                                                          
set_property PACKAGE_PIN D22 [get_ports {gmii_rxd[14]}]                                                                             
#H29                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[13]}]                                                                          
set_property PACKAGE_PIN A22 [get_ports {gmii_rxd[13]}]                                                                             
#H28                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[12]}]                                                                          
set_property PACKAGE_PIN A21 [get_ports {gmii_rxd[12]}]                                                                             
#H26                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[11]}]                                                                          
set_property PACKAGE_PIN F22 [get_ports {gmii_rxd[11]}]                                                                             
#H25                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[10]}]                                                                          
set_property PACKAGE_PIN F21 [get_ports {gmii_rxd[10]}]                                                                             
#H23                                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[9]}]                                                                           
set_property PACKAGE_PIN E20 [get_ports {gmii_rxd[9]}]
#H22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[8]}]
set_property PACKAGE_PIN E19 [get_ports {gmii_rxd[8]}]

#G21
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[15]}]
set_property PACKAGE_PIN G20 [get_ports {gmii_txd[15]}]
#G22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[14]}]
set_property PACKAGE_PIN G21 [get_ports {gmii_txd[14]}]
#D23
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[13]}]
set_property PACKAGE_PIN G15 [get_ports {gmii_txd[13]}]
#G24
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[12]}]
set_property PACKAGE_PIN G17 [get_ports {gmii_txd[12]}]
#G25
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[11]}]
set_property PACKAGE_PIN F17 [get_ports {gmii_txd[11]}]
#G28
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[10]}]
set_property PACKAGE_PIN B15 [get_ports {gmii_txd[10]}]
#G27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[9]}]
set_property PACKAGE_PIN C15 [get_ports {gmii_txd[9]}]
#G30
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[8]}]
set_property PACKAGE_PIN B16 [get_ports {gmii_txd[8]}]

#D27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[1]}]
set_property PACKAGE_PIN E18 [get_ports {gmii_tx_en[1]}]
#C27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[1]}]
set_property PACKAGE_PIN C18 [get_ports {gmii_tx_er[1]}]
#G36
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[1]}]
set_property PACKAGE_PIN A18 [get_ports {gmii_tx_clk[1]}]

#H34
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[1]}]
set_property PACKAGE_PIN E21 [get_ports {gmii_rx_dv[1]}]
#H35
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[1]}]
set_property PACKAGE_PIN D21 [get_ports {gmii_rx_er[1]}]
#C22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[1]}]
set_property PACKAGE_PIN D20 [get_ports {gmii_rx_clk[1]}]
#D20
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[1]}]
set_property PACKAGE_PIN B19 [get_ports {mii_tx_clk[1]}]

####################
### LPC 2 PHY 1
#D14
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[2]}]
set_property PACKAGE_PIN U15 [get_ports {phy_resetn[2]}]
#D12
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[2]}]
set_property PACKAGE_PIN AB20 [get_ports {mdc[2]}]
#C11                                                                                                                           
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[2]}]                                                                        
set_property PACKAGE_PIN V17 [get_ports {mdio[2]}]                                                                            
#D11                                                                                                                          
set_property IOSTANDARD LVCMOS25 [get_ports {intn[2]}]                                                                         
set_property PACKAGE_PIN AB19 [get_ports {intn[2]}]                                                                            

#H17                                                                                                                           
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[23]}]                                                                    
set_property PACKAGE_PIN AA14 [get_ports {gmii_rxd[23]}]                                                                       
#H16                                                                                                                           
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[22]}]                                                                   
set_property PACKAGE_PIN Y14 [get_ports {gmii_rxd[22]}]                                                                       
#H14                                                                                                                           
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[21]}]                                                                    
set_property PACKAGE_PIN U21 [get_ports {gmii_rxd[21]}]                                                                      
#H13                                                                                                                          
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[20]}]                                                                    
set_property PACKAGE_PIN T21 [get_ports {gmii_rxd[20]}]                                                                      
#H11                                                                                                                          
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[19]}]                                                                    
set_property PACKAGE_PIN W13 [get_ports {gmii_rxd[19]}]                                                                       
#H10                                                                                                                           
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[18]}]                                                                    
set_property PACKAGE_PIN V13 [get_ports {gmii_rxd[18]}]                                                                       
#H8                                                                                                                           
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[17]}]                                                                    
set_property PACKAGE_PIN V15 [get_ports {gmii_rxd[17]}]
#H7
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[16]}]
set_property PACKAGE_PIN V14 [get_ports {gmii_rxd[16]}]

#G9
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[23]}]
set_property PACKAGE_PIN AA16 [get_ports {gmii_txd[23]}]
#G10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[22]}]
set_property PACKAGE_PIN AB16 [get_ports {gmii_txd[22]}]
#C10
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[21]}]
set_property PACKAGE_PIN U17 [get_ports {gmii_txd[21]}]
#G13
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[20]}]
set_property PACKAGE_PIN AB17 [get_ports {gmii_txd[20]}]
#G12
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[19]}]
set_property PACKAGE_PIN AA17 [get_ports {gmii_txd[19]}]
#G16
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[18]}]
set_property PACKAGE_PIN Y15 [get_ports {gmii_txd[18]}]
#G15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[17]}]
set_property PACKAGE_PIN W15 [get_ports {gmii_txd[17]}]
#D15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[16]}]
set_property PACKAGE_PIN U16 [get_ports {gmii_txd[16]}]

#D17
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[2]}]
set_property PACKAGE_PIN V22 [get_ports {gmii_tx_en[2]}]
#C15
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[2]}]
set_property PACKAGE_PIN Y21 [get_ports {gmii_tx_er[2]}]
#C14
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[2]}]
set_property PACKAGE_PIN Y20 [get_ports {gmii_tx_clk[2]}]

#H19
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[2]}]
set_property PACKAGE_PIN Y13 [get_ports {gmii_rx_dv[2]}]
#H20
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[2]}]
set_property PACKAGE_PIN AA13 [get_ports {gmii_rx_er[2]}]
#D8
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[2]}]
set_property PACKAGE_PIN W16 [get_ports {gmii_rx_clk[2]}]
#G6
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[2]}]
set_property PACKAGE_PIN Y19 [get_ports {mii_tx_clk[2]}]


####################
### LPC 2 PHY 2
#D26
set_property IOSTANDARD LVCMOS25 [get_ports {phy_resetn[3]}]
set_property PACKAGE_PIN U12 [get_ports {phy_resetn[3]}]
#C26
set_property IOSTANDARD LVCMOS25 [get_ports {mdc[3]}]
set_property PACKAGE_PIN AB2 [get_ports {mdc[3]}]
#D24 
set_property IOSTANDARD LVCMOS25 [get_ports {mdio[3]}]
set_property PACKAGE_PIN W12 [get_ports {mdio[3]}]
#C23
set_property IOSTANDARD LVCMOS25 [get_ports {intn[3]}]                                                               
set_property PACKAGE_PIN AA8 [get_ports {intn[3]}]                                                                   

#H32                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[31]}]                                                           
set_property PACKAGE_PIN AB4 [get_ports {gmii_rxd[31]}]                                                               
#H31                                                                                                                  
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[30]}]                                                           
set_property PACKAGE_PIN AB5 [get_ports {gmii_rxd[30]}]                                                               
#H29                                                                                                                  
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[29]}]                                                          
set_property PACKAGE_PIN U5 [get_ports {gmii_rxd[29]}]                                                              
#H28                                                                                                                
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[28]}]                                                         
set_property PACKAGE_PIN U6 [get_ports {gmii_rxd[28]}]                                                             
#H26                                                                                                                  
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[27]}]                                                          
set_property PACKAGE_PIN V4 [get_ports {gmii_rxd[27]}]                                                              
#H25                                                                                                                  
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[26]}]                                                           
set_property PACKAGE_PIN V5 [get_ports {gmii_rxd[26]}]                                                              
#H23                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[25]}]                                                          
set_property PACKAGE_PIN T6 [get_ports {gmii_rxd[25]}]                                                              
#H22                                                                                                                 
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rxd[24]}]                                                          
set_property PACKAGE_PIN R6 [get_ports {gmii_rxd[24]}]                                                              

#G21
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[31]}]
set_property PACKAGE_PIN T4 [get_ports {gmii_txd[31]}]
#G22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[30]}]
set_property PACKAGE_PIN U4 [get_ports {gmii_txd[30]}]
#D23
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[29]}]
set_property PACKAGE_PIN V12 [get_ports {gmii_txd[29]}]
#G24
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[28]}]
set_property PACKAGE_PIN U10 [get_ports {gmii_txd[28]}]
#G25
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[27]}]
set_property PACKAGE_PIN U9 [get_ports {gmii_txd[27]}]
#G28
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[26]}]
set_property PACKAGE_PIN AB12 [get_ports {gmii_txd[26]}]
#G27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[25]}]
set_property PACKAGE_PIN AA12 [get_ports {gmii_txd[25]}]
#G30
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_txd[24]}]
set_property PACKAGE_PIN AA11 [get_ports {gmii_txd[24]}]

#D27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_en[3]}]
set_property PACKAGE_PIN U11 [get_ports {gmii_tx_en[3]}]
#C27
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_er[3]}]
set_property PACKAGE_PIN AB1 [get_ports {gmii_tx_er[3]}]
#G36
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_tx_clk[3]}]
set_property PACKAGE_PIN Y11 [get_ports {gmii_tx_clk[3]}]

#H34
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_dv[3]}]
set_property PACKAGE_PIN AB7 [get_ports {gmii_rx_dv[3]}]
#H35
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_er[3]}]
set_property PACKAGE_PIN AB6 [get_ports {gmii_rx_er[3]}]
#C22
set_property IOSTANDARD LVCMOS25 [get_ports {gmii_rx_clk[3]}]
set_property PACKAGE_PIN AA9 [get_ports {gmii_rx_clk[3]}]
#D20
set_property IOSTANDARD LVCMOS25 [get_ports {mii_tx_clk[3]}]
set_property PACKAGE_PIN AA7 [get_ports {mii_tx_clk[3]}]

