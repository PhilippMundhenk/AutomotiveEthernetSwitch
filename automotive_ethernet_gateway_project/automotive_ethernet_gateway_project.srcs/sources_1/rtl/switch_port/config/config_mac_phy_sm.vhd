--------------------------------------------------------------------------------
-- File       : tri_mode_ethernet_mac_0_axi_lite_sm.vhd
-- Author     : Xilinx Inc.
-- -----------------------------------------------------------------------------
-- (c) Copyright 2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 
-- -----------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Description:  This module is reponsible for bringing up both the MAC and the
-- attached PHY (if any) to enable basic packet transfer in both directions.
-- It is intended to be directly usable on a xilinx demo platform to demonstrate
-- simple bring up and data transfer.  The mac speed is set via inputs (which
-- can be connected to dip switches) and the PHY is configured to ONLY advertise
-- the specified speed.  To maximise compatibility on boards only IEEE registers
-- are used and the PHY address can be set via a parameter.
--
--------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;


entity config_mac_phy_sm is
   port (
      s_axi_aclk                       : in  std_logic;
      s_axi_resetn                     : in  std_logic;
      phy_interrupt_n                  : in std_logic;
      mac_interrupt                    : in std_logic;
      
      mac_speed                        : in  std_logic_vector(1 downto 0);
      update_speed                     : in  std_logic;
      serial_command                   : in  std_logic;
      serial_response                  : out std_logic;
      debug0_sig                        : out std_logic;
      debug1_sig                        : out std_logic;
      debug2_sig                        : out std_logic;
      debug3_sig                        : out std_logic;

      s_axi_awaddr                     : out std_logic_vector(11 downto 0) := (others => '0');
      s_axi_awvalid                    : out std_logic := '0';
      s_axi_awready                    : in  std_logic := '0';
      s_axi_wdata                      : out std_logic_vector(31 downto 0) := (others => '0');
      s_axi_wvalid                     : out std_logic := '0';
      s_axi_wready                     : in  std_logic := '0';
      s_axi_bresp                      : in  std_logic_vector(1 downto 0) := (others => '0');
      s_axi_bvalid                     : in  std_logic := '0';
      s_axi_bready                     : out std_logic := '0';
      s_axi_araddr                     : out std_logic_vector(11 downto 0) := (others => '0');
      s_axi_arvalid                    : out std_logic := '0';
      s_axi_arready                    : in  std_logic := '0';
      s_axi_rdata                      : in  std_logic_vector(31 downto 0) := (others => '0');
      s_axi_rresp                      : in  std_logic_vector(1 downto 0) := (others => '0');
      s_axi_rvalid                     : in  std_logic := '0';
      s_axi_rready                     : out std_logic := '0'
   );
end config_mac_phy_sm;

