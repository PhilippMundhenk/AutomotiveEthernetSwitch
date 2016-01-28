----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 09.12.2013 16:11:09
-- Design Name: 
-- Module Name: tx_path_output_queue - structural
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: The output queue module accepts frames from the switching fabric
-- and forwards them to the transmitter side of the MAC
-- 
-- This module consists of 5 submodules:
-- oq_control: receives data from switching fabric and stores them in the memory and fifo
-- oq_memory: contains the frame data
-- oq_fifo: contains the memory start address of the corresponding frame as well as its length and arriving timestamp
--           priority fifo can be selected
-- oq_mem_check: checks if another frame can be accepted from the switching fabric based on
--      the status of the fifo and memory
-- oq_arbitration: as soon as the MAC is ready, the next frame will be read from the memory and
--      forwarded to the MAC
--
-- further information can be found in switch_port_txpath_output_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tx_path_output_queue is
    Generic (
        FABRIC_DATA_WIDTH       	: integer;
        TRANSMITTER_DATA_WIDTH  	: integer;
        FRAME_LENGTH_WIDTH      	: integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        OQ_MEM_ADDR_WIDTH_A         : integer := 12; -- 8 bit: 14, 32 bit: 12
        OQ_MEM_ADDR_WIDTH_B         : integer := 14
    );
    Port ( 
        clk                    	: in  std_logic;
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
end tx_path_output_queue;

architecture structural of tx_path_output_queue is

    constant OQ_FIFO_DATA_WIDTH         : integer := OQ_MEM_ADDR_WIDTH_B + TIMESTAMP_WIDTH + FRAME_LENGTH_WIDTH;
    constant OQ_FIFO_LENGTH_START       : integer := 0;
    constant OQ_FIFO_TIMESTAMP_START    : integer := OQ_FIFO_LENGTH_START + FRAME_LENGTH_WIDTH;
    constant OQ_FIFO_MEM_PTR_START      : integer := OQ_FIFO_TIMESTAMP_START + TIMESTAMP_WIDTH;
    constant FABRIC2TRANSMITTER_DATA_WIDTH_RATIO : integer := FABRIC_DATA_WIDTH / TRANSMITTER_DATA_WIDTH;
    
	component output_queue_control
    Generic (
        FABRIC_DATA_WIDTH           : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        OQ_MEM_ADDR_WIDTH_A         : integer;
        OQ_MEM_ADDR_WIDTH_B         : integer;
        OQ_FIFO_DATA_WIDTH          : integer;
        FABRIC2TRANSMITTER_DATA_WIDTH_RATIO : integer
    );
    Port (
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        -- input interface fabric
        oqctrl_in_data              : in  std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        oqctrl_in_valid             : in  std_logic;
        oqctrl_in_length            : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        oqctrl_in_prio              : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oqctrl_in_timestamp         : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- output interface memory check
        oqctrl_out_mem_wr_addr      : out std_logic_vector(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_B-1 downto 0);
        -- output interface memory
        oqctrl_out_mem_wenable      : out std_logic;
        oqctrl_out_mem_addr         : out std_logic_vector(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
        oqctrl_out_mem_data         : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        -- output interface fifo
        oqctrl_out_fifo_wenable     : out std_logic;
        oqctrl_out_fifo_data        : out std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0);
        oqctrl_out_fifo_prio        : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0)
    );
	end component;

	component output_queue_memory
    Generic (
        NR_OQ_MEM             : integer;
        VLAN_PRIO_WIDTH       : integer;
        OQ_MEM_ADDR_WIDTH_A   : integer;
        OQ_MEM_ADDR_WIDTH_B   : integer;
        OQ_MEM_DATA_WIDTH_IN  : integer;
        OQ_MEM_DATA_WIDTH_OUT : integer
    );
    Port (
        --Port A -> control module
        oqmem_in_wr_prio      : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oqmem_in_wenable      : in std_logic_vector;
        oqmem_in_addr         : in std_logic_vector(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
        oqmem_in_data         : in std_logic_vector(OQ_MEM_DATA_WIDTH_IN-1 downto 0);
        oqmem_in_clk          : in std_logic;
        --Port B -> arbitration module -> mac
        oqmem_out_rd_prio     : in std_logic;
        oqmem_out_enable      : in std_logic;
        oqmem_out_addr        : in std_logic_vector(OQ_MEM_ADDR_WIDTH_B-1 downto 0);
        oqmem_out_data        : out std_logic_vector(NR_OQ_FIFOS*OQ_MEM_DATA_WIDTH_OUT-1 downto 0);
        oqmem_out_clk         : in std_logic
    );
	end component;

	component output_queue_fifo
    Generic (
        OQ_FIFO_DATA_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer
    );
    Port ( 
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        oqfifo_in_enable 		    : in  std_logic;
        oqfifo_in_data              : in  std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0);
        oqfifo_in_wr_prio           : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oqfifo_out_enable           : in  std_logic;
        oqfifo_out_data             : out std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
        oqfifo_out_rd_prio          : in std_logic;
        oqfifo_out_full             : out std_logic_vector(NR_OQ_FIFOS-1 downto 0);
        oqfifo_out_empty            : out std_logic_vector(NR_OQ_FIFOS-1 downto 0)
    );
	end component;

	component output_queue_mem_check
    Generic (
        OQ_FIFO_DATA_WIDTH          : integer;
        OQ_MEM_ADDR_WIDTH           : integer;
        OQ_FIFO_MEM_PTR_START       : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer
    );
    Port ( 
        clk                 : in  std_logic;
        reset               : in  std_logic;
        req                 : in  std_logic;
        req_length          : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        req_prio            : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        accept_frame        : out std_logic;
        mem_wr_ptr          : in  std_logic_vector(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH-1 downto 0);
        fifo_data           : in  std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
        fifo_full           : in  std_logic_vector(NR_OQ_FIFOS-1 downto 0);
        fifo_empty          : in  std_logic_vector(NR_OQ_FIFOS-1 downto 0)
    );
	end component;

	component output_queue_arbitration
    Generic (
        TRANSMITTER_DATA_WIDTH      : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        TIMESTAMP_WIDTH             : integer;
        OQ_MEM_ADDR_WIDTH           : integer;
        OQ_FIFO_DATA_WIDTH          : integer;
        OQ_FIFO_LENGTH_START        : integer;
        OQ_FIFO_TIMESTAMP_START     : integer;
        OQ_FIFO_MEM_PTR_START       : integer
    );
    Port (
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        -- input interface fifo
        oqarb_in_fifo_enable        : out std_logic;
        oqarb_in_fifo_prio          : out std_logic;
        oqarb_in_fifo_empty         : in std_logic_vector(NR_OQ_FIFOS-1 downto 0);
        oqarb_in_fifo_data          : in std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
        -- timestamp
        oqarb_in_timestamp_cnt      : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        oqarb_out_latency           : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- input interface memory
        oqarb_in_mem_data           : in  std_logic_vector(NR_OQ_FIFOS*TRANSMITTER_DATA_WIDTH-1 downto 0);
        oqarb_in_mem_enable         : out  std_logic;
        oqarb_in_mem_addr           : out  std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
        oqarb_in_mem_prio           : out std_logic;
        -- output interface mac
        oqarb_out_data              : out std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        oqarb_out_valid             : out std_logic;
        oqarb_out_last              : out std_logic;
        oqarb_out_ready             : in std_logic
    );
	end component;

    signal oqctrl2oqmem_data    : std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
    signal oqctrl2oqmem_wenable : std_logic_vector(0 downto 0);
    signal oqctrl2oqmem_addr    : std_logic_vector(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
    
    signal oqctrl2oqfifo_wenable : std_logic;
    signal oqctrl2oqfifo_data   : std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0); 
    signal oqctrl2oqfifo_prio   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    
    signal oqmem2oqarb_enable   : std_logic;
    signal oqmem2oqarb_prio     : std_logic;
    signal oqmem2oqarb_addr     : std_logic_vector(OQ_MEM_ADDR_WIDTH_B-1 downto 0);
    signal oqmem2oqarb_data     : std_logic_vector(NR_OQ_FIFOS*TRANSMITTER_DATA_WIDTH-1 downto 0);
    
    signal oqfifo2oqarb_data    : std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
    signal oqfifo2oqarb_enable  : std_logic;
    signal oqfifo2oqarb_empty   : std_logic_vector(NR_OQ_FIFOS-1 downto 0);
    signal oqfifo2oqarb_prio    : std_logic;
    
    signal oqctrl2oqchk_mem_wr_addr : std_logic_vector(NR_OQ_FIFOS*OQ_MEM_ADDR_WIDTH_B-1 downto 0);
    signal oqfifo2oqchk_full    : std_logic_vector(NR_OQ_FIFOS-1 downto 0);
    
