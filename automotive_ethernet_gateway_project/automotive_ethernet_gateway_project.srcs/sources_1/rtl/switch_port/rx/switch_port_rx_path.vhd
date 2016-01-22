----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 11.11.2013 14:33:32
-- Design Name: 
-- Module Name: switch_port_0_rx_path - rtl
--
-- Description: This is the input port to the switch fabric
-- it consists of following modules:
-- - header extraction: extract the destination mac address from the current frame
-- - lookup module and lookup memory: determine the output ports for each incoming frame
-- - input queue module: merge the data and control path, store frame in memory and request access to crossbar matrix
--
-- further information can found in file rxpath.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity switch_port_rx_path is
    Generic (
        RECEIVER_DATA_WIDTH    	: integer;
        FABRIC_DATA_WIDTH       : integer;
        NR_PORTS                : integer;
        PORT_ID                 : integer;
        FRAME_LENGTH_WIDTH      : integer;
        NR_IQ_FIFOS             : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer;
        DEST_ADDR_WIDTH         : integer := 48;
        LOOKUP_MEM_ADDR_WIDTH   : integer := 9;
        LOOKUP_MEM_DATA_WIDTH   : integer := 64
    );
    Port (
        rx_path_clock           : in  std_logic;
        rx_path_resetn          : in  std_logic;
        -- mac to rx_path interface
        rx_in_data              : in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        rx_in_valid             : in std_logic;
        rx_in_last              : in std_logic; 
        rx_in_error             : in std_logic;
        -- rx_path interface to fabric
        rx_out_data             : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        rx_out_valid            : out std_logic;
        rx_out_last             : out std_logic;
        rx_out_ports_req        : out std_logic_vector(NR_PORTS-1 downto 0);
        rx_out_prio             : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        rx_out_timestamp        : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        rx_out_length           : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0); 
        rx_out_ports_gnt        : in std_logic_vector(NR_PORTS-1 downto 0);
        -- timestamp
        rx_in_timestamp_cnt     : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0)
    );
end switch_port_rx_path;

