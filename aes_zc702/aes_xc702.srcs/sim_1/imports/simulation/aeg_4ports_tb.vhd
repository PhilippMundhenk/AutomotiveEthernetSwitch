----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 23.12.2013 11:23:15
-- Design Name: 
-- Module Name: aeg_4ports_tb - tb
-- Project Name: automotive ethernet gateway
--
-- Description: 
-- testbench for ethernet switch with 4 ports
-- user can select which ports are to be active receiving frames on the rx (input) side (PORT_ENABLED)
-- every port monitors all of its frames on the tx (output) side independetly of active input side
-- the frames are inserted to the rx side by the p_stimulus processes
-- the frames are checked at the tx side by the p_monitor processes for correct syntax

-- every port sends two different kinds of frames back-to-back and periodically
-- the user can select the destination addresses, frame lengths and iterations of the frames

-- the user has the choice to select an input queue priority fifo (NR_IQ_FIFOS = 2)
-- the user has the choice to select an output queue priority fifo (NR_OQ_FIFOS = 2)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity aeg_4ports_tb is
end aeg_4ports_tb;

architecture tb of aeg_4ports_tb is

    -- aeg user constants
    constant NR_PORTS                       : integer := 4; -- only four in this testbench
    constant FABRIC_DATA_WIDTH              : integer := 32; -- for other values, the memories and the constants of the address width have to be adjusted
                                                                -- input queue + output queue --> mem address width
                                                                -- input queue + output queue mem --> change ip data width
                                                                -- input queue control --> (de-)comment process at bottom accordingly
    constant ARBITRATION                    : integer := 2; -- 1: Round Robin, 2: Priority based, 3: Latency based, 
                                                            -- 4: Weighted prio/latency based, to do: 5: Fair Queuing
    constant NR_IQ_FIFOS                    : integer := 2; -- [ 1, 2]
    constant NR_OQ_FIFOS                    : integer := 2; -- [ 1, 2]
    constant TIMESTAMP_WIDTH                : integer := 64;

    -- aeg fixed constants
    constant GMII_DATA_WIDTH                : integer := 8;
    
    type frame_type is record
        dest : std_logic_vector(7 downto 0);        -- last byte of destination address
        vlan_enable : boolean;                      -- indicates a vlan frame
        vlan_prio : std_logic_vector(2 downto 0);   -- vlan priority
        frame_length : integer;                     -- length of the whole frame (including header)
        iterations : integer;                       -- number of back to back transmissions of this frame
        interframe_gap : integer;                   -- number of clock cycles between subsequent frames
    end record;
    
    type port_stimulus_type is record   -- periodic stimulus of frames frame1 and frame2
        frame1 : frame_type;
        frame2 : frame_type;
        iterations : integer;
    end record;
    
    -- aeg_tb stimuli                              0123
    constant PORT_ENABLED   : std_logic_vector := "1111"; -- determines active ports receiving data
    
    constant frame1_0       : frame_type := (
                                dest => x"21",
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 64,
                                iterations => 1, 
                                interframe_gap => 0);
    constant frame2_0       : frame_type := (
                                dest => x"22", -- port 3 Non RT Traffic 
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 1024, 
                                iterations => 1, 
                                interframe_gap => 19115);
    constant stim0          : port_stimulus_type := (frame1_0, frame2_0, 100);
    
    constant frame1_1       : frame_type := (
                                dest => x"28", 
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 128, 
                                iterations => 1, 
                                interframe_gap => 0); 
    constant frame2_1       : frame_type := (
                                dest => x"02", 
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 970, 
                                iterations => 1, 
                                interframe_gap => 19115); -- RT Traffic 
    constant stim1          : port_stimulus_type := (frame1_1, frame2_1, 100);
    
    constant frame1_2       : frame_type := (
                                dest => x"34", 
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 1518, 
                                iterations => 1, 
                                interframe_gap => 3076);
    constant frame2_2       : frame_type := (
                                dest => x"38", 
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 64, 
                                iterations => 0, 
                                interframe_gap => 0);
    constant stim2          : port_stimulus_type := (frame1_2, frame2_2, 0);
    
    constant frame1_3       : frame_type := (
                                dest => x"44", 
                                vlan_enable => true,
                                vlan_prio => "001",
                                frame_length => 200, 
                                iterations => 1, 
                                interframe_gap => 440);
    constant frame2_3       : frame_type := (
                                dest => x"48", 
                                vlan_enable => false,
                                vlan_prio => "000",
                                frame_length => 750, 
                                iterations => 1, 
                                interframe_gap => 1540);
    constant stim3          : port_stimulus_type := (frame1_3, frame2_3, 0);
        
    constant DA                             : std_logic_vector := x"DA";
    constant SA                             : std_logic_vector := x"5A";

    constant MAX_FRAME_LENGTH               : integer := 1522; 

    -- testbench evaluation datatyps
    type statistics_type is record
        received_messages : integer; -- counter of received messages of this destination address
        latency_100 : integer; -- number of messages up to 100 clock cycles
        latency101_150 : integer;
        latency151_200 : integer;
        latency201_250 : integer;
        latency251_300 : integer;
        latency301_350 : integer;
        latency351_400 : integer;
        latency401_450 : integer;
        latency451_500 : integer;
        latency501_600 : integer;
        latency601_700 : integer;
        latency701_800 : integer;
        latency801_900 : integer;
        latency901_1000 : integer;
        latency1001_1200 : integer;
        latency1201_1400 : integer;
        latency1401_1600 : integer;
        latency1601_1800 : integer;
        latency1801_2000 : integer;
        latency2001_2200 : integer;
        latency2201_2400 : integer;
        latency2401_2600 : integer;
        latency2601_2800 : integer;
        latency2801_3000 : integer;
        latency3001_3500 : integer;
        latency3501_4000 : integer;
        latency4001_4500 : integer;
        latency4501_5000 : integer;
        latency5001_5500 : integer;
        latency5501_6000 : integer;
        latency6001_6500 : integer;
        latency6501_7000 : integer;
        latency7001_7500 : integer;
        latency7501_8000 : integer;
        latency8001_8500 : integer;
        latency8501_9000 : integer;
        latency9001_9500 : integer;
        latency9501_10000 : integer;
        latency10001_12000 : integer;
        latency12001_14000 : integer;
        latency14001_16000 : integer;
        latency16001_18000 : integer;
        latency180001_20000 : integer;
        latency20001_22500 : integer;
        latency22501_25000 : integer;
        latency25001_27500 : integer;
        latency27501_30000 : integer;
        latency30001_32500 : integer;
        latency32501_35000 : integer;
        latency35000x : integer;
    end record;
    
    type statistics_vector_type is array (0 to 255) of statistics_type;
    type port_stats_type is record
        received_frames : integer;
        stat_vec : statistics_vector_type;
    end record;
    
    signal port_stats0  : port_stats_type := (received_frames => 0, stat_vec => (others => (others => 0)));
    signal port_stats1  : port_stats_type := (received_frames => 0, stat_vec => (others => (others => 0)));
    signal port_stats2  : port_stats_type := (received_frames => 0, stat_vec => (others => (others => 0)));
    signal port_stats3  : port_stats_type := (received_frames => 0, stat_vec => (others => (others => 0)));
    
    component automotive_ethernet_gateway is
    Generic (
		RECEIVER_DATA_WIDTH       	: integer := 8;
		TRANSMITTER_DATA_WIDTH      : integer := 8;
		FABRIC_DATA_WIDTH           : integer := 32;
		NR_PORTS                    : integer := 4;
		ARBITRATION                 : integer := 1;
		FRAME_LENGTH_WIDTH          : integer := 11;
		NR_IQ_FIFOS                 : integer := 2;
		NR_OQ_FIFOS                 : integer := 2;
		TIMESTAMP_WIDTH             : integer := 64;
		GMII_DATA_WIDTH             : integer := 8;
		TX_IFG_DELAY_WIDTH          : integer := 8;
		PAUSE_VAL_WIDTH             : integer := 16
	);
    port (
		-- asynchronous reset
		glbl_rst                    : in  std_logic;
		-- 200MHz clock input from board
		clk_in_p                    : in  std_logic;
		clk_in_n                    : in  std_logic;
		phy_resetn                  : out std_logic_vector(NR_PORTS-1 downto 0);
		intn                        : in std_logic_vector(NR_PORTS-1 downto 0);
        latency                     : out std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
		-- GMII Interface
		-----------------
		gmii_txd                    : out std_logic_vector(NR_PORTS*GMII_DATA_WIDTH-1 downto 0);
		gmii_tx_en                  : out std_logic_vector(NR_PORTS-1 downto 0);
		gmii_tx_er                  : out std_logic_vector(NR_PORTS-1 downto 0);
		gmii_tx_clk                 : out std_logic_vector(NR_PORTS-1 downto 0);
		gmii_rxd                    : in  std_logic_vector(NR_PORTS*GMII_DATA_WIDTH-1 downto 0);
		gmii_rx_dv                  : in  std_logic_vector(NR_PORTS-1 downto 0);
		gmii_rx_er                  : in  std_logic_vector(NR_PORTS-1 downto 0);
		gmii_rx_clk                 : in  std_logic_vector(NR_PORTS-1 downto 0);
		mii_tx_clk                  : in  std_logic_vector(NR_PORTS-1 downto 0);
		-- MDIO Interface
		-----------------
		mdio                        : inout std_logic_vector(NR_PORTS-1 downto 0);
		mdc                         : out std_logic_vector(NR_PORTS-1 downto 0)
    );
    end component;

    ------------------------------------------------------------------------------
    -- types to support frame data
    ------------------------------------------------------------------------------
    type data_typ is record
        data : std_logic_vector(7 downto 0);        -- data
        valid : std_logic;                          -- data_valid
        error : std_logic;                          -- data_error
    end record;
    type frame_of_data_typ is array (natural range <>) of data_typ;
  
    type frame_typ is record
        columns   : frame_of_data_typ(0 to MAX_FRAME_LENGTH); -- data field
        interframe_gap : integer;
    end record;
  
    ------------------------------------------------------------------------------
    -- Stimulus - Frame data
    ------------------------------------------------------------------------------
    shared variable frame_data0 : frame_typ;
    shared variable frame_data1 : frame_typ;
    shared variable frame_data2 : frame_typ;
    shared variable frame_data3 : frame_typ;

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
    
    function init_frame(
        dest6               : in std_logic_vector(7 downto 0);
        source6             : in std_logic_vector(7 downto 0);
        vlan_enable         : in boolean;
        vlan_priority       : in std_logic_vector(2 downto 0);
        length              : in integer;
        interframe_gap      : in integer
    )
    return frame_typ is
        variable frame_data     : frame_typ;
        variable length_type    : std_logic_vector(15 downto 0);
        variable data_byte      : std_logic_vector(15 downto 0);
        variable i              : integer;
        variable vlan_bytes     : integer := 0;
    begin
        if dest6 = x"FF" then
            frame_data.columns(0) := ( DATA => dest6, VALID => '1', ERROR => '0'); -- Destination Address, 
            frame_data.columns(1) := ( DATA => dest6, VALID => '1', ERROR => '0');
            frame_data.columns(2) := ( DATA => dest6, VALID => '1', ERROR => '0');
            frame_data.columns(3) := ( DATA => dest6, VALID => '1', ERROR => '0');
            frame_data.columns(4) := ( DATA => dest6, VALID => '1', ERROR => '0');
        else
            frame_data.columns(0) := ( DATA => DA, VALID => '1', ERROR => '0'); -- Destination Address, 
            frame_data.columns(1) := ( DATA => DA, VALID => '1', ERROR => '0');
            frame_data.columns(2) := ( DATA => DA, VALID => '1', ERROR => '0');
            frame_data.columns(3) := ( DATA => DA, VALID => '1', ERROR => '0');
            frame_data.columns(4) := ( DATA => DA, VALID => '1', ERROR => '0');
        end if;
        frame_data.columns(5) := ( DATA => dest6, VALID => '1', ERROR => '0');
        frame_data.columns(6) := ( DATA => SA, VALID => '1', ERROR => '0'); -- Source Address
        frame_data.columns(7) := ( DATA => SA, VALID => '1', ERROR => '0');
        frame_data.columns(8) := ( DATA => SA, VALID => '1', ERROR => '0');
        frame_data.columns(9) := ( DATA => SA, VALID => '1', ERROR => '0');
        frame_data.columns(10) := ( DATA => SA, VALID => '1', ERROR => '0');
        frame_data.columns(11) := ( DATA => source6, VALID => '1', ERROR => '0');
        -- VLAN
        if vlan_enable then
            vlan_bytes := 4;
            frame_data.columns(12) := ( DATA => x"81", VALID => '1', ERROR => '0'); -- VLAN Identifier
            frame_data.columns(13) := ( DATA => x"00", VALID => '1', ERROR => '0');
            data_byte := x"00" & vlan_priority & "00000"; -- VLAN Priority
            frame_data.columns(14) := ( DATA => data_byte(7 downto 0), VALID => '1', ERROR => '0');
            frame_data.columns(15) := ( DATA => x"00", VALID => '1', ERROR => '0');
        end if;
        -- Length/Type
        length_type := std_logic_vector(to_unsigned(length-18-vlan_bytes,length_type'length));
        frame_data.columns(12+vlan_bytes) := ( DATA => length_type(15 downto 8), VALID => '1', ERROR => '0'); 
        frame_data.columns(13+vlan_bytes) := ( DATA => length_type(7 downto 0), VALID => '1', ERROR => '0');
        -- Payload
        i := 14+vlan_bytes;
        while i < length - 4 loop
            data_byte := std_logic_vector(to_unsigned(i-13-vlan_bytes ,data_byte'length));
            frame_data.columns(i) := ( DATA => data_byte(7 downto 0), VALID => '1', ERROR => '0'); 
            i := i+1;
        end loop;
        -- Padding
        while i < 60+vlan_bytes loop
            frame_data.columns(i) := ( DATA => X"00", VALID => '1', ERROR => '0'); 
            i := i+1;
        end loop;
        -- Stop writing
        frame_data.columns(i) := ( DATA => X"00", VALID => '0', ERROR => '0'); 
        -- interframe_gap
        frame_data.interframe_gap := interframe_gap;
        return frame_data;
    end init_frame;
    
    function update_stats(
        port_stats_in      : in port_stats_type;
        data               : in std_logic_vector(7 downto 0);
        latency            : in std_logic_vector(63 downto 0)
    )
    return port_stats_type is
        variable port_stats         : port_stats_type;
        variable data_int           : integer;
        variable latency_int        : integer;
    begin
        data_int := to_integer(unsigned(data));
        latency_int := to_integer(unsigned(latency));
        port_stats := port_stats_in;
        
        port_stats.received_frames := port_stats.received_frames + 1;
        port_stats.stat_vec(data_int).received_messages := port_stats.stat_vec(data_int).received_messages + 1;
        if latency_int <= 100 then
            port_stats.stat_vec(data_int).latency_100 := port_stats.stat_vec(data_int).latency_100 + 1;
        elsif latency_int <= 150 then
            port_stats.stat_vec(data_int).latency101_150 := port_stats.stat_vec(data_int).latency101_150 + 1;
        elsif latency_int <= 200 then
            port_stats.stat_vec(data_int).latency151_200 := port_stats.stat_vec(data_int).latency151_200 + 1;
        elsif latency_int <= 250 then
            port_stats.stat_vec(data_int).latency201_250 := port_stats.stat_vec(data_int).latency201_250 + 1;
        elsif latency_int <= 300 then
            port_stats.stat_vec(data_int).latency251_300 := port_stats.stat_vec(data_int).latency251_300 + 1;
        elsif latency_int <= 350 then
            port_stats.stat_vec(data_int).latency301_350 := port_stats.stat_vec(data_int).latency301_350 + 1;
        elsif latency_int <= 400 then
            port_stats.stat_vec(data_int).latency351_400 := port_stats.stat_vec(data_int).latency351_400 + 1;
        elsif latency_int <= 450 then
            port_stats.stat_vec(data_int).latency401_450 := port_stats.stat_vec(data_int).latency401_450 + 1;
        elsif latency_int <= 500 then
            port_stats.stat_vec(data_int).latency451_500 := port_stats.stat_vec(data_int).latency451_500 + 1;
        elsif latency_int <= 600 then
            port_stats.stat_vec(data_int).latency501_600 := port_stats.stat_vec(data_int).latency501_600 + 1;
        elsif latency_int <= 700 then
            port_stats.stat_vec(data_int).latency601_700 := port_stats.stat_vec(data_int).latency601_700 + 1;
        elsif latency_int <= 800 then
            port_stats.stat_vec(data_int).latency701_800 := port_stats.stat_vec(data_int).latency701_800 + 1;
        elsif latency_int <= 900 then
            port_stats.stat_vec(data_int).latency801_900 := port_stats.stat_vec(data_int).latency801_900 + 1;
        elsif latency_int <= 1000 then
            port_stats.stat_vec(data_int).latency901_1000 := port_stats.stat_vec(data_int).latency901_1000 + 1;
        elsif latency_int <= 1200 then
            port_stats.stat_vec(data_int).latency1001_1200 := port_stats.stat_vec(data_int).latency1001_1200 + 1;
        elsif latency_int <= 1400 then
            port_stats.stat_vec(data_int).latency1201_1400 := port_stats.stat_vec(data_int).latency1201_1400 + 1;
        elsif latency_int <= 1600 then
            port_stats.stat_vec(data_int).latency1401_1600 := port_stats.stat_vec(data_int).latency1401_1600 + 1;
        elsif latency_int <= 1800 then
            port_stats.stat_vec(data_int).latency1601_1800 := port_stats.stat_vec(data_int).latency1601_1800 + 1;
        elsif latency_int <= 2000 then
            port_stats.stat_vec(data_int).latency1801_2000 := port_stats.stat_vec(data_int).latency1801_2000 + 1;
        elsif latency_int <= 2200 then
            port_stats.stat_vec(data_int).latency2001_2200 := port_stats.stat_vec(data_int).latency2001_2200 + 1;
        elsif latency_int <= 2400 then
            port_stats.stat_vec(data_int).latency2201_2400 := port_stats.stat_vec(data_int).latency2201_2400 + 1;
        elsif latency_int <= 2600 then
            port_stats.stat_vec(data_int).latency2401_2600 := port_stats.stat_vec(data_int).latency2401_2600 + 1;
        elsif latency_int <= 2800 then
            port_stats.stat_vec(data_int).latency2601_2800 := port_stats.stat_vec(data_int).latency2601_2800 + 1;
        elsif latency_int <= 3000 then
            port_stats.stat_vec(data_int).latency2801_3000 := port_stats.stat_vec(data_int).latency2801_3000 + 1;
        elsif latency_int <= 3500 then
            port_stats.stat_vec(data_int).latency3001_3500 := port_stats.stat_vec(data_int).latency3001_3500 + 1;
        elsif latency_int <= 4000 then
            port_stats.stat_vec(data_int).latency3501_4000 := port_stats.stat_vec(data_int).latency3501_4000 + 1;
        elsif latency_int <= 4500 then
            port_stats.stat_vec(data_int).latency4001_4500 := port_stats.stat_vec(data_int).latency4001_4500 + 1;
        elsif latency_int <= 5000 then
            port_stats.stat_vec(data_int).latency4501_5000 := port_stats.stat_vec(data_int).latency4501_5000 + 1;
        elsif latency_int <= 5500 then
            port_stats.stat_vec(data_int).latency5001_5500 := port_stats.stat_vec(data_int).latency5001_5500 + 1;
        elsif latency_int <= 6000 then
            port_stats.stat_vec(data_int).latency5501_6000 := port_stats.stat_vec(data_int).latency5501_6000 + 1;
        elsif latency_int <= 6500 then
            port_stats.stat_vec(data_int).latency6001_6500 := port_stats.stat_vec(data_int).latency6001_6500 + 1;
        elsif latency_int <= 7000 then
            port_stats.stat_vec(data_int).latency6501_7000 := port_stats.stat_vec(data_int).latency6501_7000 + 1;
        elsif latency_int <= 7500 then
            port_stats.stat_vec(data_int).latency7001_7500 := port_stats.stat_vec(data_int).latency7001_7500 + 1;
        elsif latency_int <= 8000 then
            port_stats.stat_vec(data_int).latency7501_8000 := port_stats.stat_vec(data_int).latency7501_8000 + 1;
        elsif latency_int <= 8500 then
            port_stats.stat_vec(data_int).latency8001_8500 := port_stats.stat_vec(data_int).latency8001_8500 + 1;
        elsif latency_int <= 9000 then
            port_stats.stat_vec(data_int).latency8501_9000 := port_stats.stat_vec(data_int).latency8501_9000 + 1;
        elsif latency_int <= 9500 then
            port_stats.stat_vec(data_int).latency9001_9500 := port_stats.stat_vec(data_int).latency9001_9500 + 1;
        elsif latency_int <= 10000 then
            port_stats.stat_vec(data_int).latency9501_10000 := port_stats.stat_vec(data_int).latency9501_10000 + 1;
        elsif latency_int <= 12000 then
            port_stats.stat_vec(data_int).latency10001_12000 := port_stats.stat_vec(data_int).latency10001_12000 + 1;
        elsif latency_int <= 14000 then
            port_stats.stat_vec(data_int).latency12001_14000 := port_stats.stat_vec(data_int).latency12001_14000 + 1;
        elsif latency_int <= 16000 then
            port_stats.stat_vec(data_int).latency14001_16000 := port_stats.stat_vec(data_int).latency14001_16000 + 1;
        elsif latency_int <= 18000 then
            port_stats.stat_vec(data_int).latency16001_18000 := port_stats.stat_vec(data_int).latency16001_18000 + 1;
        elsif latency_int <= 20000 then
            port_stats.stat_vec(data_int).latency180001_20000 := port_stats.stat_vec(data_int).latency180001_20000 + 1;
        elsif latency_int <= 22500 then
            port_stats.stat_vec(data_int).latency20001_22500 := port_stats.stat_vec(data_int).latency20001_22500 + 1;
        elsif latency_int <= 25000 then
            port_stats.stat_vec(data_int).latency22501_25000 := port_stats.stat_vec(data_int).latency22501_25000 + 1;
        elsif latency_int <= 27500 then
            port_stats.stat_vec(data_int).latency25001_27500 := port_stats.stat_vec(data_int).latency25001_27500 + 1;
        elsif latency_int <= 30000 then
            port_stats.stat_vec(data_int).latency27501_30000 := port_stats.stat_vec(data_int).latency27501_30000 + 1;
        elsif latency_int <= 32500 then
            port_stats.stat_vec(data_int).latency30001_32500 := port_stats.stat_vec(data_int).latency30001_32500 + 1;
        elsif latency_int <= 35000 then
            port_stats.stat_vec(data_int).latency32501_35000 := port_stats.stat_vec(data_int).latency32501_35000 + 1;
        else
            port_stats.stat_vec(data_int).latency35000x := port_stats.stat_vec(data_int).latency35000x + 1;
        end if;
        return port_stats;
    end update_stats;
    

    -- testbench signals
    constant gtx_period : time := 2.5 ns;
    signal gtx_clk              : std_logic;
    signal gtx_clkn             : std_logic;
    signal reset                : std_logic := '0';
    signal demo_mode_error      : std_logic_vector(3 downto 0) := (others => '0');
  
--    signal mdc                  : std_logic_vector(NR_PORTS-1 downto 0);
--    signal mdio                 : std_logic_vector(NR_PORTS-1 downto 0);
    signal gmii_tx_clk          : std_logic_vector(NR_PORTS-1 downto 0);
    signal gmii_tx_en           : std_logic_vector(NR_PORTS-1 downto 0);
    signal gmii_tx_er           : std_logic_vector(NR_PORTS-1 downto 0);
    signal gmii_txd             : std_logic_vector(NR_PORTS*GMII_DATA_WIDTH-1 downto 0) := (others => '0');
    signal gmii_rx_clk          : std_logic_vector(NR_PORTS-1 downto 0);
    signal gmii_rx_dv           : std_logic_vector(NR_PORTS-1 downto 0) := (others => '0');
    signal gmii_rx_er           : std_logic_vector(NR_PORTS-1 downto 0) := (others => '0');
    signal gmii_rxd             : std_logic_vector(NR_PORTS*GMII_DATA_WIDTH-1 downto 0) := (others => '0');
    signal mii_tx_clk           : std_logic_vector(NR_PORTS-1 downto 0) := (others => '0');
    signal mdc                  : std_logic_vector(NR_PORTS-1 downto 0) := (others => '0');
    signal mdio                 : std_logic_vector(NR_PORTS-1 downto 0) := (others => '0');
    signal latency              : std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
    signal latency0             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal latency1             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal latency2             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal latency3             : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    -- testbench control signals
    signal reset_finished : boolean := false;
    signal port0_finished : boolean := false;
    signal port1_finished : boolean := false;
    signal port2_finished : boolean := false;
    signal port3_finished : boolean := false;
    
begin
    
    latency0 <= latency(63 downto 0);
    latency1 <= latency(127 downto 64);
    latency2 <= latency(191 downto 128);
    latency3 <= latency(255 downto 192);
    
    ------------------------------------------------------------------------------
    -- Wire up Device Under Test
    ------------------------------------------------------------------------------
    dut: automotive_ethernet_gateway
    generic map(
        NR_PORTS             => NR_PORTS,
        FABRIC_DATA_WIDTH    => FABRIC_DATA_WIDTH,
        ARBITRATION          => ARBITRATION,
        NR_IQ_FIFOS          => NR_IQ_FIFOS,
        NR_OQ_FIFOS          => NR_OQ_FIFOS,
        TIMESTAMP_WIDTH      => TIMESTAMP_WIDTH
    )
    port map (
        -- asynchronous reset
        --------------------------------
        glbl_rst             => reset,
        -- 200MHz clock input from board
        clk_in_p             => gtx_clk,
        clk_in_n             => gtx_clkn,
        phy_resetn           => open,
        intn                 => "0000",
        latency              => latency,
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
        wait for 2000 us;
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
    -- init process. 
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
    begin
        assert false
            report "Timing checks are not valid" & cr
            severity note;
        wait for 800 ns;
        mac_reset;
        reset_finished <= true;
        wait;
    end process p_init;
    
    p_stop : process
    begin
        wait until port3_finished and port2_finished and port1_finished and port0_finished;
        if demo_mode_error /= 0 then
            assert false
                report "Errors occured"
                severity error;
        end if;
        wait for 100 us;
        assert false
            report "Simulation Completed without errors"
            severity failure;
    end process p_stop;
   
    ------------------------------------------------------------------------------
    -- Stimulus process on port 0 (traffic generator)
    ------------------------------------------------------------------------------
    p_stimulus0 : process
        ------------------------------
        -- Procedure to inject a frame
        ------------------------------
        procedure send_frame is
            variable current_col   : natural := 0;  -- Column counter within frame
            variable fcs           : std_logic_vector(31 downto 0);
        begin
            wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Adding the preamble field
            for j in 0 to 7 loop
                gmii_rxd(7 downto 0)  <= "01010101";
                gmii_rx_dv(0)           <= '1';
                gmii_rx_er(0)           <= '0';
                wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            end loop;
            -- Adding the Start of Frame Delimiter (SFD)
            gmii_rxd(7 downto 0)  <= "11010101";
            gmii_rx_dv(0)           <= '1';
            wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            current_col := 0;
            gmii_rxd(7 downto 0)  <= frame_data0.columns(current_col).data;
            gmii_rx_dv(0)           <= frame_data0.columns(current_col).valid;
            gmii_rx_er(0)           <= frame_data0.columns(current_col).error;
            fcs          := calc_crc(frame_data0.columns(current_col).data, fcs);
            wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            current_col := current_col + 1;
            -- loop over columns in frame.
            while frame_data0.columns(current_col).valid /= '0' loop
                -- send one column of data
                gmii_rxd(7 downto 0)  <= frame_data0.columns(current_col).data;
                gmii_rx_dv(0)           <= frame_data0.columns(current_col).valid;
                gmii_rx_er(0)           <= frame_data0.columns(current_col).error;
                fcs        := calc_crc(frame_data0.columns(current_col).data, fcs);
                current_col := current_col + 1;
                wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            end loop;
            -- Send the CRC.
            for j in 0 to 3 loop
                gmii_rxd(7 downto 0)  <= fcs(((8*j)+7) downto (8*j));
                gmii_rx_dv(0)           <= '1';
                gmii_rx_er(0)           <= '0';
                wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            end loop;
            -- Clear the data lines.
            gmii_rxd(7 downto 0)      <= (others => '0');
            gmii_rx_dv(0)               <=  '0';
            -- Adding the minimum Interframe gap for a receiver (12 idles)
            for j in 0 to 9 loop
                wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            end loop;
            -- Adding further interframe gap as secified by the user
            for j in 0 to frame_data0.interframe_gap loop
                wait until gmii_rx_clk(0)'event and gmii_rx_clk(0) = '1';
            end loop;
        end send_frame;
        
        variable frame_sa   : std_logic_vector(7 downto 0);
        variable frame_da   : std_logic_vector(7 downto 0);
    begin
        -- Wait for the Management MDIO transaction to finish.
        wait until reset_finished;
        -- Wait for the internal resets to settle
        wait for 800 ns;
        frame_sa := X"00";
        if PORT_ENABLED(0) = '0' then
            port0_finished <= true;
        else
            for i in 0 to stim0.iterations-1 loop
                for j in 0 to stim0.frame1.iterations-1 loop
                    frame_data0 := init_frame(stim0.frame1.dest, frame_sa, stim0.frame1.vlan_enable,
                                                stim0.frame1.vlan_prio, stim0.frame1.frame_length, stim0.frame1.interframe_gap);
                    send_frame;
                end loop;
                for j in 0 to stim0.frame2.iterations-1 loop
                    frame_data0 := init_frame(stim0.frame2.dest, frame_sa, stim0.frame2.vlan_enable,
                                                stim0.frame2.vlan_prio, stim0.frame2.frame_length, stim0.frame2.interframe_gap);
                    send_frame;
                end loop;
            end loop;
            port0_finished <= true;
        end if;
    end process p_stimulus0;
   
    ------------------------------------------------------------------------------
    -- Stimulus process on port 1
    ------------------------------------------------------------------------------
    p_stimulus1 : process
        ------------------------------
        -- Procedure to inject a frame
        ------------------------------
        procedure send_frame is
            variable current_col   : natural := 0;  -- Column counter within frame
            variable fcs           : std_logic_vector(31 downto 0);
        begin
            wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Adding the preamble field
            for j in 0 to 7 loop
                gmii_rxd(15 downto 8)  <= "01010101";
                gmii_rx_dv(1)           <= '1';
                gmii_rx_er(1)           <= '0';
                wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            end loop;
            -- Adding the Start of Frame Delimiter (SFD)
            gmii_rxd(15 downto 8)   <= "11010101";
            gmii_rx_dv(1)           <= '1';
            wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            current_col := 0;
            gmii_rxd(15 downto 8)   <= frame_data1.columns(current_col).data;
            gmii_rx_dv(1)           <= frame_data1.columns(current_col).valid;
            gmii_rx_er(1)           <= frame_data1.columns(current_col).error;
            fcs          := calc_crc(frame_data1.columns(current_col).data, fcs);
            wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            current_col := current_col + 1;
            -- loop over columns in frame.
            while frame_data1.columns(current_col).valid /= '0' loop
                -- send one column of data
                gmii_rxd(15 downto 8)  <= frame_data1.columns(current_col).data;
                gmii_rx_dv(1)           <= frame_data1.columns(current_col).valid;
                gmii_rx_er(1)           <= frame_data1.columns(current_col).error;
                fcs        := calc_crc(frame_data1.columns(current_col).data, fcs);
                current_col := current_col + 1;
                wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            end loop;
            -- Send the CRC.
            for j in 0 to 3 loop
                gmii_rxd(15 downto 8)  <= fcs(((8*j)+7) downto (8*j));
                gmii_rx_dv(1)           <= '1';
                gmii_rx_er(1)           <= '0';
                wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            end loop;
            -- Clear the data lines.
            gmii_rxd(15 downto 8)      <= (others => '0');
            gmii_rx_dv(1)               <=  '0';
            -- Adding the minimum Interframe gap for a receiver (12 idles)
            for j in 0 to 9 loop
                wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            end loop;
            -- Adding further interframe gap as secified by the user
            for j in 0 to frame_data1.interframe_gap loop
                wait until gmii_rx_clk(1)'event and gmii_rx_clk(1) = '1';
            end loop;
        end send_frame;
        
        variable frame_sa   : std_logic_vector(7 downto 0);
        variable frame_da   : std_logic_vector(7 downto 0);
    begin
        -- Wait for the Management MDIO transaction to finish.
        wait until reset_finished;
        -- Wait for the internal resets to settle
        wait for 800 ns;
        -- inject frames back to back
        frame_sa := X"01";
        if PORT_ENABLED(1) = '0' then
            port1_finished <= true;
        else
            for i in 0 to stim1.iterations-1 loop
                for j in 0 to stim1.frame1.iterations-1 loop
                    frame_data1 := init_frame(stim1.frame1.dest, frame_sa, stim1.frame1.vlan_enable,
                                                stim1.frame1.vlan_prio, stim1.frame1.frame_length, stim1.frame1.interframe_gap);
                    send_frame;
                end loop;
                for j in 0 to stim1.frame2.iterations-1 loop
                    frame_data1 := init_frame(stim1.frame2.dest, frame_sa, stim1.frame2.vlan_enable,
                                                stim1.frame2.vlan_prio, stim1.frame2.frame_length, stim1.frame2.interframe_gap);
                    send_frame;
                end loop;
            end loop;
            port1_finished <= true;
        end if;
    end process p_stimulus1;
   
    ------------------------------------------------------------------------------
    -- Stimulus process on port 2
    ------------------------------------------------------------------------------
    p_stimulus2 : process
        ------------------------------
        -- Procedure to inject a frame
        ------------------------------
        procedure send_frame is
            variable current_col   : natural := 0;  -- Column counter within frame
            variable fcs           : std_logic_vector(31 downto 0);
        begin
            wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Adding the preamble field
            for j in 0 to 7 loop
                gmii_rxd(23 downto 16)  <= "01010101";
                gmii_rx_dv(2)           <= '1';
                gmii_rx_er(2)           <= '0';
                wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            end loop;
            -- Adding the Start of Frame Delimiter (SFD)
            gmii_rxd(23 downto 16)  <= "11010101";
            gmii_rx_dv(2)           <= '1';
            wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            current_col := 0;
            gmii_rxd(23 downto 16)  <= frame_data2.columns(current_col).data;
            gmii_rx_dv(2)           <= frame_data2.columns(current_col).valid;
            gmii_rx_er(2)           <= frame_data2.columns(current_col).error;
            fcs          := calc_crc(frame_data2.columns(current_col).data, fcs);
            wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            current_col := current_col + 1;
            -- loop over columns in frame.
            while frame_data2.columns(current_col).valid /= '0' loop
                -- send one column of data
                gmii_rxd(23 downto 16)  <= frame_data2.columns(current_col).data;
                gmii_rx_dv(2)           <= frame_data2.columns(current_col).valid;
                gmii_rx_er(2)           <= frame_data2.columns(current_col).error;
                fcs        := calc_crc(frame_data2.columns(current_col).data, fcs);
                current_col := current_col + 1;
                wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            end loop;
            -- Send the CRC.
            for j in 0 to 3 loop
                gmii_rxd(23 downto 16)  <= fcs(((8*j)+7) downto (8*j));
                gmii_rx_dv(2)           <= '1';
                gmii_rx_er(2)           <= '0';
                wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            end loop;
            -- Clear the data lines.
            gmii_rxd(23 downto 16)      <= (others => '0');
            gmii_rx_dv(2)               <=  '0';
            -- Adding the minimum Interframe gap for a receiver (12 idles)
            for j in 0 to 9 loop
                wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            end loop;
            -- Adding further interframe gap as secified by the user
            for j in 0 to frame_data2.interframe_gap loop
                wait until gmii_rx_clk(2)'event and gmii_rx_clk(2) = '1';
            end loop;
        end send_frame;
        
        variable frame_sa   : std_logic_vector(7 downto 0);
        variable frame_da   : std_logic_vector(7 downto 0);
    begin
        -- Wait for the Management MDIO transaction to finish.
        wait until reset_finished;
        -- Wait for the internal resets to settle
        wait for 800 ns;
        -- inject frames back to back
        frame_sa := X"02";
        if PORT_ENABLED(2) = '0' then
            port2_finished <= true;
        else
            for i in 0 to stim2.iterations-1 loop
                for j in 0 to stim2.frame1.iterations-1 loop
                    frame_data2 := init_frame(stim2.frame1.dest, frame_sa, stim2.frame1.vlan_enable,
                                                stim2.frame1.vlan_prio, stim2.frame1.frame_length, stim2.frame1.interframe_gap);
                    send_frame;
                end loop;
                for j in 0 to stim2.frame2.iterations-1 loop
                    frame_data2 := init_frame(stim2.frame2.dest, frame_sa, stim2.frame2.vlan_enable,
                                                stim2.frame2.vlan_prio, stim2.frame2.frame_length, stim2.frame2.interframe_gap);
                    send_frame;
                end loop;
            end loop;
            port2_finished <= true;
        end if;
    end process p_stimulus2;
    
    ------------------------------------------------------------------------------
    -- Stimulus process on port 3
    ------------------------------------------------------------------------------
    p_stimulus3 : process
        ------------------------------
        -- Procedure to inject a frame
        ------------------------------
        procedure send_frame is
            variable current_col   : natural := 0;  -- Column counter within frame
            variable fcs           : std_logic_vector(31 downto 0);
        begin
            wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Adding the preamble field
            for j in 0 to 7 loop
                gmii_rxd(31 downto 24)  <= "01010101";
                gmii_rx_dv(3)           <= '1';
                gmii_rx_er(3)           <= '0';
                wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            end loop;
            -- Adding the Start of Frame Delimiter (SFD)
            gmii_rxd(31 downto 24)  <= "11010101";
            gmii_rx_dv(3)           <= '1';
            wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            current_col := 0;
            gmii_rxd(31 downto 24)  <= frame_data3.columns(current_col).data;
            gmii_rx_dv(3)           <= frame_data3.columns(current_col).valid;
            gmii_rx_er(3)           <= frame_data3.columns(current_col).error;
            fcs          := calc_crc(frame_data3.columns(current_col).data, fcs);
            wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            current_col := current_col + 1;
            -- loop over columns in frame.
            while frame_data3.columns(current_col).valid /= '0' loop
                -- send one column of data
                gmii_rxd(31 downto 24)  <= frame_data3.columns(current_col).data;
                gmii_rx_dv(3)           <= frame_data3.columns(current_col).valid;
                gmii_rx_er(3)           <= frame_data3.columns(current_col).error;
                fcs        := calc_crc(frame_data3.columns(current_col).data, fcs);
                current_col := current_col + 1;
                wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            end loop;
            -- Send the CRC.
            for j in 0 to 3 loop
                gmii_rxd(31 downto 24)  <= fcs(((8*j)+7) downto (8*j));
                gmii_rx_dv(3)           <= '1';
                gmii_rx_er(3)           <= '0';
                wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            end loop;
            -- Clear the data lines.
            gmii_rxd(31 downto 24)      <= (others => '0');
            gmii_rx_dv(3)               <=  '0';
            -- Adding the minimum Interframe gap for a receiver (12 idles)
            for j in 0 to 9 loop
                wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            end loop;
            -- Adding further interframe gap as secified by the user
            for j in 0 to frame_data3.interframe_gap loop
                wait until gmii_rx_clk(3)'event and gmii_rx_clk(3) = '1';
            end loop;
        end send_frame;
        
        variable frame_sa   : std_logic_vector(7 downto 0);
        variable frame_da   : std_logic_vector(7 downto 0);
    begin
        -- Wait for the Management MDIO transaction to finish.
        wait until reset_finished;
        -- Wait for the internal resets to settle
        wait for 800 ns;
        -- inject frames back to back
        frame_sa := X"03";
        if PORT_ENABLED(3) = '0' then
            port3_finished <= true;
        else
            for i in 0 to stim3.iterations-1 loop
                for j in 0 to stim3.frame1.iterations-1 loop
                    frame_data3 := init_frame(stim3.frame1.dest, frame_sa, stim3.frame1.vlan_enable,
                                                stim3.frame1.vlan_prio, stim3.frame1.frame_length, stim3.frame1.interframe_gap);
                    send_frame;
                end loop;
                for j in 0 to stim3.frame2.iterations-1 loop
                    frame_data3 := init_frame(stim3.frame2.dest, frame_sa, stim3.frame2.vlan_enable,
                                                stim3.frame2.vlan_prio, stim3.frame2.frame_length, stim3.frame2.interframe_gap);
                    send_frame;
                end loop;
            end loop;
            port3_finished <= true;
        end if;
    end process p_stimulus3;
    
    ------------------------------------------------------------------------------
    -- Monitor process. This process checks the data coming out of the
    -- transmitter to make sure that it matches that inserted into the
    -- receiver.
    ------------------------------------------------------------------------------
    p_monitor0 : process
        procedure check_frame is
            variable current_col    : natural := 0;
            variable byte_cnt       : natural := 0;
            variable fcs            : std_logic_vector(31 downto 0);
            variable length         : std_logic_vector(15 downto 0);
            variable vlan_bytes     : natural := 0;
        begin
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Parse over the preamble field
            while gmii_tx_en(0) /= '1' or gmii_txd(7 downto 0) = "01010101" loop
                wait until gmii_tx_clk(0)'event and gmii_tx_clk(0) = '1';
            end loop;
            -- Parse over the Start of Frame Delimiter (SFD)
            if (gmii_txd(7 downto 0) /= "11010101") then
                assert false
                    report "SFD not present @ Port 0" & cr
                    severity error;
            end if;
            wait until gmii_tx_clk(0)'event and gmii_tx_clk(0) = '1';
            -- frame has started, loop over columns of frame
            while current_col < 60+vlan_bytes or  byte_cnt < length loop
                -- check destination address
                if current_col < 5 and gmii_txd(7 downto 0) /= x"FF" then
                    if gmii_txd(7 downto 0) /= DA then
                        demo_mode_error(0) <= '1';
                        assert false
                            report "gmii_txd incorrect during Destination Address field @ Port 0" & cr
                            severity error;
                    end if;
                end if;
                if current_col = 5 then
                    port_stats0 <= update_stats(port_stats0, gmii_txd(7 downto 0), latency0);
                end if;
                -- check source address
                if current_col >= 6 and current_col < 11 then
                    if gmii_txd(7 downto 0) /= SA then
                        demo_mode_error(0) <= '1';
                        assert false
                            report "gmii_txd incorrect during Source Address field @ Port 0" & cr
                            severity error;
                    end if;
                end if;
                -- read length / vlan
                if current_col = 12 then
                    if gmii_txd(7 downto 0) = x"81" then
                        vlan_bytes := 4;
                    else
                        vlan_bytes := 0;
                        length(15 downto 8) := gmii_txd(7 downto 0);
                    end if;
                end if;
                if current_col = 13 then
                    if vlan_bytes = 4 then
                        if gmii_txd(7 downto 0) /= x"00" then
                            demo_mode_error(0) <= '1';
                            assert false
                                report "vlan incorrect @ Port 0" & cr
                                severity error;
                        end if;
                    else
                        length(7 downto 0) := gmii_txd(7 downto 0);
                    end if;
                end if;
                if current_col = 16 and vlan_bytes = 4 then
                    length(15 downto 8) := gmii_txd(7 downto 0);
                end if;
                if current_col = 17 and vlan_bytes = 4 then
                    length(7 downto 0) := gmii_txd(7 downto 0);
                end if;
                -- data
                if current_col > 13 + vlan_bytes and byte_cnt < length then
                    byte_cnt := byte_cnt + 1;
                    if gmii_txd(7 downto 0) /= (byte_cnt mod 256) then
                        demo_mode_error(0) <= '1';
                        assert false
                            report "gmii_txd incorrect @ Port 0" & cr
                            severity error;
                    end if;
                -- padding
                elsif current_col < 60 + vlan_bytes and byte_cnt = length then
                    if gmii_txd(7 downto 0) /= x"00" then
                        demo_mode_error(0) <= '1';
                        assert false
                            report "Padding incorrect @ Port 0" & cr
                            severity error;
                    end if;
                end if;
                -- calculate expected crc for the frame
                fcs        := calc_crc(gmii_txd(7 downto 0), fcs);
                current_col        := current_col + 1;
                wait until gmii_tx_clk(0)'event and gmii_tx_clk(0) = '1';
            end loop;  -- while data valid
            -- Check the FCS matches that expected from calculation
            -- Having checked all data columns, txd must contain FCS.
            for j in 0 to 3 loop
                if gmii_tx_en(0) = '0' then
                    demo_mode_error(0) <= '1';
                    assert false
                        report "gmii_tx_en incorrect during FCS field @ Port 0" & cr
                        severity error;
                end if;
                if gmii_txd(7 downto 0) /= fcs(((8*j)+7) downto (8*j)) then
                    demo_mode_error(0) <= '1';
                    assert false
                        report "gmii_txd incorrect during FCS field @ Port 0" & cr
                        severity error;
                end if;
                wait until gmii_tx_clk(0)'event and gmii_tx_clk(0) = '1';
            end loop;  -- j
        end check_frame;
        variable frames_received : natural;
    begin  -- process p_monitor0
        frames_received := 0;
        -- wait for reset to complete before starting monitor to ignore false startup errors
        wait until reset_finished;
        while true loop
            check_frame;
            frames_received := frames_received + 1;
        end loop;
    end process p_monitor0;

    p_monitor1 : process
        procedure check_frame is
            variable current_col    : natural := 0;
            variable byte_cnt       : natural := 0;
            variable fcs            : std_logic_vector(31 downto 0);
            variable length         : std_logic_vector(15 downto 0);
            variable data           : std_logic_vector(7 downto 0);
            variable vlan_bytes     : natural := 0;
        begin
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Parse over the preamble field
            while gmii_tx_en(1) /= '1' or gmii_txd(15 downto 8) = "01010101" loop
                wait until gmii_tx_clk(1)'event and gmii_tx_clk(1) = '1';
            end loop;
            -- Parse over the Start of Frame Delimiter (SFD)
            if (gmii_txd(15 downto 8) /= "11010101") then
                assert false
                    report "SFD not present @ Port 1" & cr
                    severity error;
            end if;
            wait until gmii_tx_clk(1)'event and gmii_tx_clk(1) = '1';
            -- frame has started, loop over columns of frame
            while current_col < 60+vlan_bytes or  byte_cnt < length loop
                -- check destination address
                if current_col < 5 and gmii_txd(15 downto 8) /= x"FF" then
                    if gmii_txd(15 downto 8) /= DA then
                        demo_mode_error(1) <= '1';
                        assert false
                            report "gmii_txd incorrect during Destination Address field @ Port 1" & cr
                            severity error;
                    end if;
                end if;
                if current_col = 5 then
                    port_stats1 <= update_stats(port_stats1, gmii_txd(15 downto 8), latency1);
                end if;
                -- check source address
                if current_col >= 6 and current_col < 11 then
                    if gmii_txd(15 downto 8) /= SA then
                        demo_mode_error(1) <= '1';
                        assert false
                            report "gmii_txd incorrect during Source Address field @ Port 1" & cr
                            severity error;
                    end if;
                end if;
                -- read length / vlan
                if current_col = 12 then
                    if gmii_txd(15 downto 8) = x"81" then
                        vlan_bytes := 4;
                    else
                        vlan_bytes := 0;
                        length(15 downto 8) := gmii_txd(15 downto 8);
                    end if;
                end if;
                if current_col = 13 then
                    if vlan_bytes = 4 then
                        if gmii_txd(15 downto 8) /= x"00" then
                            demo_mode_error(1) <= '1';
                            assert false
                                report "vlan incorrect @ Port 1" & cr
                                severity error;
                        end if;
                    else
                        length(7 downto 0) := gmii_txd(15 downto 8);
                    end if;
                end if;
                if current_col = 16 and vlan_bytes = 4 then
                    length(15 downto 8) := gmii_txd(15 downto 8);
                end if;
                if current_col = 17 and vlan_bytes = 4 then
                    length(7 downto 0) := gmii_txd(15 downto 8);
                end if;
                -- data
                if current_col > 13 + vlan_bytes and byte_cnt < length then
                    byte_cnt := byte_cnt + 1;
                    if gmii_txd(15 downto 8) /= (byte_cnt mod 256) then
                        demo_mode_error(1) <= '1';
                        assert false
                            report "gmii_txd incorrect @ Port 1" & cr
                            severity error;
                    end if;
                -- padding
                elsif current_col < 60 + vlan_bytes and byte_cnt = length then
                    if gmii_txd(15 downto 8) /= x"00" then
                        demo_mode_error(1) <= '1';
                        assert false
                            report "Padding incorrect @ Port 1" & cr
                            severity error;
                    end if;
                end if;
                -- calculate expected crc for the frame
                data := gmii_txd(15 downto 8);
                fcs        := calc_crc(data, fcs);
                current_col        := current_col + 1;
                wait until gmii_tx_clk(1)'event and gmii_tx_clk(1) = '1';
            end loop;  -- while data valid
            -- Check the FCS matches that expected from calculation
            -- Having checked all data columns, txd must contain FCS.
            for j in 0 to 3 loop
                if gmii_tx_en(1) = '0' then
                    demo_mode_error(1) <= '1';
                    assert false
                        report "gmii_tx_en incorrect during FCS field @ Port 1" & cr
                        severity error;
                end if;
                if gmii_txd(15 downto 8) /= fcs(((8*j)+7) downto (8*j)) then
                    demo_mode_error(1) <= '1';
                    assert false
                        report "gmii_txd incorrect during FCS field @ Port 1" & cr
                        severity error;
                end if;
                wait until gmii_tx_clk(1)'event and gmii_tx_clk(1) = '1';
            end loop;  -- j
        end check_frame;
        variable frames_received : natural;
    begin  -- process p_monitor0
        frames_received := 0;
        -- wait for reset to complete before starting monitor to ignore false startup errors
        wait until reset_finished;
        while true loop
            check_frame;
            frames_received := frames_received + 1;
        end loop;
    end process p_monitor1;

    p_monitor2 : process
        procedure check_frame is
            variable current_col    : natural := 0;
            variable byte_cnt       : natural := 0;
            variable fcs            : std_logic_vector(31 downto 0);
            variable length         : std_logic_vector(15 downto 0);
            variable data           : std_logic_vector(7 downto 0);
            variable vlan_bytes     : natural := 0;
        begin
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Parse over the preamble field
            while gmii_tx_en(2) /= '1' or gmii_txd(23 downto 16) = "01010101" loop
                wait until gmii_tx_clk(2)'event and gmii_tx_clk(2) = '1';
            end loop;
            -- Parse over the Start of Frame Delimiter (SFD)
            if (gmii_txd(23 downto 16) /= "11010101") then
                assert false
                    report "SFD not present @ Port 2" & cr
                    severity error;
            end if;
            wait until gmii_tx_clk(2)'event and gmii_tx_clk(2) = '1';
            -- frame has started, loop over columns of frame
            while current_col < 60+vlan_bytes or  byte_cnt < length loop
                -- check destination address
                if current_col < 5 and gmii_txd(23 downto 16) /= x"FF" then
                    if gmii_txd(23 downto 16) /= DA then
                        demo_mode_error(2) <= '1';
                        assert false
                            report "gmii_txd incorrect during Destination Address field @ Port 2" & cr
                            severity error;
                    end if;
                end if;
                if current_col = 5 then
                    port_stats2 <= update_stats(port_stats2, gmii_txd(23 downto 16), latency2);
                end if;
                -- check source address
                if current_col >= 6 and current_col < 11 then
                    if gmii_txd(23 downto 16) /= SA then
                        demo_mode_error(2) <= '1';
                        assert false
                            report "gmii_txd incorrect during Source Address field @ Port 2" & cr
                            severity error;
                    end if;
                end if;
                -- read length / vlan
                if current_col = 12 then
                    if gmii_txd(23 downto 16) = x"81" then
                        vlan_bytes := 4;
                    else
                        vlan_bytes := 0;
                        length(15 downto 8) := gmii_txd(23 downto 16);
                    end if;
                end if;
                if current_col = 13 then
                    if vlan_bytes = 4 then
                        if gmii_txd(23 downto 16) /= x"00" then
                            demo_mode_error(2) <= '1';
                            assert false
                                report "vlan incorrect @ Port 2" & cr
                                severity error;
                        end if;
                    else
                        length(7 downto 0) := gmii_txd(23 downto 16);
                    end if;
                end if;
                if current_col = 16 and vlan_bytes = 4 then
                    length(15 downto 8) := gmii_txd(23 downto 16);
                end if;
                if current_col = 17 and vlan_bytes = 4 then
                    length(7 downto 0) := gmii_txd(23 downto 16);
                end if;
                -- data
                if current_col > 13 + vlan_bytes and byte_cnt < length then
                    byte_cnt := byte_cnt + 1;
                    if gmii_txd(23 downto 16) /= (byte_cnt mod 256) then
                        demo_mode_error(2) <= '1';
                        assert false
                            report "gmii_txd incorrect @ Port 2" & cr
                            severity error;
                    end if;
                -- padding
                elsif current_col < 60 + vlan_bytes and byte_cnt = length then
                    if gmii_txd(23 downto 16) /= x"00" then
                        demo_mode_error(2) <= '1';
                        assert false
                            report "Padding incorrect @ Port 2" & cr
                            severity error;
                    end if;
                end if;
                -- calculate expected crc for the frame
                data := gmii_txd(23 downto 16);
                fcs        := calc_crc(data, fcs);
                current_col        := current_col + 1;
                wait until gmii_tx_clk(2)'event and gmii_tx_clk(2) = '1';
            end loop;
            -- Check the FCS matches that expected from calculation
            -- Having checked all data columns, txd must contain FCS.
            for j in 0 to 3 loop
                if gmii_tx_en(2) = '0' then
                    demo_mode_error(2) <= '1';
                    assert false
                        report "gmii_tx_en incorrect during FCS field @ Port 2" & cr
                        severity error;
                end if;
                if gmii_txd(23 downto 16) /= fcs(((8*j)+7) downto (8*j)) then
                    demo_mode_error(2) <= '1';
                    assert false
                        report "gmii_txd incorrect during FCS field @ Port 2" & cr
                        severity error;
                end if;
                wait until gmii_tx_clk(2)'event and gmii_tx_clk(2) = '1';
            end loop;  -- j
        end check_frame;
        variable frames_received : natural;
    begin  -- process p_monitor0
        frames_received := 0;
        -- wait for reset to complete before starting monitor to ignore false startup errors
        wait until reset_finished;
        while true loop
            check_frame;
            frames_received := frames_received + 1;
        end loop;
    end process p_monitor2;

    p_monitor3 : process
        procedure check_frame is
            variable current_col    : natural := 0;
            variable byte_cnt       : natural := 0;
            variable fcs            : std_logic_vector(31 downto 0);
            variable length         : std_logic_vector(15 downto 0);
            variable data           : std_logic_vector(7 downto 0);
            variable vlan_bytes     : natural := 0;
        begin
            -- Reset the FCS calculation
            fcs         := (others => '0');
            -- Parse over the preamble field
            while gmii_tx_en(3) /= '1' or gmii_txd(31 downto 24) = "01010101" loop
                wait until gmii_tx_clk(3)'event and gmii_tx_clk(3) = '1';
            end loop;
            -- Parse over the Start of Frame Delimiter (SFD)
            if (gmii_txd(31 downto 24) /= "11010101") then
                assert false
                    report "SFD not present @ Port 3" & cr
                    severity error;
            end if;
            wait until gmii_tx_clk(3)'event and gmii_tx_clk(3) = '1';
            -- frame has started, loop over columns of frame
            while current_col < 60+vlan_bytes or  byte_cnt < length loop
                -- check destination address
                if current_col < 5 and gmii_txd(31 downto 24) /= x"FF" then
                    if gmii_txd(31 downto 24) /= DA then
                        demo_mode_error(3) <= '1';
                        assert false
                            report "gmii_txd incorrect during Destination Address field @ Port 3" & cr
                            severity error;
                    end if;
                end if;
                if current_col = 5 then
                    port_stats3 <= update_stats(port_stats3, gmii_txd(31 downto 24), latency3);
                end if;
                -- check source address
                if current_col >= 6 and current_col < 11 then
                    if gmii_txd(31 downto 24) /= SA then
                        demo_mode_error(3) <= '1';
                        assert false
                            report "gmii_txd incorrect during Source Address field @ Port 3" & cr
                            severity error;
                    end if;
                end if;
                -- read length / vlan
                if current_col = 12 then
                    if gmii_txd(31 downto 24) = x"81" then
                        vlan_bytes := 4;
                    else
                        vlan_bytes := 0;
                        length(15 downto 8) := gmii_txd(31 downto 24);
                    end if;
                end if;
                if current_col = 13 then
                    if vlan_bytes = 4 then
                        if gmii_txd(31 downto 24) /= x"00" then
                            demo_mode_error(3) <= '1';
                            assert false
                                report "vlan incorrect @ Port 3" & cr
                                severity error;
                        end if;
                    else
                        length(7 downto 0) := gmii_txd(31 downto 24);
                    end if;
                end if;
                if current_col = 16 and vlan_bytes = 4 then
                    length(15 downto 8) := gmii_txd(31 downto 24);
                end if;
                if current_col = 17 and vlan_bytes = 4 then
                    length(7 downto 0) := gmii_txd(31 downto 24);
                end if;
                -- data
                if current_col > 13 + vlan_bytes and byte_cnt < length then
                    byte_cnt := byte_cnt + 1;
                    if gmii_txd(31 downto 24) /= (byte_cnt mod 256) then
                        demo_mode_error(3) <= '1';
                        assert false
                            report "gmii_txd incorrect @ Port 3" & cr
                            severity error;
                    end if;
                -- padding
                elsif current_col < 60 + vlan_bytes and byte_cnt = length then
                    if gmii_txd(31 downto 24) /= x"00" then
                        demo_mode_error(3) <= '1';
                        assert false
                            report "Padding incorrect @ Port 3" & cr
                            severity error;
                    end if;
                end if;
                -- calculate expected crc for the frame
                data := gmii_txd(31 downto 24);
                fcs        := calc_crc(data, fcs);
                current_col        := current_col + 1;
                wait until gmii_tx_clk(3)'event and gmii_tx_clk(3) = '1';
            end loop;  -- while data valid
            -- Check the FCS matches that expected from calculation
            -- Having checked all data columns, txd must contain FCS.
            for j in 0 to 3 loop
                if gmii_tx_en(3) = '0' then
                    demo_mode_error(3) <= '1';
                    assert false
                        report "gmii_tx_en incorrect during FCS field @ Port 3" & cr
                        severity error;
                end if;
                if gmii_txd(31 downto 24) /= fcs(((8*j)+7) downto (8*j)) then
                    demo_mode_error(3) <= '1';
                    assert false
                        report "gmii_txd incorrect during FCS field @ Port 3" & cr
                        severity error;
                end if;
                wait until gmii_tx_clk(3)'event and gmii_tx_clk(3) = '1';
            end loop;  -- j
        end check_frame;
        variable frames_received : natural;
    begin  -- process p_monitor0
        frames_received := 0;
        -- wait for reset to complete before starting monitor to ignore false startup errors
        wait until reset_finished;
        while true loop
            check_frame;
            frames_received := frames_received + 1;
        end loop;
    end process p_monitor3;
    
end tb;
