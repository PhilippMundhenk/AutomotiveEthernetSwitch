// Copyright 1986-1999, 2001-2013 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2013.4 (win64) Build 353583 Mon Dec  9 17:49:19 MST 2013
// Date        : Wed Mar 12 12:33:58 2014
// Host        : RP3-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/aeg_repository/Software/automotive_ethernet_gateway_project/automotive_ethernet_gateway_project.srcs/sources_1/ip/fifo_generator_2/fifo_generator_2_stub.v
// Design      : fifo_generator_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module fifo_generator_2(clk, rst, din, wr_en, rd_en, dout, full, empty)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[88:0],wr_en,rd_en,dout[88:0],full,empty" */;
  input clk;
  input rst;
  input [88:0]din;
  input wr_en;
  input rd_en;
  output [88:0]dout;
  output full;
  output empty;
endmodule
