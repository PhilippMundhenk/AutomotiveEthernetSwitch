----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 11.11.2013 14:33:32
-- Design Name: 
-- Module Name: switch_port_0_tx_path - rtl
--
-- Description: to be done
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity switch_port_tx_path is
    Generic (
        FABRIC_DATA_WIDTH       : integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        FRAME_LENGTH_WIDTH      : integer;
        NR_OQ_FIFOS             : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port ( 
        tx_path_clock           : in  std_logic;
        tx_path_resetn          : in  std_logic;
        -- tx_path interface to fabric
        tx_in_data              : in  std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        tx_in_valid             : in  std_logic;
        tx_in_length            : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        tx_in_prio              : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        tx_in_timestamp         : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        tx_in_req               : in  std_logic;
        tx_in_accept_frame      : out std_logic;
        -- timestamp
        tx_in_timestamp_cnt     : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        tx_out_latency          : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- tx_path interface to mac
        tx_out_data             : out std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        tx_out_valid            : out std_logic;
        tx_out_ready            : in  std_logic;
        tx_out_last             : out std_logic     
    );
end switch_port_tx_path;

architecture rtl of switch_port_tx_path is

	component tx_path_output_queue
    Generic (
        FABRIC_DATA_WIDTH      	: integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        FRAME_LENGTH_WIDTH      : integer;
        NR_OQ_FIFOS             : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port ( 
        clk                     : in  std_logic;
        reset                   : in  std_logic;
        -- tx_path interface to fabric
        oq_in_data              : in  std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        oq_in_valid             : in  std_logic;
        oq_in_length            : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        oq_in_prio              : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oq_in_timestamp         : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        oq_in_req               : in  std_logic;
        oq_in_accept_frame      : out std_logic;
        -- timestamp
        oq_in_timestamp_cnt     : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        oq_out_latency          : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- tx_path interface to mac
        oq_out_data             : out std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        oq_out_valid            : out std_logic;
        oq_out_ready            : in  std_logic;
        oq_out_last             : out std_logic
    );
	end component;

    signal reset  : std_logic;

begin
    
    reset   <= not tx_path_resetn;
    
    output_queue : tx_path_output_queue
        Generic map(
            FABRIC_DATA_WIDTH          	=> FABRIC_DATA_WIDTH,
            TRANSMITTER_DATA_WIDTH      => TRANSMITTER_DATA_WIDTH,
            FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
            NR_OQ_FIFOS                 => NR_OQ_FIFOS,
            VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
            TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH
        )
        Port map( 
            clk                         => tx_path_clock,
            reset                       => reset,
            -- tx_path interface to fabric
            oq_in_data                  => tx_in_data,
            oq_in_valid                 => tx_in_valid,
            oq_in_length                => tx_in_length,
            oq_in_prio                  => tx_in_prio,
            oq_in_timestamp             => tx_in_timestamp,
            oq_in_req                   => tx_in_req,
            oq_in_accept_frame          => tx_in_accept_frame,
            -- timestamp
            oq_in_timestamp_cnt         => tx_in_timestamp_cnt,
            oq_out_latency              => tx_out_latency,
            -- tx_path interface to mac
            oq_out_data                 => tx_out_data,
            oq_out_valid                => tx_out_valid,
            oq_out_ready                => tx_out_ready,
            oq_out_last                 => tx_out_last  
        );
        
end rtl;