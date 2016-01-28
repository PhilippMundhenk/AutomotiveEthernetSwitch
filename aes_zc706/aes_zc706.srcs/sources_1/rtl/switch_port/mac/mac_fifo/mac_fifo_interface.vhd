-- -----------------------------------------------------------------------------
-- Description: this module contains
-- - an rx Fifo interface between the MAC and the input port
-- - an tx Fifo interface between the output port and the MAC
-- to decouple the clocks of the MAC and the switch
-- switch should have a equal or higher clock rate as the MAC
--------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;


entity mac_fifo_interface is
    generic (
        GMII_DATA_WIDTH         : integer;
        RECEIVER_DATA_WIDTH     : integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        FULL_DUPLEX_ONLY        : boolean := true
    );  -- If fifo is to be used only in full duplex set to true for optimised implementation
    port (
        -- txpath interface
        tx_fifo_in_clk         	: in  std_logic;
        tx_fifo_in_reset        : in  std_logic;
        tx_fifo_in_data         : in  std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        tx_fifo_in_valid        : in  std_logic;
        tx_fifo_in_last         : in  std_logic;
        tx_fifo_in_ready        : out std_logic;
        -- support block interface
        tx_fifo_out_clk         : in  std_logic;
        tx_fifo_out_reset       : in  std_logic;
        tx_fifo_out_data        : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        tx_fifo_out_valid       : out std_logic;
        tx_fifo_out_last        : out std_logic;
        tx_fifo_out_ready       : in  std_logic;
        tx_fifo_out_error       : out std_logic;
        -- rxpath interface
        rx_fifo_out_clk         : in  std_logic;
        rx_fifo_out_reset       : in  std_logic;
        rx_fifo_out_data        : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        rx_fifo_out_valid       : out std_logic;
        rx_fifo_out_last        : out std_logic;
        rx_fifo_out_error       : out std_logic;
        -- support block interface
        rx_fifo_in_clk          : in  std_logic;
        rx_fifo_in_reset        : in  std_logic;
        rx_fifo_in_data         : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        rx_fifo_in_valid        : in  std_logic;
        rx_fifo_in_last         : in  std_logic;
        rx_fifo_in_error        : in  std_logic
    );
end mac_fifo_interface;

architecture RTL of mac_fifo_interface is

	component switch_input_port_fifo
	generic (
		GMII_DATA_WIDTH         : integer;
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
		rx_fifo_in_error       	: in  std_logic
	);
	end component;

	component switch_output_port_fifo
    generic (
        GMII_DATA_WIDTH         : integer;
        TRANSMITTER_DATA_WIDTH  : integer
    );
    port (
        -- User-side interface (write)
        tx_fifo_in_clk          : in  std_logic;
        tx_fifo_in_reset        : in  std_logic;
        tx_fifo_in_data         : in  std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        tx_fifo_in_valid        : in  std_logic;
        tx_fifo_in_last         : in  std_logic;
        tx_fifo_in_ready        : out std_logic;
        -- MAC-side interface (read)
        tx_fifo_out_clk         : in  std_logic;
        tx_fifo_out_reset       : in  std_logic;
        tx_fifo_out_data        : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        tx_fifo_out_valid       : out std_logic;
        tx_fifo_out_last        : out std_logic;
        tx_fifo_out_ready       : in  std_logic;
        tx_fifo_out_error       : out std_logic
    );
	end component;

begin

	rx_fifo_i : switch_input_port_fifo
    generic map(
        GMII_DATA_WIDTH      	=> GMII_DATA_WIDTH,
        RECEIVER_DATA_WIDTH   	=> RECEIVER_DATA_WIDTH
    )
    port map(
        rx_fifo_out_clk       	=> rx_fifo_out_clk,
        rx_fifo_out_reset     	=> rx_fifo_out_reset,
        rx_fifo_out_data      	=> rx_fifo_out_data,
        rx_fifo_out_valid     	=> rx_fifo_out_valid,
        rx_fifo_out_last      	=> rx_fifo_out_last,
        rx_fifo_out_error      	=> rx_fifo_out_error,

        rx_fifo_in_clk        	=> rx_fifo_in_clk,
        rx_fifo_in_reset      	=> rx_fifo_in_reset,
        rx_fifo_in_data       	=> rx_fifo_in_data,
        rx_fifo_in_valid      	=> rx_fifo_in_valid,
        rx_fifo_in_last       	=> rx_fifo_in_last,
        rx_fifo_in_error       	=> rx_fifo_in_error
    );

	tx_fifo_i : switch_output_port_fifo
    generic map(
        GMII_DATA_WIDTH         => GMII_DATA_WIDTH,
        TRANSMITTER_DATA_WIDTH  => TRANSMITTER_DATA_WIDTH
    )
    port map(
        tx_fifo_in_clk      	=> tx_fifo_in_clk,
        tx_fifo_in_reset    	=> tx_fifo_in_reset,
        tx_fifo_in_data     	=> tx_fifo_in_data,
        tx_fifo_in_valid    	=> tx_fifo_in_valid,
        tx_fifo_in_last     	=> tx_fifo_in_last,
        tx_fifo_in_ready    	=> tx_fifo_in_ready,

        tx_fifo_out_clk     	=> tx_fifo_out_clk,
        tx_fifo_out_reset   	=> tx_fifo_out_reset,
        tx_fifo_out_data    	=> tx_fifo_out_data,
        tx_fifo_out_valid   	=> tx_fifo_out_valid,
        tx_fifo_out_last    	=> tx_fifo_out_last,
        tx_fifo_out_ready   	=> tx_fifo_out_ready,
        tx_fifo_out_error    	=> tx_fifo_out_error
    );

end RTL;