--    attribute mark_debug : string;
--    attribute mark_debug of oqctrl2oqmem_data: signal is "true";
--    attribute mark_debug of oqctrl2oqmem_wenable: signal is "true";
--    attribute mark_debug of oqctrl2oqmem_addr: signal is "true";
--    attribute mark_debug of oqctrl2oqfifo_data: signal is "true";
--    attribute mark_debug of oqmem2oqarb_enable: signal is "true";
--    attribute mark_debug of oqmem2oqarb_addr: signal is "true";
--    attribute mark_debug of oqmem2oqarb_data: signal is "true";
--    attribute mark_debug of oqfifo2oqarb_data: signal is "true";
--    attribute mark_debug of oqfifo2oqarb_enable: signal is "true";
--    attribute mark_debug of oqfifo2oqarb_empty: signal is "true";
--    attribute mark_debug of oqctrl2oqchk_mem_wr_addr: signal is "true";
--    attribute mark_debug of oqfifo2oqchk_full: signal is "true";
    
begin

    oq_control : output_queue_control
    Generic map(
        FABRIC_DATA_WIDTH          	=> FABRIC_DATA_WIDTH,
        FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
        NR_OQ_FIFOS                 => NR_OQ_FIFOS,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH,
        OQ_MEM_ADDR_WIDTH_A         => OQ_MEM_ADDR_WIDTH_A,
        OQ_MEM_ADDR_WIDTH_B         => OQ_MEM_ADDR_WIDTH_B,
        OQ_FIFO_DATA_WIDTH          => OQ_FIFO_DATA_WIDTH,
        FABRIC2TRANSMITTER_DATA_WIDTH_RATIO => FABRIC2TRANSMITTER_DATA_WIDTH_RATIO
    )
    Port map(
        clk                         => clk,
        reset                       => reset,
        -- input interface fabric
        oqctrl_in_data              => oq_in_data,
        oqctrl_in_valid             => oq_in_valid,
        oqctrl_in_length            => oq_in_length,
        oqctrl_in_prio              => oq_in_prio,
        oqctrl_in_timestamp         => oq_in_timestamp,
        -- output interface memory check
        oqctrl_out_mem_wr_addr      => oqctrl2oqchk_mem_wr_addr,
        -- output interface memory
        oqctrl_out_mem_wenable      => oqctrl2oqmem_wenable(0),
        oqctrl_out_mem_addr         => oqctrl2oqmem_addr,
        oqctrl_out_mem_data         => oqctrl2oqmem_data,
        -- output interface fifo
        oqctrl_out_fifo_wenable     => oqctrl2oqfifo_wenable,
        oqctrl_out_fifo_data        => oqctrl2oqfifo_data,
        oqctrl_out_fifo_prio        => oqctrl2oqfifo_prio
    );

  oq_mem : output_queue_memory
    Generic map(
        NR_OQ_MEM                   => NR_OQ_FIFOS,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
        OQ_MEM_ADDR_WIDTH_A         => OQ_MEM_ADDR_WIDTH_A,
        OQ_MEM_ADDR_WIDTH_B         => OQ_MEM_ADDR_WIDTH_B,
        OQ_MEM_DATA_WIDTH_IN        => FABRIC_DATA_WIDTH,
        OQ_MEM_DATA_WIDTH_OUT       => TRANSMITTER_DATA_WIDTH
    )
    Port map(
        --Port A -> Control module
        oqmem_in_wr_prio      => oq_in_prio,
        oqmem_in_wenable      => oqctrl2oqmem_wenable,
        oqmem_in_addr         => oqctrl2oqmem_addr,
        oqmem_in_data         => oqctrl2oqmem_data,
        oqmem_in_clk          => clk,
        --Port B -> Scheduling moudle
        oqmem_out_rd_prio     => oqmem2oqarb_prio,
        oqmem_out_enable      => oqmem2oqarb_enable,
        oqmem_out_addr        => oqmem2oqarb_addr,
        oqmem_out_data        => oqmem2oqarb_data,
        oqmem_out_clk         => clk
    );

  oq_fifo : output_queue_fifo
    Generic map(
        OQ_FIFO_DATA_WIDTH    => OQ_FIFO_DATA_WIDTH,
        NR_OQ_FIFOS           => NR_OQ_FIFOS,
        VLAN_PRIO_WIDTH       => VLAN_PRIO_WIDTH
    )
    Port map( 
        clk                   => clk,
        reset                 => reset,
        oqfifo_in_enable 	  => oqctrl2oqfifo_wenable,
        oqfifo_in_data        => oqctrl2oqfifo_data,
        oqfifo_in_wr_prio     => oqctrl2oqfifo_prio,
        oqfifo_out_enable     => oqfifo2oqarb_enable,
        oqfifo_out_data       => oqfifo2oqarb_data,
        oqfifo_out_rd_prio    => oqfifo2oqarb_prio,
        oqfifo_out_full       => oqfifo2oqchk_full,
        oqfifo_out_empty      => oqfifo2oqarb_empty
    );

    oq_mem_check : output_queue_mem_check
    Generic map(
        OQ_FIFO_DATA_WIDTH          => OQ_FIFO_DATA_WIDTH,
        OQ_MEM_ADDR_WIDTH           => OQ_MEM_ADDR_WIDTH_B,
        OQ_FIFO_MEM_PTR_START       => OQ_FIFO_MEM_PTR_START,
        FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
        NR_OQ_FIFOS                 => NR_OQ_FIFOS,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH
    )
    Port map( 
        clk                 => clk,
        reset               => reset,
        req                 => oq_in_req,
        req_length          => oq_in_length,
        req_prio            => oq_in_prio,
        accept_frame        => oq_in_accept_frame,
        mem_wr_ptr          => oqctrl2oqchk_mem_wr_addr,
        fifo_data           => oqfifo2oqarb_data,
        fifo_full           => oqfifo2oqchk_full,
        fifo_empty          => oqfifo2oqarb_empty
    );

    oq_arbitration : output_queue_arbitration
    Generic map(
        TRANSMITTER_DATA_WIDTH      => TRANSMITTER_DATA_WIDTH,
        FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
        NR_OQ_FIFOS                 => NR_OQ_FIFOS,
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH,
        OQ_MEM_ADDR_WIDTH           => OQ_MEM_ADDR_WIDTH_B,
        OQ_FIFO_DATA_WIDTH          => OQ_FIFO_DATA_WIDTH,
        OQ_FIFO_LENGTH_START        => OQ_FIFO_LENGTH_START,
        OQ_FIFO_TIMESTAMP_START     => OQ_FIFO_TIMESTAMP_START,
        OQ_FIFO_MEM_PTR_START       => OQ_FIFO_MEM_PTR_START
    )
    Port map(
        clk                         => clk,
        reset                       => reset,
        -- input interface fifo
        oqarb_in_fifo_enable        => oqfifo2oqarb_enable,
        oqarb_in_fifo_prio          => oqfifo2oqarb_prio,
        oqarb_in_fifo_empty         => oqfifo2oqarb_empty,
        oqarb_in_fifo_data          => oqfifo2oqarb_data,
        -- timestamp
        oqarb_in_timestamp_cnt      => oq_in_timestamp_cnt,
        oqarb_out_latency           => oq_out_latency,
        -- input interface memory
        oqarb_in_mem_data           => oqmem2oqarb_data,
        oqarb_in_mem_enable         => oqmem2oqarb_enable,
        oqarb_in_mem_addr           => oqmem2oqarb_addr,
        oqarb_in_mem_prio           => oqmem2oqarb_prio,
        -- output interface mac
        oqarb_out_data              => oq_out_data,
        oqarb_out_valid             => oq_out_valid,
        oqarb_out_last              => oq_out_last,
        oqarb_out_ready             => oq_out_ready
    );
        
end structural;
