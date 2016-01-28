-- Copyright 1986-1999, 2001-2013 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2013.4 (win64) Build 353583 Mon Dec  9 17:49:19 MST 2013
-- Date        : Thu Jan 16 12:12:07 2014
-- Host        : RP3-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode funcsim
--               C:/aeg_repository/Software/automotive_ethernet_gateway_project/automotive_ethernet_gateway_project.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_funcsim.vhdl
-- Design      : blk_mem_gen_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z045ffg900-2
-- --------------------------------------------------------------------------------
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity blk_mem_gen_0blk_mem_gen_prim_wrapper_init is
  port (
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    enb : in STD_LOGIC;
    clkb : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    clka : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );
end blk_mem_gen_0blk_mem_gen_prim_wrapper_init;

architecture STRUCTURE of blk_mem_gen_0blk_mem_gen_prim_wrapper_init is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  signal \n_68_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_69_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_70_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_71_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_72_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_73_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_74_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \n_75_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : STD_LOGIC;
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_CASCADEOUTA_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_CASCADEOUTB_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_DBITERR_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_SBITERR_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_ECCPARITY_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_RDADDRECC_UNCONNECTED\ : STD_LOGIC_VECTOR ( 8 downto 0 );
  attribute box_type : string;
  attribute box_type of \DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\ : label is "PRIMITIVE";
begin
\DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\: unisim.vcomponents.RAMB36E1
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      EN_ECC_READ => false,
      EN_ECC_WRITE => false,
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_00 => X"4001DADADADADA022001DADADADADA011001DADADADADA008000C100001000C2",
      INIT_01 => X"1000DADADADADA084000DADADADADA062000DADADADADA051000DADADADADA04",
      INIT_02 => X"2000DADADADADA0D1000DADADADADA0C4000DADADADADA0A2000DADADADADA09",
      INIT_03 => X"4000DADADADADA122000DADADADADA111000DADADADADA104000DADADADADA0E",
      INIT_04 => X"1000DADADADADA184000DADADADADA162000DADADADADA151000DADADADADA14",
      INIT_05 => X"2000DADADADADA1D1000DADADADADA1C4000DADADADADA1A2000DADADADADA19",
      INIT_06 => X"4000DADADADADA222000DADADADADA211000DADADADADA204000DADADADADA1E",
      INIT_07 => X"1000DADADADADA284000DADADADADA262000DADADADADA251000DADADADADA24",
      INIT_08 => X"2000DADADADADA2D1000DADADADADA2C4000DADADADADA2A2000DADADADADA29",
      INIT_09 => X"4000DADADADADA322000DADADADADA311000DADADADADA304000DADADADADA2E",
      INIT_0A => X"1000DADADADADA384000DADADADADA362000DADADADADA351000DADADADADA34",
      INIT_0B => X"2000DADADADADA3D1000DADADADADA3C4000DADADADADA3A2000DADADADADA39",
      INIT_0C => X"4000DADADADADA422000DADADADADA411000DADADADADA404000DADADADADA3E",
      INIT_0D => X"1000DADADADADA484000DADADADADA462000DADADADADA451000DADADADADA44",
      INIT_0E => X"2000DADADADADA4D1000DADADADADA4C4000DADADADADA4A2000DADADADADA49",
      INIT_0F => X"4000DADADADADA522000DADADADADA511000DADADADADA504000DADADADADA4E",
      INIT_10 => X"1000DADADADADA584000DADADADADA562000DADADADADA551000DADADADADA54",
      INIT_11 => X"2000DADADADADA5D1000DADADADADA5C4000DADADADADA5A2000DADADADADA59",
      INIT_12 => X"4000DADADADADA622000DADADADADA611000DADADADADA604000DADADADADA5E",
      INIT_13 => X"1000DADADADADA684000DADADADADA662000DADADADADA651000DADADADADA64",
      INIT_14 => X"2000DADADADADA6D1000DADADADADA6C4000DADADADADA6A2000DADADADADA69",
      INIT_15 => X"4000DADADADADA722000DADADADADA711000DADADADADA704000DADADADADA6E",
      INIT_16 => X"1000DADADADADA784000DADADADADA762000DADADADADA751000DADADADADA74",
      INIT_17 => X"2000DADADADADA7D1000DADADADADA7C4000DADADADADA7A2000DADADADADA79",
      INIT_18 => X"4000DADADADADA822000DADADADADA811000DADADADADA804000DADADADADA7E",
      INIT_19 => X"1000DADADADADA884000DADADADADA862000DADADADADA851000DADADADADA84",
      INIT_1A => X"2000DADADADADA8D1000DADADADADA8C4000DADADADADA8A2000DADADADADA89",
      INIT_1B => X"4000DADADADADA922000DADADADADA911000DADADADADA904000DADADADADA8E",
      INIT_1C => X"1000DADADADADA984000DADADADADA962000DADADADADA951000DADADADADA94",
      INIT_1D => X"2000DADADADADA9D1000DADADADADA9C4000DADADADADA9A2000DADADADADA99",
      INIT_1E => X"4000DADADADADAA22000DADADADADAA11000DADADADADAA04000DADADADADA9E",
      INIT_1F => X"1000DADADADADAA84000DADADADADAA62000DADADADADAA51000DADADADADAA4",
      INIT_20 => X"2000DADADADADAAD1000DADADADADAAC4000DADADADADAAA2000DADADADADAA9",
      INIT_21 => X"4000DADADADADAB22000DADADADADAB11000DADADADADAB04000DADADADADAAE",
      INIT_22 => X"1000DADADADADAB84000DADADADADAB62000DADADADADAB51000DADADADADAB4",
      INIT_23 => X"2000DADADADADABD1000DADADADADABC4000DADADADADABA2000DADADADADAB9",
      INIT_24 => X"4000DADADADADAC22000DADADADADAC11000DADADADADAC04000DADADADADABE",
      INIT_25 => X"1000DADADADADAC84000DADADADADAC62000DADADADADAC51000DADADADADAC4",
      INIT_26 => X"2000DADADADADACD1000DADADADADACC4000DADADADADACA2000DADADADADAC9",
      INIT_27 => X"4000DADADADADAD22000DADADADADAD11000DADADADADAD04000DADADADADACE",
      INIT_28 => X"1000DADADADADAD84000DADADADADAD62000DADADADADAD51000DADADADADAD4",
      INIT_29 => X"2000DADADADADADD1000DADADADADADC4000DADADADADADA2000DADADADADAD9",
      INIT_2A => X"4000DADADADADAE22000DADADADADAE11000DADADADADAE04000DADADADADADE",
      INIT_2B => X"1000DADADADADAE84000DADADADADAE62000DADADADADAE51000DADADADADAE4",
      INIT_2C => X"2000DADADADADAED1000DADADADADAEC4000DADADADADAEA2000DADADADADAE9",
      INIT_2D => X"4000DADADADADAF22000DADADADADAF11000DADADADADAF04000DADADADADAEE",
      INIT_2E => X"1000DADADADADAF84000DADADADADAF62000DADADADADAF51000DADADADADAF4",
      INIT_2F => X"2000DADADADADAFD1000DADADADADAFC4000DADADADADAFA2000DADADADADAF9",
      INIT_30 => X"0000000000000000F000000000000001F000FFFFFFFFFFFF4000DADADADADAFE",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      INIT_FILE => "NONE",
      IS_CLKARDCLK_INVERTED => '0',
      IS_CLKBWRCLK_INVERTED => '0',
      IS_ENARDEN_INVERTED => '0',
      IS_ENBWREN_INVERTED => '0',
      IS_RSTRAMARSTRAM_INVERTED => '0',
      IS_RSTRAMB_INVERTED => '0',
      IS_RSTREGARSTREG_INVERTED => '0',
      IS_RSTREGB_INVERTED => '0',
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      RAM_MODE => "SDP",
      RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
      READ_WIDTH_A => 72,
      READ_WIDTH_B => 0,
      RSTREG_PRIORITY_A => "REGCE",
      RSTREG_PRIORITY_B => "REGCE",
      SIM_COLLISION_CHECK => "ALL",
      SIM_DEVICE => "7SERIES",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 0,
      WRITE_WIDTH_B => 72
    )
    port map (
      ADDRARDADDR(15) => \<const1>\,
      ADDRARDADDR(14 downto 6) => addrb(8 downto 0),
      ADDRARDADDR(5) => \<const1>\,
      ADDRARDADDR(4) => \<const1>\,
      ADDRARDADDR(3) => \<const1>\,
      ADDRARDADDR(2) => \<const1>\,
      ADDRARDADDR(1) => \<const1>\,
      ADDRARDADDR(0) => \<const1>\,
      ADDRBWRADDR(15) => \<const1>\,
      ADDRBWRADDR(14 downto 6) => addra(8 downto 0),
      ADDRBWRADDR(5) => \<const1>\,
      ADDRBWRADDR(4) => \<const1>\,
      ADDRBWRADDR(3) => \<const1>\,
      ADDRBWRADDR(2) => \<const1>\,
      ADDRBWRADDR(1) => \<const1>\,
      ADDRBWRADDR(0) => \<const1>\,
      CASCADEINA => \<const0>\,
      CASCADEINB => \<const0>\,
      CASCADEOUTA => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_CASCADEOUTA_UNCONNECTED\,
      CASCADEOUTB => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_CASCADEOUTB_UNCONNECTED\,
      CLKARDCLK => clkb,
      CLKBWRCLK => clka,
      DBITERR => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_DBITERR_UNCONNECTED\,
      DIADI(31 downto 0) => dina(31 downto 0),
      DIBDI(31 downto 0) => dina(63 downto 32),
      DIPADIP(3) => \<const0>\,
      DIPADIP(2) => \<const0>\,
      DIPADIP(1) => \<const0>\,
      DIPADIP(0) => \<const0>\,
      DIPBDIP(3) => \<const0>\,
      DIPBDIP(2) => \<const0>\,
      DIPBDIP(1) => \<const0>\,
      DIPBDIP(0) => \<const0>\,
      DOADO(31 downto 0) => doutb(31 downto 0),
      DOBDO(31 downto 0) => doutb(63 downto 32),
      DOPADOP(3) => \n_68_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPADOP(2) => \n_69_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPADOP(1) => \n_70_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPADOP(0) => \n_71_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPBDOP(3) => \n_72_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPBDOP(2) => \n_73_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPBDOP(1) => \n_74_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      DOPBDOP(0) => \n_75_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram\,
      ECCPARITY(7 downto 0) => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_ECCPARITY_UNCONNECTED\(7 downto 0),
      ENARDEN => enb,
      ENBWREN => wea(0),
      INJECTDBITERR => \<const0>\,
      INJECTSBITERR => \<const0>\,
      RDADDRECC(8 downto 0) => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_RDADDRECC_UNCONNECTED\(8 downto 0),
      REGCEAREGCE => \<const0>\,
      REGCEB => \<const0>\,
      RSTRAMARSTRAM => \<const0>\,
      RSTRAMB => \<const0>\,
      RSTREGARSTREG => \<const0>\,
      RSTREGB => \<const0>\,
      SBITERR => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SDP.WIDE_PRIM36.ram_SBITERR_UNCONNECTED\,
      WEA(3) => \<const0>\,
      WEA(2) => \<const0>\,
      WEA(1) => \<const0>\,
      WEA(0) => \<const0>\,
      WEBWE(7) => \<const1>\,
      WEBWE(6) => \<const1>\,
      WEBWE(5) => \<const1>\,
      WEBWE(4) => \<const1>\,
      WEBWE(3) => \<const1>\,
      WEBWE(2) => \<const1>\,
      WEBWE(1) => \<const1>\,
      WEBWE(0) => \<const1>\
    );
