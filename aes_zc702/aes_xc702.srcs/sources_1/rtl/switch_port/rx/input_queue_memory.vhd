----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 26.11.2013 17:14:16
-- Design Name: 
-- Module Name: input_queue_memory - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: wrapper for the input queue memory
-- The input queue memory stores incoming frames until arbitration is succesful
-- input queue control modules handles frame storage for frames received from MAC
-- input queue arbitration handles memory read accesses
-- memory overflow is handled in input queue fifo by deleting the oldest frame in memory
-- 
-- more detailed information can found in file switch_port_rxpath_input_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity input_queue_memory is
    Generic (
        IQ_MEM_ADDR_WIDTH_A    : integer;
        IQ_MEM_ADDR_WIDTH_B    : integer;
        IQ_MEM_DATA_WIDTH_IN   : integer;
        IQ_MEM_DATA_WIDTH_OUT  : integer
    );
    Port (
        --Port A -> Control module
        iqmem_in_wenable   	: in std_logic_vector;
        iqmem_in_addr       : in std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
        iqmem_in_data       : in std_logic_vector(IQ_MEM_DATA_WIDTH_IN-1 downto 0);
        iqmem_in_clk        : in std_logic;
        --Port B -> arbitration module -> switch fabric
        iqmem_out_enable    : in std_logic;
        iqmem_out_addr      : in std_logic_vector(IQ_MEM_ADDR_WIDTH_B-1 downto 0);
        iqmem_out_data      : out std_logic_vector(IQ_MEM_DATA_WIDTH_OUT-1 downto 0);
        iqmem_out_clk       : in std_logic
    );
end input_queue_memory;

architecture rtl of input_queue_memory is

	component blk_mem_gen_1 is
	Port (
		--Port A -> Control module
		wea      	: in std_logic_vector;
		addra      	: in std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
		dina       	: in std_logic_vector(IQ_MEM_DATA_WIDTH_IN-1 downto 0);
		clka       	: in std_logic;
		--Port B -> arbitration module -> switch fabric
		enb        	: in std_logic;  --opt port
		addrb      	: in std_logic_vector(IQ_MEM_ADDR_WIDTH_B-1 downto 0);
		doutb      	: out std_logic_vector(IQ_MEM_DATA_WIDTH_OUT-1 downto 0);
		clkb       	: in std_logic
	);
	end component;
  
begin

	input_queue_mem_ip : blk_mem_gen_1
    PORT MAP (
		--Port A
		wea       	=> iqmem_in_wenable,
		addra      	=> iqmem_in_addr,
		dina       	=> iqmem_in_data,
		clka       	=> iqmem_in_clk,
		--Port B
		enb        	=> iqmem_out_enable, 
		addrb      	=> iqmem_out_addr,
		doutb      	=> iqmem_out_data,
		clkb      	=> iqmem_out_clk
    );

end rtl;
