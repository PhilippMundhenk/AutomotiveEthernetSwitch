--------------------------------------------------------------------------------
-- File       : aeg_design_switch_fabric.vhd
-- Author     : Andreas Ettner
-- -----------------------------------------------------------------------------
-- Description:
-- the switching fabric consists of one fabric_arbitration module for each output port
-- the arbitration module decides which input port is allowed to transmit data to
-- its output port
-- the switching module instantiates the fabric_arbitration modules and handles the
-- wiring between the input ports and the arbitration modules
--
-- further information can be found in file switch_fabric.svg
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity aeg_design_0_switch_fabric is
    generic (
        FABRIC_DATA_WIDTH              	: integer;
        NR_PORTS                        : integer;
        ARBITRATION                     : integer;
        FRAME_LENGTH_WIDTH              : integer;
        VLAN_PRIO_WIDTH                 : integer;
        TIMESTAMP_WIDTH                 : integer
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
end aeg_design_0_switch_fabric;

architecture structural of aeg_design_0_switch_fabric is

    component switch_fabric_arbitration is
    generic (
        FABRIC_DATA_WIDTH       : integer;
        NR_PORTS                : integer;
        ARBITRATION             : integer;
        FRAME_LENGTH_WIDTH      : integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;
        timestamp_cnt           : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- data from the RX data path
        farb_in_data            : in  std_logic_vector(NR_PORTS*FABRIC_DATA_WIDTH-1 downto 0);
        farb_in_valid           : in  std_logic_vector(NR_PORTS-1 downto 0);
        farb_in_last            : in  std_logic_vector(NR_PORTS-1 downto 0);
        farb_in_ports_req       : in std_logic_vector(NR_PORTS-1 downto 0);
        farb_in_prio            : in std_logic_vector(NR_PORTS*VLAN_PRIO_WIDTH-1 downto 0);
        farb_in_timestamp       : in std_logic_vector(NR_PORTS*TIMESTAMP_WIDTH-1 downto 0);
        farb_in_length          : in std_logic_vector(NR_PORTS*FRAME_LENGTH_WIDTH-1 downto 0);
        farb_in_ports_gnt       : out std_logic_vector(NR_PORTS-1 downto 0);
        -- data TO the TX data path
        farb_out_prio           : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        farb_out_timestamp      : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        farb_out_data           : out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        farb_out_valid          : out std_logic;
        farb_out_length         : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        farb_out_req            : out std_logic;
        farb_out_accept_frame   : in  std_logic
    );
    end component;
    
    signal reset                : std_logic;
    signal ports_req_sig        : std_logic_vector(NR_PORTS*NR_PORTS-1 downto 0);
    signal ports_gnt_sig        : std_logic_vector(NR_PORTS*NR_PORTS-1 downto 0);
    
begin
    
    reset <= not fabric_resetn;
    
    -- reorder req and grant symbols
    -- as one req/gnt signal of each input port should be connected to one arbitration module
    assign_p : process(ports_gnt_sig, fabric_in_ports_req)
    begin
        for i in 0 to NR_PORTS-1 loop
            for o in 0 to NR_PORTS-1 loop
                ports_req_sig(i*NR_PORTS+o) <= fabric_in_ports_req(o*NR_PORTS+i);
                fabric_in_ports_gnt(i*NR_PORTS+o) <= ports_gnt_sig(o*NR_PORTS+i);
            end loop;
        end loop;
    end process;

    -- connect the signals from the input port to the arbitration modules
    Xarb : for INST in 0 to NR_PORTS-1 generate
        fabric_arbitration : switch_fabric_arbitration
        generic map(
            FABRIC_DATA_WIDTH       => FABRIC_DATA_WIDTH,
            NR_PORTS                => NR_PORTS,
            ARBITRATION             => ARBITRATION,
            FRAME_LENGTH_WIDTH      => FRAME_LENGTH_WIDTH,
            VLAN_PRIO_WIDTH         => VLAN_PRIO_WIDTH,
            TIMESTAMP_WIDTH         => TIMESTAMP_WIDTH
        )
        port map(
            clk                     => fabric_clk,
            reset                   => reset,
            timestamp_cnt           => timestamp_cnt,
            -- data from the input ports
            farb_in_data            => fabric_in_data,
            farb_in_valid           => fabric_in_valid,
            farb_in_last            => fabric_in_last,
            farb_in_ports_req       => ports_req_sig((INST+1)*NR_PORTS-1 downto INST*NR_PORTS),
            farb_in_prio            => fabric_in_prio,
            farb_in_timestamp       => fabric_in_timestamp,
            farb_in_length          => fabric_in_length,
            farb_in_ports_gnt       => ports_gnt_sig((INST+1)*NR_PORTS-1 downto INST*NR_PORTS),
            -- data to the output port
            farb_out_prio           => fabric_out_prio((INST+1)*VLAN_PRIO_WIDTH-1 downto INST*VLAN_PRIO_WIDTH),
            farb_out_timestamp      => fabric_out_timestamp((INST+1)*TIMESTAMP_WIDTH-1 downto INST*TIMESTAMP_WIDTH),
            farb_out_data           => fabric_out_data((INST+1)*FABRIC_DATA_WIDTH-1 downto INST*FABRIC_DATA_WIDTH),
            farb_out_valid          => fabric_out_valid(INST),
            farb_out_length         => fabric_out_length((INST+1)*FRAME_LENGTH_WIDTH-1 downto INST*FRAME_LENGTH_WIDTH),
            farb_out_req            => fabric_out_req(INST),
            farb_out_accept_frame   => fabric_out_accept_frame(INST)
        );
    end generate Xarb;
    
end structural;
