----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 10.01.2014 17:49:53
-- Design Name: 
-- Module Name: config_init - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.4
-- 
-- Description: This module initialises the TEMAC IP core using configuration vectors
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity config_init is
    Generic (
        NR_PORTS                    : integer;
        CONFIG_VECTOR_WIDTH         : integer
    );
    Port ( 
        port12_speed                : in std_logic;
        port34_speed                : in std_logic;
        rx_configuration_vector     : out std_logic_vector(NR_PORTS*CONFIG_VECTOR_WIDTH-1 downto 0);
        tx_configuration_vector     : out std_logic_vector(NR_PORTS*CONFIG_VECTOR_WIDTH-1 downto 0)
    );
end config_init;

architecture rtl of config_init is

begin
    init : process(port12_speed, port34_speed)
        variable rx_configuration_vector0 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable rx_configuration_vector1 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable rx_configuration_vector2 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable rx_configuration_vector3 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable tx_configuration_vector0 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable tx_configuration_vector1 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable tx_configuration_vector2 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
        variable tx_configuration_vector3 : std_logic_vector(CONFIG_VECTOR_WIDTH-1 downto 0);
    begin
        if NR_PORTS >= 1 then
            rx_configuration_vector0(79 downto 32) := (others => '0'); -- pause frame source address
            rx_configuration_vector0(31 downto 16) := x"05EE"; -- max frame size
            rx_configuration_vector0(15) := '0'; -- reserved
            rx_configuration_vector0(14) := '0'; -- max frame enable
            rx_configuration_vector0(13) := port12_speed; -- speed configuration
            rx_configuration_vector0(12) := not port12_speed; -- speed configuration
            rx_configuration_vector0(11) := '1'; -- promiscuous mode
            rx_configuration_vector0(10) := '0'; -- reserved
            rx_configuration_vector0(9) := '0'; -- control frame length check disable
            rx_configuration_vector0(8) := '0'; -- receiver length/type error check disable
            rx_configuration_vector0(7) := '0'; -- reserved
            rx_configuration_vector0(6) := '0'; -- half-duplex
            rx_configuration_vector0(5) := '1'; -- flow control enable
            rx_configuration_vector0(4) := '0'; -- jumbo frame enable
            rx_configuration_vector0(3) := '0'; -- in-band fcs enable
            rx_configuration_vector0(2) := '0'; -- vlan enable
            rx_configuration_vector0(1) := '1'; -- receiver enable
            rx_configuration_vector0(0) := '0'; -- receiver reset
            tx_configuration_vector0(79 downto 32) := (others => '0'); -- pause frame source address
            tx_configuration_vector0(31 downto 16) := x"05EE"; -- max frame size
            tx_configuration_vector0(15) := '0'; -- reserved
            tx_configuration_vector0(14) := '0'; -- max frame enable
            tx_configuration_vector0(13) := port12_speed; -- speed configuration
            tx_configuration_vector0(12) := not port12_speed; -- speed configuration
            tx_configuration_vector0(11 downto 9) := "000"; -- reserved
            tx_configuration_vector0(8) := '0'; -- interframe gap adjust enable
            tx_configuration_vector0(7) := '0'; -- reserved
            tx_configuration_vector0(6) := '0'; -- half-duplex
            tx_configuration_vector0(5) := '1'; -- flow control enable
            tx_configuration_vector0(4) := '0'; -- jumbo frame enable
            tx_configuration_vector0(3) := '0'; -- in-band fcs enable
            tx_configuration_vector0(2) := '0'; -- vlan enable
            tx_configuration_vector0(1) := '1'; -- transmitter enable
            tx_configuration_vector0(0) := '0'; -- transmitter reset
            rx_configuration_vector(79 downto 0) <= rx_configuration_vector0;
            tx_configuration_vector(79 downto 0) <= tx_configuration_vector0;
        end if;
        if NR_PORTS >= 2 then
            rx_configuration_vector1(79 downto 32) := (others => '0'); -- pause frame source address
            rx_configuration_vector1(31 downto 16) := x"05EE"; -- max frame size
            rx_configuration_vector1(15) := '0'; -- reserved
            rx_configuration_vector1(14) := '0'; -- max frame enable
            rx_configuration_vector1(13) := port12_speed; -- speed configuration
            rx_configuration_vector1(12) := not port12_speed; -- speed configuration
            rx_configuration_vector1(11) := '1'; -- promiscuous mode
            rx_configuration_vector1(10) := '0'; -- reserved
            rx_configuration_vector1(9) := '0'; -- control frame length check disable
            rx_configuration_vector1(8) := '0'; -- receiver length/type error check disable
            rx_configuration_vector1(7) := '0'; -- reserved
            rx_configuration_vector1(6) := '0'; -- half-duplex
            rx_configuration_vector1(5) := '1'; -- flow control enable
            rx_configuration_vector1(4) := '0'; -- jumbo frame enable
            rx_configuration_vector1(3) := '0'; -- in-band fcs enable
            rx_configuration_vector1(2) := '0'; -- vlan enable
            rx_configuration_vector1(1) := '1'; -- receiver enable
            rx_configuration_vector1(0) := '0'; -- receiver reset
            tx_configuration_vector1(79 downto 32) := (others => '0'); -- pause frame source address
            tx_configuration_vector1(31 downto 16) := x"05EE"; -- max frame size
            tx_configuration_vector1(15) := '0'; -- reserved
            tx_configuration_vector1(14) := '0'; -- max frame enable
            tx_configuration_vector1(13) := port12_speed; -- speed configuration
            tx_configuration_vector1(12) := not port12_speed; -- speed configuration
            tx_configuration_vector1(11 downto 9) := "000"; -- reserved
            tx_configuration_vector1(8) := '0'; -- interframe gap adjust enable
            tx_configuration_vector1(7) := '0'; -- reserved
            tx_configuration_vector1(6) := '0'; -- half-duplex
            tx_configuration_vector1(5) := '1'; -- flow control enable
            tx_configuration_vector1(4) := '0'; -- jumbo frame enable
            tx_configuration_vector1(3) := '0'; -- in-band fcs enable
            tx_configuration_vector1(2) := '0'; -- vlan enable
            tx_configuration_vector1(1) := '1'; -- transmitter enable
            tx_configuration_vector1(0) := '0'; -- transmitter reset
            rx_configuration_vector(159 downto 80) <= rx_configuration_vector1;
            tx_configuration_vector(159 downto 80) <= tx_configuration_vector1;
        end if;
        if NR_PORTS >= 3 then
            rx_configuration_vector2(79 downto 32) := (others => '0'); -- pause frame source address
            rx_configuration_vector2(31 downto 16) := x"05EE"; -- max frame size
            rx_configuration_vector2(15) := '0'; -- reserved
            rx_configuration_vector2(14) := '0'; -- max frame enable
            rx_configuration_vector2(13) := port34_speed; -- speed configuration
            rx_configuration_vector2(12) := not port34_speed; -- speed configuration
            rx_configuration_vector2(11) := '1'; -- promiscuous mode
            rx_configuration_vector2(10) := '0'; -- reserved
            rx_configuration_vector2(9) := '0'; -- control frame length check disable
            rx_configuration_vector2(8) := '0'; -- receiver length/type error check disable
            rx_configuration_vector2(7) := '0'; -- reserved
            rx_configuration_vector2(6) := '0'; -- half-duplex
            rx_configuration_vector2(5) := '1'; -- flow control enable
            rx_configuration_vector2(4) := '0'; -- jumbo frame enable
            rx_configuration_vector2(3) := '0'; -- in-band fcs enable
            rx_configuration_vector2(2) := '0'; -- vlan enable
            rx_configuration_vector2(1) := '1'; -- receiver enable
            rx_configuration_vector2(0) := '0'; -- receiver reset
            tx_configuration_vector2(79 downto 32) := (others => '0'); -- pause frame source address
            tx_configuration_vector2(31 downto 16) := x"05EE"; -- max frame size
            tx_configuration_vector2(15) := '0'; -- reserved
            tx_configuration_vector2(14) := '0'; -- max frame enable
            tx_configuration_vector2(13) := port34_speed; -- speed configuration
            tx_configuration_vector2(12) := not port34_speed; -- speed configuration
            tx_configuration_vector2(11 downto 9) := "000"; -- reserved
            tx_configuration_vector2(8) := '0'; -- interframe gap adjust enable
            tx_configuration_vector2(7) := '0'; -- reserved
            tx_configuration_vector2(6) := '0'; -- half-duplex
            tx_configuration_vector2(5) := '1'; -- flow control enable
            tx_configuration_vector2(4) := '0'; -- jumbo frame enable
            tx_configuration_vector2(3) := '0'; -- in-band fcs enable
            tx_configuration_vector2(2) := '0'; -- vlan enable
            tx_configuration_vector2(1) := '1'; -- transmitter enable
            tx_configuration_vector2(0) := '0'; -- transmitter reset
            rx_configuration_vector(239 downto 160) <= rx_configuration_vector2;
            tx_configuration_vector(239 downto 160) <= tx_configuration_vector2;
        end if;
        if NR_PORTS >= 4 then
            rx_configuration_vector3(79 downto 32) := (others => '0'); -- pause frame source address
            rx_configuration_vector3(31 downto 16) := x"05EE"; -- max frame size
            rx_configuration_vector3(15) := '0'; -- reserved
            rx_configuration_vector3(14) := '0'; -- max frame enable
            rx_configuration_vector3(13) := '1'; -- speed configuration
            rx_configuration_vector3(12) := '0'; -- speed configuration
            rx_configuration_vector3(11) := '1'; -- promiscuous mode
            rx_configuration_vector3(10) := '0'; -- reserved
            rx_configuration_vector3(9) := '0'; -- control frame length check disable
            rx_configuration_vector3(8) := '0'; -- receiver length/type error check disable
            rx_configuration_vector3(7) := '0'; -- reserved
            rx_configuration_vector3(6) := '0'; -- half-duplex
            rx_configuration_vector3(5) := '1'; -- flow control enable
            rx_configuration_vector3(4) := '0'; -- jumbo frame enable
            rx_configuration_vector3(3) := '0'; -- in-band fcs enable
            rx_configuration_vector3(2) := '0'; -- vlan enable
            rx_configuration_vector3(1) := '1'; -- receiver enable
            rx_configuration_vector3(0) := '0'; -- receiver reset
            tx_configuration_vector3(79 downto 32) := (others => '0'); -- pause frame source address
            tx_configuration_vector3(31 downto 16) := x"05EE"; -- max frame size
            tx_configuration_vector3(15) := '0'; -- reserved
            tx_configuration_vector3(14) := '0'; -- max frame enable
            tx_configuration_vector3(13) := port34_speed; -- speed configuration
            tx_configuration_vector3(12) := not port34_speed; -- speed configuration
            tx_configuration_vector3(11 downto 9) := "000"; -- reserved
            tx_configuration_vector3(8) := '0'; -- interframe gap adjust enable
            tx_configuration_vector3(7) := '0'; -- reserved
            tx_configuration_vector3(6) := '0'; -- half-duplex
            tx_configuration_vector3(5) := '1'; -- flow control enable
            tx_configuration_vector3(4) := '0'; -- jumbo frame enable
            tx_configuration_vector3(3) := '0'; -- in-band fcs enable
            tx_configuration_vector3(2) := '0'; -- vlan enable
            tx_configuration_vector3(1) := '1'; -- transmitter enable
            tx_configuration_vector3(0) := '0'; -- transmitter reset
            rx_configuration_vector(319 downto 240) <= rx_configuration_vector3;
            tx_configuration_vector(319 downto 240) <= tx_configuration_vector3;
        end if;
    end process;
end rtl;
