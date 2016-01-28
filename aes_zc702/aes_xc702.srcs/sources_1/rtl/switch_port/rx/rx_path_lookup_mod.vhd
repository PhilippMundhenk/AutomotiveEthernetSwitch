----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 21.11.2013 12:06:03
-- Design Name: rx_path_lookup.vhd
-- Module Name: rx_path_lookup - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description:
-- this module handles the frame lookup
-- according to the header input the output ports for each frame are searched for in the lookup memory
-- the lookup memory constists of one base configuration, frame confiugrations and one default configuration
-- - base configuration gives the entry to the frame configuration
-- - frame configurations returns a one-hot-encoded output ports vector for each valid mac destination address
--         and the priority of the frame
-- - for mac address not in the lookup table the default configuration decides whether to skip this frame or 
--       to send it to default output ports
-- transmitting the frame on the receiving port is prevented by setting the corresponding bit in the ports vector to '0'
--
-- for more details on the lookup memory and search process see switch_port_rxpath_lookup_memory.svg
-- for more detail on the lookup module see switch_port_rxpath_lookup.svg
-- 
-- base_address is an internal register pointing to the base configuration; lateron it has to be connected to a processor
-- the housekeeping processor also has to take care of writing all the configurations to the lookup memory
-- thereby, an overflow of the memory address space of the binary list must not happen as no overflow control is
--       implemented in the lookup algorithm
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity rx_path_lookup is
    Generic (
        DEST_MAC_WIDTH         	: integer;
        NR_PORTS                : integer;
        PORT_ID                 : integer;
        LOOKUP_MEM_ADDR_WIDTH   : integer;
        LOOKUP_MEM_DATA_WIDTH   : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer;
        -- lookup memory address constants
        LOWER_ADDR_START        : integer := 20;
        UPPER_ADDR_START        : integer := 40;
        DEF_ADDR_START          : integer := 0;
        ENABLE_START            : integer := 63;
        PORTS_START             : integer := 60;
        PRIO_START              : integer := 48;
        SKIP_FRAME_START        : integer := 0;
        DEST_MAC_START          : integer := 0
    );
    Port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;
        -- input interface
        lookup_in_dest          : in std_logic_vector(DEST_MAC_WIDTH-1 downto 0);
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
end rx_path_lookup;

