// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.1 (win64) Build 881834 Fri Apr  4 14:15:54 MDT 2014
// Date        : Thu Jul 24 13:33:21 2014
// Host        : CE-2013-124 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               D:/SHS/Research/AutoEnetGway/Mine/xc702/aes_xc702/aes_xc702.srcs/sources_1/ip/fifo_generator_2/fifo_generator_2_stub.v
// Design      : fifo_generator_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2014.1" *)
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