architecture rtl of switch_port_rx_path is

	component rx_path_header_extraction
    Generic (
        RECEIVER_DATA_WIDTH     : integer;
        DEST_ADDR_WIDTH         : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;           
        -- input interface
        hext_in_data            : in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        hext_in_valid           : in std_logic;
        hext_in_last            : in std_logic;
        hext_in_timestamp_cnt   : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- output interface
        hext_out_dest       	: out std_logic_vector(DEST_ADDR_WIDTH-1 downto 0);
        hext_out_vlan_enable    : out std_logic;
        hext_out_vlan_prio      : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        hext_out_valid          : out std_logic;
        hext_out_timestamp      : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        hext_out_ready          : in std_logic
    );
	end component;

	component rx_path_lookup
    Generic (
        DEST_MAC_WIDTH          : integer;
        NR_PORTS                : integer;
        PORT_ID                 : integer;
        LOOKUP_MEM_ADDR_WIDTH   : integer;
        LOOKUP_MEM_DATA_WIDTH   : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;
        -- input interface
        lookup_in_dest          : in std_logic_vector(DEST_ADDR_WIDTH-1 downto 0);
        lookup_in_vlan_enable   : in std_logic;
        lookup_in_vlan_prio     : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        lookup_in_valid         : in std_logic;
        lookup_in_timestamp     : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        lookup_in_ready         : out std_logic;
        -- output interface
        lookup_out_ports        : out std_logic_vector(NR_PORTS-1 downto 0);
        lookup_out_prio         : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        lookup_out_skip         : out std_logic;
        lookup_out_timestamp    : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        lookup_out_valid        : out std_logic;
        -- lookup memory interface
        mem_enable              : out std_logic;
        mem_addr                : out std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
        mem_data                : in std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0)
    );
	end component;

	component rx_path_lookup_memory
    Generic (
        LOOKUP_MEM_ADDR_WIDTH   : integer;
        LOOKUP_MEM_DATA_WIDTH   : integer
    );
    Port (
        --Port A -> Processor
        mem_in_wenable          : in std_logic_vector(0 downto 0);
        mem_in_addr             : in std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
        mem_in_data             : in std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
        mem_in_clk              : in std_logic;
        --Port B -> Lookup module
        mem_out_enable          : in std_logic;  --opt port
        mem_out_addr            : in std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
        mem_out_data            : out std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
        mem_out_clk             : in std_logic
    );
	end component;
    
	component rx_path_input_queue
    Generic (
        RECEIVER_DATA_WIDTH     : integer;
        FABRIC_DATA_WIDTH       : integer;
        NR_PORTS                : integer;
        FRAME_LENGTH_WIDTH      : integer;
        NR_IQ_FIFOS             : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port ( 
        clk                     : in std_logic;
        reset                   : in std_logic;
        -- input interface data
        iq_in_mac_data          : in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        iq_in_mac_valid         : in std_logic;
        iq_in_mac_last          : in std_logic; 
        iq_in_mac_error         : in std_logic;
        -- input interface control
        iq_in_lu_ports          : in std_logic_vector(NR_PORTS-1 downto 0);
        iq_in_lu_prio           : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        iq_in_lu_skip           : in std_logic;
        iq_in_lu_timestamp      : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        iq_in_lu_valid          : in std_logic;  
        -- output interface arbitration
        iq_out_ports_req        : out std_logic_vector(NR_PORTS-1 downto 0);
        iq_out_prio             : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        iq_out_timestamp        : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        iq_out_length           : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        iq_out_ports_gnt        : in std_logic_vector(NR_PORTS-1 downto 0);  
        -- output interface data
        iq_out_data             : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        iq_out_last             : out std_logic;
        iq_out_valid            : out std_logic
    );
	end component;

    signal hext2lookup_dest     : std_logic_vector(DEST_ADDR_WIDTH-1 downto 0);
    signal hext2lookup_vlan_enable : std_logic;
    signal hext2lookup_vlan_prio : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal hext2lookup_valid    : std_logic;
    signal hext2lookup_timestamp : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal hext2lookup_ready    : std_logic;
    
    signal mem2lookup_enable    : std_logic;
    signal mem2lookup_addr      : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal mem2lookup_data      : std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
    
    signal lookup2iq_ports_sig  : std_logic_vector(NR_PORTS-1 downto 0);
    signal lookup2iq_prio_sig   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal lookup2iq_skip_sig   : std_logic;
    signal lookup2iq_timestamp  : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal lookup2iq_valid_sig  : std_logic;
    
    signal rx_path_reset        : std_logic;

--    attribute mark_debug : string;
--    attribute mark_debug of hext2lookup_header	: signal is "true";
--    attribute mark_debug of hext2lookup_valid	: signal is "true";
--    attribute mark_debug of hext2lookup_ready	: signal is "true";
--    attribute mark_debug of mem2lookup_enable	: signal is "true";
--    attribute mark_debug of mem2lookup_addr		: signal is "true";
--    attribute mark_debug of mem2lookup_data		: signal is "true";
--    attribute mark_debug of lookup2iq_ports_sig	: signal is "true";
--    attribute mark_debug of lookup2iq_skip_sig	: signal is "true";
--    attribute mark_debug of lookup2iq_valid_sig	: signal is "true";
--    attribute mark_debug of lookup2iq_ready_sig	: signal is "true";

begin   

	-- can be moved to a higher layer lateron
	rx_path_reset <= not rx_path_resetn;

	header_extraction : rx_path_header_extraction
    Generic map(
        RECEIVER_DATA_WIDTH    	=> RECEIVER_DATA_WIDTH,
        DEST_ADDR_WIDTH         => DEST_ADDR_WIDTH,
        VLAN_PRIO_WIDTH         => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH         => TIMESTAMP_WIDTH
    )
    Port map(
        clk                     => rx_path_clock,
        reset                   => rx_path_reset,
        -- input interface
        hext_in_data            => rx_in_data,
        hext_in_valid           => rx_in_valid,
        hext_in_last            => rx_in_last, 
        hext_in_timestamp_cnt   => rx_in_timestamp_cnt,
        -- output interface
        hext_out_dest           => hext2lookup_dest,
        hext_out_vlan_enable    => hext2lookup_vlan_enable,
        hext_out_vlan_prio      => hext2lookup_vlan_prio,
        hext_out_valid          => hext2lookup_valid,
        hext_out_timestamp      => hext2lookup_timestamp,
        hext_out_ready          => hext2lookup_ready
    );

	lookup : rx_path_lookup
    Generic map(
        DEST_MAC_WIDTH          => DEST_ADDR_WIDTH,
        NR_PORTS                => NR_PORTS,
        PORT_ID                 => PORT_ID,
        LOOKUP_MEM_ADDR_WIDTH   => LOOKUP_MEM_ADDR_WIDTH,
        LOOKUP_MEM_DATA_WIDTH   => LOOKUP_MEM_DATA_WIDTH,
        VLAN_PRIO_WIDTH         => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH         => TIMESTAMP_WIDTH
    )
    Port map(
        clk                     => rx_path_clock,
        reset                   => rx_path_reset,
        -- input interface
        lookup_in_dest          => hext2lookup_dest,
        lookup_in_vlan_enable   => hext2lookup_vlan_enable,
        lookup_in_vlan_prio     => hext2lookup_vlan_prio,
        lookup_in_valid         => hext2lookup_valid,
        lookup_in_timestamp     => hext2lookup_timestamp,
        lookup_in_ready         => hext2lookup_ready,
        -- output interface
        lookup_out_ports        => lookup2iq_ports_sig,
        lookup_out_prio         => lookup2iq_prio_sig,
        lookup_out_skip         => lookup2iq_skip_sig,
        lookup_out_timestamp    => lookup2iq_timestamp,
        lookup_out_valid        => lookup2iq_valid_sig,
        -- lookup memory interface
        mem_enable              => mem2lookup_enable,
        mem_addr                => mem2lookup_addr,
        mem_data                => mem2lookup_data
    );

	lookup_memory : rx_path_lookup_memory
    Generic map(
        LOOKUP_MEM_ADDR_WIDTH   => LOOKUP_MEM_ADDR_WIDTH,
        LOOKUP_MEM_DATA_WIDTH   => LOOKUP_MEM_DATA_WIDTH
    )
    Port map(
        --Port A (write interface) -> Processor
        mem_in_wenable          => (others => '0'),
        mem_in_addr             => (others => '0'),
        mem_in_data             => (others => '0'),
        mem_in_clk              => '0',
        --Port B (read interface) -> Lookup module
        mem_out_enable          => mem2lookup_enable,
        mem_out_addr            => mem2lookup_addr,
        mem_out_data            => mem2lookup_data,
        mem_out_clk             => rx_path_clock
    );

	input_queue : rx_path_input_queue
    Generic map(
        RECEIVER_DATA_WIDTH     => RECEIVER_DATA_WIDTH,
        FABRIC_DATA_WIDTH       => FABRIC_DATA_WIDTH,
        NR_PORTS                => NR_PORTS,
        FRAME_LENGTH_WIDTH      => FRAME_LENGTH_WIDTH,
        NR_IQ_FIFOS             => NR_IQ_FIFOS,
        VLAN_PRIO_WIDTH         => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH         => TIMESTAMP_WIDTH
    )
    Port map( 
        clk                     => rx_path_clock,
        reset                   => rx_path_reset,
        -- input interface data
        iq_in_mac_data          => rx_in_data,
        iq_in_mac_valid         => rx_in_valid,
        iq_in_mac_last          => rx_in_last,
        iq_in_mac_error         => rx_in_error,
        -- input interface control
        iq_in_lu_ports          => lookup2iq_ports_sig,
        iq_in_lu_prio           => lookup2iq_prio_sig,
        iq_in_lu_skip           => lookup2iq_skip_sig,
        iq_in_lu_timestamp      => lookup2iq_timestamp,
        iq_in_lu_valid          => lookup2iq_valid_sig,
        -- output interface arbitration
        iq_out_ports_req        => rx_out_ports_req,
        iq_out_prio             => rx_out_prio,
        iq_out_timestamp        => rx_out_timestamp,
        iq_out_length           => rx_out_length,
        iq_out_ports_gnt        => rx_out_ports_gnt,
        -- output interface data
        iq_out_data             => rx_out_data,
        iq_out_last             => rx_out_last,
        iq_out_valid            => rx_out_valid
    );

end rtl;