architecture rtl of config_mac_phy_sm is

  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

   component aeg_design_0_sync_block
   port (
      clk                        : in  std_logic;
      data_in                    : in  std_logic;
      data_out                   : out std_logic
   );
   end component;


   -- main state machine

   -- Encoded main state machine states.
   type state_typ is         (STARTUP,
                              -- CHANGE_SPEED, -- not necessary, check phy first
--                              MDIO_SET_INTERRUPT,
--                              MDIO_READ_INTERRUPT,
                              MDIO_RESTART, -- restart and autoneg
                              MDIO_STATS, -- polling for autoneg
                              MDIO_STATS_POLL_CHECK, -- polling for autoneg, replace with interrupt
                              MDIO_READ_INTERRUPT2,
                              MDIO_READ_SPEED,
                              MDIO_READ_SPEED_POLL,
                              MAC_UPDATE_SPEED100,
                              MAC_UPDATE_SPEED1000,
                              CHECK_SPEED); -- waiting for a speed update

   -- MDIO State machine
   type mdio_state_typ is    (IDLE,
                              SET_DATA,
                              INIT,
                              POLL);

   -- AXI State Machine
   type axi_state_typ is     (IDLE_A,
                              READ,
                              WRITE,
                              DONE);


   -- Management configuration register address     (0x500)
   constant CONFIG_MANAGEMENT_ADD  : std_logic_vector(16 downto 0) := "00000" & X"500";

   -- Receiver configuration register address       (0x4040)
   constant RECEIVER_ADD           : std_logic_vector(16 downto 0) := "00000" & X"404";

   -- Transmitter configuration register address    (0x4080)
   constant TRANSMITTER_ADD        : std_logic_vector(16 downto 0) :="00000" &  X"408";

   -- Speed configuration register address    (0x410)
   constant SPEED_CONFIG_ADD       : std_logic_vector(16 downto 0) :="00000" &  X"410";
   
   -- MDIO registers
   constant MDIO_CONTROL           : std_logic_vector(16 downto 0) := "00000" & X"504";
   constant MDIO_TX_DATA           : std_logic_vector(16 downto 0) := "00000" & X"508";
   constant MDIO_RX_DATA           : std_logic_vector(16 downto 0) := "00000" & X"50C";
   constant MDIO_OP_RD             : std_logic_vector(1 downto 0) := "10";
   constant MDIO_OP_WR             : std_logic_vector(1 downto 0) := "01";

   -- PHY Registers
   -- phy address is actually a 6 bit field but other bits are reserved so simpler to specify as 8 bit
   --constant PHY_ADDR               : std_logic_vector(7 downto 0) := X"07";
   constant PHY_ADDR               : std_logic_vector(7 downto 0) := X"00";
   constant PHY_CONTROL_REG        : std_logic_vector(7 downto 0) := X"00";
   constant PHY_STATUS_REG         : std_logic_vector(7 downto 0) := X"01";
   constant PHY_ABILITY_REG        : std_logic_vector(7 downto 0) := X"04";
   constant PHY_1000BASET_CONTROL_REG : std_logic_vector(7 downto 0) := X"09";
   constant PHY_1000BASET_STATUS_REG : std_logic_vector(7 downto 0) := X"0A";
   constant PHY_INTERRUPT_REG      : std_logic_vector(7 downto 0) := X"12";
   constant PHY_CLEAR_INTERRUPT_REG : std_logic_vector(7 downto 0) := X"13";

   ---------------------------------------------------
   -- Signal declarations
   signal axi_status               : std_logic_vector(4 downto 0);   -- used to keep track of axi transactions
   signal mdio_ready               : std_logic := '0';               -- captured to acknowledge the end of mdio transactions
   signal axi_rd_data              : std_logic_vector(31 downto 0) := (others => '0');
   signal axi_wr_data              : std_logic_vector(31 downto 0);
   signal mdio_wr_data             : std_logic_vector(31 downto 0) := (others => '0');

   signal axi_state                : state_typ;                      -- main state machine to configure example design
   signal mdio_access_sm           : mdio_state_typ;                 -- mdio state machine to handle mdio register config
   signal axi_access_sm            : axi_state_typ;                  -- axi state machine - handles the 5 channels

   signal start_access             : std_logic;                      -- used to kick the axi acees state machine
   signal start_mdio               : std_logic;                      -- used to kick the mdio state machine
   signal drive_mdio               : std_logic;                      -- selects between mdio fields and direct sm control
   signal mdio_op                  : std_logic_vector(1 downto 0);
   signal mdio_reg_addr            : std_logic_vector(7 downto 0);
   signal writenread               : std_logic;
   signal addr                     : std_logic_vector(16 downto 0);
   signal speed                    : std_logic_vector(1 downto 0);
   signal update_speed_sync        : std_logic;
   signal update_speed_reg         : std_logic;

   signal count_shift              : std_logic_vector(20 downto 0) := (others => '1');

   -- to avoid logic being stripped a serial input is included which enables an address/data and
   -- control to be setup for a user config access..
   signal serial_command_shift     : std_logic_vector(36 downto 0);
   signal load_data                : std_logic;
   signal capture_data             : std_logic;
   signal write_access             : std_logic;
   signal read_access              : std_logic;

   signal s_axi_reset              : std_logic;

   signal s_axi_awvalid_int        : std_logic;
   signal s_axi_wvalid_int         : std_logic;
   signal s_axi_bready_int         : std_logic;
   signal s_axi_arvalid_int        : std_logic;
   signal s_axi_rready_int         : std_logic;