GND: unisim.vcomponents.GND
    port map (
      G => \<const0>\
    );
VCC: unisim.vcomponents.VCC
    port map (
      P => \<const1>\
    );
end STRUCTURE;
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity blk_mem_gen_0blk_mem_gen_prim_width is
  port (
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    enb : in STD_LOGIC;
    clkb : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    clka : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );
end blk_mem_gen_0blk_mem_gen_prim_width;

architecture STRUCTURE of blk_mem_gen_0blk_mem_gen_prim_width is
begin
\prim_init.ram\: entity work.blk_mem_gen_0blk_mem_gen_prim_wrapper_init
    port map (
      addra(8 downto 0) => addra(8 downto 0),
      addrb(8 downto 0) => addrb(8 downto 0),
      clka => clka,
      clkb => clkb,
      dina(63 downto 0) => dina(63 downto 0),
      doutb(63 downto 0) => doutb(63 downto 0),
      enb => enb,
      wea(0) => wea(0)
    );
end STRUCTURE;
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity blk_mem_gen_0blk_mem_gen_generic_cstr is
  port (
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    enb : in STD_LOGIC;
    clkb : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    clka : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );
end blk_mem_gen_0blk_mem_gen_generic_cstr;

architecture STRUCTURE of blk_mem_gen_0blk_mem_gen_generic_cstr is
begin
\ramloop[0].ram.r\: entity work.blk_mem_gen_0blk_mem_gen_prim_width
    port map (
      addra(8 downto 0) => addra(8 downto 0),
      addrb(8 downto 0) => addrb(8 downto 0),
      clka => clka,
      clkb => clkb,
      dina(63 downto 0) => dina(63 downto 0),
      doutb(63 downto 0) => doutb(63 downto 0),
      enb => enb,
      wea(0) => wea(0)
    );
end STRUCTURE;
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity blk_mem_gen_0blk_mem_gen_top is
  port (
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    enb : in STD_LOGIC;
    clkb : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    clka : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );
end blk_mem_gen_0blk_mem_gen_top;

