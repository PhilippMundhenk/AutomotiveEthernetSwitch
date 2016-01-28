-- -----------------------------------------------------------------------------
-- Description: to be done
--------------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- The entity declaration for the FIFO
--------------------------------------------------------------------------------

entity mac_fifo_interface is
    generic (
     GMII_DATA_WIDTH            : integer;
     RECEIVER_DATA_WIDTH        : integer;
     FULL_DUPLEX_ONLY           : boolean := true
    );  -- If fifo is to be used only in full duplex set to true for optimised implementation
    port (
     tx_fifo_in_clk             : in  std_logic;
     tx_fifo_in_reset           : in  std_logic;
     tx_fifo_in_data            : in  std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
     tx_fifo_in_valid           : in  std_logic;
     tx_fifo_in_last            : in  std_logic;
     tx_fifo_in_ready           : out std_logic;

     tx_fifo_out_clk            : in  std_logic;
     tx_fifo_out_resetn         : in  std_logic;
     tx_fifo_out_data           : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
     tx_fifo_out_valid          : out std_logic;
     tx_fifo_out_last           : out std_logic;
     tx_fifo_out_ready          : in  std_logic;
     tx_fifo_out_user           : out std_logic;

     rx_fifo_out_clk            : in  std_logic;
     rx_fifo_out_resetn         : in  std_logic;
     rx_fifo_out_data           : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
     rx_fifo_out_valid          : out std_logic;
     rx_fifo_out_last           : out std_logic;
     rx_fifo_out_user           : out std_logic;

     rx_fifo_in_clk             : in  std_logic;
     rx_fifo_in_reset           : in  std_logic;
     rx_fifo_in_data            : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
     rx_fifo_in_valid           : in  std_logic;
     rx_fifo_in_last            : in  std_logic;
     rx_fifo_in_user            : in  std_logic;
     rx_fifo_status             : out std_logic_vector(3 downto 0) := "0000";
     rx_fifo_overflow           : out std_logic := '0'
    );
end mac_fifo_interface;

architecture RTL of mac_fifo_interface is

component switch_input_port_fifo
   generic (
     GMII_DATA_WIDTH            : integer;
     RECEIVER_DATA_WIDTH        : integer
   );
   port (
     -- User-side interface (read)
     rx_fifo_out_clk            : in  std_logic;
     rx_fifo_out_resetn         : in  std_logic;
     rx_fifo_out_data           : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
     rx_fifo_out_valid          : out std_logic;
     rx_fifo_out_last           : out std_logic;
     rx_fifo_out_user           : out std_logic;

     -- MAC-side interface (write)
     rx_fifo_in_clk             : in  std_logic;
     rx_fifo_in_reset           : in  std_logic;
     rx_fifo_in_data            : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
     rx_fifo_in_valid           : in  std_logic;
     rx_fifo_in_last            : in  std_logic;
     rx_fifo_in_user            : in  std_logic
   );
end component;

component switch_output_port_fifo
    generic (
        GMII_DATA_WIDTH            : integer;
        TRANSMITTER_DATA_WIDTH     : integer
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
        tx_fifo_out_resetn          : in  std_logic;
        tx_fifo_out_data            : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        tx_fifo_out_valid           : out std_logic;
        tx_fifo_out_last            : out std_logic;
        tx_fifo_out_ready           : in  std_logic;
        tx_fifo_out_user            : out std_logic
    );
end component;

begin
------------------------------------------------------------------------------
-- Instantiate the Receiver FIFO
------------------------------------------------------------------------------
rx_fifo_i : switch_input_port_fifo
    generic map(
        GMII_DATA_WIDTH       => GMII_DATA_WIDTH,
        RECEIVER_DATA_WIDTH   => RECEIVER_DATA_WIDTH
    )
    port map(
        rx_fifo_out_clk       => rx_fifo_out_clk,
        rx_fifo_out_resetn    => rx_fifo_out_resetn,
        rx_fifo_out_data      => rx_fifo_out_data,
        rx_fifo_out_valid     => rx_fifo_out_valid,
        rx_fifo_out_last      => rx_fifo_out_last,
        rx_fifo_out_user      => rx_fifo_out_user,

        rx_fifo_in_clk        => rx_fifo_in_clk,
        rx_fifo_in_reset      => rx_fifo_in_reset,
        rx_fifo_in_data       => rx_fifo_in_data,
        rx_fifo_in_valid      => rx_fifo_in_valid,
        rx_fifo_in_last       => rx_fifo_in_last,
        rx_fifo_in_user       => rx_fifo_in_user
    );

  ------------------------------------------------------------------------------
  -- Instantiate the Transmitter FIFO
  ------------------------------------------------------------------------------
tx_fifo_i : switch_output_port_fifo
    generic map(
        GMII_DATA_WIDTH         => GMII_DATA_WIDTH,
        TRANSMITTER_DATA_WIDTH  => TRANSMITTER_DATA_WIDTH
    )
    port map(
        tx_fifo_in_clk     => tx_fifo_in_clk,
        tx_fifo_in_reset   => tx_fifo_in_reset,
        tx_fifo_in_tdata   => tx_fifo_in_data,
        tx_fifo_in_tvalid  => tx_fifo_in_valid,
        tx_fifo_in_tlast   => tx_fifo_in_last,
        tx_fifo_in_tready  => tx_fifo_in_ready,

        tx_fifo_out_clk    => tx_fifo_out_clk,
        tx_fifo_out_resetn => tx_fifo_out_resetn,
        tx_fifo_out_tdata  => tx_fifo_out_data,
        tx_fifo_out_tvalid => tx_fifo_out_valid,
        tx_fifo_out_tlast  => tx_fifo_out_last,
        tx_fifo_out_tready => tx_fifo_out_ready,
        tx_fifo_out_tuser  => tx_fifo_out_user
    );

end RTL;