--attribute mark_debug : string;
--attribute mark_debug of axi_status		: signal is "true";
--attribute mark_debug of mdio_ready	: signal is "true";
--attribute mark_debug of axi_rd_data		: signal is "true";
--attribute mark_debug of axi_wr_data		: signal is "true";
--attribute mark_debug of mdio_wr_data		: signal is "true";
--attribute mark_debug of axi_state	: signal is "true";
--attribute mark_debug of mdio_access_sm		: signal is "true";
--attribute mark_debug of axi_access_sm		: signal is "true";
--attribute mark_debug of start_access		: signal is "true";
--attribute mark_debug of start_mdio	: signal is "true";
--attribute mark_debug of drive_mdio		: signal is "true";
--attribute mark_debug of mdio_op		: signal is "true";
--attribute mark_debug of mdio_reg_addr		: signal is "true";
--attribute mark_debug of writenread	: signal is "true";
--attribute mark_debug of addr		: signal is "true";
--attribute mark_debug of speed		: signal is "true";
--attribute mark_debug of update_speed_sync		: signal is "true";
--attribute mark_debug of update_speed_reg	: signal is "true";
--attribute mark_debug of count_shift		: signal is "true";
--attribute mark_debug of s_axi_aclk		: signal is "true";
--attribute mark_debug of s_axi_resetn		: signal is "true";
--attribute mark_debug of phy_interrupt_n	: signal is "true";
--attribute mark_debug of mac_interrupt		: signal is "true";
--attribute mark_debug of s_axi_awaddr		: signal is "true";
--attribute mark_debug of s_axi_awvalid		: signal is "true";
--attribute mark_debug of s_axi_awready	: signal is "true";
--attribute mark_debug of s_axi_wdata		: signal is "true";
--attribute mark_debug of s_axi_wvalid		: signal is "true";
--attribute mark_debug of s_axi_wready		: signal is "true";
--attribute mark_debug of s_axi_bresp	: signal is "true";
--attribute mark_debug of s_axi_bvalid		: signal is "true";
--attribute mark_debug of s_axi_bready		: signal is "true";
--attribute mark_debug of s_axi_araddr		: signal is "true";
--attribute mark_debug of s_axi_arvalid	: signal is "true";
--attribute mark_debug of s_axi_arready		: signal is "true";
--attribute mark_debug of s_axi_rdata		: signal is "true";
--attribute mark_debug of s_axi_rresp		: signal is "true";
--attribute mark_debug of s_axi_rvalid	: signal is "true";
--attribute mark_debug of s_axi_rready	: signal is "true";

