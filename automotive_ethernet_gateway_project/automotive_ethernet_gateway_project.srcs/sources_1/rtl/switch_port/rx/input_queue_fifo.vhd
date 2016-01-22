----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 26.11.2013 17:14:16
-- Design Name: 
-- Module Name: input_queue_fifo - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: 
-- NR_IQ_FIFOS are instantiated, they contain frames of one priority each
-- Input Control FIFO is a first-word-fall-through fifo, input data is immediately on output
-- Input Control FIFO stores output ports, length and memory start address of corresponding frame
-- switch to next word either if succesfully sent in input config arbitration module,
--          memory overflow or fifo overflow (see iq_overflow module)
-- 
-- more detailed information can found in file switch_port_rxpath_input_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_1164.ALL;


entity input_queue_fifo is
    Generic (
        IQ_FIFO_DATA_WIDTH         	: integer;
        NR_IQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer
    );
    Port ( 
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        wr_en 		                : in  std_logic;
        din                         : in  std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0);
        wr_priority                 : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        rd_en                       : in  std_logic;
        overflow                    : in  std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        dout                        : out std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0);
        rd_priority                 : in std_logic;
        full                        : out std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        empty                       : out std_logic_vector(NR_IQ_FIFOS-1 downto 0)
    );
end input_queue_fifo;

architecture rtl of input_queue_fifo is

    component fifo_generator_1 is
        port (
            clk            	: in  std_logic;
            rst             : in  std_logic;
            wr_en 		    : in  std_logic;
            rd_en           : in  std_logic;
            din             : in  std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0);
            dout            : out std_logic_vector(IQ_FIFO_DATA_WIDTH-1 downto 0);
            full            : out std_logic;
            empty           : out std_logic
        );
    end component;

    signal rd_en_sig        : std_logic_vector(NR_IQ_FIFOS-1 downto 0) := (others => '0');
    signal wr_en_sig        : std_logic_vector(NR_IQ_FIFOS-1 downto 0) := (others => '0');
    -- internal register, to be connected to a processor for more flexibility
    signal high_priority_border_value_reg   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := "001";
begin

    init_p : process(rd_en, wr_priority, overflow, wr_en, rd_priority, high_priority_border_value_reg)
        variable wr_temp      : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := (others => '0');
        variable rd_temp      : std_logic_vector(0 downto 0) := (others => '0');
    begin
        rd_temp(0) := rd_priority;
        wr_temp := wr_priority;
        for i in 0 to NR_IQ_FIFOS-1 loop
            -- read access
            if (rd_en = '1' and to_integer(unsigned(rd_temp)) = i) or (overflow(i) = '1') then
                rd_en_sig(i) <= '1';
            else
                rd_en_sig(i) <= '0';
            end if;
            -- write access
            if NR_IQ_FIFOS = 1 then
                wr_en_sig(0) <= wr_en;
            else
                if i = 0 then
                    if wr_temp >= high_priority_border_value_reg then
                        wr_en_sig(i) <= '0';
                    else
                        wr_en_sig(i) <= wr_en;
                    end if;
                else
                    if wr_temp >= high_priority_border_value_reg then
                        wr_en_sig(i) <= wr_en;
                    else
                        wr_en_sig(i) <= '0';
                    end if;
                end if;
            end if;
        end loop;
    end process;

    Xfifo : for i in 0 to NR_IQ_FIFOS-1 generate
    input_queue_fifo_ip : fifo_generator_1 
        PORT MAP (
            clk        	=> clk,
            rst         => reset,
            wr_en 		=> wr_en_sig(i),
            rd_en       => rd_en_sig(i),
            din         => din,
            dout        => dout((i+1)*IQ_FIFO_DATA_WIDTH-1 downto i*IQ_FIFO_DATA_WIDTH),
            full        => full(i),
            empty       => empty(i)
        );
    end generate Xfifo;

end rtl;
