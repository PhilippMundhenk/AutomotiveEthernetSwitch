--------------------------------------------------------------------------------
-- Description:
-- This module contains The Ethernet MAC Block
-- as well as a FIFO block to decouple the switch clock frequency from the MAC
-- clock frequency

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tri_mode_ethernet_mac_block is
    Generic (
        RECEIVER_DATA_WIDTH       	: integer;
        TRANSMITTER_DATA_WIDTH     	: integer;
        GMII_DATA_WIDTH            	: integer;
        RX_STATISTICS_WIDTH        	: integer:=28;
        TX_STATISTICS_WIDTH        	: integer:=32;
        TX_IFG_DELAY_WIDTH         	: integer;
        PAUSE_VAL_WIDTH            	: integer
    );
    port(
        gtx_clk                    	: in  std_logic;
        -- asynchronous reset
        glbl_rstn                  	: in  std_logic;
        rx_axi_rstn                	: in  std_logic;
        tx_axi_rstn                	: in  std_logic;
        -- Reference clock for IDELAYCTRL's
        refclk                     	: in  std_logic;
        -- Receiver Interface
        -----------------------------------------
        rx_mac_aclk                	: out std_logic;
        rx_reset                   	: out std_logic;
        -- mac to rxpath interface
        ------------------------------------------
        mac_out_clock              	: in  std_logic;
        mac_out_resetn             	: in  std_logic;
        mac_out_data               	: out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        mac_out_valid              	: out std_logic;
        mac_out_last               	: out std_logic;
        mac_out_error              	: out std_logic;
        -- Transmitter Interface
        --------------------------------------------
        tx_mac_aclk                	: out std_logic;
        tx_reset                   	: out std_logic;
        tx_ifg_delay               	: in  std_logic_vector(TX_IFG_DELAY_WIDTH-1 downto 0);
        -- txpath to mac interface
        ---------------------------------------------
        mac_in_clock               	: in  std_logic;
        mac_in_resetn              	: in  std_logic;
        mac_in_data                	: in  std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        mac_in_valid               	: in  std_logic;
        mac_in_ready               	: out std_logic;
        mac_in_last                	: in  std_logic;
        -- MAC Control Interface
        --------------------------
        pause_req                  	: in  std_logic;
        pause_val                  	: in  std_logic_vector(PAUSE_VAL_WIDTH-1 downto 0);
        -- GMII Interface
        -------------------
        gmii_txd                  	: out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        gmii_tx_en                	: out std_logic;
        gmii_tx_er                	: out std_logic;
        gmii_tx_clk               	: out std_logic;
        gmii_rxd                  	: in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        gmii_rx_dv                	: in  std_logic;
        gmii_rx_er                	: in  std_logic;
        gmii_rx_clk               	: in  std_logic;
        mii_tx_clk                  : in  std_logic;
        -- MDIO Interface
        -------------------
        mdio                      	: inout std_logic;
        mdc                       	: out std_logic;
        -- AXI-Lite Interface
        -----------------
        s_axi_aclk                	: in  std_logic;
        s_axi_resetn              	: in  std_logic;
        s_axi_awaddr              	: in  std_logic_vector(11 downto 0);
        s_axi_awvalid             	: in  std_logic;
        s_axi_awready             	: out std_logic;
        s_axi_wdata               	: in  std_logic_vector(31 downto 0);
        s_axi_wvalid              	: in  std_logic;
        s_axi_wready              	: out std_logic;
        s_axi_bresp               	: out std_logic_vector(1 downto 0);
        s_axi_bvalid              	: out std_logic;
        s_axi_bready              	: in  std_logic;
        s_axi_araddr              	: in  std_logic_vector(11 downto 0);
        s_axi_arvalid             	: in  std_logic;
        s_axi_arready             	: out std_logic;
        s_axi_rdata               	: out std_logic_vector(31 downto 0);
        s_axi_rresp               	: out std_logic_vector(1 downto 0);
        s_axi_rvalid              	: out std_logic;
        s_axi_rready              	: in  std_logic;
        mac_interrupt               : out std_logic
    );
end tri_mode_ethernet_mac_block;