begin

   s_axi_awvalid <= s_axi_awvalid_int;
   s_axi_wvalid  <= s_axi_wvalid_int;
   s_axi_bready  <= s_axi_bready_int;
   s_axi_arvalid <= s_axi_arvalid_int;
   s_axi_rready  <= s_axi_rready_int;

   s_axi_reset <= not s_axi_resetn;
   
   update_speed_sync <= update_speed;

   update_reg : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if s_axi_reset = '1' then
            update_speed_reg   <= '0';
         else
            update_speed_reg   <= update_speed_sync;
         end if;
      end if;
   end process update_reg;

   -----------------------------------------------------------------------------
   -- Management process. This process sets up the configuration by
   -- turning off flow control, then checks gathered statistics at the
   -- end of transmission
   -----------------------------------------------------------------------------
   gen_state : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if s_axi_reset = '1' then
            axi_state      <= STARTUP;
            start_access   <= '0';
            start_mdio     <= '0';
            drive_mdio     <= '0';
            mdio_op        <= (others => '0');
            mdio_reg_addr  <= (others => '0');
            writenread     <= '0';
            addr           <= (others => '0');
            axi_wr_data    <= (others => '0');
            speed          <= mac_speed;
            debug0_sig     <= '0';
            debug1_sig     <= '0';
            debug2_sig     <= '0';
            debug3_sig     <= '0';
         -- main state machine is kicking off multi cycle accesses in each state so has to
         -- stall while they take place
         elsif axi_access_sm = IDLE_A and mdio_access_sm = IDLE and start_access = '0' and start_mdio = '0' then
            case axi_state is
               when STARTUP =>
                  -- this state will be ran after reset to wait for count_shift
                  if (count_shift(20) = '0') then
                     -- set up MDC frequency. Write to Management configuration
                     -- register. This will enable MDIO and set MDC to 2.5MHz
                     speed          <= mac_speed;
                     assert false
                       report "Setting MDC Frequency to 2.5MHz...." & cr
                       severity note;
                     start_mdio     <= '0';
                     drive_mdio     <= '0';
                     start_access   <= '1';
                     writenread     <= '1';
                     addr           <= CONFIG_MANAGEMENT_ADD;
                     --axi_wr_data    <= X"00000053"; -- this is 2.5 MHz
                     axi_wr_data    <= X"00000068";
                     axi_state      <= MDIO_RESTART;
                  end if;
--                  when SET_PHY_SPEEDS =>  -- not needed, MAC and PHY support both 10M - 1G defaultly
--                when MDIO_SET_INTERRUPT =>
--                debug0_sig <= '1';
--                    -- set auto-negotiation interrupt
--                    assert false
--                        report "Setting Auto-Negotiation-Completed interrupt" & cr
--                        severity note;
--                    drive_mdio     <= '1';
--                    start_mdio     <= '1';
--                    start_access   <= '0';
--                    writenread     <= '0';
--                    mdio_reg_addr  <= PHY_INTERRUPT_REG;
--                    mdio_op        <= MDIO_OP_WR;
--                    axi_wr_data    <= X"00000800"; -- bit 11 for auto-negotiation completed, bit 14 for speed changed
--                    axi_state      <= MDIO_READ_INTERRUPT;

