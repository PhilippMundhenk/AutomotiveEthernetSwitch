----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 18.11.2013 10:02:58
-- Design Name: 
-- Module Name: switch_input_port_fifo - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: 
-- FIFO interface between MAC and switch port on the receive path
-- for decoupling clocks and data widths
-- bandwidth on user interface (read) must be higher than mac interface (write)
-- width = error_width + last_width + data_width
-- depth = 16 entries
-- see switch_mac_rxfifo.svg for further information
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity switch_input_port_fifo is
	generic (
		GMII_DATA_WIDTH        	: integer;
		RECEIVER_DATA_WIDTH     : integer
	);
	port (
		-- User-side interface (read)
		rx_fifo_out_clk         : in  std_logic;
		rx_fifo_out_reset       : in  std_logic;
		rx_fifo_out_data        : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
		rx_fifo_out_valid       : out std_logic;
		rx_fifo_out_last        : out std_logic;
		rx_fifo_out_error       : out std_logic;
		-- MAC-side interface (write)
		rx_fifo_in_clk          : in  std_logic;
		rx_fifo_in_reset        : in  std_logic;
		rx_fifo_in_data         : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
		rx_fifo_in_valid        : in  std_logic;
		rx_fifo_in_last         : in  std_logic;
		rx_fifo_in_error        : in  std_logic
	);
end switch_input_port_fifo;

architecture rtl of switch_input_port_fifo is

	component fifo_generator_0 is
	PORT (
        wr_clk      	: IN  std_logic := '0';
     	rd_clk          : IN  std_logic := '0';
        valid           : OUT std_logic := '0';
        wr_rst          : IN  std_logic := '0';
        rd_rst          : IN  std_logic := '0';
        wr_en 		    : IN  std_logic := '0';
        rd_en           : IN  std_logic := '0';
        din             : IN  std_logic_vector(GMII_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
        dout            : OUT std_logic_vector(RECEIVER_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
        full            : OUT std_logic := '0';
        empty           : OUT std_logic := '1'
	);
	end component;
  
	signal din_sig      : std_logic_vector(GMII_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
	signal dout_sig     : std_logic_vector(GMII_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
	signal empty_sig    : std_logic := '0';
	signal rd_en_sig    : std_logic := '0';
  
begin

	-- FIFO input ports
	din_sig            	<= rx_fifo_in_error & rx_fifo_in_last & rx_fifo_in_data;
	rd_en_sig          	<= not empty_sig;
	-- module output ports
	rx_fifo_out_error  	<= dout_sig(RECEIVER_DATA_WIDTH+2-1);
	rx_fifo_out_last   	<= dout_sig(RECEIVER_DATA_WIDTH+1-1);
	rx_fifo_out_data   	<= dout_sig(RECEIVER_DATA_WIDTH-1 downto 0);
  
	-- connecting the FIFO inputs and outputs
	rx_fifo_ip : fifo_generator_0 
    PORT MAP (
        wr_clk          => rx_fifo_in_clk,
        wr_rst          => rx_fifo_in_reset,
        wr_en 		    => rx_fifo_in_valid,
        din             => din_sig,
        full            => open,
        rd_clk          => rx_fifo_out_clk,
        rd_rst          => rx_fifo_out_reset,
        valid           => rx_fifo_out_valid,
        rd_en           => rd_en_sig,
        dout            => dout_sig,
        empty           => empty_sig
    );

end rtl;
