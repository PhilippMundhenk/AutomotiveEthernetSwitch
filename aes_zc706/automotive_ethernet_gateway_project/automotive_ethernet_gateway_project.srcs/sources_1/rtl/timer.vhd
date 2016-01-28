----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 16.01.2014 10:36:58
-- Design Name: 
-- Module Name: timer - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.4
--
-- Description: This module provides a global timer to take timestamp and calculate latencies
--              the counter increments every clock cycle (125 MHz -> 8 ns)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity timer is
    Generic (
        TIMESTAMP_WIDTH             : integer
    );
    Port (
        refclk                      : in std_logic;
        resetn                      : in std_logic;
        clk_cycle_cnt               : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0)
    );
end timer;

architecture rtl of timer is

    signal cnt_reg      : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);

    begin

    -- timestamp counter
    cnt_p : process (refclk)
    begin
        if refclk'event and refclk = '1' then
            if resetn = '0' then
                cnt_reg <= (others => '0');
            else
                cnt_reg <= cnt_reg + 1;
            end if;
        end if;
    end process;

    clk_cycle_cnt <= cnt_reg;

end rtl;
