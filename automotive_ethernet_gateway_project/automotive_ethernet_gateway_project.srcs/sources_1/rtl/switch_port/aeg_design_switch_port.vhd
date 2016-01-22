----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 11.11.2013 13:56:52
-- Design Name: 
-- Module Name: aeg_design_0_switch_port

-- Description: This module describes one port for the Ethernet switch
--              It consists of:
--              - The rx_path: the logic processing the received data before
--                sending to the fabric
--              - The tx_path: the logic receiving data from the fabric and 
--                handling the transmission of frames
--              - The TEMAC receives/sends frames
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aeg_design_0_switch_port is
    Generic (
        RECEIVER_DATA_WIDTH     : integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        FABRIC_DATA_WIDTH       : integer;
        NR_PORTS                : integer;
        FRAME_LENGTH_WIDTH      : integer;
        NR_IQ_FIFOS             : integer;
        NR_OQ_FIFOS             : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer;
        GMII_DATA_WIDTH         : integer;
        TX_IFG_DELAY_WIDTH      : integer;
        PAUSE_VAL_WIDTH         : integer;
        PORT_ID                 : integer
    );
    Port (
        gtx_clk                 : in  std_logic;
        -- asynchronous reset
        glbl_rstn               : in  std_logic;
        rx_axi_rstn             : in  std_logic;
        tx_axi_rstn             : in  std_logic;
		-- Reference clock for IDELAYCTRL's
        refclk                  : in  std_logic;
        timestamp_cnt           : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        latency                 : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        debug0_sig              : out std_logic;
        debug1_sig              : out std_logic;
        debug2_sig              : out std_logic;
        debug3_sig              : out std_logic;
        -- Receiver Interface
        -----------------------------------------
        rx_mac_aclk             : out std_logic;
        rx_reset                : out std_logic;
        -- RX Switch Fabric Intrface
        ------------------------------------------
        rx_path_clock           : in  std_logic;
        rx_path_resetn          : in  std_logic;
        rx_out_data             : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        rx_out_valid            : out std_logic;
        rx_out_last             : out std_logic;
        rx_out_ports_req        : out std_logic_vector(NR_PORTS-1 downto 0);
        rx_out_prio             : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        rx_out_timestamp        : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        rx_out_length           : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0); 
        rx_out_ports_gnt        : in std_logic_vector(NR_PORTS-1 downto 0);
        -- Transmitter Interface
        --------------------------------------------
        tx_mac_aclk             : out std_logic;
        tx_reset                : out std_logic;
        tx_ifg_delay            : in  std_logic_vector(TX_IFG_DELAY_WIDTH-1 downto 0);
        -- TX Switch Fabric Intrface
        ---------------------------------------------
        tx_path_clock           : in  std_logic;
        tx_path_resetn          : in  std_logic;
        tx_in_data              : in  std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        tx_in_valid             : in  std_logic;
        tx_in_length            : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        tx_in_prio              : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        tx_in_timestamp         : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        tx_in_req               : in  std_logic;
        tx_in_accept_frame      : out std_logic;
        -- MAC Control Interface
        --------------------------
        pause_req               : in  std_logic;
        pause_val               : in  std_logic_vector(PAUSE_VAL_WIDTH-1 downto 0);
        -- GMII Interface
        -------------------
        gmii_txd                : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        gmii_tx_en              : out std_logic;
        gmii_tx_er              : out std_logic;
        gmii_tx_clk             : out std_logic;
        gmii_rxd                : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        gmii_rx_dv              : in  std_logic;
        gmii_rx_er              : in  std_logic;
        gmii_rx_clk             : in  std_logic;
        mii_tx_clk              : in  std_logic;
        phy_interrupt_n         : in std_logic;
        -- MDIO Interface
        -------------------
        mdio                    : inout std_logic;
        mdc                     : out std_logic;
        -- AXI-Lite Interface
        -----------------
        s_axi_aclk              : in  std_logic;
        s_axi_resetn            : in  std_logic
    );
end aeg_design_0_switch_port;

