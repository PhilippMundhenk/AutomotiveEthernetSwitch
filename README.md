[![GitHub release](https://img.shields.io/github/release/PhilippMundhenk/AutomotiveEthernetSwitch.svg)](https://github.com/PhilippMundhenk/AutomotiveEthernetSwitch/releases) [![GitHub issues](https://img.shields.io/github/issues/PhilippMundhenk/AutomotiveEthernetSwitch.svg)](https://github.com/PhilippMundhenk/AutomotiveEthernetSwitch/issues) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/PhilippMundhenk/AutomotiveEthernetSwitch/blob/master/LICENSE)

# AutomotiveEthernetSwitch
This is a prototype implementation of an FPGA-based switch for Automotive Ethernet Applications. It is optimized for the Xilinx Zynq-7000 All Programmable SoC ZC702/ZC706 Evaluation Kit with Tokyo Electron Device TB-FMCL-GLAN 1000 Base-T Ethernet FMC adapters.

To build the bitstream, a license for the Xilinx Tri-Mode Ethernet Media Access Controller (TEMAC) in version 8.3 is required.

The project is contained in two folders, aes_zc702 and aes_zc706 corresponding to the two implementation platforms ZC702 and ZC706.
The design and implementation of this work has been performed by **Andreas Ettner**.

**Notes**
----------
- Tool versions 
	- Vivado 2013.4 for the ZC706 build and Vivado 2014.1 for the ZC702 build. 
- Timing violation in ZC702 build
	- Hold violation in Port-2 of the Ethernet Tx Path is due to the chained clock buffers/muxes in the design to support Auto-negotiation (for Ethernet Link) and single GTX clock for all Ethernet Ports. The violation should not normally affect the performance on the board. In case of persistent errors, modify the design by one of the options below. 
	- Generating isolated in-phase GTX clocks for the different ports which are aligned with the switch fabric clock.
	- Removing the ClockMux in the Ethernet Core design -- This will force the link to support only 1Gbps (or 100 Mbps if you use the MII Clock).
	- Choose another optimisation strategy for the implementation run in Vivado (Eg. Performance optimisations)