architecture STRUCTURE of blk_mem_gen_0blk_mem_gen_top is
begin
\valid.cstr\: entity work.blk_mem_gen_0blk_mem_gen_generic_cstr
    port map (
      addra(8 downto 0) => addra(8 downto 0),
      addrb(8 downto 0) => addrb(8 downto 0),
      clka => clka,
      clkb => clkb,
      dina(63 downto 0) => dina(63 downto 0),
      doutb(63 downto 0) => doutb(63 downto 0),
      enb => enb,
      wea(0) => wea(0)
    );
end STRUCTURE;
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity blk_mem_gen_0blk_mem_gen_v8_1_synth is
  port (
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    enb : in STD_LOGIC;
    clkb : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    clka : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );
end blk_mem_gen_0blk_mem_gen_v8_1_synth;

architecture STRUCTURE of blk_mem_gen_0blk_mem_gen_v8_1_synth is
begin
\gnativebmg.native_blk_mem_gen\: entity work.blk_mem_gen_0blk_mem_gen_top
    port map (
      addra(8 downto 0) => addra(8 downto 0),
      addrb(8 downto 0) => addrb(8 downto 0),
      clka => clka,
      clkb => clkb,
      dina(63 downto 0) => dina(63 downto 0),
      doutb(63 downto 0) => doutb(63 downto 0),
      enb => enb,
      wea(0) => wea(0)
    );
