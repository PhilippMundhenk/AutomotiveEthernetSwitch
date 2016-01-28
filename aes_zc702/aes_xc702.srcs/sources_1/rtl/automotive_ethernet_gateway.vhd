--------------------------------------------------------------------------------
-- File       : automotive_ethernet_gateway.vhd
-- Author     : Andreas Ettner
-- -----------------------------------------------------------------------------
-- Description:  This module is the top level layer of the automotive ethernet
--                 gateway switch. It contains following modules:
--
--               This level:
--
--               * Instantiates the switch_ports and switch_fabric
--
--               * Instantiates the clocking circuitry and resets
--
--               * Instantiates a state machine which drives the AXI Lite
--                 interface to bring the TEMACs up in the correct state
--
--               * Instantiates a global counter to measure the latency of messages through the switch
--               // IMPORTANT: comment the latency port for hardware implementations
--                             decomment the latency port for simulations
--                    remove the latency port as soon as vivado supports vhdl2008 which allows
--                    signal addressing of submodules in test benches
--
-- Constant generic values are defined in this module for global values (switch width, number of ports, MAC values)
-- More values are defined in the corresponding submodules
--
-- Debugging with Integrated Logic Analyser (ILA) might cause an error because of a path name larger than 260 bytes
-- Solution: Create a virtual drive with the .xpr in its root (use the subst command in the cmd console)
--              run implementation on the virtual drive
--           To avoid an waveform error when debugging, restart vivado after implementation on the original drive
--------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity automotive_ethernet_gateway is
    Generic (
		RECEIVER_DATA_WIDTH       	: integer := 8;
		TRANSMITTER_DATA_WIDTH      : integer := 8;
		FABRIC_DATA_WIDTH           : integer := 32;
		NR_PORTS                    : integer := 4;
		ARBITRATION                 : integer := 2; -- 1: Round Robin, 2: Priority based, 3: Latency based, 
                                                                    -- 4: Weighted prio/latency based, 5: to do: Fair Queuing
		FRAME_LENGTH_WIDTH          : integer := 11;
		NR_IQ_FIFOS                 : integer := 1;
		NR_OQ_FIFOS                 : integer := 1;
		VLAN_PRIO_WIDTH             : integer := 3;
		TIMESTAMP_WIDTH             : integer := 64;
		GMII_DATA_WIDTH             : integer := 8;
		TX_IFG_DELAY_WIDTH          : integer := 8;
		PAUSE_VAL_WIDTH             : integer := 16;
		CONFIG_VECTOR_WIDTH         : integer := 80
	);
    port (
		-- asynchronous reset
		glbl_rst                    : in  std_logic;
		-- 200MHz clock input from board
		clk_in_p                    : in  std_logic;
		clk_in_n                    : in  std_logic;
		phy_resetn                  : out std_logic_vector(NR_PORTS-1 downto 0);
		intn                        : in std_logic_vector(NR_PORTS-1 downto 0);
		debug0                      : out std_logic;
		debug1                      : out std_logic;
		debug2                      : out std_logic;
		debug3                      : out std_logic;
		--latency                     : out std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0); -- COMMENT THIS LINE for hardware implementation
		-- GMII Interface
		-----------------
		gmii_txd                    : out std_logic_vector(NR_PORTS*GMII_DATA_WIDTH-1 downto 0);
		gmii_tx_en                  : out std_logic_vector(NR_PORTS-1 downto 0);
		gmii_tx_er                  : out std_logic_vector(NR_PORTS-1 downto 0);
		gmii_tx_clk                 : out std_logic_vector(NR_PORTS-1 downto 0);
		gmii_rxd                    : in  std_logic_vector(NR_PORTS*GMII_DATA_WIDTH-1 downto 0);
		gmii_rx_dv                  : in  std_logic_vector(NR_PORTS-1 downto 0);
		gmii_rx_er                  : in  std_logic_vector(NR_PORTS-1 downto 0);
		gmii_rx_clk                 : in  std_logic_vector(NR_PORTS-1 downto 0);
		mii_tx_clk                  : in  std_logic_vector(NR_PORTS-1 downto 0);
		-- MDIO Interface
		-----------------
		mdio                        : inout std_logic_vector(NR_PORTS-1 downto 0);
		mdc                         : out std_logic_vector(NR_PORTS-1 downto 0)
    );
end automotive_ethernet_gateway;

