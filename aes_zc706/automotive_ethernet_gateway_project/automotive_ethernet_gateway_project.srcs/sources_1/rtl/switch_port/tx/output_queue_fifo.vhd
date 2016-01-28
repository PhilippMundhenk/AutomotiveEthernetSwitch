----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 10.12.2013 15:14:45
-- Design Name: 
-- Module Name: output_queue_fifo - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013
--
-- Description: wrapper for the output queue fifo
-- the output queue fifo stores the length and output queue memory address of frames received 
-- from the switching fabric temporarily until they can be tranismitted via the mac
-- 
-- further information can be found in switch_port_txpath_output_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity output_queue_fifo is
    Generic (
        OQ_FIFO_DATA_WIDTH         	: integer;
        NR_OQ_FIFOS                 : integer;
        VLAN_PRIO_WIDTH             : integer
    );
    Port ( 
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        oqfifo_in_enable 		    : in  std_logic;
        oqfifo_in_data              : in  std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0);
        oqfifo_in_wr_prio           : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oqfifo_out_enable           : in  std_logic;
        oqfifo_out_data             : out std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
        oqfifo_out_rd_prio          : in std_logic;
        oqfifo_out_full             : out std_logic_vector(NR_OQ_FIFOS-1 downto 0);
        oqfifo_out_empty            : out std_logic_vector(NR_OQ_FIFOS-1 downto 0)
    );
end output_queue_fifo;

architecture rtl of output_queue_fifo is

    component fifo_generator_2 is
        port (
            clk            	: in  std_logic;
            rst             : in  std_logic;
            wr_en 		    : in  std_logic;
            rd_en           : in  std_logic;
            din             : in  std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0);
            dout            : out std_logic_vector(OQ_FIFO_DATA_WIDTH-1 downto 0);
            full            : out std_logic;
            empty           : out std_logic
        );
    end component;
    
    signal rd_en_sig        : std_logic_vector(NR_OQ_FIFOS-1 downto 0) := (others => '0');
    signal wr_en_sig        : std_logic_vector(NR_OQ_FIFOS-1 downto 0) := (others => '0');
    
    signal high_priority_border_value_reg   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := "001";

begin

    init_p : process(oqfifo_out_enable, oqfifo_in_wr_prio, oqfifo_in_enable, oqfifo_out_rd_prio, high_priority_border_value_reg)
        variable wr_temp      : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := (others => '0');
        variable rd_temp      : std_logic_vector(0 downto 0) := (others => '0');
    begin
        rd_temp(0) := oqfifo_out_rd_prio;
        wr_temp := oqfifo_in_wr_prio;
        for i in 0 to NR_OQ_FIFOS-1 loop
            -- read access
            if (oqfifo_out_enable = '1' and to_integer(unsigned(rd_temp)) = i) then
                rd_en_sig(i) <= '1';
            else
                rd_en_sig(i) <= '0';
            end if;
            -- write access
            if NR_OQ_FIFOS = 1 then
                wr_en_sig(0) <= oqfifo_in_enable;
            else
                if i = 0 then
                    if wr_temp >= high_priority_border_value_reg then
                        wr_en_sig(i) <= '0';
                    else
                        wr_en_sig(i) <= oqfifo_in_enable;
                    end if;
                else
                    if wr_temp >= high_priority_border_value_reg then
                        wr_en_sig(i) <= oqfifo_in_enable;
                    else
                        wr_en_sig(i) <= '0';
                    end if;
                end if;
            end if;
        end loop;
    end process;

    Xfifo : for i in 0 to NR_OQ_FIFOS-1 generate
    output_queue_fifo_ip : fifo_generator_2 
        PORT MAP (
            clk         => clk,
            rst         => reset,
            wr_en 		=> wr_en_sig(i),
            rd_en       => rd_en_sig(i),
            din         => oqfifo_in_data,
            dout        => oqfifo_out_data((i+1)*OQ_FIFO_DATA_WIDTH-1 downto i*OQ_FIFO_DATA_WIDTH),
            full        => oqfifo_out_full(i),
            empty       => oqfifo_out_empty(i)
        );
    end generate Xfifo;

end rtl;