end STRUCTURE;
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    regcea : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 63 downto 0 );
    clkb : in STD_LOGIC;
    rstb : in STD_LOGIC;
    enb : in STD_LOGIC;
    regceb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 63 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    injectsbiterr : in STD_LOGIC;
    injectdbiterr : in STD_LOGIC;
    sbiterr : out STD_LOGIC;
    dbiterr : out STD_LOGIC;
    rdaddrecc : out STD_LOGIC_VECTOR ( 8 downto 0 );
    s_aclk : in STD_LOGIC;
    s_aresetn : in STD_LOGIC;
    s_axi_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    s_axi_injectsbiterr : in STD_LOGIC;
    s_axi_injectdbiterr : in STD_LOGIC;
    s_axi_sbiterr : out STD_LOGIC;
    s_axi_dbiterr : out STD_LOGIC;
    s_axi_rdaddrecc : out STD_LOGIC_VECTOR ( 8 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "blk_mem_gen_v8_1";
  attribute C_FAMILY : string;
  attribute C_FAMILY of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "zynq";
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "zynq";
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "./";
  attribute C_INTERFACE_TYPE : integer;
  attribute C_INTERFACE_TYPE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_AXI_TYPE : integer;
  attribute C_AXI_TYPE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_AXI_SLAVE_TYPE : integer;
  attribute C_AXI_SLAVE_TYPE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_USE_BRAM_BLOCK : integer;
  attribute C_USE_BRAM_BLOCK of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_ENABLE_32BIT_ADDRESS : integer;
  attribute C_ENABLE_32BIT_ADDRESS of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_CTRL_ECC_ALGO : string;
  attribute C_CTRL_ECC_ALGO of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "NONE";
  attribute C_HAS_AXI_ID : integer;
  attribute C_HAS_AXI_ID of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_AXI_ID_WIDTH : integer;
  attribute C_AXI_ID_WIDTH of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 4;
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_BYTE_SIZE : integer;
  attribute C_BYTE_SIZE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 9;
  attribute C_ALGORITHM : integer;
  attribute C_ALGORITHM of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_PRIM_TYPE : integer;
  attribute C_PRIM_TYPE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_LOAD_INIT_FILE : integer;
  attribute C_LOAD_INIT_FILE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_INIT_FILE_NAME : string;
  attribute C_INIT_FILE_NAME of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "blk_mem_gen_0.mif";
  attribute C_INIT_FILE : string;
  attribute C_INIT_FILE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "blk_mem_gen_0.mem";
  attribute C_USE_DEFAULT_DATA : integer;
  attribute C_USE_DEFAULT_DATA of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "0";
  attribute C_RST_TYPE : string;
  attribute C_RST_TYPE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "SYNC";
  attribute C_HAS_RSTA : integer;
  attribute C_HAS_RSTA of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_RST_PRIORITY_A : string;
  attribute C_RST_PRIORITY_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "CE";
  attribute C_RSTRAM_A : integer;
  attribute C_RSTRAM_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_INITA_VAL : string;
  attribute C_INITA_VAL of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "0";
  attribute C_HAS_ENA : integer;
  attribute C_HAS_ENA of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_REGCEA : integer;
  attribute C_HAS_REGCEA of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_USE_BYTE_WEA : integer;
  attribute C_USE_BYTE_WEA of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_WEA_WIDTH : integer;
  attribute C_WEA_WIDTH of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_WRITE_MODE_A : string;
  attribute C_WRITE_MODE_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "WRITE_FIRST";
  attribute C_WRITE_WIDTH_A : integer;
  attribute C_WRITE_WIDTH_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 64;
  attribute C_READ_WIDTH_A : integer;
  attribute C_READ_WIDTH_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 64;
  attribute C_WRITE_DEPTH_A : integer;
  attribute C_WRITE_DEPTH_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 512;
  attribute C_READ_DEPTH_A : integer;
  attribute C_READ_DEPTH_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 512;
  attribute C_ADDRA_WIDTH : integer;
  attribute C_ADDRA_WIDTH of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 9;
  attribute C_HAS_RSTB : integer;
  attribute C_HAS_RSTB of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_RST_PRIORITY_B : string;
  attribute C_RST_PRIORITY_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "CE";
  attribute C_RSTRAM_B : integer;
  attribute C_RSTRAM_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_INITB_VAL : string;
  attribute C_INITB_VAL of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "0";
  attribute C_HAS_ENB : integer;
  attribute C_HAS_ENB of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_HAS_REGCEB : integer;
  attribute C_HAS_REGCEB of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_USE_BYTE_WEB : integer;
  attribute C_USE_BYTE_WEB of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_WEB_WIDTH : integer;
  attribute C_WEB_WIDTH of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 1;
  attribute C_WRITE_MODE_B : string;
  attribute C_WRITE_MODE_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "WRITE_FIRST";
  attribute C_WRITE_WIDTH_B : integer;
  attribute C_WRITE_WIDTH_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 64;
  attribute C_READ_WIDTH_B : integer;
  attribute C_READ_WIDTH_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 64;
  attribute C_WRITE_DEPTH_B : integer;
  attribute C_WRITE_DEPTH_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 512;
  attribute C_READ_DEPTH_B : integer;
  attribute C_READ_DEPTH_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 512;
  attribute C_ADDRB_WIDTH : integer;
  attribute C_ADDRB_WIDTH of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 9;
  attribute C_HAS_MEM_OUTPUT_REGS_A : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_MEM_OUTPUT_REGS_B : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_A : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_B : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_MUX_PIPELINE_STAGES : integer;
  attribute C_MUX_PIPELINE_STAGES of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_SOFTECC_INPUT_REGS_A : integer;
  attribute C_HAS_SOFTECC_INPUT_REGS_A of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B : integer;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_USE_SOFTECC : integer;
  attribute C_USE_SOFTECC of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_USE_ECC : integer;
  attribute C_USE_ECC of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_HAS_INJECTERR : integer;
  attribute C_HAS_INJECTERR of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_SIM_COLLISION_CHECK : string;
  attribute C_SIM_COLLISION_CHECK of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "ALL";
  attribute C_COMMON_CLK : integer;
  attribute C_COMMON_CLK of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_DISABLE_WARN_BHV_COLL : integer;
  attribute C_DISABLE_WARN_BHV_COLL of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute C_DISABLE_WARN_BHV_RANGE : integer;
  attribute C_DISABLE_WARN_BHV_RANGE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is 0;
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ : entity is "yes";
end \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\;

architecture STRUCTURE of \blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\ is
  signal \<const0>\ : STD_LOGIC;
begin
  dbiterr <= \<const0>\;
  douta(63) <= \<const0>\;
  douta(62) <= \<const0>\;
  douta(61) <= \<const0>\;
  douta(60) <= \<const0>\;
  douta(59) <= \<const0>\;
  douta(58) <= \<const0>\;
  douta(57) <= \<const0>\;
  douta(56) <= \<const0>\;
  douta(55) <= \<const0>\;
  douta(54) <= \<const0>\;
  douta(53) <= \<const0>\;
  douta(52) <= \<const0>\;
  douta(51) <= \<const0>\;
  douta(50) <= \<const0>\;
  douta(49) <= \<const0>\;
  douta(48) <= \<const0>\;
  douta(47) <= \<const0>\;
  douta(46) <= \<const0>\;
  douta(45) <= \<const0>\;
  douta(44) <= \<const0>\;
  douta(43) <= \<const0>\;
  douta(42) <= \<const0>\;
  douta(41) <= \<const0>\;
  douta(40) <= \<const0>\;
  douta(39) <= \<const0>\;
  douta(38) <= \<const0>\;
  douta(37) <= \<const0>\;
  douta(36) <= \<const0>\;
  douta(35) <= \<const0>\;
  douta(34) <= \<const0>\;
  douta(33) <= \<const0>\;
  douta(32) <= \<const0>\;
  douta(31) <= \<const0>\;
  douta(30) <= \<const0>\;
  douta(29) <= \<const0>\;
  douta(28) <= \<const0>\;
  douta(27) <= \<const0>\;
  douta(26) <= \<const0>\;
  douta(25) <= \<const0>\;
  douta(24) <= \<const0>\;
  douta(23) <= \<const0>\;
  douta(22) <= \<const0>\;
  douta(21) <= \<const0>\;
  douta(20) <= \<const0>\;
  douta(19) <= \<const0>\;
  douta(18) <= \<const0>\;
  douta(17) <= \<const0>\;
  douta(16) <= \<const0>\;
  douta(15) <= \<const0>\;
  douta(14) <= \<const0>\;
  douta(13) <= \<const0>\;
  douta(12) <= \<const0>\;
  douta(11) <= \<const0>\;
  douta(10) <= \<const0>\;
  douta(9) <= \<const0>\;
  douta(8) <= \<const0>\;
  douta(7) <= \<const0>\;
  douta(6) <= \<const0>\;
  douta(5) <= \<const0>\;
  douta(4) <= \<const0>\;
  douta(3) <= \<const0>\;
  douta(2) <= \<const0>\;
  douta(1) <= \<const0>\;
  douta(0) <= \<const0>\;
  rdaddrecc(8) <= \<const0>\;
  rdaddrecc(7) <= \<const0>\;
  rdaddrecc(6) <= \<const0>\;
  rdaddrecc(5) <= \<const0>\;
  rdaddrecc(4) <= \<const0>\;
  rdaddrecc(3) <= \<const0>\;
  rdaddrecc(2) <= \<const0>\;
  rdaddrecc(1) <= \<const0>\;
  rdaddrecc(0) <= \<const0>\;
  s_axi_arready <= \<const0>\;
  s_axi_awready <= \<const0>\;
  s_axi_bid(3) <= \<const0>\;
  s_axi_bid(2) <= \<const0>\;
  s_axi_bid(1) <= \<const0>\;
  s_axi_bid(0) <= \<const0>\;
  s_axi_bresp(1) <= \<const0>\;
  s_axi_bresp(0) <= \<const0>\;
  s_axi_bvalid <= \<const0>\;
  s_axi_dbiterr <= \<const0>\;
  s_axi_rdaddrecc(8) <= \<const0>\;
  s_axi_rdaddrecc(7) <= \<const0>\;
  s_axi_rdaddrecc(6) <= \<const0>\;
  s_axi_rdaddrecc(5) <= \<const0>\;
  s_axi_rdaddrecc(4) <= \<const0>\;
  s_axi_rdaddrecc(3) <= \<const0>\;
  s_axi_rdaddrecc(2) <= \<const0>\;
  s_axi_rdaddrecc(1) <= \<const0>\;
  s_axi_rdaddrecc(0) <= \<const0>\;
  s_axi_rdata(63) <= \<const0>\;
  s_axi_rdata(62) <= \<const0>\;
  s_axi_rdata(61) <= \<const0>\;
  s_axi_rdata(60) <= \<const0>\;
  s_axi_rdata(59) <= \<const0>\;
  s_axi_rdata(58) <= \<const0>\;
  s_axi_rdata(57) <= \<const0>\;
  s_axi_rdata(56) <= \<const0>\;
  s_axi_rdata(55) <= \<const0>\;
  s_axi_rdata(54) <= \<const0>\;
  s_axi_rdata(53) <= \<const0>\;
  s_axi_rdata(52) <= \<const0>\;
  s_axi_rdata(51) <= \<const0>\;
  s_axi_rdata(50) <= \<const0>\;
  s_axi_rdata(49) <= \<const0>\;
  s_axi_rdata(48) <= \<const0>\;
  s_axi_rdata(47) <= \<const0>\;
  s_axi_rdata(46) <= \<const0>\;
  s_axi_rdata(45) <= \<const0>\;
  s_axi_rdata(44) <= \<const0>\;
  s_axi_rdata(43) <= \<const0>\;
  s_axi_rdata(42) <= \<const0>\;
  s_axi_rdata(41) <= \<const0>\;
  s_axi_rdata(40) <= \<const0>\;
  s_axi_rdata(39) <= \<const0>\;
  s_axi_rdata(38) <= \<const0>\;
  s_axi_rdata(37) <= \<const0>\;
  s_axi_rdata(36) <= \<const0>\;
  s_axi_rdata(35) <= \<const0>\;
  s_axi_rdata(34) <= \<const0>\;
  s_axi_rdata(33) <= \<const0>\;
  s_axi_rdata(32) <= \<const0>\;
  s_axi_rdata(31) <= \<const0>\;
  s_axi_rdata(30) <= \<const0>\;
  s_axi_rdata(29) <= \<const0>\;
  s_axi_rdata(28) <= \<const0>\;
  s_axi_rdata(27) <= \<const0>\;
  s_axi_rdata(26) <= \<const0>\;
  s_axi_rdata(25) <= \<const0>\;
  s_axi_rdata(24) <= \<const0>\;
  s_axi_rdata(23) <= \<const0>\;
  s_axi_rdata(22) <= \<const0>\;
  s_axi_rdata(21) <= \<const0>\;
  s_axi_rdata(20) <= \<const0>\;
  s_axi_rdata(19) <= \<const0>\;
  s_axi_rdata(18) <= \<const0>\;
  s_axi_rdata(17) <= \<const0>\;
  s_axi_rdata(16) <= \<const0>\;
  s_axi_rdata(15) <= \<const0>\;
  s_axi_rdata(14) <= \<const0>\;
  s_axi_rdata(13) <= \<const0>\;
  s_axi_rdata(12) <= \<const0>\;
  s_axi_rdata(11) <= \<const0>\;
  s_axi_rdata(10) <= \<const0>\;
  s_axi_rdata(9) <= \<const0>\;
  s_axi_rdata(8) <= \<const0>\;
  s_axi_rdata(7) <= \<const0>\;
  s_axi_rdata(6) <= \<const0>\;
  s_axi_rdata(5) <= \<const0>\;
  s_axi_rdata(4) <= \<const0>\;
  s_axi_rdata(3) <= \<const0>\;
  s_axi_rdata(2) <= \<const0>\;
  s_axi_rdata(1) <= \<const0>\;
  s_axi_rdata(0) <= \<const0>\;
  s_axi_rid(3) <= \<const0>\;
  s_axi_rid(2) <= \<const0>\;
  s_axi_rid(1) <= \<const0>\;
  s_axi_rid(0) <= \<const0>\;
  s_axi_rlast <= \<const0>\;
  s_axi_rresp(1) <= \<const0>\;
  s_axi_rresp(0) <= \<const0>\;
  s_axi_rvalid <= \<const0>\;
  s_axi_sbiterr <= \<const0>\;
  s_axi_wready <= \<const0>\;
  sbiterr <= \<const0>\;
GND: unisim.vcomponents.GND
    port map (
      G => \<const0>\
    );
inst_blk_mem_gen: entity work.blk_mem_gen_0blk_mem_gen_v8_1_synth
    port map (
      addra(8 downto 0) => addra(8 downto 0),
      addrb(8 downto 0) => addrb(8 downto 0),
      clka => clka,
      clkb => clkb,
      dina(63 downto 0) => dina(63 downto 0),
      doutb(63 downto 0) => doutb(63 downto 0),
      enb => enb,
      wea(0) => wea(0)
    );
end STRUCTURE;
library IEEE; use IEEE.STD_LOGIC_1164.ALL;
library UNISIM; use UNISIM.VCOMPONENTS.ALL; 
entity blk_mem_gen_0 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of blk_mem_gen_0 : entity is true;
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of blk_mem_gen_0 : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of blk_mem_gen_0 : entity is "blk_mem_gen_v8_1,Vivado 2013.4";
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of blk_mem_gen_0 : entity is "blk_mem_gen_0,blk_mem_gen_v8_1,{}";
  attribute core_generation_info : string;
  attribute core_generation_info of blk_mem_gen_0 : entity is "blk_mem_gen_0,blk_mem_gen_v8_1,{x_ipProduct=Vivado 2013.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=blk_mem_gen,x_ipVersion=8.1,x_ipCoreRevision=0,x_ipLanguage=VHDL,C_FAMILY=zynq,C_XDEVICEFAMILY=zynq,C_ELABORATION_DIR=./,C_INTERFACE_TYPE=0,C_AXI_TYPE=1,C_AXI_SLAVE_TYPE=0,C_HAS_AXI_ID=0,C_AXI_ID_WIDTH=4,C_MEM_TYPE=1,C_BYTE_SIZE=9,C_ALGORITHM=1,C_PRIM_TYPE=1,C_LOAD_INIT_FILE=1,C_INIT_FILE_NAME=blk_mem_gen_0.mif,C_INIT_FILE=blk_mem_gen_0.mem,C_USE_DEFAULT_DATA=0,C_DEFAULT_DATA=0,C_RST_TYPE=SYNC,C_HAS_RSTA=0,C_RST_PRIORITY_A=CE,C_RSTRAM_A=0,C_INITA_VAL=0,C_HAS_ENA=0,C_HAS_REGCEA=0,C_USE_BYTE_WEA=0,C_WEA_WIDTH=1,C_WRITE_MODE_A=WRITE_FIRST,C_WRITE_WIDTH_A=64,C_READ_WIDTH_A=64,C_WRITE_DEPTH_A=512,C_READ_DEPTH_A=512,C_ADDRA_WIDTH=9,C_HAS_RSTB=0,C_RST_PRIORITY_B=CE,C_RSTRAM_B=0,C_INITB_VAL=0,C_HAS_ENB=1,C_HAS_REGCEB=0,C_USE_BYTE_WEB=0,C_WEB_WIDTH=1,C_WRITE_MODE_B=WRITE_FIRST,C_WRITE_WIDTH_B=64,C_READ_WIDTH_B=64,C_WRITE_DEPTH_B=512,C_READ_DEPTH_B=512,C_ADDRB_WIDTH=9,C_HAS_MEM_OUTPUT_REGS_A=0,C_HAS_MEM_OUTPUT_REGS_B=0,C_HAS_MUX_OUTPUT_REGS_A=0,C_HAS_MUX_OUTPUT_REGS_B=0,C_MUX_PIPELINE_STAGES=0,C_HAS_SOFTECC_INPUT_REGS_A=0,C_HAS_SOFTECC_OUTPUT_REGS_B=0,C_USE_SOFTECC=0,C_USE_ECC=0,C_HAS_INJECTERR=0,C_SIM_COLLISION_CHECK=ALL,C_COMMON_CLK=0,C_ENABLE_32BIT_ADDRESS=0,C_DISABLE_WARN_BHV_COLL=0,C_DISABLE_WARN_BHV_RANGE=0,C_USE_BRAM_BLOCK=0,C_CTRL_ECC_ALGO=NONE}";
end blk_mem_gen_0;

architecture STRUCTURE of blk_mem_gen_0 is
  signal \<const0>\ : STD_LOGIC;
  signal NLW_U0_dbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_dbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_sbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_sbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_douta_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_U0_rdaddrecc_UNCONNECTED : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_U0_s_axi_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_U0_s_axi_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_U0_s_axi_rdaddrecc_UNCONNECTED : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_U0_s_axi_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_U0_s_axi_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_U0_s_axi_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute C_ADDRA_WIDTH : integer;
  attribute C_ADDRA_WIDTH of U0 : label is 9;
  attribute C_ADDRB_WIDTH : integer;
  attribute C_ADDRB_WIDTH of U0 : label is 9;
  attribute C_ALGORITHM : integer;
  attribute C_ALGORITHM of U0 : label is 1;
  attribute C_AXI_ID_WIDTH : integer;
  attribute C_AXI_ID_WIDTH of U0 : label is 4;
  attribute C_AXI_SLAVE_TYPE : integer;
  attribute C_AXI_SLAVE_TYPE of U0 : label is 0;
  attribute C_AXI_TYPE : integer;
  attribute C_AXI_TYPE of U0 : label is 1;
  attribute C_BYTE_SIZE : integer;
  attribute C_BYTE_SIZE of U0 : label is 9;
  attribute C_COMMON_CLK : integer;
  attribute C_COMMON_CLK of U0 : label is 0;
  attribute C_CTRL_ECC_ALGO : string;
  attribute C_CTRL_ECC_ALGO of U0 : label is "NONE";
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of U0 : label is "0";
  attribute C_DISABLE_WARN_BHV_COLL : integer;
  attribute C_DISABLE_WARN_BHV_COLL of U0 : label is 0;
  attribute C_DISABLE_WARN_BHV_RANGE : integer;
  attribute C_DISABLE_WARN_BHV_RANGE of U0 : label is 0;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of U0 : label is "./";
  attribute C_ENABLE_32BIT_ADDRESS : integer;
  attribute C_ENABLE_32BIT_ADDRESS of U0 : label is 0;
  attribute C_FAMILY : string;
  attribute C_FAMILY of U0 : label is "zynq";
  attribute C_HAS_AXI_ID : integer;
  attribute C_HAS_AXI_ID of U0 : label is 0;
  attribute C_HAS_ENA : integer;
  attribute C_HAS_ENA of U0 : label is 0;
  attribute C_HAS_ENB : integer;
  attribute C_HAS_ENB of U0 : label is 1;
  attribute C_HAS_INJECTERR : integer;
  attribute C_HAS_INJECTERR of U0 : label is 0;
  attribute C_HAS_MEM_OUTPUT_REGS_A : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_A of U0 : label is 0;
  attribute C_HAS_MEM_OUTPUT_REGS_B : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_B of U0 : label is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_A : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_A of U0 : label is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_B : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_B of U0 : label is 0;
  attribute C_HAS_REGCEA : integer;
  attribute C_HAS_REGCEA of U0 : label is 0;
  attribute C_HAS_REGCEB : integer;
  attribute C_HAS_REGCEB of U0 : label is 0;
  attribute C_HAS_RSTA : integer;
  attribute C_HAS_RSTA of U0 : label is 0;
  attribute C_HAS_RSTB : integer;
  attribute C_HAS_RSTB of U0 : label is 0;
  attribute C_HAS_SOFTECC_INPUT_REGS_A : integer;
  attribute C_HAS_SOFTECC_INPUT_REGS_A of U0 : label is 0;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B : integer;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B of U0 : label is 0;
  attribute C_INITA_VAL : string;
  attribute C_INITA_VAL of U0 : label is "0";
  attribute C_INITB_VAL : string;
  attribute C_INITB_VAL of U0 : label is "0";
  attribute C_INIT_FILE : string;
  attribute C_INIT_FILE of U0 : label is "blk_mem_gen_0.mem";
  attribute C_INIT_FILE_NAME : string;
  attribute C_INIT_FILE_NAME of U0 : label is "blk_mem_gen_0.mif";
  attribute C_INTERFACE_TYPE : integer;
  attribute C_INTERFACE_TYPE of U0 : label is 0;
  attribute C_LOAD_INIT_FILE : integer;
  attribute C_LOAD_INIT_FILE of U0 : label is 1;
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of U0 : label is 1;
  attribute C_MUX_PIPELINE_STAGES : integer;
  attribute C_MUX_PIPELINE_STAGES of U0 : label is 0;
  attribute C_PRIM_TYPE : integer;
  attribute C_PRIM_TYPE of U0 : label is 1;
  attribute C_READ_DEPTH_A : integer;
  attribute C_READ_DEPTH_A of U0 : label is 512;
  attribute C_READ_DEPTH_B : integer;
  attribute C_READ_DEPTH_B of U0 : label is 512;
  attribute C_READ_WIDTH_A : integer;
  attribute C_READ_WIDTH_A of U0 : label is 64;
  attribute C_READ_WIDTH_B : integer;
  attribute C_READ_WIDTH_B of U0 : label is 64;
  attribute C_RSTRAM_A : integer;
  attribute C_RSTRAM_A of U0 : label is 0;
  attribute C_RSTRAM_B : integer;
  attribute C_RSTRAM_B of U0 : label is 0;
  attribute C_RST_PRIORITY_A : string;
  attribute C_RST_PRIORITY_A of U0 : label is "CE";
  attribute C_RST_PRIORITY_B : string;
  attribute C_RST_PRIORITY_B of U0 : label is "CE";
  attribute C_RST_TYPE : string;
  attribute C_RST_TYPE of U0 : label is "SYNC";
  attribute C_SIM_COLLISION_CHECK : string;
  attribute C_SIM_COLLISION_CHECK of U0 : label is "ALL";
  attribute C_USE_BRAM_BLOCK : integer;
  attribute C_USE_BRAM_BLOCK of U0 : label is 0;
  attribute C_USE_BYTE_WEA : integer;
  attribute C_USE_BYTE_WEA of U0 : label is 0;
  attribute C_USE_BYTE_WEB : integer;
  attribute C_USE_BYTE_WEB of U0 : label is 0;
  attribute C_USE_DEFAULT_DATA : integer;
  attribute C_USE_DEFAULT_DATA of U0 : label is 0;
  attribute C_USE_ECC : integer;
  attribute C_USE_ECC of U0 : label is 0;
  attribute C_USE_SOFTECC : integer;
  attribute C_USE_SOFTECC of U0 : label is 0;
  attribute C_WEA_WIDTH : integer;
  attribute C_WEA_WIDTH of U0 : label is 1;
  attribute C_WEB_WIDTH : integer;
  attribute C_WEB_WIDTH of U0 : label is 1;
  attribute C_WRITE_DEPTH_A : integer;
  attribute C_WRITE_DEPTH_A of U0 : label is 512;
  attribute C_WRITE_DEPTH_B : integer;
  attribute C_WRITE_DEPTH_B of U0 : label is 512;
  attribute C_WRITE_MODE_A : string;
  attribute C_WRITE_MODE_A of U0 : label is "WRITE_FIRST";
  attribute C_WRITE_MODE_B : string;
  attribute C_WRITE_MODE_B of U0 : label is "WRITE_FIRST";
  attribute C_WRITE_WIDTH_A : integer;
  attribute C_WRITE_WIDTH_A of U0 : label is 64;
  attribute C_WRITE_WIDTH_B : integer;
  attribute C_WRITE_WIDTH_B of U0 : label is 64;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of U0 : label is "zynq";
  attribute DONT_TOUCH : boolean;
  attribute DONT_TOUCH of U0 : label is true;
  attribute downgradeipidentifiedwarnings of U0 : label is "yes";
begin
GND: unisim.vcomponents.GND
    port map (
      G => \<const0>\
    );
U0: entity work.\blk_mem_gen_0blk_mem_gen_v8_1__parameterized0\
    port map (
      addra(8 downto 0) => addra(8 downto 0),
      addrb(8 downto 0) => addrb(8 downto 0),
      clka => clka,
      clkb => clkb,
      dbiterr => NLW_U0_dbiterr_UNCONNECTED,
      dina(63 downto 0) => dina(63 downto 0),
      dinb(63) => \<const0>\,
      dinb(62) => \<const0>\,
      dinb(61) => \<const0>\,
      dinb(60) => \<const0>\,
      dinb(59) => \<const0>\,
      dinb(58) => \<const0>\,
      dinb(57) => \<const0>\,
      dinb(56) => \<const0>\,
      dinb(55) => \<const0>\,
      dinb(54) => \<const0>\,
      dinb(53) => \<const0>\,
      dinb(52) => \<const0>\,
      dinb(51) => \<const0>\,
      dinb(50) => \<const0>\,
      dinb(49) => \<const0>\,
      dinb(48) => \<const0>\,
      dinb(47) => \<const0>\,
      dinb(46) => \<const0>\,
      dinb(45) => \<const0>\,
      dinb(44) => \<const0>\,
      dinb(43) => \<const0>\,
      dinb(42) => \<const0>\,
      dinb(41) => \<const0>\,
      dinb(40) => \<const0>\,
      dinb(39) => \<const0>\,
      dinb(38) => \<const0>\,
      dinb(37) => \<const0>\,
      dinb(36) => \<const0>\,
      dinb(35) => \<const0>\,
      dinb(34) => \<const0>\,
      dinb(33) => \<const0>\,
      dinb(32) => \<const0>\,
      dinb(31) => \<const0>\,
      dinb(30) => \<const0>\,
      dinb(29) => \<const0>\,
      dinb(28) => \<const0>\,
      dinb(27) => \<const0>\,
      dinb(26) => \<const0>\,
      dinb(25) => \<const0>\,
      dinb(24) => \<const0>\,
      dinb(23) => \<const0>\,
      dinb(22) => \<const0>\,
      dinb(21) => \<const0>\,
      dinb(20) => \<const0>\,
      dinb(19) => \<const0>\,
      dinb(18) => \<const0>\,
      dinb(17) => \<const0>\,
      dinb(16) => \<const0>\,
      dinb(15) => \<const0>\,
      dinb(14) => \<const0>\,
      dinb(13) => \<const0>\,
      dinb(12) => \<const0>\,
      dinb(11) => \<const0>\,
      dinb(10) => \<const0>\,
      dinb(9) => \<const0>\,
      dinb(8) => \<const0>\,
      dinb(7) => \<const0>\,
      dinb(6) => \<const0>\,
      dinb(5) => \<const0>\,
      dinb(4) => \<const0>\,
      dinb(3) => \<const0>\,
      dinb(2) => \<const0>\,
      dinb(1) => \<const0>\,
      dinb(0) => \<const0>\,
      douta(63 downto 0) => NLW_U0_douta_UNCONNECTED(63 downto 0),
      doutb(63 downto 0) => doutb(63 downto 0),
      ena => \<const0>\,
      enb => enb,
      injectdbiterr => \<const0>\,
      injectsbiterr => \<const0>\,
      rdaddrecc(8 downto 0) => NLW_U0_rdaddrecc_UNCONNECTED(8 downto 0),
      regcea => \<const0>\,
      regceb => \<const0>\,
      rsta => \<const0>\,
      rstb => \<const0>\,
      s_aclk => \<const0>\,
      s_aresetn => \<const0>\,
      s_axi_araddr(31) => \<const0>\,
      s_axi_araddr(30) => \<const0>\,
      s_axi_araddr(29) => \<const0>\,
      s_axi_araddr(28) => \<const0>\,
      s_axi_araddr(27) => \<const0>\,
      s_axi_araddr(26) => \<const0>\,
      s_axi_araddr(25) => \<const0>\,
      s_axi_araddr(24) => \<const0>\,
      s_axi_araddr(23) => \<const0>\,
      s_axi_araddr(22) => \<const0>\,
      s_axi_araddr(21) => \<const0>\,
      s_axi_araddr(20) => \<const0>\,
      s_axi_araddr(19) => \<const0>\,
      s_axi_araddr(18) => \<const0>\,
      s_axi_araddr(17) => \<const0>\,
      s_axi_araddr(16) => \<const0>\,
      s_axi_araddr(15) => \<const0>\,
      s_axi_araddr(14) => \<const0>\,
      s_axi_araddr(13) => \<const0>\,
      s_axi_araddr(12) => \<const0>\,
      s_axi_araddr(11) => \<const0>\,
      s_axi_araddr(10) => \<const0>\,
      s_axi_araddr(9) => \<const0>\,
      s_axi_araddr(8) => \<const0>\,
      s_axi_araddr(7) => \<const0>\,
      s_axi_araddr(6) => \<const0>\,
      s_axi_araddr(5) => \<const0>\,
      s_axi_araddr(4) => \<const0>\,
      s_axi_araddr(3) => \<const0>\,
      s_axi_araddr(2) => \<const0>\,
      s_axi_araddr(1) => \<const0>\,
      s_axi_araddr(0) => \<const0>\,
      s_axi_arburst(1) => \<const0>\,
      s_axi_arburst(0) => \<const0>\,
      s_axi_arid(3) => \<const0>\,
      s_axi_arid(2) => \<const0>\,
      s_axi_arid(1) => \<const0>\,
      s_axi_arid(0) => \<const0>\,
      s_axi_arlen(7) => \<const0>\,
      s_axi_arlen(6) => \<const0>\,
      s_axi_arlen(5) => \<const0>\,
      s_axi_arlen(4) => \<const0>\,
      s_axi_arlen(3) => \<const0>\,
      s_axi_arlen(2) => \<const0>\,
      s_axi_arlen(1) => \<const0>\,
      s_axi_arlen(0) => \<const0>\,
      s_axi_arready => NLW_U0_s_axi_arready_UNCONNECTED,
      s_axi_arsize(2) => \<const0>\,
      s_axi_arsize(1) => \<const0>\,
      s_axi_arsize(0) => \<const0>\,
      s_axi_arvalid => \<const0>\,
      s_axi_awaddr(31) => \<const0>\,
      s_axi_awaddr(30) => \<const0>\,
      s_axi_awaddr(29) => \<const0>\,
      s_axi_awaddr(28) => \<const0>\,
      s_axi_awaddr(27) => \<const0>\,
      s_axi_awaddr(26) => \<const0>\,
      s_axi_awaddr(25) => \<const0>\,
      s_axi_awaddr(24) => \<const0>\,
      s_axi_awaddr(23) => \<const0>\,
      s_axi_awaddr(22) => \<const0>\,
      s_axi_awaddr(21) => \<const0>\,
      s_axi_awaddr(20) => \<const0>\,
      s_axi_awaddr(19) => \<const0>\,
      s_axi_awaddr(18) => \<const0>\,
      s_axi_awaddr(17) => \<const0>\,
      s_axi_awaddr(16) => \<const0>\,
      s_axi_awaddr(15) => \<const0>\,
      s_axi_awaddr(14) => \<const0>\,
      s_axi_awaddr(13) => \<const0>\,
      s_axi_awaddr(12) => \<const0>\,
      s_axi_awaddr(11) => \<const0>\,
      s_axi_awaddr(10) => \<const0>\,
      s_axi_awaddr(9) => \<const0>\,
      s_axi_awaddr(8) => \<const0>\,
      s_axi_awaddr(7) => \<const0>\,
      s_axi_awaddr(6) => \<const0>\,
      s_axi_awaddr(5) => \<const0>\,
      s_axi_awaddr(4) => \<const0>\,
      s_axi_awaddr(3) => \<const0>\,
      s_axi_awaddr(2) => \<const0>\,
      s_axi_awaddr(1) => \<const0>\,
      s_axi_awaddr(0) => \<const0>\,
      s_axi_awburst(1) => \<const0>\,
      s_axi_awburst(0) => \<const0>\,
      s_axi_awid(3) => \<const0>\,
      s_axi_awid(2) => \<const0>\,
      s_axi_awid(1) => \<const0>\,
      s_axi_awid(0) => \<const0>\,
      s_axi_awlen(7) => \<const0>\,
      s_axi_awlen(6) => \<const0>\,
      s_axi_awlen(5) => \<const0>\,
      s_axi_awlen(4) => \<const0>\,
      s_axi_awlen(3) => \<const0>\,
      s_axi_awlen(2) => \<const0>\,
      s_axi_awlen(1) => \<const0>\,
      s_axi_awlen(0) => \<const0>\,
      s_axi_awready => NLW_U0_s_axi_awready_UNCONNECTED,
      s_axi_awsize(2) => \<const0>\,
      s_axi_awsize(1) => \<const0>\,
      s_axi_awsize(0) => \<const0>\,
      s_axi_awvalid => \<const0>\,
      s_axi_bid(3 downto 0) => NLW_U0_s_axi_bid_UNCONNECTED(3 downto 0),
      s_axi_bready => \<const0>\,
      s_axi_bresp(1 downto 0) => NLW_U0_s_axi_bresp_UNCONNECTED(1 downto 0),
      s_axi_bvalid => NLW_U0_s_axi_bvalid_UNCONNECTED,
      s_axi_dbiterr => NLW_U0_s_axi_dbiterr_UNCONNECTED,
      s_axi_injectdbiterr => \<const0>\,
      s_axi_injectsbiterr => \<const0>\,
      s_axi_rdaddrecc(8 downto 0) => NLW_U0_s_axi_rdaddrecc_UNCONNECTED(8 downto 0),
      s_axi_rdata(63 downto 0) => NLW_U0_s_axi_rdata_UNCONNECTED(63 downto 0),
      s_axi_rid(3 downto 0) => NLW_U0_s_axi_rid_UNCONNECTED(3 downto 0),
      s_axi_rlast => NLW_U0_s_axi_rlast_UNCONNECTED,
      s_axi_rready => \<const0>\,
      s_axi_rresp(1 downto 0) => NLW_U0_s_axi_rresp_UNCONNECTED(1 downto 0),
      s_axi_rvalid => NLW_U0_s_axi_rvalid_UNCONNECTED,
      s_axi_sbiterr => NLW_U0_s_axi_sbiterr_UNCONNECTED,
      s_axi_wdata(63) => \<const0>\,
      s_axi_wdata(62) => \<const0>\,
      s_axi_wdata(61) => \<const0>\,
      s_axi_wdata(60) => \<const0>\,
      s_axi_wdata(59) => \<const0>\,
      s_axi_wdata(58) => \<const0>\,
      s_axi_wdata(57) => \<const0>\,
      s_axi_wdata(56) => \<const0>\,
      s_axi_wdata(55) => \<const0>\,
      s_axi_wdata(54) => \<const0>\,
      s_axi_wdata(53) => \<const0>\,
      s_axi_wdata(52) => \<const0>\,
      s_axi_wdata(51) => \<const0>\,
      s_axi_wdata(50) => \<const0>\,
      s_axi_wdata(49) => \<const0>\,
      s_axi_wdata(48) => \<const0>\,
      s_axi_wdata(47) => \<const0>\,
      s_axi_wdata(46) => \<const0>\,
      s_axi_wdata(45) => \<const0>\,
      s_axi_wdata(44) => \<const0>\,
      s_axi_wdata(43) => \<const0>\,
      s_axi_wdata(42) => \<const0>\,
      s_axi_wdata(41) => \<const0>\,
      s_axi_wdata(40) => \<const0>\,
      s_axi_wdata(39) => \<const0>\,
      s_axi_wdata(38) => \<const0>\,
      s_axi_wdata(37) => \<const0>\,
      s_axi_wdata(36) => \<const0>\,
      s_axi_wdata(35) => \<const0>\,
      s_axi_wdata(34) => \<const0>\,
      s_axi_wdata(33) => \<const0>\,
      s_axi_wdata(32) => \<const0>\,
      s_axi_wdata(31) => \<const0>\,
      s_axi_wdata(30) => \<const0>\,
      s_axi_wdata(29) => \<const0>\,
      s_axi_wdata(28) => \<const0>\,
      s_axi_wdata(27) => \<const0>\,
      s_axi_wdata(26) => \<const0>\,
      s_axi_wdata(25) => \<const0>\,
      s_axi_wdata(24) => \<const0>\,
      s_axi_wdata(23) => \<const0>\,
      s_axi_wdata(22) => \<const0>\,
      s_axi_wdata(21) => \<const0>\,
      s_axi_wdata(20) => \<const0>\,
      s_axi_wdata(19) => \<const0>\,
      s_axi_wdata(18) => \<const0>\,
      s_axi_wdata(17) => \<const0>\,
      s_axi_wdata(16) => \<const0>\,
      s_axi_wdata(15) => \<const0>\,
      s_axi_wdata(14) => \<const0>\,
      s_axi_wdata(13) => \<const0>\,
      s_axi_wdata(12) => \<const0>\,
      s_axi_wdata(11) => \<const0>\,
      s_axi_wdata(10) => \<const0>\,
      s_axi_wdata(9) => \<const0>\,
      s_axi_wdata(8) => \<const0>\,
      s_axi_wdata(7) => \<const0>\,
      s_axi_wdata(6) => \<const0>\,
      s_axi_wdata(5) => \<const0>\,
      s_axi_wdata(4) => \<const0>\,
      s_axi_wdata(3) => \<const0>\,
      s_axi_wdata(2) => \<const0>\,
      s_axi_wdata(1) => \<const0>\,
      s_axi_wdata(0) => \<const0>\,
      s_axi_wlast => \<const0>\,
      s_axi_wready => NLW_U0_s_axi_wready_UNCONNECTED,
      s_axi_wstrb(0) => \<const0>\,
      s_axi_wvalid => \<const0>\,
      sbiterr => NLW_U0_sbiterr_UNCONNECTED,
      wea(0) => wea(0),
      web(0) => \<const0>\
    );
end STRUCTURE;