architecture wrapper of automotive_ethernet_gateway is

	attribute DowngradeIPIdentifiedWarnings: string;
	attribute DowngradeIPIdentifiedWarnings of wrapper : architecture is "yes";

    component timer
    Generic (
        TIMESTAMP_WIDTH             : integer
    );
    Port (
        refclk                      : in std_logic;
        resetn                      : in std_logic;
        clk_cycle_cnt               : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0)
    );
    end component;

	------------------------------------------------------------------------------
	-- Component Declaration for a switch port
	------------------------------------------------------------------------------
	component aeg_design_0_switch_port
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
	end component;

	------------------------------------------------------------------------------
	-- Component Declaration for the switch fabric
	------------------------------------------------------------------------------
	component aeg_design_0_switch_fabric
	generic (
		FABRIC_DATA_WIDTH      	: integer;
		NR_PORTS                : integer;
		ARBITRATION             : integer;
		FRAME_LENGTH_WIDTH      : integer;
		VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
	);
	port (
		fabric_clk              : in  std_logic;
		fabric_resetn           : in  std_logic;
		timestamp_cnt           : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
		-- data from the RX data path
		fabric_in_data          : in  std_logic_vector(NR_PORTS*FABRIC_DATA_WIDTH-1 downto 0);
		fabric_in_valid         : in  std_logic_vector(NR_PORTS-1 downto 0);
		fabric_in_last          : in  std_logic_vector(NR_PORTS-1 downto 0);
		fabric_in_ports_req     : in std_logic_vector(NR_PORTS*NR_PORTS-1 downto 0);
		fabric_in_prio          : in std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
        fabric_in_timestamp     : in std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
		fabric_in_length        : in std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
		fabric_in_ports_gnt     : out std_logic_vector(NR_PORTS*NR_PORTS-1 downto 0);
		-- data TO the TX data path
		fabric_out_prio         : out std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
        fabric_out_timestamp    : out std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
		fabric_out_data         : out std_logic_vector(NR_PORTS*FABRIC_DATA_WIDTH-1 downto 0);
		fabric_out_valid        : out std_logic_vector(NR_PORTS-1 downto 0);
		fabric_out_length       : out std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
		fabric_out_req          : out std_logic_vector(NR_PORTS-1 downto 0);
		fabric_out_accept_frame : in  std_logic_vector(NR_PORTS-1 downto 0)
	);
	end component;

	------------------------------------------------------------------------------
	-- Component declaration for the synchroniser
	------------------------------------------------------------------------------
	component aeg_design_0_sync_block
	port (
		clk                     : in  std_logic;
		data_in                 : in  std_logic;
		data_out                : out std_logic
	);
	end component;

	------------------------------------------------------------------------------
	-- Component declaration for the clocking logic
	------------------------------------------------------------------------------
	component aeg_design_0_clocks is
	port (
		-- clocks
		clk_in_p                : in std_logic;
		clk_in_n                : in std_logic;
		-- asynchronous resets
		glbl_rst                : in std_logic;
		dcm_locked              : out std_logic;
		-- clock outputs
		gtx_clk_bufg            : out std_logic;
		refclk_bufg             : out std_logic;
		s_axi_aclk              : out std_logic
	);
	end component;

	------------------------------------------------------------------------------
	-- Component declaration for the reset logic
	------------------------------------------------------------------------------
	component aeg_design_0_resets is
	port (
		-- clocks
		s_axi_aclk              : in std_logic;
		gtx_clk                 : in std_logic;
		-- asynchronous resets
		glbl_rst                : in std_logic;
		rx_reset                : in std_logic;
		tx_reset                : in std_logic;
		dcm_locked              : in std_logic;
		-- synchronous reset outputs
		glbl_rst_intn           : out std_logic;
		gtx_resetn              : out std_logic := '0';
		s_axi_resetn            : out std_logic := '0';
		phy_resetn              : out std_logic
	);
	end component;

    ------------------------------------------------------------------------------
    -- Shareable logic component declarations
    ------------------------------------------------------------------------------
    component tri_mode_ethernet_mac_0_support_resets
    port (
        glbl_rstn               : in     std_logic;
        refclk                  : in     std_logic;
        idelayctrl_ready        : in     std_logic;
        idelayctrl_reset_out    : out    std_logic    
    );
    end component;

    -- Internal signals
    signal idelayctrl_reset      : std_logic;
    signal idelayctrl_ready      : std_logic;

	------------------------------------------------------------------------------
	-- internal signals used in this top level wrapper.
	------------------------------------------------------------------------------

	-- example design clocks
	signal gtx_clk_bufg        				: std_logic;
	signal refclk_bufg                      : std_logic;
	signal s_axi_aclk                       : std_logic;
	signal rx_mac_aclk                      : std_logic;
	signal tx_mac_aclk                      : std_logic;
	signal phy_resetn_sig                   : std_logic;
	-- resets (and reset generation)
	signal s_axi_resetn                     : std_logic;
	signal gtx_resetn                       : std_logic;
	signal rx_reset                         : std_logic := '0';
	signal tx_reset                         : std_logic := '0';
	signal dcm_locked                       : std_logic;
	signal glbl_rst_intn                    : std_logic;
	-- USER side RX AXI-S interface
	signal rx2fabric_data                   : std_logic_vector(NR_PORTS*FABRIC_DATA_WIDTH-1 downto 0);
	signal rx2fabric_valid                  : std_logic_vector(NR_PORTS-1 downto 0);
	signal rx2fabric_last                   : std_logic_vector(NR_PORTS-1 downto 0);
	signal rx2fabric_ports_req              : std_logic_vector(NR_PORTS*NR_PORTS-1 downto 0);
	signal rx2fabric_prio                   : std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
    signal rx2fabric_timestamp              : std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
	signal rx2fabric_length                 : std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
	signal rx2fabric_ports_gnt              : std_logic_vector(NR_PORTS*NR_PORTS-1 downto 0);
	-- USER side TX AXI-S interface
	signal fabric2tx_prio                   : std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
    signal fabric2tx_timestamp              : std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
	signal fabric2tx_data                   : std_logic_vector(NR_PORTS*FABRIC_DATA_WIDTH-1 downto 0);
	signal fabric2tx_valid                  : std_logic_vector(NR_PORTS-1 downto 0);
	signal fabric2tx_length                 : std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
	signal fabric2tx_req                    : std_logic_vector(NR_PORTS-1 downto 0);
	signal fabric2tx_accept_frame           : std_logic_vector(NR_PORTS-1 downto 0);
	-- ifg_delay
	signal tx_ifg_delay                     : std_logic_vector(7 downto 0) := (others => '0'); -- not used in this example
	signal rx_configuration_vector          : std_logic_vector(CONFIG_VECTOR_WIDTH*NR_PORTS-1 downto 0);
	signal tx_configuration_vector          : std_logic_vector(CONFIG_VECTOR_WIDTH*NR_PORTS-1 downto 0);
	-- evaluation signals
	signal timestamp_cnt                    : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
	signal latency                          : std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0); -- COMMENT THIS LINE for simulation

    signal debug0_sig : std_logic_vector(NR_PORTS-1 downto 0);
    signal debug1_sig : std_logic_vector(NR_PORTS-1 downto 0);
    signal debug2_sig : std_logic_vector(NR_PORTS-1 downto 0);
    signal debug3_sig : std_logic_vector(NR_PORTS-1 downto 0);
    
