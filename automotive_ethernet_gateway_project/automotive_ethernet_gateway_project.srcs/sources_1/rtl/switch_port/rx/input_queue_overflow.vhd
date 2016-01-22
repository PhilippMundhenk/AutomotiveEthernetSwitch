----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 02.01.2014 13:22:29
-- Design Name: 
-- Module Name: input_queue_overflow - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.4
--
-- Description: 
-- combinatioral path to check for overflow of the iq_memory and iq_fifos
-- 
-- more detailed information can found in file switch_port_rxpath_input_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity input_queue_overflow is
    Generic(
        IQ_FIFO_DATA_WIDTH          : integer;
        IQ_MEM_ADDR_WIDTH           : integer;
        IQ_FIFO_MEM_PTR_START       : integer;
        NR_IQ_FIFOS                 : integer
    );
    Port ( 
        fifo_full                   : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        fifo_empty                  : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        mem_wr_addr                 : in std_logic_vector(IQ_MEM_ADDR_WIDTH-1 downto 0);
        mem_rd_addr                 : in std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0);
        overflow                    : out std_logic_vector(NR_IQ_FIFOS-1 downto 0)
    );
end input_queue_overflow;

architecture rtl of input_queue_overflow is

begin

    -- overflow if the memory currently written to is one address below current fifo word
    -- or if fifo is full
    overflow_detection_p : process(mem_rd_addr, mem_wr_addr, fifo_empty, fifo_full)
    begin
        for i in 0 to NR_IQ_FIFOS-1 loop
            if fifo_empty(i) = '0' and mem_rd_addr(i*IQ_FIFO_DATA_WIDTH+IQ_FIFO_MEM_PTR_START+IQ_MEM_ADDR_WIDTH-1 
                                            downto i*IQ_FIFO_DATA_WIDTH+IQ_FIFO_MEM_PTR_START) - mem_wr_addr = 1 then
                overflow(i) <= '1';
            elsif fifo_full(i) = '1' then
                overflow(i) <= '1';
            else
                overflow(i) <= '0';
            end if;
        end loop;
    end process;

end rtl;