architecture wrapper of tri_mode_ethernet_mac_block is

	attribute DowngradeIPIdentifiedWarnings: string;
	attribute DowngradeIPIdentifiedWarnings of wrapper : architecture is "yes";

	------------------------------------------------------------------------------
	-- Component declaration for the Tri-Mode Ethernet MAC Support Level wrapper
	------------------------------------------------------------------------------
	component tri_mode_ethernet_mac_0
    port(
		gtx_clk                    	: in  std_logic;
		-- asynchronous reset
		glbl_rstn                  	: in  std_logic;
		rx_axi_rstn                	: in  std_logic;
		tx_axi_rstn                	: in  std_logic;
		-- Receiver Interface
		----------------------------
		rx_enable                   : out std_logic;
		rx_statistics_vector       	: out std_logic_vector(RX_STATISTICS_WIDTH-1 downto 0);
		rx_statistics_valid        	: out std_logic;
		rx_mac_aclk                	: out std_logic;
		rx_reset                   	: out std_logic;
		rx_axis_mac_tdata          	: out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
		rx_axis_mac_tvalid         	: out std_logic;
		rx_axis_mac_tlast          	: out std_logic;
		rx_axis_mac_tuser          	: out std_logic;
		-- Transmitter Interface
		-------------------------------
		tx_enable                   : out std_logic;
		tx_ifg_delay               	: in  std_logic_vector(TX_IFG_DELAY_WIDTH-1 downto 0);
		tx_statistics_vector       	: out std_logic_vector(TX_STATISTICS_WIDTH-1 downto 0);
		tx_statistics_valid        	: out std_logic;
		tx_mac_aclk                	: out std_logic;
		tx_reset                   	: out std_logic;
		tx_axis_mac_tdata          	: in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
		tx_axis_mac_tvalid         	: in  std_logic;
		tx_axis_mac_tlast          	: in  std_logic;
		tx_axis_mac_tuser          	: in  std_logic_vector(0 downto 0);
		tx_axis_mac_tready         	: out std_logic;
		-- MAC Control Interface
		------------------------
		pause_req                  	: in  std_logic;
		pause_val                  	: in  std_logic_vector(PAUSE_VAL_WIDTH-1 downto 0);
		-- Reference clock for IDELAYCTRL's
		speedis100                 	: out std_logic;
		speedis10100               	: out std_logic;
		-- GMII Interface
		-----------------
		gmii_txd                   	: out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
		gmii_tx_en                 	: out std_logic;
		gmii_tx_er                 	: out std_logic;
		gmii_tx_clk                	: out std_logic;
		gmii_rxd                   	: in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
		gmii_rx_dv                 	: in  std_logic;
		gmii_rx_er                 	: in  std_logic;
		gmii_rx_clk                	: in  std_logic;
		mii_tx_clk                  : in  std_logic;
		-- MDIO Interface
		-----------------
		mdio                       	: inout std_logic;
		mdc                        	: out std_logic;
		-- AXI-Lite Interface
		-----------------
		s_axi_aclk                 	: in  std_logic;
		s_axi_resetn               	: in  std_logic;
		s_axi_awaddr               	: in  std_logic_vector(11 downto 0);
		s_axi_awvalid              	: in  std_logic;
		s_axi_awready              	: out std_logic;
		s_axi_wdata                	: in  std_logic_vector(31 downto 0);
		s_axi_wvalid               	: in  std_logic;
		s_axi_wready               	: out std_logic;
		s_axi_bresp                	: out std_logic_vector(1 downto 0);
		s_axi_bvalid               	: out std_logic;
		s_axi_bready               	: in  std_logic;
		s_axi_araddr               	: in  std_logic_vector(11 downto 0);
		s_axi_arvalid              	: in  std_logic;
		s_axi_arready              	: out std_logic;
		s_axi_rdata                	: out std_logic_vector(31 downto 0);
		s_axi_rresp                	: out std_logic_vector(1 downto 0);
		s_axi_rvalid               	: out std_logic;
		s_axi_rready               	: in  std_logic;
		mac_irq                    	: out std_logic
	);
	end component;

	------------------------------------------------------------------------------
	-- Component declaration for the fifo
	------------------------------------------------------------------------------
	component mac_fifo_interface
    generic (
        GMII_DATA_WIDTH        	: integer;
        RECEIVER_DATA_WIDTH     : integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        FULL_DUPLEX_ONLY        : boolean := true
    );  -- If fifo is to be used only in full duplex set to true for optimised implementation
    port (
        -- txpath interface
        tx_fifo_in_clk          : in  std_logic;
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
        rx_fifo_out_error        : out std_logic;
        -- support block interface
        rx_fifo_in_clk          : in  std_logic;
        rx_fifo_in_reset        : in  std_logic;
        rx_fifo_in_data         : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        rx_fifo_in_valid        : in  std_logic;
        rx_fifo_in_last         : in  std_logic;
        rx_fifo_in_error        : in  std_logic
    );
    end component;

	------------------------------------------------------------------------------
	-- Component declaration for the reset synchroniser
	------------------------------------------------------------------------------
	component aeg_design_0_reset_sync
	port (
		reset_in                : in  std_logic;    -- Active high asynchronous reset
		enable                  : in  std_logic;
		clk                     : in  std_logic;    -- clock to be sync'ed to
		reset_out               : out std_logic     -- "Synchronised" reset signal
	);
	end component;

	------------------------------------------------------------------------------
	-- Internal signals used in this fifo block level wrapper.
	------------------------------------------------------------------------------

	signal rx_mac_aclk_int      : std_logic;   -- MAC Rx clock
	signal tx_mac_aclk_int      : std_logic;   -- MAC Tx clock
	signal rx_reset_int         : std_logic;   -- MAC Rx reset
	signal tx_reset_int         : std_logic;   -- MAC Tx reset
	signal tx_mac_resetn        : std_logic;
	signal tx_mac_reset         : std_logic;
	signal rx_mac_reset         : std_logic;
	signal mac_out_reset        : std_logic;
	signal mac_in_reset         : std_logic;

	-- MAC receiver client I/F
	signal sup2rxfifo_data      : std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
	signal sup2rxfifo_valid     : std_logic;
	signal sup2rxfifo_last      : std_logic;
	signal sup2rxfifo_error     : std_logic;

	-- MAC transmitter client I/F
	signal txfifo2sup_data      : std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
	signal txfifo2sup_valid     : std_logic;
	signal txfifo2sup_ready     : std_logic;
	signal txfifo2sup_last      : std_logic;
	signal txfifo2sup_error     : std_logic_vector(0 downto 0);


