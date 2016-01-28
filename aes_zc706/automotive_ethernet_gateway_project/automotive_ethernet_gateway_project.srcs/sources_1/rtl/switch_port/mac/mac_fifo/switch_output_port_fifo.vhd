----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 12.12.2013 10:41:20
-- Design Name: 
-- Module Name: switch_output_port_fifo - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description:
-- FIFO interface between switch port on the transmit path and MAC 
-- for decoupling clocks and data widths
-- bandwidth on user interface (read) must be higher than mac interface (write)
-- width = error_width + last_width + data_width
-- depth = 32 entries
--
-- see switch_mac_txfifo.svg for further information
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity switch_output_port_fifo is
    generic (
        GMII_DATA_WIDTH           	: integer;
        TRANSMITTER_DATA_WIDTH     	: integer
    );
    port (
        -- User-side interface (write)
        tx_fifo_in_clk              : in  std_logic;
        tx_fifo_in_reset            : in  std_logic;
        tx_fifo_in_data             : in  std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        tx_fifo_in_valid            : in  std_logic;
        tx_fifo_in_last             : in  std_logic;
        tx_fifo_in_ready            : out std_logic;
        -- MAC-side interface (read)
        tx_fifo_out_clk             : in  std_logic;
        tx_fifo_out_reset           : in  std_logic;
        tx_fifo_out_data            : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        tx_fifo_out_valid           : out std_logic;
        tx_fifo_out_last            : out std_logic;
        tx_fifo_out_ready           : in  std_logic;
        tx_fifo_out_error           : out std_logic
    );
end switch_output_port_fifo;

architecture rtl of switch_output_port_fifo is

    component fifo_generator_3 is
        PORT (
            wr_clk     	: IN  std_logic := '0';
     	    rd_clk      : IN  std_logic := '0';
            wr_rst      : IN  std_logic := '0';
            rd_rst      : IN  std_logic := '0';
            wr_en 		: IN  std_logic := '0';
            rd_en       : IN  std_logic := '0';
            din         : IN  std_logic_vector(TRANSMITTER_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
            dout        : OUT std_logic_vector(GMII_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
            full        : OUT std_logic := '0';
            empty       : OUT std_logic := '1'
        );
    end component;

    signal dout_sig : std_logic_vector(GMII_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
    signal din_sig  : std_logic_vector(TRANSMITTER_DATA_WIDTH+2-1 DOWNTO 0) := (OTHERS => '0');
    signal full_sig : std_logic;
    signal empty_sig : std_logic;

begin

	din_sig <= '0' & tx_fifo_in_last & tx_fifo_in_data;

	-- module output ports
	tx_fifo_out_error   <= dout_sig(GMII_DATA_WIDTH+2-1);
	tx_fifo_out_last   <= dout_sig(GMII_DATA_WIDTH+1-1);
	tx_fifo_out_data   <= dout_sig(GMII_DATA_WIDTH-1 downto 0);
	tx_fifo_in_ready   <= not full_sig;
	tx_fifo_out_valid  <= not empty_sig;

	-- connecting the FIFO inputs and outputs
	rx_fifo_ip : fifo_generator_3 
    PORT MAP (
         wr_clk   		=> tx_fifo_in_clk,
         wr_rst        	=> tx_fifo_in_reset,
         wr_en 		    => tx_fifo_in_valid,
         din            => din_sig,
         full           => full_sig,
         rd_clk         => tx_fifo_out_clk,
         rd_rst         => tx_fifo_out_reset,
         rd_en          => tx_fifo_out_ready,
         dout           => dout_sig,
         empty         	=> empty_sig
    );
     
end rtl;