architecture rtl of rx_path_lookup is

    -- determine the next search address (median) of the binary search
    -- upper and lower are the corresponding border memory adresses of the remaining search space
    -- return value median = (upper + lower) / 2
    function upper_add_lower_by2_f (upper, lower : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0))
            return std_logic_vector is
        variable x1 : integer;
        variable x2 : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH downto 0);
        variable x3 : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    begin
        x1 := to_integer(unsigned(upper)) + to_integer(unsigned(lower));
        x2 := std_logic_vector(to_unsigned(x1,x2'length));
        x3 := x2(LOOKUP_MEM_ADDR_WIDTH downto 1);
        return x3;
    end upper_add_lower_by2_f;

    -- lookup state machine
    type state is (
        IDLE,
        READ_BASE,
        LOOKUP,
        READ_DEFAULT
    );
    signal cur_state       	: state;
    signal nxt_state        : state;
    
    -- state machine signals
    signal read_header_sig  : std_logic := '0';
    signal read_base_sig    : std_logic := '0';
    signal read_default_sig : std_logic := '0';
    signal lookup_valid_sig : std_logic := '0';
    signal read_lookup_sig  : std_logic := '0';
    signal update_sig       : std_logic := '0';
    signal lower_sig        : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal upper_sig        : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal median_sig       : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    -- process registers
    signal dest_mac_reg     : std_logic_vector(DEST_MAC_WIDTH-1 downto 0);
    signal vlan_enable_reg  : std_logic;
    signal vlan_prio_reg    : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal lower_reg        : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal upper_reg        : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal median_reg       : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal default_reg      : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal ports_reg        : std_logic_vector(NR_PORTS-1 downto 0);
    signal prio_reg         : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal skip_frame_reg   : std_logic;
    signal timestamp_reg    : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    -- alias signals for memory read access
    signal mem_lower_sig           	: std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_upper_sig            : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_default_sig          : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_lookup_enable_sig    : std_logic;
    signal mem_ports_sig            : std_logic_vector(NR_PORTS-1 downto 0);
    signal mem_prio_sig             : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal mem_skip_frame_sig       : std_logic;
    signal mem_dest_mac_sig         : std_logic_vector(DEST_MAC_WIDTH-1 downto 0);
    -- internal registers (to be connected to the outside, e.g. housekeeping processor)
    signal base_address     : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0) := "000000000";
    signal mem_addr_sig             : std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
    
begin
  
	-- alias names (signals) for lookup memory output ranges
	mem_lower_sig 			<= mem_data(LOWER_ADDR_START+LOOKUP_MEM_ADDR_WIDTH-1 downto LOWER_ADDR_START);
	mem_upper_sig 			<= mem_data(UPPER_ADDR_START+LOOKUP_MEM_ADDR_WIDTH-1 downto UPPER_ADDR_START);
	mem_default_sig 		<= mem_data(DEF_ADDR_START+LOOKUP_MEM_ADDR_WIDTH-1 downto DEF_ADDR_START);
	mem_lookup_enable_sig 	<= mem_data(ENABLE_START);
	mem_ports_sig 			<= mem_data(PORTS_START+NR_PORTS-1 downto PORTS_START);
	mem_prio_sig            <= mem_data(PRIO_START+VLAN_PRIO_WIDTH-1 downto PRIO_START);
	mem_skip_frame_sig 		<= mem_data(SKIP_FRAME_START);
	mem_dest_mac_sig 		<= mem_data(DEST_MAC_START+DEST_MAC_WIDTH-1 downto DEST_MAC_START);
  
	-- next state logic
	next_state_logic_p : process(clk)
	begin
		if (clk'event and clk = '1') then
			if reset = '1' then
				cur_state <= IDLE;
			else
				cur_state <= nxt_state;
			end if;
		end if;
	end process next_state_logic_p;
	
	-- Decode next state, combinitorial logic
	output_logic_p : process(cur_state, lookup_in_valid, mem_lookup_enable_sig, mem_default_sig, 
							BASE_ADDRESS, median_sig, upper_reg, lower_reg, median_reg, default_reg, dest_mac_reg, 
							mem_dest_mac_sig, mem_upper_sig, mem_lower_sig)
	begin
		-- default signal assignments
		nxt_state <= IDLE;
		read_header_sig <= '0'; -- read_header_p
		read_base_sig <= '0'; -- write_internal_registers_p
		read_default_sig <= '0'; -- output_reg_p
		lookup_valid_sig <= '0'; -- output_valid_p
		read_lookup_sig <= '0'; -- output_reg_p
		update_sig <= '0'; -- write_internal_registers_p
		upper_sig <= (others => '0'); -- upper_add_lower_by2_f
		lower_sig <= (others => '0'); -- upper_add_lower_by2_f
		-- default output values
		mem_enable <= '0';
		mem_addr_sig <= (others => '1');
    
		case cur_state is
			when IDLE => -- waiting for a new header
				if lookup_in_valid = '1' then
					nxt_state <= READ_BASE;
					read_header_sig <= '1'; -- read_header_p
					mem_enable <= '1';
					mem_addr_sig <= BASE_ADDRESS;
				end if;

			when READ_BASE => -- read base address, determine if lookup is enabled
				read_base_sig <= '1'; -- internal_reg_p
				mem_enable <= '1';
				if mem_lookup_enable_sig = '0' then -- lookup disabled, read default configuration
					nxt_state <= READ_DEFAULT;
					mem_addr_sig <= mem_default_sig;
				else -- lookup enabled, search for address in the middle of binary lookup list
					nxt_state <= LOOKUP;
					upper_sig <= mem_upper_sig; -- upper_add_lower_by2_f
					lower_sig <= mem_lower_sig; -- upper_add_lower_by2_f
					mem_addr_sig <= median_sig; -- upper_add_lower_by2_f
				end if;

			when LOOKUP => -- lookup the median memory address and check if the memory mac address matches the frame mac address
				if dest_mac_reg = mem_dest_mac_sig then -- MAC ADDRESS found -> Algorithm terminates
					nxt_state <= IDLE;
					read_lookup_sig <= '1'; -- output_reg_p
					lookup_valid_sig  <= '1'; -- output_valid_p
				elsif upper_reg <= lower_reg then -- MAC ADDRESS not found -> Algorithm terminats with default configuration
					nxt_state <= READ_DEFAULT;
					mem_addr_sig <= default_reg;
					mem_enable <= '1';
				else -- MAC ADDRESS not found, Algorithm not terminated yet, continue lookup with decreased search space
					update_sig <= '1'; -- internal_reg_p
					mem_addr_sig <= median_sig; -- upper_add_lower_by2_f
					mem_enable <= '1';
					nxt_state <= LOOKUP;
					if dest_mac_reg > mem_dest_mac_sig then
						upper_sig <= upper_reg; -- upper_add_lower_by2_f
						lower_sig <= median_reg + 1; -- upper_add_lower_by2_f
					else -- dest_mac_reg < mem_dest_mac_sig
						upper_sig <= median_reg - 1; -- upper_add_lower_by2_f
						lower_sig <= lower_reg; -- upper_add_lower_by2_f
					end if;
				end if;

			when READ_DEFAULT =>
			    nxt_state <= IDLE;
				read_default_sig  <= '1'; -- output_reg_p
				lookup_valid_sig  <= '1'; -- output_valid_p

		end case;
	end process;

	-- handshake protocol to read header from previous module and store header into internal buffer
	read_header_p : process (clk)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				dest_mac_reg <= (others => '0');
				vlan_enable_reg <= '0';
				vlan_prio_reg <= (others => '0');
				timestamp_reg <= (others => '0');
                lookup_in_ready <= '0';
			else
				dest_mac_reg <= dest_mac_reg;
				vlan_enable_reg <= vlan_enable_reg;
				vlan_prio_reg <= vlan_prio_reg;
				timestamp_reg <= timestamp_reg;
				lookup_in_ready <= '0';
				if read_header_sig = '1' then
					dest_mac_reg <= lookup_in_dest;
					vlan_enable_reg <= lookup_in_vlan_enable;
					vlan_prio_reg <= lookup_in_vlan_prio;
					timestamp_reg <= lookup_in_timestamp;
					lookup_in_ready <= '1';
				end if;
			end if;
		end if;
	end process;
  
	-- handles access to the internal registers needed for lookup
	internal_reg_p : process (clk) -- to be done
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				lower_reg <= (others => '0');
				upper_reg <= (others => '0');
				default_reg <= (others => '0');
				median_reg <= (others => '0');
                mem_addr <= (others => '1');
			else
				lower_reg <= lower_reg;
				upper_reg <= upper_reg;
				default_reg <= default_reg;
				median_reg <= median_reg;
                mem_addr <= mem_addr_sig;
				if read_base_sig = '1' then -- read inital values from base configuration
					lower_reg <= mem_lower_sig;
					upper_reg <= mem_upper_sig;
					default_reg <= mem_default_sig;
					median_reg <= median_sig;
				elsif update_sig = '1' then -- update registers according to remaining search space
					lower_reg <= lower_sig;
					upper_reg <= upper_sig;
					median_reg <= median_sig;
				end if;
			end if;
		end if;
	end process;
  
	-- assign next memory search address: median address in the remaining address search space
	median_sig <= upper_add_lower_by2_f(upper_sig, lower_sig);

	-- updates the output value registers (ports, priority and skip)
	output_reg_p : process (clk)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				ports_reg <= (others => '0');
				prio_reg <= (others => '0');
				skip_frame_reg <= '0';
			else
				ports_reg <= ports_reg;
				prio_reg <= prio_reg;
				skip_frame_reg <= skip_frame_reg;
				if read_default_sig = '1' then
					ports_reg <= mem_ports_sig;
					ports_reg(PORT_ID) <= '0';
					if lookup_in_vlan_enable = '1' then
					   prio_reg <= vlan_prio_reg;
					else
					   prio_reg <= mem_prio_sig;
					end if;
					skip_frame_reg <= mem_skip_frame_sig;
				elsif read_lookup_sig = '1' then
					ports_reg <= mem_ports_sig;
					ports_reg(PORT_ID) <= '0'; -- comment for loopback functionality
					if lookup_in_vlan_enable = '1' then
					   prio_reg <= vlan_prio_reg;
				    else
					   prio_reg <= mem_prio_sig;
					end if;
					skip_frame_reg <= '0';
				end if;
			end if;
		end if;
	end process;

	-- sets the output valid bit
	output_valid_p : process (clk)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				lookup_out_valid <= '0';
			else
				lookup_out_valid <= '0';
				if lookup_valid_sig = '1' then
					lookup_out_valid <= '1';
				end if;
			end if;
		end if;
	end process;
  
	-- other outputs
	lookup_out_ports <= ports_reg;
	lookup_out_prio <= prio_reg;
	lookup_out_skip <= skip_frame_reg;
	lookup_out_timestamp <= timestamp_reg;
  
end rtl;
