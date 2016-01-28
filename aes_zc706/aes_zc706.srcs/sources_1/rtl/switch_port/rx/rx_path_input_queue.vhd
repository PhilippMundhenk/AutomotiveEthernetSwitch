----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 26.11.2013 16:32:15
-- Design Name: rx_path_input_queue.vhd
-- Module Name: rx_path_input_queue - structural
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description:
-- Input frame scheduling consisting of 5 submodules:
-- input_queue_control: receive frames and line in queue, remove error-frames
-- input_queue_memory: store the received frames
-- input_queue_fifo: store memory pointer, frame length and output ports of the frames located in the memory
--                  depending on needs one fifo or two priority fifos can be selected
-- input_queue_overflow: checks for memory overflow and fifo overflow
-- input_queue_scheduling: decide which frame to offer next to switch fabric and control frame transmission
--                  depending on NR_IQ_FIFOS priority behaviour (NR_IQ_FIFOS = 2) or best effort (NR_IQ_FIFOS = 1) is considered
--
-- more detailed information can found in file switch_port_rxpath_input_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rx_path_input_queue is
    Generic (
        RECEIVER_DATA_WIDTH        	: integer;
        FABRIC_DATA_WIDTH           : integer;
        NR_PORTS                    : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_IQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        IQ_MEM_ADDR_WIDTH_A         : integer := 12;
        IQ_MEM_ADDR_WIDTH_B         : integer := 10  -- 8 bit: 12, 32 bit: 10
    );
    Port ( 
        clk                    	: in std_logic;
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
end rx_path_input_queue;

architecture structural of rx_path_input_queue is
	-- memory and fifo data constants
	constant IQ_MEM_DATA_WIDTH_RATIO       : integer := FABRIC_DATA_WIDTH / RECEIVER_DATA_WIDTH;
	constant IQ_FIFO_DATA_WIDTH            : integer := VLAN_PRIO_WIDTH+FRAME_LENGTH_WIDTH+TIMESTAMP_WIDTH+NR_PORTS+IQ_MEM_ADDR_WIDTH_A;
	-- fifo address constants
	constant IQ_FIFO_PRIO_START            : integer := 0;
	constant IQ_FIFO_FRAME_LEN_START       : integer := IQ_FIFO_PRIO_START + VLAN_PRIO_WIDTH;
	constant IQ_FIFO_TIMESTAMP_START       : integer := IQ_FIFO_FRAME_LEN_START + FRAME_LENGTH_WIDTH;
	constant IQ_FIFO_PORTS_START           : integer := IQ_FIFO_TIMESTAMP_START + TIMESTAMP_WIDTH;
	constant IQ_FIFO_MEM_PTR_START         : integer := IQ_FIFO_PORTS_START + NR_PORTS;

	component input_queue_control is
    Generic (
        RECEIVER_DATA_WIDTH        	: integer;
        NR_PORTS                    : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        IQ_MEM_ADDR_WIDTH           : integer;
        IQ_MEM_DATA_WIDTH_RATIO     : integer;
        IQ_FIFO_DATA_WIDTH          : integer;
        FRAME_LENGTH_WIDTH          : integer;
        IQ_FIFO_PRIO_START          : integer;
        IQ_FIFO_FRAME_LEN_START     : integer;
        IQ_FIFO_TIMESTAMP_START     : integer;
        IQ_FIFO_PORTS_START         : integer;
        IQ_FIFO_MEM_PTR_START       : integer
    );
    Port ( 
        clk                         : in std_logic;
        reset                       : in std_logic;
        -- input interface mac
        iqctrl_in_mac_data          : in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        iqctrl_in_mac_valid         : in std_logic;
        iqctrl_in_mac_last          : in std_logic; 
        iqctrl_in_mac_error         : in std_logic;
        -- input interface lookup
        iqctrl_in_lu_ports          : in std_logic_vector(NR_PORTS-1 downto 0);
        iqctrl_in_lu_prio           : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        iqctrl_in_lu_skip           : in std_logic;
        iqctrl_in_lu_timestamp      : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        iqctrl_in_lu_valid          : in std_logic;
        -- output interface memory
        iqctrl_out_mem_wenable      : out std_logic;
        iqctrl_out_mem_addr         : out std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
        iqctrl_out_mem_data         : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        -- output interface fifo
        iqctrl_out_fifo_wenable     : out std_logic;
        iqctrl_out_fifo_data        : out std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0)
    );
	end component;

	component input_queue_memory is
    Generic (
        IQ_MEM_ADDR_WIDTH_A         : integer;
        IQ_MEM_ADDR_WIDTH_B         : integer;
        IQ_MEM_DATA_WIDTH_IN        : integer;
        IQ_MEM_DATA_WIDTH_OUT       : integer
    );
    Port (
        iqmem_in_wenable       	: in std_logic_vector;
        iqmem_in_addr           : in std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
        iqmem_in_data           : in std_logic_vector(IQ_MEM_DATA_WIDTH_IN-1 downto 0);
        iqmem_in_clk            : in std_logic;
        
        iqmem_out_enable        : in std_logic;
        iqmem_out_addr          : in std_logic_vector(IQ_MEM_ADDR_WIDTH_B-1 downto 0);
        iqmem_out_data          : out std_logic_vector(IQ_MEM_DATA_WIDTH_OUT-1 downto 0);
        iqmem_out_clk           : in std_logic
    );
	end component;

	component input_queue_fifo is
	Generic (
        IQ_FIFO_DATA_WIDTH         	: integer;
        NR_IQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer
    );
    Port ( 
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        wr_en 		                : in  std_logic;
        din                         : in  std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0);
        wr_priority                 : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        rd_en                       : in  std_logic;
        overflow                    : in  std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        dout                        : out std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0);
        rd_priority                 : in  std_logic;
        full                        : out std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        empty                       : out std_logic_vector(NR_IQ_FIFOS-1 downto 0)
    );
	end component;

    component input_queue_overflow is
    Generic(
        IQ_FIFO_DATA_WIDTH          : integer;
        IQ_MEM_ADDR_WIDTH           : integer;
        IQ_FIFO_MEM_PTR_START       : integer;
        NR_IQ_FIFOS                 : integer
    );
    Port ( 
        fifo_full                   : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        fifo_empty                  : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        mem_wr_addr                 : in std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
        mem_rd_addr                 : in std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0);
        overflow                    : out std_logic_vector(NR_IQ_FIFOS-1 downto 0)
    );
    end component;

	component input_queue_arbitration is
    Generic(
        FABRIC_DATA_WIDTH           : integer;
        IQ_FIFO_DATA_WIDTH          : integer;
        NR_PORTS                    : integer;
        IQ_MEM_ADDR_WIDTH_A         : integer;
        IQ_MEM_ADDR_WIDTH_B         : integer;
        FRAME_LENGTH_WIDTH          : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        IQ_FIFO_PRIO_START          : integer;
        IQ_FIFO_FRAME_LEN_START     : integer;
        IQ_FIFO_TIMESTAMP_START     : integer;
        IQ_FIFO_PORTS_START         : integer;
        IQ_FIFO_MEM_PTR_START       : integer;
        IQ_MEM_DATA_WIDTH_RATIO     : integer;
        NR_IQ_FIFOS                 : integer
    );
    Port ( 
        clk                         : in std_logic;
        reset                       : in std_logic;
        -- input interface memory
        iqarb_in_mem_enable         : out std_logic;
        iqarb_in_mem_addr           : out std_logic_vector(IQ_MEM_ADDR_WIDTH_B-1 downto 0);
        iqarb_in_mem_data           : in std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        -- input interface fifo
        iqarb_in_fifo_enable        : out  std_logic;
        iqarb_in_fifo_prio          : out std_logic;
        iqarb_in_fifo_data          : in std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0);
        iqarb_in_fifo_empty         : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        iqarb_in_fifo_overflow      : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        -- output interface arbitration
        iqarb_out_ports_req         : out std_logic_vector(NR_PORTS-1 downto 0);
        iqarb_out_prio              : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        iqarb_out_timestamp         : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        iqarb_out_length            : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        iqarb_out_ports_gnt         : in std_logic_vector(NR_PORTS-1 downto 0);
        -- output interface data
        iqarb_out_data              : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        iqarb_out_last              : out std_logic;
        iqarb_out_valid             : out std_logic
    );
	end component;

    signal iqctrl2iqmem_data    : std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
    signal iqctrl2iqmem_wenable : std_logic_vector(0 downto 0);
    signal iqctrl2iqmem_addr    : std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
    
    signal iqctrl2iqfifo_wenable : std_logic;
    signal iqctrl2iqfifo_data   : std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0); 
    
    signal iqfifo2iqarb_renable : std_logic;
    signal iqfifo2iqarb_data    : std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0); 
    signal iqfifo2iqarb_prio    : std_logic;
    signal iqfifo2iqarb_empty   : std_logic_vector(NR_IQ_FIFOS-1 downto 0);
    
    signal iqfifo2iqovfl_full   : std_logic_vector(NR_IQ_FIFOS-1 downto 0);
    
    signal iqovfl2iqarb_overflow : std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        
    signal iqmem2iqarb_data     : std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
    signal iqmem2iqarb_enable   : std_logic;
    signal iqmem2iqarb_addr     : std_logic_vector(IQ_MEM_ADDR_WIDTH_B-1 downto 0);    