begin

	------------------------------------------------------------------------------
	-- Connect the output clock signals
	------------------------------------------------------------------------------

	rx_mac_aclk        	<= rx_mac_aclk_int;
	tx_mac_aclk         <= tx_mac_aclk_int;
	rx_reset            <= rx_reset_int;
	tx_reset            <= tx_reset_int;
	mac_out_reset       <= not mac_out_resetn;
	mac_in_reset        <= not mac_in_resetn;
   
	------------------------------------------------------------------------------
	-- Instantiate the Tri-Mode Ethernet MAC Support Level wrapper
	------------------------------------------------------------------------------
	tri_mode_ethernet_mac_i : tri_mode_ethernet_mac_0
	port map(
		gtx_clk               	=> gtx_clk,
		-- asynchronous reset
		glbl_rstn             	=> glbl_rstn,
		rx_axi_rstn           	=> rx_axi_rstn,
		tx_axi_rstn           	=> tx_axi_rstn,
		-- Client Receiver Interface
		rx_enable               => open,
		rx_statistics_vector  	=> open,
		rx_statistics_valid   	=> open,
		rx_mac_aclk           	=> rx_mac_aclk_int,
		rx_reset              	=> rx_reset_int,
		rx_axis_mac_tdata     	=> sup2rxfifo_data,
		rx_axis_mac_tvalid    	=> sup2rxfifo_valid,
		rx_axis_mac_tlast     	=> sup2rxfifo_last,
		rx_axis_mac_tuser     	=> sup2rxfifo_error,
		-- Client Transmitter Interface
		tx_enable               => open,
		tx_ifg_delay          	=> tx_ifg_delay,
		tx_statistics_vector  	=> open,
		tx_statistics_valid   	=> open,
		tx_mac_aclk           	=> tx_mac_aclk_int,
		tx_reset              	=> tx_reset_int,
		tx_axis_mac_tdata     	=> txfifo2sup_data ,
		tx_axis_mac_tvalid    	=> txfifo2sup_valid,
		tx_axis_mac_tlast     	=> txfifo2sup_last,
		tx_axis_mac_tuser     	=> txfifo2sup_error,
		tx_axis_mac_tready    	=> txfifo2sup_ready,
		-- Flow Control
		pause_req             	=> pause_req,
		pause_val             	=> pause_val,
		-- speed control
		speedis100            	=> open,
		speedis10100          	=> open,
		-- GMII Interface
		gmii_txd              	=> gmii_txd,
		gmii_tx_en            	=> gmii_tx_en,
		gmii_tx_er            	=> gmii_tx_er,
		gmii_tx_clk           	=> gmii_tx_clk,
		gmii_rxd              	=> gmii_rxd,
		gmii_rx_dv            	=> gmii_rx_dv,
		gmii_rx_er            	=> gmii_rx_er,
		gmii_rx_clk           	=> gmii_rx_clk,
		mii_tx_clk              => mii_tx_clk,
		-- MDIO Interface
		mdio                  	=> mdio,
		mdc                   	=> mdc,
		-- AXI lite interface
		s_axi_aclk            	=> s_axi_aclk,
		s_axi_resetn          	=> s_axi_resetn,
		s_axi_awaddr          	=> s_axi_awaddr,
		s_axi_awvalid         	=> s_axi_awvalid,
		s_axi_awready         	=> s_axi_awready,
		s_axi_wdata           	=> s_axi_wdata,
		s_axi_wvalid          	=> s_axi_wvalid,
		s_axi_wready          	=> s_axi_wready,
		s_axi_bresp           	=> s_axi_bresp,
		s_axi_bvalid          	=> s_axi_bvalid,
		s_axi_bready          	=> s_axi_bready,
		s_axi_araddr          	=> s_axi_araddr,
		s_axi_arvalid         	=> s_axi_arvalid,
		s_axi_arready         	=> s_axi_arready,
		s_axi_rdata           	=> s_axi_rdata,
		s_axi_rresp           	=> s_axi_rresp,
		s_axi_rvalid          	=> s_axi_rvalid,
		s_axi_rready          	=> s_axi_rready,
		mac_irq               	=> mac_interrupt
	);

	------------------------------------------------------------------------------
	-- Instantiate the user side FIFO
	------------------------------------------------------------------------------

	-- locally reset sync the mac generated resets - the resets are already fully sync
	-- so adding a reset sync shouldn't change that
	rx_mac_reset_gen : aeg_design_0_reset_sync
	port map (
		clk               	=> rx_mac_aclk_int,
		enable              => '1',
		reset_in            => rx_reset_int,
		reset_out           => rx_mac_reset
	);

	tx_mac_reset_gen : aeg_design_0_reset_sync
	port map (
		clk                 => tx_mac_aclk_int,
		enable              => '1',
		reset_in            => tx_reset_int,
		reset_out           => tx_mac_reset
	);

	fifo_interface : mac_fifo_interface
    generic map(
        GMII_DATA_WIDTH       	=> GMII_DATA_WIDTH,
        RECEIVER_DATA_WIDTH   	=> RECEIVER_DATA_WIDTH,
        TRANSMITTER_DATA_WIDTH 	=> TRANSMITTER_DATA_WIDTH,
        FULL_DUPLEX_ONLY      	=> true
    )
    port map(
        -- txpath interface
        tx_fifo_in_clk        	=> mac_in_clock,
        tx_fifo_in_reset      	=> mac_in_reset,
        tx_fifo_in_data       	=> mac_in_data,
        tx_fifo_in_valid      	=> mac_in_valid,
        tx_fifo_in_last       	=> mac_in_last,
        tx_fifo_in_ready      	=> mac_in_ready,
        -- support block interface
        tx_fifo_out_clk       	=> tx_mac_aclk_int,
        tx_fifo_out_reset     	=> tx_mac_reset,
        tx_fifo_out_data      	=> txfifo2sup_data,
        tx_fifo_out_valid     	=> txfifo2sup_valid,
        tx_fifo_out_last      	=> txfifo2sup_last,
        tx_fifo_out_ready     	=> txfifo2sup_ready,
        tx_fifo_out_error      	=> txfifo2sup_error(0),
        -- rxpath interface
        rx_fifo_out_clk       	=> mac_out_clock,
        rx_fifo_out_reset     	=> mac_out_reset,
        rx_fifo_out_data      	=> mac_out_data,
        rx_fifo_out_valid     	=> mac_out_valid,
        rx_fifo_out_last      	=> mac_out_last,
        rx_fifo_out_error      	=> mac_out_error,
        -- support block interface
        rx_fifo_in_clk        	=> rx_mac_aclk_int,
        rx_fifo_in_reset      	=> rx_mac_reset,
        rx_fifo_in_data       	=> sup2rxfifo_data,
        rx_fifo_in_valid      	=> sup2rxfifo_valid,
        rx_fifo_in_last       	=> sup2rxfifo_last,
        rx_fifo_in_error       	=> sup2rxfifo_error
    );

end wrapper;
