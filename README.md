[![GitHub release](https://img.shields.io/github/release/PhilippMundhenk/AutomotiveEthernetSwitch.svg)](https://github.com/PhilippMundhenk/AutomotiveEthernetSwitch/releases) [![GitHub issues](https://img.shields.io/github/issues/PhilippMundhenk/AutomotiveEthernetSwitch.svg)](https://github.com/PhilippMundhenk/AutomotiveEthernetSwitch/issues) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/PhilippMundhenk/AutomotiveEthernetSwitch/blob/master/LICENSE)

# AutomotiveEthernetSwitch
This is a prototype implementation of an FPGA-based switch for Automotive Ethernet Applications. It is optimized for the Xilinx Zynq-7000 All Programmable SoC ZC706/ZC702 Evaluation Kit with Tokyo Electron Device TB-FMCL-GLAN 1000 Base-T Ethernet FMC adapters.

To build the bitstream, a license for the Xilinx Tri-Mode Ethernet Media Access Controller (TEMAC) in version 8.3 is required.

The project is contained in two folders, aes_zc702 and aes_zc706 corresponding to the two implementation platforms ZC702 and ZC706.
The design and implementation of this work has been performed by **Andreas Ettner**.