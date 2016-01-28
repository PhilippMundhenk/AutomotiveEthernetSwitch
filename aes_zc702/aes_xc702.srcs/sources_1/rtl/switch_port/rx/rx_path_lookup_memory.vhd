----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 21.11.2013 14:22:20
-- Design Name: rx_path_lookup_memory.vhd
-- Module Name: rx_path_lookup_memory - structural
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: this module contains the lookup memory
-- for details on the lookup memory and search process see switch_port_rxpath_lookup_memory.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rx_path_lookup_memory is
    Generic (
        LOOKUP_MEM_ADDR_WIDTH  	: integer;
        LOOKUP_MEM_DATA_WIDTH   : integer
    );
    Port (
        --Port A -> Processor
        mem_in_wenable     	: in std_logic_vector;
        mem_in_addr         : in std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
        mem_in_data         : in std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
        mem_in_clk          : in std_logic;
        --Port B -> Lookup module
        mem_out_enable      : in std_logic;
        mem_out_addr        : in std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
        mem_out_data        : out std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
        mem_out_clk         : in std_logic
    );
end rx_path_lookup_memory;

architecture structural of rx_path_lookup_memory is

	component blk_mem_gen_0 is
	Port (
		--Port A -> Processor
		wea        : in std_logic_vector;
		addra      : in std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
		dina       : in std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
		clka       : in std_logic;
		--Port B -> Lookup module
		enb        : in std_logic;  --opt port
		addrb      : in std_logic_vector(LOOKUP_MEM_ADDR_WIDTH-1 downto 0);
		doutb      : out std_logic_vector(LOOKUP_MEM_DATA_WIDTH-1 downto 0);
		clkb       : in std_logic
	);
	end component;
    signal neg_clk : std_logic;
begin
    neg_clk <= not mem_out_clk;
    
	lookup_mem_ip : blk_mem_gen_0
    PORT MAP (
		--Port A
		wea        => mem_in_wenable,
		addra      => mem_in_addr,
		dina       => mem_in_data,
		clka       => mem_in_clk,
		--Port B
		enb        => mem_out_enable, 
		addrb      => mem_out_addr,
		doutb      => mem_out_data,
		clkb       => mem_out_clk
    );
    
end structural;