--               when MDIO_READ_INTERRUPT => 
--                  drive_mdio     <= '1';
--                  start_mdio     <= '1';
--                  start_access   <= '0';
--                  writenread     <= '0';
--                  assert false
--                    report "Read interrupt" & cr
--                    severity note;
--                  mdio_reg_addr  <= PHY_INTERRUPT_REG;
--                  mdio_op        <= MDIO_OP_RD;
--                  axi_state      <= MDIO_RESTART;
                  
               when MDIO_RESTART =>
                  if axi_rd_data = X"00010800" then
                     debug1_sig <= '1';
                  end if;
                  -- set autoneg and reset
                  -- if loopback is selected then do not set autonegotiate and program the required speed directly
                  -- otherwise set autonegotiate
                  assert false
                    report "Applying PHY software reset" & cr
                    severity note;
                  drive_mdio     <= '1';
                  start_mdio     <= '1';
                  start_access   <= '0';
                  writenread     <= '0';
                  mdio_reg_addr  <= PHY_CONTROL_REG;
                  mdio_op        <= MDIO_OP_WR;
                  --axi_wr_data    <= X"0000" & X"9" & X"000";
                  axi_wr_data    <= X"00009000";
                  axi_state      <= MDIO_STATS;
                  
               when MDIO_STATS =>
                  drive_mdio     <= '1';
                  start_mdio     <= '1';
                  start_access   <= '0';
                  writenread     <= '0';
                  assert false
                    report "Wait for Autonegotiation to complete" & cr
                    severity note;
                  mdio_reg_addr  <= PHY_STATUS_REG;
                  mdio_op        <= MDIO_OP_RD;
                  axi_state      <= MDIO_STATS_POLL_CHECK;
                  
               when MDIO_STATS_POLL_CHECK =>
                  -- bit 5 is autoneg complete - assume required speed is selected
                  if axi_rd_data(5) = '1' then
                     axi_state      <= MDIO_READ_INTERRUPT2;
                    -- axi_state      <= CHECK_SPEED;
                  else
                     axi_state      <= MDIO_STATS;
                  end if;

               when MDIO_READ_INTERRUPT2 => 
                  drive_mdio     <= '1';
                  start_mdio     <= '1';
                  start_access   <= '0';
                  writenread     <= '0';
                  assert false
                    report "Read interrupt" & cr
                    severity note;
                  mdio_reg_addr  <= PHY_INTERRUPT_REG;
                  mdio_op        <= MDIO_OP_RD;
                  axi_state      <= MDIO_READ_SPEED;

               when MDIO_READ_SPEED => 
                  drive_mdio     <= '1';
                  start_mdio     <= '1';
                  start_access   <= '0';
                  writenread     <= '0';
                  assert false
                    report "Read negotiated speed" & cr
                    severity note;
                  mdio_reg_addr  <= PHY_1000BASET_STATUS_REG;
                  mdio_op        <= MDIO_OP_RD;
                  axi_state      <= MDIO_READ_SPEED_POLL;
                  
               when MDIO_READ_SPEED_POLL =>
                  if axi_rd_data(11) = '1' then -- link partner 1G capable
                     axi_state      <= MAC_UPDATE_SPEED1000;
                     debug2_sig <= '1';
                  else 
                     axi_state      <= MAC_UPDATE_SPEED100;
                     debug2_sig <= '0';
                  end if;
                  
               when MAC_UPDATE_SPEED100 =>
                  assert false
                     report "Programming MAC speed 100" & cr
                     severity note;
                  drive_mdio     <= '0';
                  start_mdio     <= '0';
                  start_access   <= '1';
                  writenread     <= '1';
                  addr           <= SPEED_CONFIG_ADD;
                  -- bits 31:30 are used
                  axi_wr_data    <= "01" & X"0000000" & "00";
                  axi_state      <= CHECK_SPEED;                              

               when MAC_UPDATE_SPEED1000 =>
                  assert false
                     report "Programming MAC speed 1000" & cr
                     severity note;
                  drive_mdio     <= '0';
                  start_mdio     <= '0';
                  start_access   <= '1';
                  writenread     <= '1';
                  addr           <= SPEED_CONFIG_ADD;
                  -- bits 31:30 are used
                  axi_wr_data    <= "10" & X"0000000" & "00";
                  axi_state      <= CHECK_SPEED;
                  
               when CHECK_SPEED =>
                debug3_sig <= '1';
                  if update_speed_reg = '1' then
                    --axi_state      <= CHANGE_SPEED;
                    axi_state      <= STARTUP;
                  else
                     if capture_data = '1' then
                        axi_wr_data <= serial_command_shift(33 downto 2);
                     end if;
                     if write_access = '1' or read_access = '1' then
                        addr         <= "00000" & serial_command_shift (13 downto 2);
                        start_access <= '1';
                        writenread   <= write_access;
                     end if;
                  end if;
               when others =>
                  axi_state <= STARTUP;
            end case;
         else
            start_access <= '0';
            start_mdio   <= '0';
         end if;
      end if;
   end process gen_state;


   --------------------------------------------------
   -- MDIO setup - split from main state machine to make more manageable

   gen_mdio_state : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if s_axi_reset = '1' then
            mdio_access_sm <= IDLE;
         elsif axi_access_sm = IDLE_A or axi_access_sm = DONE then
            case mdio_access_sm is
               when IDLE =>
                  if start_mdio = '1' then
                     if mdio_op = MDIO_OP_WR then
                        mdio_access_sm <= SET_DATA;
                        mdio_wr_data   <= axi_wr_data;
                     else
                        mdio_access_sm <= INIT;
                        mdio_wr_data   <= PHY_ADDR & mdio_reg_addr & mdio_op & "001" & "00000000000";
                     end if;
                  end if;
               when SET_DATA =>
                  mdio_access_sm <= INIT;
                  mdio_wr_data   <= PHY_ADDR & mdio_reg_addr & mdio_op & "001" & "00000000000";
               when INIT =>
                  mdio_access_sm <= POLL;
               when POLL =>
                  if mdio_ready = '1' then
                     mdio_access_sm <= IDLE;
                  end if;
            end case;
         elsif mdio_access_sm = POLL and mdio_ready = '1' then
            mdio_access_sm <= IDLE;
         end if;
      end if;
   end process gen_mdio_state;


   ---------------------------------------------------------------------------------------------
   -- processes to generate the axi transactions - only simple reads and write can be generated

   gen_axi_state : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if s_axi_reset = '1' then
            axi_access_sm <= IDLE_A;
         else
            case axi_access_sm is
               when IDLE_A =>
                  if start_access = '1' or start_mdio = '1' or mdio_access_sm /= IDLE then
                     if mdio_access_sm = POLL then
                        axi_access_sm <= READ;
                     elsif (start_access = '1' and writenread = '1') or
                           (start_mdio = '1' or mdio_access_sm = SET_DATA or mdio_access_sm = INIT) then
                        axi_access_sm <= WRITE;
                     else
                        axi_access_sm <= READ;
                     end if;
                  end if;
               when WRITE =>
                  -- wait in this state until axi_status signals the write is complete
                  if axi_status(4 downto 2) = "111" then
                     axi_access_sm <= DONE;
                  end if;
               when READ =>
                  -- wait in this state until axi_status signals the read is complete
                  if axi_status(1 downto 0) = "11" then
                     axi_access_sm <= DONE;
                  end if;
               when DONE =>
                  axi_access_sm <= IDLE_A;
            end case;
         end if;
      end if;
   end process gen_axi_state;

   -- need a process per axi interface (i.e 5)
   -- in each case the interface is driven accordingly and once acknowledged a sticky
   -- status bit is set and the process waits until the access_sm moves on
   -- READ ADDR
   read_addr_p : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if axi_access_sm = READ then
            if axi_status(0) = '0' then
               if drive_mdio = '1' then
                  s_axi_araddr   <= MDIO_RX_DATA(11 downto 0);
               else
                  s_axi_araddr   <= addr(11 downto 0);
               end if;
               s_axi_arvalid_int <= '1';
               if s_axi_arready = '1' and s_axi_arvalid_int = '1' then
                  axi_status(0)     <= '1';
                  s_axi_araddr      <= (others => '0');
                  s_axi_arvalid_int <= '0';
               end if;
            end if;
         else
            axi_status(0)     <= '0';
            s_axi_araddr      <= (others => '0');
            s_axi_arvalid_int <= '0';
         end if;
      end if;
   end process read_addr_p;

   -- READ DATA/RESP
   read_data_p : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if axi_access_sm = READ then
            if axi_status(1) = '0' then
               s_axi_rready_int  <= '1';
               if s_axi_rvalid = '1' and s_axi_rready_int = '1' then
                  axi_status(1) <= '1';
                  s_axi_rready_int  <= '0';
                  axi_rd_data   <= s_axi_rdata;
                  if drive_mdio = '1' and s_axi_rdata(16) = '1' then
                     mdio_ready <= '1';
                  end if;
               end if;
            end if;
         else
            s_axi_rready_int  <= '0';
            axi_status(1)     <= '0';
            if axi_access_sm = IDLE_A  and (start_access = '1' or start_mdio = '1') then
               mdio_ready     <= '0';
               axi_rd_data   <= (others => '0');
            end if;
         end if;
      end if;
   end process read_data_p;

   -- WRITE ADDR
   write_addr_p : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if axi_access_sm = WRITE then
            if axi_status(2) = '0' then
               if drive_mdio = '1' then
                  if mdio_access_sm = SET_DATA then
                     s_axi_awaddr <= MDIO_TX_DATA(11 downto 0);
                  else
                     s_axi_awaddr <= MDIO_CONTROL(11 downto 0);
                  end if;
               else
                  s_axi_awaddr   <= addr(11 downto 0);
               end if;
               s_axi_awvalid_int <= '1';
               if s_axi_awready = '1' and s_axi_awvalid_int = '1' then
                  axi_status(2)     <= '1';
                  s_axi_awaddr      <= (others => '0');
                  s_axi_awvalid_int <= '0';
               end if;
            end if;
         else
            s_axi_awaddr      <= (others => '0');
            s_axi_awvalid_int <= '0';
            axi_status(2)     <= '0';
         end if;
      end if;
   end process write_addr_p;

   -- WRITE DATA
   write_data_p : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if axi_access_sm = WRITE then
            if axi_status(3) = '0' then
               if drive_mdio = '1' then
                  s_axi_wdata   <= mdio_wr_data;
               else
                  s_axi_wdata   <= axi_wr_data;
               end if;
               s_axi_wvalid_int  <= '1';
               if s_axi_wready = '1' and s_axi_wvalid_int = '1' then
                  axi_status(3)    <= '1';
                  s_axi_wdata      <= (others => '0');
                  s_axi_wvalid_int <= '0';
               end if;
            end if;
         else
            s_axi_wdata      <= (others => '0');
            s_axi_wvalid_int <= '0';
            axi_status(3)    <= '0';
         end if;
      end if;
   end process write_data_p;

   -- WRITE RESP
   write_resp_p : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if axi_access_sm = WRITE then
            if axi_status(4) = '0' then
               s_axi_bready_int  <= '1';
               if s_axi_bvalid = '1' and s_axi_bready_int = '1' then
                  axi_status(4)    <= '1';
                  s_axi_bready_int     <= '0';
               end if;
            end if;
         else
            s_axi_bready_int     <= '0';
            axi_status(4)    <= '0';
         end if;
      end if;
   end process write_resp_p;

   shift_command : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         if load_data = '1' then
            serial_command_shift <= serial_command_shift(35 downto 33) & axi_rd_data & serial_command_shift(0) & serial_command;
         else
            serial_command_shift <= serial_command_shift(35 downto 0) & serial_command;
         end if;
      end if;
   end process shift_command;

   serial_response <= serial_command_shift(34) when axi_state = CHECK_SPEED else '1';

   -- the serial command is expected to have a start and stop bit - to avoid a counter -
   -- and a two bit code field in the uppper two bits.
   -- these decode as follows:
   -- 00 - read address
   -- 01 - write address
   -- 10 - write data
   -- 11 - read data - slightly more involved - when detected the read data is registered into the shift and passed out
   -- 11 is used for read data as if the input is tied high the output will simply reflect whatever was
   -- captured but will not result in any activity
   -- it is expected that the write data is setup BEFORE the write address
   shift_decode : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         load_data <= '0';
         capture_data <= '0';
         write_access <= '0';
         read_access <= '0';
         if serial_command_shift(36) = '0' and serial_command_shift(35) = '1' and serial_command_shift(0) = '1' then
            if serial_command_shift(34) = '1' and serial_command_shift(33) = '1' then
               load_data <= '1';
            elsif serial_command_shift(34) = '1' and serial_command_shift(33) = '0' then
               capture_data <= '1';
            elsif serial_command_shift(34) = '0' and serial_command_shift(33) = '1' then
               write_access <= '1';
            else
               read_access <= '1';
            end if;
         end if;
      end if;
   end process shift_decode;


   -- don't reset this  - it will always be updated before it is used..
   -- it does need an init value (all ones)
   -- Create fully synchronous reset in the s_axi clock domain.
   gen_count : process (s_axi_aclk)
   begin
      if s_axi_aclk'event and s_axi_aclk = '1' then
         count_shift <= count_shift(19 downto 0) & s_axi_reset;
      end if;
   end process gen_count;

end rtl;