architecture rtl of aeg_design_0_switch_port is

	component tri_mode_ethernet_mac_block
    Generic (
        RECEIVER_DATA_WIDTH     : integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        GMII_DATA_WIDTH         : integer;
        TX_IFG_DELAY_WIDTH      : integer;
        PAUSE_VAL_WIDTH         : integer
    );
    port(
        gtx_clk                 : in  std_logic;
        -- asynchronous reset
        glbl_rstn               : in  std_logic;
        rx_axi_rstn             : in  std_logic;
        tx_axi_rstn             : in  std_logic;
        -- Reference clock for IDELAYCTRL's
        refclk                  : in  std_logic;
        -- Receiver Statistics Interface
        -----------------------------------------
        rx_mac_aclk             : out std_logic;
        rx_reset                : out std_logic;
        -- mac to rxpath interface
        ------------------------------------------
        mac_out_clock           : in  std_logic;
        mac_out_resetn          : in  std_logic;
        mac_out_data            : out std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        mac_out_valid           : out std_logic;
        mac_out_last            : out std_logic;
        mac_out_error           : out std_logic;
        -- Transmitter Statistics Interface
        --------------------------------------------
        tx_mac_aclk             : out std_logic;
        tx_reset                : out std_logic;
        tx_ifg_delay            : in  std_logic_vector(TX_IFG_DELAY_WIDTH-1 downto 0);
        -- txpath to mac interface
        ---------------------------------------------
        mac_in_clock            : in  std_logic;
        mac_in_resetn           : in  std_logic;
        mac_in_data             : in  std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        mac_in_valid            : in  std_logic;
        mac_in_ready            : out std_logic;
        mac_in_last             : in  std_logic;
        -- MAC Control Interface
        --------------------------
        pause_req               : in  std_logic;
        pause_val               : in  std_logic_vector(PAUSE_VAL_WIDTH-1 downto 0);
        -- GMII Interface
        -------------------
        gmii_txd                : out std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        gmii_tx_en              : out std_logic;
        gmii_tx_er              : out std_logic;
        gmii_tx_clk             : out std_logic;
        gmii_rxd                : in  std_logic_vector(GMII_DATA_WIDTH-1 downto 0);
        gmii_rx_dv              : in  std_logic;
        gmii_rx_er              : in  std_logic;
        gmii_rx_clk             : in  std_logic;
        mii_tx_clk              : in  std_logic;
        -- MDIO Interface
        -------------------
        mdio                    : inout std_logic;
        mdc                     : out std_logic;
        -- AXI-Lite Interface
        -----------------
        s_axi_aclk              : in  std_logic;
        s_axi_resetn            : in  std_logic;
        s_axi_awaddr            : in  std_logic_vector(11 downto 0);
        s_axi_awvalid           : in  std_logic;
        s_axi_awready           : out std_logic;
        s_axi_wdata             : in  std_logic_vector(31 downto 0);
        s_axi_wvalid            : in  std_logic;
        s_axi_wready            : out std_logic;
        s_axi_bresp             : out std_logic_vector(1 downto 0);
        s_axi_bvalid            : out std_logic;
        s_axi_bready            : in  std_logic;
        s_axi_araddr            : in  std_logic_vector(11 downto 0);
        s_axi_arvalid           : in  std_logic;
        s_axi_arready           : out std_logic;
        s_axi_rdata             : out std_logic_vector(31 downto 0);
        s_axi_rresp             : out std_logic_vector(1 downto 0);
        s_axi_rvalid            : out std_logic;
        s_axi_rready            : in  std_logic;
        mac_interrupt           : out std_logic
    );
	end component;

    component config_mac_phy_sm
    port (
        s_axi_aclk              : in  std_logic;
        s_axi_resetn            : in  std_logic;
        phy_interrupt_n         : in std_logic;
        mac_interrupt           : in std_logic;
        mac_speed               : in  std_logic_vector(1 downto 0);
        update_speed            : in  std_logic;
        serial_command          : in  std_logic;
        serial_response         : out std_logic;
        debug0_sig              : out std_logic;
        debug1_sig              : out std_logic;
        debug2_sig              : out std_logic;
        debug3_sig              : out std_logic;
        s_axi_awaddr            : out std_logic_vector(11 downto 0) := (others => '0');
        s_axi_awvalid           : out std_logic := '0';
        s_axi_awready           : in  std_logic;
        s_axi_wdata             : out std_logic_vector(31 downto 0) := (others => '0');
        s_axi_wvalid            : out std_logic := '0';
        s_axi_wready            : in  std_logic;
        s_axi_bresp             : in  std_logic_vector(1 downto 0);
        s_axi_bvalid            : in  std_logic;
        s_axi_bready            : out std_logic;
        s_axi_araddr            : out std_logic_vector(11 downto 0) := (others => '0');
        s_axi_arvalid           : out std_logic := '0';
        s_axi_arready           : in  std_logic;
        s_axi_rdata             : in  std_logic_vector(31 downto 0);
        s_axi_rresp             : in  std_logic_vector(1 downto 0);
        s_axi_rvalid            : in  std_logic;
        s_axi_rready            : out std_logic := '0'
    );
    end component;

	component switch_port_rx_path is
    Generic (
		RECEIVER_DATA_WIDTH   	: integer;
		FABRIC_DATA_WIDTH     	: integer;
		NR_PORTS              	: integer;
		FRAME_LENGTH_WIDTH    	: integer;
		NR_IQ_FIFOS             : integer;
		VLAN_PRIO_WIDTH         : integer;
		TIMESTAMP_WIDTH         : integer;
        PORT_ID                 : integer
    );
    Port (
		rx_path_clock         	: in  std_logic;
		rx_path_resetn        	: in  std_logic;
		-- mac to rx_path interface
		rx_in_data            	: in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
		rx_in_valid           	: in std_logic;
		rx_in_last            	: in std_logic; 
		rx_in_error           	: in std_logic;
        rx_in_timestamp_cnt     : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
		-- rx_path interface to fabric
		rx_out_data           	: out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
		rx_out_valid          	: out std_logic;
		rx_out_last           	: out std_logic;
		rx_out_ports_req      	: out std_logic_vector(NR_PORTS-1 downto 0);
		rx_out_prio             : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        rx_out_timestamp        : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
		rx_out_length         	: out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0); 
		rx_out_ports_gnt      	: in std_logic_vector(NR_PORTS-1 downto 0)
	);
	end component;

	component switch_port_tx_path is
    Generic (
        FABRIC_DATA_WIDTH       : integer;
        TRANSMITTER_DATA_WIDTH  : integer;
        FRAME_LENGTH_WIDTH      : integer;
        NR_OQ_FIFOS             : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port ( 
        tx_path_clock           : in  std_logic;
        tx_path_resetn          : in  std_logic;
        -- tx_path interface to fabric
        tx_in_data              : in  std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        tx_in_valid             : in  std_logic;
        tx_in_length            : in  std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        tx_in_prio              : in std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        tx_in_timestamp         : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        tx_in_req               : in  std_logic;
        tx_in_accept_frame      : out std_logic;
        -- timestamp
        tx_in_timestamp_cnt     : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        tx_out_latency          : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- tx_path interface to mac
        tx_out_data             : out std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        tx_out_valid            : out std_logic;
        tx_out_ready            : in  std_logic;
        tx_out_last             : out std_logic     
    );
	end component;

	signal mac2rx_data_sig      : std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
	signal mac2rx_valid_sig     : std_logic;
	signal mac2rx_last_sig      : std_logic;
	signal mac2rx_error_sig     : std_logic;
   
	signal tx2mac_data_sig      : std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
	signal tx2mac_valid_sig     : std_logic;
	signal tx2mac_ready_sig     : std_logic;
	signal tx2mac_last_sig      : std_logic; 
    
    signal s_axi_awaddr         : std_logic_vector(11 downto 0) := (others => '0');
    signal s_axi_awvalid        : std_logic := '0';
    signal s_axi_awready        : std_logic := '0';
    signal s_axi_wdata          : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_wvalid         : std_logic := '0';
    signal s_axi_wready         : std_logic := '0';
    signal s_axi_bresp          : std_logic_vector(1 downto 0) := (others => '0');
    signal s_axi_bvalid         : std_logic := '0';
    signal s_axi_bready         : std_logic := '0';
    signal s_axi_araddr         : std_logic_vector(11 downto 0) := (others => '0');
    signal s_axi_arvalid        : std_logic := '0';
    signal s_axi_arready        : std_logic := '0';
    signal s_axi_rdata          : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_rresp          : std_logic_vector(1 downto 0) := (others => '0');
    signal s_axi_rvalid         : std_logic := '0';
    signal s_axi_rready         : std_logic := '0';
    signal mac_interrupt        : std_logic := '0';
    
--	attribute mark_debug : string;
--	attribute mark_debug of mac2rx_data_sig		: signal is "true";
--	attribute mark_debug of mac2rx_valid_sig	: signal is "true";
--	attribute mark_debug of mac2rx_last_sig		: signal is "true";
--	attribute mark_debug of mac2rx_error_sig		: signal is "true";
    
begin

	------------------------------------------------------------------------------
	-- Instantiate the TRIMAC core FIFO Block wrapper
	------------------------------------------------------------------------------
	trimac_block : tri_mode_ethernet_mac_block
    Generic map (
		RECEIVER_DATA_WIDTH      	=> RECEIVER_DATA_WIDTH,
		TRANSMITTER_DATA_WIDTH      => TRANSMITTER_DATA_WIDTH,
		GMII_DATA_WIDTH             => GMII_DATA_WIDTH,
		TX_IFG_DELAY_WIDTH          => TX_IFG_DELAY_WIDTH,
		PAUSE_VAL_WIDTH             => PAUSE_VAL_WIDTH
    )
    port map (
		gtx_clk                     => gtx_clk,
		-- asynchronous reset
		glbl_rstn                   => glbl_rstn,
		rx_axi_rstn                 => rx_axi_rstn,
		tx_axi_rstn                 => tx_axi_rstn,
		-- Reference clock for IDELAYCTRL's
		refclk                      => refclk,
		-- Receiver Statistics Interface
		-----------------------------------------
		rx_mac_aclk                 => rx_mac_aclk,
		rx_reset                    => rx_reset,
		-- Receiver => AXI-S Interface
		------------------------------------------
		mac_out_clock               => rx_path_clock,
		mac_out_resetn              => rx_path_resetn,
		mac_out_data                => mac2rx_data_sig,
		mac_out_valid               => mac2rx_valid_sig,
		mac_out_last                => mac2rx_last_sig,
		mac_out_error               => mac2rx_error_sig,
		-- Transmitter Statistics Interface
		--------------------------------------------
		tx_mac_aclk                 => tx_mac_aclk,
		tx_reset                    => tx_reset,
		tx_ifg_delay                => tx_ifg_delay,
		-- Transmitter => AXI-S Interface
		---------------------------------------------
		mac_in_clock                => tx_path_clock,
		mac_in_resetn               => tx_path_resetn,
		mac_in_data                 => tx2mac_data_sig,
		mac_in_valid                => tx2mac_valid_sig,
		mac_in_ready                => tx2mac_ready_sig,
		mac_in_last                 => tx2mac_last_sig,
		-- MAC Control Interface
		--------------------------
		pause_req                   => pause_req,
		pause_val                   => pause_val,
		-- GMII Interface
		-------------------
		gmii_txd                    => gmii_txd,
		gmii_tx_en                  => gmii_tx_en,
		gmii_tx_er                  => gmii_tx_er,
		gmii_tx_clk                 => gmii_tx_clk,
		gmii_rxd                    => gmii_rxd,
		gmii_rx_dv                  => gmii_rx_dv,
		gmii_rx_er                  => gmii_rx_er,
		gmii_rx_clk                 => gmii_rx_clk,
		mii_tx_clk                  => mii_tx_clk,
		-- MDIO Interface
		-------------------
		mdio                        => mdio,
		mdc                         => mdc,
		-- AXI-Lite Interface
		-----------------
		s_axi_aclk                  => s_axi_aclk,
		s_axi_resetn                => s_axi_resetn,
		s_axi_awaddr                => s_axi_awaddr,
		s_axi_awvalid               => s_axi_awvalid,
		s_axi_awready               => s_axi_awready,
		s_axi_wdata                 => s_axi_wdata,
		s_axi_wvalid                => s_axi_wvalid,
		s_axi_wready                => s_axi_wready,
		s_axi_bresp                 => s_axi_bresp,
		s_axi_bvalid                => s_axi_bvalid,
		s_axi_bready                => s_axi_bready,
		s_axi_araddr                => s_axi_araddr,
		s_axi_arvalid               => s_axi_arvalid,
		s_axi_arready               => s_axi_arready,
		s_axi_rdata                 => s_axi_rdata,
		s_axi_rresp                 => s_axi_rresp,
		s_axi_rvalid                => s_axi_rvalid,
		s_axi_rready                => s_axi_rready,
		mac_interrupt               => mac_interrupt
	);

    config_mac_phy : config_mac_phy_sm
    port map(
        s_axi_aclk                  => s_axi_aclk,
        s_axi_resetn                => s_axi_resetn,
        phy_interrupt_n             => phy_interrupt_n,
        mac_interrupt               => mac_interrupt,
        mac_speed                   => "01",
        update_speed                => '0',
        serial_command              => '0',
        serial_response             => open,
        debug0_sig                  => debug0_sig,
        debug1_sig                  => debug1_sig,
        debug2_sig                  => debug2_sig,
        debug3_sig                  => debug3_sig,
        -- AXI-Lite Interface
        -----------
        s_axi_awaddr                => s_axi_awaddr,
        s_axi_awvalid               => s_axi_awvalid,
        s_axi_awready               => s_axi_awready,
        s_axi_wdata                 => s_axi_wdata,
        s_axi_wvalid                => s_axi_wvalid,
        s_axi_wready                => s_axi_wready,
        s_axi_bresp                 => s_axi_bresp,
        s_axi_bvalid                => s_axi_bvalid,
        s_axi_bready                => s_axi_bready,
        s_axi_araddr                => s_axi_araddr,
        s_axi_arvalid               => s_axi_arvalid,
        s_axi_arready               => s_axi_arready,
        s_axi_rdata                 => s_axi_rdata,
        s_axi_rresp                 => s_axi_rresp,
        s_axi_rvalid                => s_axi_rvalid,
        s_axi_rready                => s_axi_rready
    );

	rx_path : switch_port_rx_path
    Generic map(
		RECEIVER_DATA_WIDTH         => RECEIVER_DATA_WIDTH,
		FABRIC_DATA_WIDTH           => FABRIC_DATA_WIDTH,
		NR_PORTS                    => NR_PORTS,
		FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
		NR_IQ_FIFOS                 => NR_IQ_FIFOS,
		VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
		TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH,
		PORT_ID                     => PORT_ID
    )
    Port map(
		rx_path_clock               => rx_path_clock,
		rx_path_resetn              => rx_path_resetn,
		-- mac to rx_path interface
		rx_in_data                  => mac2rx_data_sig,
		rx_in_valid                 => mac2rx_valid_sig,
		rx_in_last                  => mac2rx_last_sig,
		rx_in_error                 => mac2rx_error_sig,
		rx_in_timestamp_cnt         => timestamp_cnt,
		-- rx_path interface to fabric
		rx_out_data                 => rx_out_data,
		rx_out_valid                => rx_out_valid,
		rx_out_last                 => rx_out_last,
		rx_out_ports_req            => rx_out_ports_req,
		rx_out_prio                 => rx_out_prio,
        rx_out_timestamp            => rx_out_timestamp,
		rx_out_length               => rx_out_length,
		rx_out_ports_gnt            => rx_out_ports_gnt
    );

	tx_path : switch_port_tx_path
    Generic map(
        FABRIC_DATA_WIDTH           => FABRIC_DATA_WIDTH,
        TRANSMITTER_DATA_WIDTH      => TRANSMITTER_DATA_WIDTH,
        FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
        NR_OQ_FIFOS                 => NR_OQ_FIFOS,
        VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH
    )
    Port map( 
       tx_path_clock                => tx_path_clock,
       tx_path_resetn               => tx_path_resetn,
       -- tx_path interface to fabric
       tx_in_data                   => tx_in_data,
       tx_in_valid                  => tx_in_valid,
       tx_in_length                 => tx_in_length,
       tx_in_prio                   => tx_in_prio,
       tx_in_timestamp              => tx_in_timestamp,
       tx_in_req                    => tx_in_req,
       tx_in_accept_frame           => tx_in_accept_frame,
       -- timestamp
       tx_in_timestamp_cnt          => timestamp_cnt,
       tx_out_latency               => latency,
       -- tx_path interface to mac
       tx_out_data                  => tx2mac_data_sig,
       tx_out_valid                 => tx2mac_valid_sig,
       tx_out_ready                 => tx2mac_ready_sig,
       tx_out_last                  => tx2mac_last_sig  
    );
    
end rtl;
