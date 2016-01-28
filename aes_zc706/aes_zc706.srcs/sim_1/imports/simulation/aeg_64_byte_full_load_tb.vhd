--------------------------------------------------------------------------------
-- Title      : Demo testbench
-- Project    : 
--------------------------------------------------------------------------------
-- File       : aeg_64_byte_full_load_tb.vhd
-- -----------------------------------------------------------------------------
--
-- This testbench performs the following operations:
--
-- 256 Frames a pushed into the receiver from the PHY interface (GMII).
-- Their destination MAC addresses are in range FF:00:00:00:00:00 to FF:00:00:00:00:FF
-- Each frame is 64 Byte in size and frames are inserted back to back (after the
--     minimum interframe gap)
-- These insertions are done by the stimulus process.
-- The monitor process observes the messages coming out of the transmitter side of 
--     the switch and compare to the data expected
-- The lookup module skips every forth frame as it is not in the lookup memory
-- FF:00:00:00:00:FE has an error and should be skipped

entity aeg_64_byte_full_load_tb is
end aeg_64_byte_full_load_tb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture testbench of aeg_64_byte_full_load_tb is

constant RECEIVER_DATA_WIDTH           : integer := 8;
constant NR_PORTS                      : integer := 4;
constant GMII_DATA_WIDTH               : integer := 8;
constant RX_STATISTICS_WIDTH           : integer := 28;
constant TX_STATISTICS_WIDTH           : integer := 32;
constant TX_IFG_DELAY_WIDTH            : integer := 8;
constant PAUSE_VAL_WIDTH               : integer := 16;

  ------------------------------------------------------------------------------
  -- Component Declaration for Device Under Test (DUT).
  ------------------------------------------------------------------------------
   component automotive_ethernet_gateway
    Generic (
      RECEIVER_DATA_WIDTH           : integer;
      NR_PORTS                      : integer;
      GMII_DATA_WIDTH               : integer;
      RX_STATISTICS_WIDTH           : integer;
      TX_STATISTICS_WIDTH           : integer;
      TX_IFG_DELAY_WIDTH            : integer;
      PAUSE_VAL_WIDTH               : integer
    );
    port (
      -- asynchronous reset
      glbl_rst                      : in  std_logic;

      -- 200MHz clock input from board
      clk_in_p                      : in  std_logic;
      clk_in_n                      : in  std_logic;

      phy_resetn                    : out std_logic;

      -- GMII Interface
      -----------------
      gmii_txd                      : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
      gmii_tx_en                    : out std_logic;
      gmii_tx_er                    : out std_logic;
      gmii_tx_clk                   : out std_logic;
      gmii_rxd                      : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
      gmii_rx_dv                    : in  std_logic;
      gmii_rx_er                    : in  std_logic;
      gmii_rx_clk                   : in  std_logic;
      mii_tx_clk                    : in  std_logic;

      -- MDIO Interface
      -----------------
      mdio                          : inout std_logic;
      mdc                           : out std_logic;

      -- Serialised statistics vectors
      --------------------------------
      tx_statistics_s               : out std_logic;
      rx_statistics_s               : out std_logic;

      -- Serialised Pause interface controls
      --------------------------------------
      pause_req_s                   : in  std_logic;

      -- Main example design controls
      -------------------------------
      mac_speed                     : in  std_logic_vector(1 downto 0);
      update_speed                  : in  std_logic;
      serial_response               : out std_logic;
      enable_phy_loopback           : in  std_logic;
      reset_error                   : in  std_logic
    );
  end component;


  ------------------------------------------------------------------------------
  -- types to support frame data
  ------------------------------------------------------------------------------
  -- Tx Data and Data_valid record
  type data_typ is record
      data : std_logic_vector(7 downto 0);        -- data
      valid : std_logic;                          -- data_valid
      error : std_logic;                          -- data_error
  end record;
  type frame_of_data_typ is array (natural range <>) of data_typ;
  
  -- Tx Data, Data_valid and underrun record
  type frame_typ is record
      columns   : frame_of_data_typ(0 to 65);-- data field
  end record;
  
  ------------------------------------------------------------------------------
  -- Stimulus - Frame data
  ------------------------------------------------------------------------------
  shared variable frame_data : frame_typ := (
      columns  => (
        0      => ( DATA => X"FF", VALID => '1', ERROR => '0'), -- Destination Address (DA)
        1      => ( DATA => X"00", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"00", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"00", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"00", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"00", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'), -- Length/Type = Length = 46
       14      => ( DATA => X"01", VALID => '1', ERROR => '0'),
       15      => ( DATA => X"02", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"03", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       19      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"07", VALID => '1', ERROR => '0'),
       21      => ( DATA => X"08", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"09", VALID => '1', ERROR => '0'),
       23      => ( DATA => X"0A", VALID => '1', ERROR => '0'),
       24      => ( DATA => X"0B", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"0C", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"0D", VALID => '1', ERROR => '0'),
       27      => ( DATA => X"0E", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"0F", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"10", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       31      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"13", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"14", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"15", VALID => '1', ERROR => '0'),
       35      => ( DATA => X"16", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"17", VALID => '1', ERROR => '0'),
       37      => ( DATA => X"18", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"19", VALID => '1', ERROR => '0'),
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"1B", VALID => '1', ERROR => '0'),
       41      => ( DATA => X"1C", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"1D", VALID => '1', ERROR => '0'),
       43      => ( DATA => X"1E", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"1F", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"20", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"21", VALID => '1', ERROR => '0'),
       47      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       49      => ( DATA => X"24", VALID => '1', ERROR => '0'),
       50      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       51      => ( DATA => X"26", VALID => '1', ERROR => '0'),
       52      => ( DATA => X"27", VALID => '1', ERROR => '0'),
       53      => ( DATA => X"28", VALID => '1', ERROR => '0'),
       54      => ( DATA => X"29", VALID => '1', ERROR => '0'),
       55      => ( DATA => X"2A", VALID => '1', ERROR => '0'),
       56      => ( DATA => X"2B", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2C", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"2D", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"2E", VALID => '1', ERROR => '0'), -- 46th Byte of Data
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')
     )
  );
  
  ------------------------------------------------------------------------------
  -- CRC engine
  ------------------------------------------------------------------------------
  function calc_crc (data : in std_logic_vector;
                     fcs  : in std_logic_vector)
  return std_logic_vector is

    variable crc          : std_logic_vector(31 downto 0);
    variable crc_feedback : std_logic;
  begin

    crc := not fcs;

    for I in 0 to 7 loop
      crc_feedback      := crc(0) xor data(I);

      crc(4 downto 0)   := crc(5 downto 1);
      crc(5)            := crc(6)  xor crc_feedback;
      crc(7 downto 6)   := crc(8 downto 7);
      crc(8)            := crc(9)  xor crc_feedback;
      crc(9)            := crc(10) xor crc_feedback;
      crc(14 downto 10) := crc(15 downto 11);
      crc(15)           := crc(16) xor crc_feedback;
      crc(18 downto 16) := crc(19 downto 17);
      crc(19)           := crc(20) xor crc_feedback;
      crc(20)           := crc(21) xor crc_feedback;
      crc(21)           := crc(22) xor crc_feedback;
      crc(22)           := crc(23);
      crc(23)           := crc(24) xor crc_feedback;
      crc(24)           := crc(25) xor crc_feedback;
      crc(25)           := crc(26);
      crc(26)           := crc(27) xor crc_feedback;
      crc(27)           := crc(28) xor crc_feedback;
      crc(28)           := crc(29);
      crc(29)           := crc(30) xor crc_feedback;
      crc(30)           := crc(31) xor crc_feedback;
      crc(31)           :=             crc_feedback;
    end loop;

    -- return the CRC result
    return not crc;
  end calc_crc;

  ------------------------------------------------------------------------------
  -- Test Bench signals and constants
  ------------------------------------------------------------------------------

  -- Delay to provide setup and hold timing at the GMII/RGMII.
  constant dly : time := 4.8 ns;
  constant gtx_period : time := 2.5 ns;
  
  shared variable counter            : integer := 0;

  -- testbench signals
  signal gtx_clk              : std_logic;
  signal gtx_clkn             : std_logic;
  signal reset                : std_logic := '0';
  signal demo_mode_error      : std_logic := '0';
  signal frames_received      : std_logic_vector(7 downto 0) := x"00";

  signal mdc                  : std_logic;
  signal mdio                 : std_logic;
  signal mdio_count           : unsigned(5 downto 0) := (others => '0');
  signal last_mdio            : std_logic;
  signal mdio_read            : std_logic;
  signal mdio_addr            : std_logic;
  signal mdio_fail            : std_logic;
  signal gmii_tx_clk          : std_logic;
  signal gmii_tx_en           : std_logic;
  signal gmii_tx_er           : std_logic;
  signal gmii_txd             : std_logic_vector(7 downto 0) := (others => '0');
  signal gmii_rx_clk          : std_logic;
  signal gmii_rx_dv           : std_logic := '0';
  signal gmii_rx_er           : std_logic := '0';
  signal gmii_rxd             : std_logic_vector(7 downto 0) := (others => '0');
  signal mii_tx_clk           : std_logic := '0';

  -- testbench control signals
  signal tx_monitor_finished_1G     : boolean := false;
  signal management_config_finished : boolean := false;
  signal rx_stimulus_finished       : boolean := false;

  signal send_complete              : std_logic := '0';

  signal phy_speed                  : std_logic_vector(1 downto 0) := "10";
  signal mac_speed                  : std_logic_vector(1 downto 0) := "10";
  signal update_speed               : std_logic := '0';

  signal serial_response            : std_logic;
  signal enable_phy_loopback        : std_logic := '0';

begin

  ------------------------------------------------------------------------------
  -- Wire up Device Under Test
  ------------------------------------------------------------------------------
  dut: automotive_ethernet_gateway
    Generic map (
      RECEIVER_DATA_WIDTH  => RECEIVER_DATA_WIDTH,
      NR_PORTS             => NR_PORTS,
      GMII_DATA_WIDTH      => GMII_DATA_WIDTH,
      RX_STATISTICS_WIDTH  => RX_STATISTICS_WIDTH,
      TX_STATISTICS_WIDTH  => TX_STATISTICS_WIDTH,
      TX_IFG_DELAY_WIDTH   => TX_IFG_DELAY_WIDTH,
      PAUSE_VAL_WIDTH      => PAUSE_VAL_WIDTH
    )
    port map (
      -- asynchronous reset
      --------------------------------
      glbl_rst             => reset,

      -- 200MHz clock input from board
      clk_in_p             => gtx_clk,
      clk_in_n             => gtx_clkn,

      phy_resetn           => open,

      -- GMII Interface
      --------------------------------
      gmii_txd             => gmii_txd,
      gmii_tx_en           => gmii_tx_en,
      gmii_tx_er           => gmii_tx_er,
      gmii_tx_clk          => gmii_tx_clk,
      gmii_rxd             => gmii_rxd,
      gmii_rx_dv           => gmii_rx_dv,
      gmii_rx_er           => gmii_rx_er,
      gmii_rx_clk          => gmii_rx_clk,
      mii_tx_clk           => mii_tx_clk,
      
      -- MDIO Interface
      mdc                  => mdc,
      mdio                 => mdio,

      -- Serialised statistics vectors
      --------------------------------
      tx_statistics_s      => open,
      rx_statistics_s      => open,

      -- Serialised Pause interface controls
      --------------------------------------
      pause_req_s          => '0',

      -- Main example design controls
      -------------------------------
      mac_speed            => mac_speed,
      update_speed         => update_speed,
      serial_response      => serial_response,
      enable_phy_loopback  => enable_phy_loopback,
      reset_error          => '0'
    );


  ------------------------------------------------------------------------------
  -- If the simulation is still going after delay below
  -- then something has gone wrong: terminate with an error
  ------------------------------------------------------------------------------
  p_timebomb : process
  begin
    wait for 300 us;
    assert false
      report "ERROR - Simulation running forever!"
      severity failure;
  end process p_timebomb;

  ------------------------------------------------------------------------------
  -- Clock drivers
  ------------------------------------------------------------------------------

  -- drives input to an MMCM at 200MHz which creates gtx_clk at 125 MHz
  p_gtx_clk : process
  begin
    gtx_clk <= '0';
    gtx_clkn <= '1';
    wait for 80 ns;
    loop
      wait for gtx_period;
      gtx_clk <= '1';
      gtx_clkn <= '0';
      wait for gtx_period;
      gtx_clk <= '0';
      gtx_clkn <= '1';
    end loop;
  end process p_gtx_clk;
  
  gmii_rx_clk <= gmii_tx_clk;

  -----------------------------------------------------------------------------
  -- reset process. 
  ----------------------------------------------------------------------------- 
  p_reset : process
     procedure mac_reset is
     begin
        assert false
          report "Resetting core..." & cr
          severity note;
  
        reset <= '1';
        wait for 200 ns;
        reset <= '0';
  
        assert false
          report "Timing checks are valid" & cr
          severity note;
     end procedure mac_reset; 
  begin
    assert false
       report "Timing checks are not valid" & cr
       severity note;
    mac_speed <= "10";
    phy_speed <= "10";
    update_speed <= '0';
    
    wait for 800 ns;
    mac_reset;
    management_config_finished <= true;
--    wait for 167.8 us;
--    mac_reset;
    wait;
  end process p_reset;

  ------------------------------------------------------------------------------
  -- Stimulus process. This process will inject frames of data into the
  -- PHY side of the receiver.
  ------------------------------------------------------------------------------
  p_stimulus : process

    ----------------------------------------------------------
    -- Procedure to inject a frame into the receiver at 1Gb/s
    ----------------------------------------------------------
    procedure send_frame_1g is
      variable current_col   : natural := 0;  -- Column counter within frame
      variable fcs           : std_logic_vector(31 downto 0);
    begin

      wait until gmii_rx_clk'event and gmii_rx_clk = '1';

      -- Reset the FCS calculation
      fcs         := (others => '0');

      -- Adding the preamble field
      for j in 0 to 7 loop
        gmii_rxd   <= "01010101" after dly;
        gmii_rx_dv <= '1' after dly;
        gmii_rx_er <= '0' after dly;
        wait until gmii_rx_clk'event and gmii_rx_clk = '1';
      end loop;

      -- Adding the Start of Frame Delimiter (SFD)
      gmii_rxd   <= "11010101" after dly;
      gmii_rx_dv <= '1' after dly;
      wait until gmii_rx_clk'event and gmii_rx_clk = '1';
      current_col := 0;
      gmii_rxd     <= frame_data.columns(current_col).data after dly;
      gmii_rx_dv   <= frame_data.columns(current_col).valid after dly;
      gmii_rx_er   <= frame_data.columns(current_col).error after dly;
      fcs          := calc_crc(frame_data.columns(current_col).data, fcs);

      wait until gmii_rx_clk'event and gmii_rx_clk = '1';

      current_col := current_col + 1;
      -- loop over columns in frame.
      while frame_data.columns(current_col).valid /= '0' loop
        -- send one column of data
        gmii_rxd   <= frame_data.columns(current_col).data after dly;
        gmii_rx_dv <= frame_data.columns(current_col).valid after dly;
        gmii_rx_er <= frame_data.columns(current_col).error after dly;
        fcs        := calc_crc(frame_data.columns(current_col).data, fcs);

        current_col := current_col + 1;
        wait until gmii_rx_clk'event and gmii_rx_clk = '1';

      end loop;

      -- Send the CRC.
      for j in 0 to 3 loop
         gmii_rxd   <= fcs(((8*j)+7) downto (8*j)) after dly;
         gmii_rx_dv <= '1' after dly;
         gmii_rx_er <= '0' after dly;
        wait until gmii_rx_clk'event and gmii_rx_clk = '1';
      end loop;

        -- Clear the data lines.
        gmii_rxd   <= (others => '0') after dly;
        gmii_rx_dv <=  '0' after dly;

        -- Adding the minimum Interframe gap for a receiver (8 idles)
        for j in 0 to 7 loop
          wait until gmii_rx_clk'event and gmii_rx_clk = '1';
        end loop;

    end send_frame_1g;

  begin

    -- Wait for the Management MDIO transaction to finish.
    wait until management_config_finished;
    -- Wait for the internal resets to settle
    wait for 800 ns;

    -- inject 256 frames back to back
    for dest_address6 in 0 to 255 loop
        frame_data.columns(5).data := std_logic_vector(to_unsigned(dest_address6, frame_data.columns(5).data'length));
        if dest_address6 = 254 then
            frame_data.columns(40).error := '1';
        else
            frame_data.columns(40).error := '0';
        end if;
        send_frame_1g;
    end loop;
    
    send_complete <= '1';
    
    -- Wait for 1G monitor process to complete.
    wait until tx_monitor_finished_1G;
    rx_stimulus_finished <= true;

    -- Our work here is done
    if (demo_mode_error = '0') then
      assert false
        report "Test completed successfully"
        severity note;
    end if;
    assert false
      report "Simulation stopped"
      severity failure;
  end process p_stimulus;


  ------------------------------------------------------------------------------
  -- Monitor process. This process checks the data coming out of the
  -- transmitter to make sure that it matches that inserted into the
  -- receiver.
  ------------------------------------------------------------------------------
  p_monitor : process

    procedure check_frame_1g(dest_address6 : integer) is
      variable current_col   : natural := 0;  -- Column counter within frame
      variable fcs           : std_logic_vector(31 downto 0);
      
      variable addr_comp_reg  : std_logic_vector(95 downto 0);

    begin

      -- Reset the FCS calculation
      fcs         := (others => '0');

      while current_col < 12 loop
          addr_comp_reg((current_col*8 + 7) downto (current_col*8)) :=  frame_data.columns(current_col).data;
          current_col        := current_col + 1;
      end loop;

     current_col := 0;

     -- Parse over the preamble field
     while gmii_tx_en /= '1' or gmii_txd = "01010101" loop
        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
     end loop;

     -- Parse over the Start of Frame Delimiter (SFD)
     if (gmii_txd /= "11010101") then
        demo_mode_error <= '1';
        assert false
          report "SFD not present" & cr
          severity error;
     end if;
     wait until gmii_tx_clk'event and gmii_tx_clk = '1';

     -- frame has started, loop over columns of frame
     while ((frame_data.columns(current_col).valid)='1') loop
        if gmii_tx_en /= frame_data.columns(current_col).valid then
            demo_mode_error <= '1';
            assert false
                report "gmii_tx_en incorrect" & cr
                severity error;
        end if;

        if gmii_tx_en = '1' then
            -- The transmitted Destination Address was the Source Address of the injected frame
            if current_col < 5 then
                if gmii_txd(7 downto 0) /= frame_data.columns(current_col).data(7 downto 0) then
                   demo_mode_error <= '1';
                   assert false
                     report "gmii_txd incorrect during Destination Address field" & cr
                     severity error;
                end if;
            elsif current_col = 5 then
                if gmii_txd(7 downto 0) /= std_logic_vector(to_unsigned(dest_address6, gmii_txd'length)) then
                   demo_mode_error <= '1';
                   assert false
                     report "gmii_txd incorrect during 6th Destination Address field" & cr
                     severity error;
                end if;
            elsif current_col >= 6 and current_col < 12 then
                if gmii_txd(7 downto 0) /= frame_data.columns(current_col).data(7 downto 0) then
                   demo_mode_error <= '1';
                   assert false
                     report "gmii_txd incorrect during Source Address field" & cr
                     severity error;
                 end if;
            -- for remainder of frame
            else
                if gmii_txd(7 downto 0) /= frame_data.columns(current_col).data(7 downto 0) then
                   demo_mode_error <= '1';
                   assert false
                     report "gmii_txd incorrect" & cr
                     severity error;
                 end if;
            end if;
        end if;

        -- calculate expected crc for the frame
        fcs        := calc_crc(gmii_txd, fcs);

        -- wait for next column of data
        current_col        := current_col + 1;
        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
     end loop;  -- while data valid

     -- Check the FCS matches that expected from calculation
     -- Having checked all data columns, txd must contain FCS.
     for j in 0 to 3 loop
        if gmii_tx_en = '0' then
            demo_mode_error <= '1';
            assert false
              report "gmii_tx_en incorrect during FCS field" & cr
              severity error;
        end if;

        if gmii_txd /= fcs(((8*j)+7) downto (8*j)) then
            demo_mode_error <= '1';
            assert false
              report "gmii_txd incorrect during FCS field" & cr
              severity error;
        end if;

        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
     end loop;  -- j
   end check_frame_1g;
   
  begin  -- process p_monitor

    -- wait for reset to complete before starting monitor to ignore false startup errors
    wait until management_config_finished;
    wait for 100 ns;
    
    for dest_address6 in 0 to 253 loop
        check_frame_1g(dest_address6);
        counter := counter + 1;
        frames_received <= std_logic_vector(to_unsigned(counter,frames_received'length));
    end loop;
    
    -- provoking an error to see if tb works correctly
    check_frame_1g(255);
    counter := counter + 1;
    frames_received <= std_logic_vector(to_unsigned(counter,frames_received'length));
    
    if send_complete = '0' then
      wait until send_complete'event and send_complete = '1';
    end if;
    wait for 200 ns;
    tx_monitor_finished_1G <= true;

    wait;
  end process p_monitor;

end testbench;