--	attribute mark_debug : string;
--	attribute mark_debug of iqctrl2iqmem_data		: signal is "true";
--	attribute mark_debug of iqctrl2iqmem_wenable	: signal is "true";
--	attribute mark_debug of iqctrl2iqmem_addr		: signal is "true";
--	attribute mark_debug of iqctrl2iqfifo_wenable	: signal is "true";
--	attribute mark_debug of iqctrl2iqfifo_data		: signal is "true";
--	attribute mark_debug of iqfifo2iqarb_renable	: signal is "true";
--	attribute mark_debug of iqfifo2iqarb_data		: signal is "true";
--	attribute mark_debug of iqfifo2iqarb_empty		: signal is "true";
--	attribute mark_debug of iqfifo2iqarb_overflow	: signal is "true";
--	attribute mark_debug of iqmem2iqarb_data		: signal is "true";  
--	attribute mark_debug of iqmem2iqarb_enable		: signal is "true";
--	attribute mark_debug of iqmem2iqarb_addr		: signal is "true";   

begin

	iq_control : input_queue_control
    Generic map(
        RECEIVER_DATA_WIDTH        	=> RECEIVER_DATA_WIDTH,
        NR_PORTS                    => NR_PORTS,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH,
        IQ_MEM_ADDR_WIDTH           => IQ_MEM_ADDR_WIDTH_A,
        IQ_MEM_DATA_WIDTH_RATIO     => IQ_MEM_DATA_WIDTH_RATIO,
        IQ_FIFO_DATA_WIDTH          => IQ_FIFO_DATA_WIDTH,
        FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
        IQ_FIFO_PRIO_START          => IQ_FIFO_PRIO_START,
        IQ_FIFO_FRAME_LEN_START     => IQ_FIFO_FRAME_LEN_START,
        IQ_FIFO_TIMESTAMP_START     => IQ_FIFO_TIMESTAMP_START,
        IQ_FIFO_PORTS_START         => IQ_FIFO_PORTS_START,
        IQ_FIFO_MEM_PTR_START       => IQ_FIFO_MEM_PTR_START
    )
    Port map( 
        clk                         => clk,
        reset                       => reset,
        -- input interface mac
        iqctrl_in_mac_data          => iq_in_mac_data,
        iqctrl_in_mac_valid         => iq_in_mac_valid,
        iqctrl_in_mac_last          => iq_in_mac_last,
        iqctrl_in_mac_error         => iq_in_mac_error,
        -- input interface lookup
        iqctrl_in_lu_ports          => iq_in_lu_ports,
        iqctrl_in_lu_prio           => iq_in_lu_prio,
        iqctrl_in_lu_skip           => iq_in_lu_skip,
        iqctrl_in_lu_timestamp      => iq_in_lu_timestamp,
        iqctrl_in_lu_valid          => iq_in_lu_valid,
        -- output interface memory
        iqctrl_out_mem_wenable      => iqctrl2iqmem_wenable(0),
        iqctrl_out_mem_addr         => iqctrl2iqmem_addr,
        iqctrl_out_mem_data         => iqctrl2iqmem_data,
        -- output interface fifo
        iqctrl_out_fifo_wenable     => iqctrl2iqfifo_wenable,
        iqctrl_out_fifo_data        => iqctrl2iqfifo_data
    );

	iq_mem : input_queue_memory
    Generic map(
        IQ_MEM_ADDR_WIDTH_A     => IQ_MEM_ADDR_WIDTH_A,
        IQ_MEM_ADDR_WIDTH_B     => IQ_MEM_ADDR_WIDTH_B,
        IQ_MEM_DATA_WIDTH_IN    => RECEIVER_DATA_WIDTH,
        IQ_MEM_DATA_WIDTH_OUT   => FABRIC_DATA_WIDTH
    )
    Port map(
        --Port A -> Control module
        iqmem_in_wenable      => iqctrl2iqmem_wenable,
        iqmem_in_addr         => iqctrl2iqmem_addr,
        iqmem_in_data         => iqctrl2iqmem_data,
        iqmem_in_clk          => clk,
        --Port B -> Scheduling moudle
        iqmem_out_enable      => iqmem2iqarb_enable,
        iqmem_out_addr        => iqmem2iqarb_addr,
        iqmem_out_data        => iqmem2iqarb_data,
        iqmem_out_clk         => clk
    );

	iq_fifo : input_queue_fifo
    Generic map(
        IQ_FIFO_DATA_WIDTH         	=> IQ_FIFO_DATA_WIDTH,
        NR_IQ_FIFOS                 => NR_IQ_FIFOS,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH
    )
    Port map( 
        clk                         => clk,
        reset                       => reset,
        wr_en 		                => iqctrl2iqfifo_wenable,
        din                         => iqctrl2iqfifo_data,
        wr_priority                 => iqctrl2iqfifo_data(IQ_FIFO_PRIO_START+VLAN_PRIO_WIDTH-1 downto IQ_FIFO_PRIO_START),
        rd_en                       => iqfifo2iqarb_renable,
        overflow                    => iqovfl2iqarb_overflow,
        dout                        => iqfifo2iqarb_data,
        rd_priority                 => iqfifo2iqarb_prio,
        full                        => iqfifo2iqovfl_full,
        empty                       => iqfifo2iqarb_empty
    );

    iq_overflow : input_queue_overflow
    Generic map(
        IQ_FIFO_DATA_WIDTH          => IQ_FIFO_DATA_WIDTH,
        IQ_MEM_ADDR_WIDTH           => IQ_MEM_ADDR_WIDTH_A,
        IQ_FIFO_MEM_PTR_START       => IQ_FIFO_MEM_PTR_START,
        NR_IQ_FIFOS                 => NR_IQ_FIFOS
    )
    Port map( 
        fifo_full                   => iqfifo2iqovfl_full,
        fifo_empty                  => iqfifo2iqarb_empty,
        mem_wr_addr                 => iqctrl2iqmem_addr,
        mem_rd_addr                 => iqfifo2iqarb_data,
        overflow                    => iqovfl2iqarb_overflow
    );

	iq_arbitration : input_queue_arbitration
    Generic map(
        FABRIC_DATA_WIDTH           => FABRIC_DATA_WIDTH,
        IQ_FIFO_DATA_WIDTH          => IQ_FIFO_DATA_WIDTH,
        NR_PORTS                    => NR_PORTS,
        IQ_MEM_ADDR_WIDTH_A         => IQ_MEM_ADDR_WIDTH_A,
        IQ_MEM_ADDR_WIDTH_B         => IQ_MEM_ADDR_WIDTH_B,
        FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH,
        IQ_FIFO_PRIO_START          => IQ_FIFO_PRIO_START,
        IQ_FIFO_FRAME_LEN_START     => IQ_FIFO_FRAME_LEN_START,
        IQ_FIFO_TIMESTAMP_START     => IQ_FIFO_TIMESTAMP_START,
        IQ_FIFO_PORTS_START         => IQ_FIFO_PORTS_START,
        IQ_FIFO_MEM_PTR_START       => IQ_FIFO_MEM_PTR_START,
        IQ_MEM_DATA_WIDTH_RATIO     => IQ_MEM_DATA_WIDTH_RATIO,
        NR_IQ_FIFOS                 => NR_IQ_FIFOS
    )
    Port map( 
        clk                         => clk,
        reset                       => reset,
        -- input interface memory
        iqarb_in_mem_enable         => iqmem2iqarb_enable,
        iqarb_in_mem_addr           => iqmem2iqarb_addr,
        iqarb_in_mem_data           => iqmem2iqarb_data,
        -- input interface fifo
        iqarb_in_fifo_enable        => iqfifo2iqarb_renable,
        iqarb_in_fifo_prio          => iqfifo2iqarb_prio,
        iqarb_in_fifo_data          => iqfifo2iqarb_data,
        iqarb_in_fifo_empty         => iqfifo2iqarb_empty,
        iqarb_in_fifo_overflow      => iqovfl2iqarb_overflow,
        -- output interface arbitration
        iqarb_out_ports_req         => iq_out_ports_req,
        iqarb_out_prio              => iq_out_prio,
        iqarb_out_timestamp         => iq_out_timestamp,
        iqarb_out_length            => iq_out_length,
        iqarb_out_ports_gnt         => iq_out_ports_gnt, 
        -- output interface data
        iqarb_out_data              => iq_out_data,
        iqarb_out_last              => iq_out_last,
        iqarb_out_valid             => iq_out_valid
    );

end structural;
