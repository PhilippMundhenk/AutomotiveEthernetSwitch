----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 20.12.2013 16:58:39
-- Design Name: 
-- Module Name: arbitration_round_robin - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq7000
-- Tool Versions: vivado 2013.3
-- 
-- Description:
-- This logic path implementation of a round robin algorithm determines which of
--   the input ports is allowed to send the to the output port.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity arbitration_module is
    generic(
        NR_PORTS                : integer;
        LD_NR_PORTS             : integer
    );
    port(
        in_req_ports            : in std_logic_vector(NR_PORTS-1 downto 0);
        in_prev_winner          : in std_logic_vector(LD_NR_PORTS-1 downto 0);
        out_winner_port         : out std_logic_vector(LD_NR_PORTS-1 downto 0)
    );
end arbitration_module;

architecture rtl of arbitration_module is

begin

    round_robin_p : process(in_req_ports, in_prev_winner)
        variable arb_port   : integer := 0;
    begin
        out_winner_port <= in_prev_winner;
        for i in 1 to NR_PORTS-1 loop
            arb_port := (to_integer(unsigned(in_prev_winner))+i) mod NR_PORTS;
            if in_req_ports(arb_port) = '1' then
                out_winner_port <= std_logic_vector(to_unsigned(arb_port,LD_NR_PORTS));
            end if;
            exit when in_req_ports(arb_port) = '1';
        end loop;
    end process;

end rtl;
