// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.1 (win64) Build 881834 Fri Apr  4 14:15:54 MDT 2014
// Date        : Thu Jul 24 13:45:06 2014
// Host        : CE-2013-124 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               D:/SHS/Research/AutoEnetGway/Mine/xc702/aes_xc702/aes_xc702.srcs/sources_1/ip/blk_mem_gen_2/blk_mem_gen_2_stub.v
// Design      : blk_mem_gen_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_2,Vivado 2014.1" *)
module blk_mem_gen_2(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[11:0],dina[31:0],clkb,enb,addrb[13:0],doutb[7:0]" */;
  input clka;
  input [0:0]wea;
  input [11:0]addra;
  input [31:0]dina;
  input clkb;
  input enb;
  input [13:0]addrb;
  output [7:0]doutb;
endmodule