begin


    -- Instantiate the sharable reset logic
    tri_mode_ethernet_mac_support_resets_i : tri_mode_ethernet_mac_0_support_resets
    port map(
        glbl_rstn               => glbl_rst_intn,
        refclk                  => refclk_bufg,
        idelayctrl_ready        => idelayctrl_ready,
        idelayctrl_reset_out    => idelayctrl_reset   
    );

    -- An IDELAYCTRL primitive needs to be instantiated for the Fixed Tap Delay
    -- mode of the IDELAY.
    tri_mode_ethernet_mac_idelayctrl_common_i : IDELAYCTRL
    port map (
        RDY                     => idelayctrl_ready,
        REFCLK                  => refclk_bufg,
        RST                     => idelayctrl_reset
    );

	----------------------------------------------------------------------------
	-- Clock logic to generate required clocks from the 200MHz on board
	-- if 125MHz is available directly this can be removed
	----------------------------------------------------------------------------
	aeg_clocks : aeg_design_0_clocks
	port map (
		-- differential clock inputs
		clk_in_p       	=> clk_in_p,
		clk_in_n        => clk_in_n,
		-- asynchronous control/resets
		glbl_rst        => glbl_rst,
		dcm_locked      => dcm_locked,
		-- clock outputs
		gtx_clk_bufg    => gtx_clk_bufg,
		refclk_bufg     => refclk_bufg,
		s_axi_aclk      => s_axi_aclk
	);

	------------------------------------------------------------------------------
	-- Generate resets
	------------------------------------------------------------------------------
	aeg_resets : aeg_design_0_resets
	port map (
		-- clocks
		s_axi_aclk       => s_axi_aclk,
		gtx_clk          => gtx_clk_bufg,
		-- asynchronous resets
		glbl_rst         => glbl_rst,
		rx_reset         => rx_reset,
		tx_reset         => tx_reset,
		dcm_locked       => dcm_locked,
		-- synchronous reset outputs
		glbl_rst_intn    => glbl_rst_intn,
		gtx_resetn       => gtx_resetn,
		s_axi_resetn     => s_axi_resetn,
		phy_resetn       => phy_resetn_sig
	);
	-- generate the user side resets
	phy_resetn <= (others => phy_resetn_sig);

    timer_i : timer
    Generic map(
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH
    )
    Port map(
        refclk                      => gtx_clk_bufg,
        resetn                      => glbl_rst_intn,
        clk_cycle_cnt               => timestamp_cnt
    );

    Xports : for PORT_ID in 0 to NR_PORTS-1 generate
        switch_port : aeg_design_0_switch_port
        Generic map (
            RECEIVER_DATA_WIDTH         => RECEIVER_DATA_WIDTH,
            TRANSMITTER_DATA_WIDTH      => TRANSMITTER_DATA_WIDTH,
            FABRIC_DATA_WIDTH           => FABRIC_DATA_WIDTH,
            NR_PORTS                    => NR_PORTS,
            FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
            NR_IQ_FIFOS                 => NR_IQ_FIFOS,
            NR_OQ_FIFOS                 => NR_OQ_FIFOS,
            VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
            TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH,
            GMII_DATA_WIDTH             => GMII_DATA_WIDTH,
            TX_IFG_DELAY_WIDTH          => TX_IFG_DELAY_WIDTH,
            PAUSE_VAL_WIDTH             => PAUSE_VAL_WIDTH,
            PORT_ID                     => PORT_ID
        )
        port map (
            gtx_clk                     => gtx_clk_bufg,
            -- asynchronous reset
            glbl_rstn                   => glbl_rst_intn,
            rx_axi_rstn                 => '1',
            tx_axi_rstn                 => '1',
            -- Reference clock for IDELAYCTRL's
            refclk                      => refclk_bufg,
            timestamp_cnt               => timestamp_cnt,
            latency                     => latency((PORT_ID+1)*TIMESTAMP_WIDTH-1 downto PORT_ID*TIMESTAMP_WIDTH),
            debug0_sig                  => debug0_sig(PORT_ID),
            debug1_sig                  => debug1_sig(PORT_ID),
            debug2_sig                  => debug2_sig(PORT_ID),
            debug3_sig                  => debug3_sig(PORT_ID),
            -- Receiver Statistics Interface
            -----------------------------------------
            rx_mac_aclk                 => rx_mac_aclk,
            rx_reset                    => open,
            -- Receiver
            ------------------------------------------
            rx_path_clock               => gtx_clk_bufg,
            rx_path_resetn              => gtx_resetn,
            rx_out_data                 => rx2fabric_data((PORT_ID+1)*FABRIC_DATA_WIDTH-1 downto PORT_ID*FABRIC_DATA_WIDTH),
            rx_out_valid                => rx2fabric_valid(PORT_ID),
            rx_out_last                 => rx2fabric_last(PORT_ID),
            rx_out_ports_req            => rx2fabric_ports_req((PORT_ID+1)*NR_PORTS-1 downto PORT_ID*NR_PORTS),
            rx_out_prio                 => rx2fabric_prio((PORT_ID+1)*VLAN_PRIO_WIDTH-1 downto PORT_ID*VLAN_PRIO_WIDTH),
            rx_out_timestamp            => rx2fabric_timestamp((PORT_ID+1)*TIMESTAMP_WIDTH-1 downto PORT_ID*TIMESTAMP_WIDTH),
            rx_out_length               => rx2fabric_length((PORT_ID+1)*FRAME_LENGTH_WIDTH-1 downto PORT_ID*FRAME_LENGTH_WIDTH),
            rx_out_ports_gnt            => rx2fabric_ports_gnt((PORT_ID+1)*NR_PORTS-1 downto PORT_ID*NR_PORTS),
            -- Transmitter Statistics Interface
            --------------------------------------------
            tx_mac_aclk                 => tx_mac_aclk,
            tx_reset                    => open,
            tx_ifg_delay                => tx_ifg_delay,
            -- Transmitter
            ---------------------------------------------
            tx_path_clock               => gtx_clk_bufg,
            tx_path_resetn              => gtx_resetn,
            tx_in_data                  => fabric2tx_data((PORT_ID+1)*FABRIC_DATA_WIDTH-1 downto PORT_ID*FABRIC_DATA_WIDTH),
            tx_in_valid                 => fabric2tx_valid(PORT_ID),
            tx_in_length                => fabric2tx_length((PORT_ID+1)*FRAME_LENGTH_WIDTH-1 downto PORT_ID*FRAME_LENGTH_WIDTH),
            tx_in_prio                  => fabric2tx_prio((PORT_ID+1)*VLAN_PRIO_WIDTH-1 downto PORT_ID*VLAN_PRIO_WIDTH),
            tx_in_timestamp             => fabric2tx_timestamp((PORT_ID+1)*TIMESTAMP_WIDTH-1 downto PORT_ID*TIMESTAMP_WIDTH),
            tx_in_req                   => fabric2tx_req(PORT_ID),
            tx_in_accept_frame          => fabric2tx_accept_frame(PORT_ID),
            -- MAC Control Interface
            --------------------------
            pause_req                   => '0',
            pause_val                   => (others => '0'),
            -- GMII Interface
            -------------------
            gmii_txd                    => gmii_txd((PORT_ID+1)*GMII_DATA_WIDTH-1 downto PORT_ID*GMII_DATA_WIDTH),
            gmii_tx_en                  => gmii_tx_en(PORT_ID),
            gmii_tx_er                  => gmii_tx_er(PORT_ID),
            gmii_tx_clk                 => gmii_tx_clk(PORT_ID),
            gmii_rxd                    => gmii_rxd((PORT_ID+1)*GMII_DATA_WIDTH-1 downto PORT_ID*GMII_DATA_WIDTH),
            gmii_rx_dv                  => gmii_rx_dv(PORT_ID),
            gmii_rx_er                  => gmii_rx_er(PORT_ID),
            gmii_rx_clk                 => gmii_rx_clk(PORT_ID),
            mii_tx_clk                  => mii_tx_clk(PORT_ID),
            phy_interrupt_n             => intn(PORT_ID),
            -- MDIO Interface
            -------------------
            mdio                        => mdio(PORT_ID),
            mdc                         => mdc(PORT_ID),
            -- AXI-Lite Interface
            -----------------
            s_axi_aclk                  => s_axi_aclk,
            s_axi_resetn                => s_axi_resetn
        );
    end generate Xports;

	------------------------------------------------------------------------------
	--  Instantiate the switching fabric
	------------------------------------------------------------------------------
	switch_fabric : aeg_design_0_switch_fabric
	generic map (
		FABRIC_DATA_WIDTH          	=> FABRIC_DATA_WIDTH,
		NR_PORTS                    => NR_PORTS,
		ARBITRATION                 => ARBITRATION,
		FRAME_LENGTH_WIDTH          => FRAME_LENGTH_WIDTH,
		VLAN_PRIO_WIDTH             => VLAN_PRIO_WIDTH,
        TIMESTAMP_WIDTH             => TIMESTAMP_WIDTH
	)
	port map (
		fabric_clk                  => gtx_clk_bufg,
		fabric_resetn               => gtx_resetn,
		timestamp_cnt               => timestamp_cnt,
		-- rxpath interface
		fabric_in_data              => rx2fabric_data,
		fabric_in_valid             => rx2fabric_valid,
		fabric_in_last              => rx2fabric_last,
		fabric_in_ports_req         => rx2fabric_ports_req,
		fabric_in_prio              => rx2fabric_prio,
        fabric_in_timestamp         => rx2fabric_timestamp,
		fabric_in_length            => rx2fabric_length,
		fabric_in_ports_gnt         => rx2fabric_ports_gnt,
		-- txpath interface
		fabric_out_prio             => fabric2tx_prio,
        fabric_out_timestamp        => fabric2tx_timestamp,
		fabric_out_data             => fabric2tx_data,
		fabric_out_valid            => fabric2tx_valid,
		fabric_out_length           => fabric2tx_length,
		fabric_out_req              => fabric2tx_req,
		fabric_out_accept_frame     => fabric2tx_accept_frame
	);

    debug0 <= intn(0);
--    debug1 <= intn(1);
--    debug2 <= intn(2);
--    debug3 <= intn(3);
--debug0 <= debug0_sig(0);
debug1 <= debug1_sig(0);
debug2 <= debug2_sig(0);
debug3 <= debug3_sig(0);
    
end wrapper;
