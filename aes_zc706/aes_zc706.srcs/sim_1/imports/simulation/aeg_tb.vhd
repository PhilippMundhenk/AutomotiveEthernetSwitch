----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 28.11.2013 13:51:50
-- Design Name: 
-- Module Name: aeg1500_tb - Behavioral
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado
--
-- Description: test automotive ethernet gateway
-- test one port in a user side loopback
-- the number of test frames and the frames size are arbitrary
----------------------------------------------------------------------------------

entity aeg_tb is
end aeg_tb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture testbench of aeg_tb is
-- aeg_tb properties
constant NR_TEST_FRAMES                 : integer := 20; -- number of frames sent
constant FRAME_LENGTH                   : integer := 64; -- ethernet frame size

constant MAX_FRAME_LENGTH               : integer := 1522; 
constant PAYLOAD_LENGTH                 : integer := FRAME_LENGTH - 18;

-- aeg constants
constant RECEIVER_DATA_WIDTH            : integer := 8;
constant NR_PORTS                       : integer := 4;
constant GMII_DATA_WIDTH                : integer := 8;
constant TX_IFG_DELAY_WIDTH             : integer := 8;
constant PAUSE_VAL_WIDTH                : integer := 16;

  ------------------------------------------------------------------------------
  -- Component Declaration for Device Under Test (DUT).
  ------------------------------------------------------------------------------
   component automotive_ethernet_gateway
    Generic (
      RECEIVER_DATA_WIDTH           : integer;
      NR_PORTS                      : integer;
      GMII_DATA_WIDTH               : integer;
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
      mdc                           : out std_logic--;

      -- Main example design controls
      -------------------------------
      --reset_error                   : in  std_logic
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
      columns   : frame_of_data_typ(0 to MAX_FRAME_LENGTH);-- data field
  end record;
  
  ------------------------------------------------------------------------------
  -- Stimulus - Frame data
  ------------------------------------------------------------------------------
  shared variable frame_data : frame_typ;
  
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
      mdio                 => mdio
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
  p_init : process
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
     
     procedure init_frame is
        variable length_type        : std_logic_vector(15 downto 0);
        variable data_byte          : std_logic_vector(15 downto 0);
        variable i                  : integer;
    begin
        frame_data.columns(0) := ( DATA => X"12", VALID => '1', ERROR => '0'); -- Destination Address (DA)'), 
        frame_data.columns(1) := ( DATA => X"34", VALID => '1', ERROR => '0');
        frame_data.columns(2) := ( DATA => X"56", VALID => '1', ERROR => '0');
        frame_data.columns(3) := ( DATA => X"78", VALID => '1', ERROR => '0');
        frame_data.columns(4) := ( DATA => X"00", VALID => '1', ERROR => '0');
        frame_data.columns(5) := ( DATA => X"00", VALID => '1', ERROR => '0');
        frame_data.columns(6) := ( DATA => X"5A", VALID => '1', ERROR => '0'); -- Source Address (5A)
        frame_data.columns(7) := ( DATA => X"02", VALID => '1', ERROR => '0');
        frame_data.columns(8) := ( DATA => X"03", VALID => '1', ERROR => '0');
        frame_data.columns(9) := ( DATA => X"04", VALID => '1', ERROR => '0');
        frame_data.columns(10) := ( DATA => X"05", VALID => '1', ERROR => '0');
        frame_data.columns(11) := ( DATA => X"06", VALID => '1', ERROR => '0');
          
        length_type := std_logic_vector(to_unsigned(PAYLOAD_LENGTH,length_type'length));
        frame_data.columns(12) := ( DATA => length_type(15 downto 8), VALID => '1', ERROR => '0');
        frame_data.columns(13) := ( DATA => length_type(7 downto 0), VALID => '1', ERROR => '0'); -- Length/Type
          
        i := 14;
        while i < PAYLOAD_LENGTH + 14 loop
            data_byte := std_logic_vector(to_unsigned(i-13 ,data_byte'length));
            frame_data.columns(i) := ( DATA => data_byte(7 downto 0), VALID => '1', ERROR => '0'); -- Payload
            i := i+1;
        end loop;
        while i < 60 loop
            frame_data.columns(i) := ( DATA => X"00", VALID => '1', ERROR => '0'); -- Padding
            i := i+1;
        end loop;
        
        frame_data.columns(i) := ( DATA => X"00", VALID => '0', ERROR => '0'); -- Stop writing
    end procedure init_frame;
  begin
    assert false
       report "Timing checks are not valid" & cr
       severity note;
    mac_speed <= "10";
    phy_speed <= "10";
    update_speed <= '0';
    
    wait for 800 ns;
    mac_reset;
    init_frame;
    management_config_finished <= true;
    wait;
  end process p_init;

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
    for dest_address6 in 0 to NR_TEST_FRAMES-1 loop
        frame_data.columns(5).data := std_logic_vector(to_unsigned(dest_address6, frame_data.columns(5).data'length));
        if dest_address6 = NR_TEST_FRAMES-3 then
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
    
    for dest_address6 in 0 to NR_TEST_FRAMES-1 loop
        if dest_address6 mod 4 /= 3 and dest_address6 /= NR_TEST_FRAMES-3 then
            check_frame_1g(dest_address6);
            counter := counter + 1;
            frames_received <= std_logic_vector(to_unsigned(counter,frames_received'length));
        end if;
    end loop;
    
    if send_complete = '0' then
      wait until send_complete'event and send_complete = '1';
    end if;
    wait for 200 ns;
    tx_monitor_finished_1G <= true;

    wait;
  end process p_monitor;

end testbench;


